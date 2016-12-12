// ===================================================================
// TODO
// ===================================================================
/*
- tester dongle NFC
- tester bouton reset softAP
- bugfix: save AP into eeprom
- optimiser la redirection pour recevoir de gros flux de data sans planter :p
- dans le popup de config de la borne, virer les boutons inutiles
- configurer l'URL du HOST (serveur BDD distant) par WebSocket
- cacher le SSID de la softAP ?
- exposer l'url du websoket d'une façon ou d'une autre :p [DONE] c'est routeur, IP facile à récupérer
*/
#include <ESP8266WiFi.h>
#include <WiFiClient.h> 
#include <ESP8266WebServer.h>
#include <WiFiManager.h>
#include <SPI.h>
#include "MFRC522.h"
#include <WebSocketsServer.h>
#include "maxoucard_config.h"
#include "wsock_commands.h"
 
// ===================================================================
// Configuration
// ===================================================================
// #define SOFTAP_NAME               "Borne1"
// #define SOFTAP_PASS               "12345678"
#define SOFTAP_CHANNEL            11
#define SOFTAP_HIDE               1
#define AUTOCONNECT_NAME          SOFTAP_NAME "-Config"

#define HTTP_SERVER_PORT          80
#define SOCKET_SERVER_PORT        81

#define PIN_AUTOCONNECT_RESET     14 // marked 'GPIO14' on ESP-12 module
#define PIN_LED                   2
/* wiring the MFRC522 to ESP8266 (ESP-12)
RST     = GPIO5
SDA(SS) = GPIO4 
MOSI    = GPIO13
MISO    = GPIO12
SCK     = GPIO14
GND     = GND
3.3V    = 3.3V
*/
#define RST_PIN  5  // RST-PIN für RC522 - RFID - SPI - Modul GPIO5 
#define SS_PIN  4  // SDA-PIN für RC522 - RFID - SPI - Modul GPIO4 


// ===================================================================
// Debug stuff
// ===================================================================
#  define dprint_init(x)  Serial.begin(x); delay(100); Serial.println("Startup.")
#  define dprint(x)       Serial.print(x)
#  define dprintln(x)     Serial.println(x)


// ===================================================================
// Globals
// ===================================================================
WiFiClient          gWiFiClient;                                            // client WiFi qui devra se connecter au routeur internet
char                gBuffer[256] = {0};
MFRC522             gRC522(SS_PIN, RST_PIN);                                // Create MFRC522 instance
WebSocketsServer    gSocketServer = WebSocketsServer(SOCKET_SERVER_PORT);   // creation d'un serveur WebSocket
ESP8266WebServer    gHttpServer(HTTP_SERVER_PORT);                          // creation d'un serveur HTTP

// TODO: recuperer depuis serveur websock ou auto-configurateur Wifi
char *              gRemoteHostURL = "jsonplaceholder.typicode.com";
int                 gRemoteHostPort = 80;


// ===================================================================
// HTTP Server Routines
// ===================================================================
bool waitResponseUntilTimeout(int aTimeoutMS) {
    int timeout = millis() + aTimeoutMS;
    while (gWiFiClient.available() == 0) {
        if (timeout - millis() < 0) {
          dprintln(F("HTTP_SERVER: Timeout while reaching remote host."));
          gWiFiClient.stop();
          return true;
        }
    }
    return false;
}


void HTTP_HandleRoot() {
    gHttpServer.send(200, "text/html", "<h1>Hello World, " SOFTAP_NAME " !</h1>");
}


void HTTP_HandleNotFound() {
    dprint(F("HTTP_SERVER: Proxy request to "));
    dprint(gRemoteHostURL);
    dprint(F(":"));
    dprintln(gRemoteHostPort);

    // try to connect to remote host
    while (!gWiFiClient.connect(gRemoteHostURL, gRemoteHostPort)) {
        Serial.println("HTTP_SERVER: Connection failed, retrying...");
        delay(500);
    }
    dprint("HTTP_SERVER: Requesting uri: ");
    String requestUri = gHttpServer.uri();

    // TODO: an easier way to get the request url?
    if (gHttpServer.args() > 0) {
         requestUri += "?";
        for (int i = 0; i < gHttpServer.args(); i++) {
            requestUri += gHttpServer.argName(i);
            requestUri += "=";
            requestUri += gHttpServer.arg(i);
            if (i + 1 < gHttpServer.args()) {
                requestUri += "&";
            }
        }
    }
    dprintln(requestUri);

    // send request to remote
    gWiFiClient.print(String("GET ") + requestUri);
    gWiFiClient.print(String(" HTTP/1.1\r\n") +
                      "Host: " + gRemoteHostURL + "\r\n" + 
                      "Connection: close\r\n\r\n");

    // protect against timeout
    if(waitResponseUntilTimeout(5000)) {
        dprintln(">>> Client Timeout !");
        gWiFiClient.stop();
    }
    else {
        // TODO: use library ?
        // Read all the lines of the reply from server and print them to Serial
        String response = "";
        while(gWiFiClient.available()) {
            String line = gWiFiClient.readStringUntil('\r');
            response += line;
        }

        Serial.println(response);

        String body = response.substring(response.indexOf("\n\n"));
        Serial.println("====== BODY ==========");
        Serial.println(body);
        gHttpServer.send(200, "application/json; charset=utf-8", body);

        gWiFiClient.stop();
  }
}


// ===================================================================
// Automatic WiFi configuration
// ===================================================================
bool AC_UserReset() {
    pinMode(PIN_AUTOCONNECT_RESET, INPUT_PULLUP);
    pinMode(PIN_LED, OUTPUT);
    delay(2000);
    
    // blink LED to tell you can press reset autoconf button
    bool on = true;
    for(int i = 0; i < 50; i++) {
        digitalWrite(PIN_LED, on ? HIGH : LOW);
        on = !on;
        delay(200);
        if(digitalRead(PIN_AUTOCONNECT_RESET) == HIGH) {
            dprintln("AUTOCONNECT: User reset");
            digitalWrite(PIN_LED, LOW);
            return true;
        }
    }
    return false;
}



// Tries to connect to previously saved AP (unless reset pin is high).
// If no previous configuration found, this will create a softAP named AUTOCONNECT_NAME.
// Then, connect any browser-enabled device to this softAP, and configure your AP.
void AC_Autoconnect(bool aForceReset) {
    WiFiManager wifiManager;
    wifiManager.setConnectTimeout(30); // on va essayer de se connecter à la box pdt xxx secondes
   
    if(aForceReset) { //WiFi.SSID() == "" || digitalRead(PIN_AUTOCONNECT_RESET) == HIGH) {
        dprintln(F("AUTOCONNECT: Reset settings, please connect to " AUTOCONNECT_NAME " from a browser-enabled device."));
        wifiManager.resetSettings();
    }
    
    dprintln(F("AUTOCONNECT: Connecting..."));
    if(!wifiManager.autoConnect(AUTOCONNECT_NAME, SOFTAP_PASS)) {
        dprintln("AUTOCONNECT: failed to connect and hit timeout");
        delay(3000);
        ESP.reset();
        delay(5000);
    } 

    // wifiManager.setConnectTimeout(45);
    // wifiManager.setAPCallback(AC_APCallback);
    // wifiManager.setSaveConfigCallback(AC_SaveCallback);
    dprint(F("AUTOCONNECT: Connected to "));
    dprint(WiFi.SSID());
    dprint(F(", IP: "));
    dprintln(WiFi.localIP());
    
}


// ===================================================================
// SoftAP
// ===================================================================
// Creates a softAP
void createSoftAP() {
    dprint(F("SOFT_AP: Creating soft AP "));
    dprintln(SOFTAP_NAME);
    // set both access point and station
    WiFi.mode(WIFI_AP_STA);
  
    // create soft AP
    WiFi.softAP(SOFTAP_NAME, SOFTAP_PASS);
    // WiFi.softAP(SOFTAP_NAME, SOFTAP_PASS, SOFTAP_CHANNEL, SOFTAP_HIDE);

    dprint(F("SOFT_AP: Created soft AP with IP "));
    dprintln(WiFi.softAPIP());

    delay(1000);
}


// ===================================================================
// WebSocket Server Routines
// ===================================================================
void WSOCK_HandleEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t lenght) {
    switch(type) {
    case WStype_DISCONNECTED: {
        dprintln(F("WSOCK_SERVER: Disconnected!"));
    } break;
    case WStype_CONNECTED: {
        IPAddress ip = gSocketServer.remoteIP(num);
        Serial.printf("WSOCK_SERVER: [%u] Connected from %d.%d.%d.%d url: %s\n", num, ip[0], ip[1], ip[2], ip[3], payload);
        // send message to client
        gSocketServer.sendTXT(num, "WSOCK_SERVER: Connected");
    } break;
    case WStype_TEXT: {
        Serial.printf("[%u] get Text: %s\n", lenght, payload);

        // copy payload to string buffer
        for(int i = 0; i < lenght; i++) {
            gBuffer[i] = payload[i];
        }
        gBuffer[lenght] = '\0';
        if(!strcmp(gBuffer, WSOCK_COMMAND_REMOTE)) {
            // just reply
            gSocketServer.sendTXT(num, WSOCK_COMMAND_REMOTE WSOCK_COMMAND_SEPARATOR WSOCK_OK);
        }
        else if(!strcmp(gBuffer, "L1")) {
            dprintln("led ON!!!");
            digitalWrite(PIN_LED, HIGH);
        }
        else if(!strcmp(gBuffer,"L0")) {
            dprintln("led OFF!!!");
            digitalWrite(PIN_LED, LOW);
        }

        // send message to client
        // gSocketServer.sendTXT(num, "coucou ici :)");
    } break;
    case WStype_BIN: {
        Serial.printf("[%u] get binary lenght: %u\n", num, lenght);
        hexdump(payload, lenght);

        // send message to client
        // webSocket.sendBIN(num, payload, lenght);
    } break;
    }
}

void setup() {
  delay(1000);
  
  // démarrage out put série pour debug
  dprint_init(115200);

  // connexion au réseau WiFi
  AC_Autoconnect(AC_UserReset());

  // creation softAP
  createSoftAP();

  // démarrage du serveur Web
  gHttpServer.on("/", HTTP_HandleRoot);
  gHttpServer.onNotFound(HTTP_HandleNotFound);  
  gHttpServer.begin();
  dprintln("HTTP_SERVER: Started");

  // démarrage serveur WebSocket local
  gSocketServer.begin();
  gSocketServer.onEvent(WSOCK_HandleEvent);
  dprintln("WSOCK_SERVER: Started");


  // TODO: blink LED to say all OK


  // TODO: remove
  // debug stuff
  pinMode(A0, INPUT);
  

  /*
  SPI.begin();           // Init SPI bus
  mfrc522.PCD_Init();    // Init MFRC522
  
  WiFi.begin(ssid, pass);
  
  int retries = 0;
  while ((WiFi.status() != WL_CONNECTED) && (retries < 10)) {
    retries++;
    delay(500);
    Serial.print(".");
  }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println(F("WiFi connected"));
  }
  
  Serial.println(F("Ready!"));
  Serial.println(F("======================================================")); 
  Serial.println(F("Scan for Card and print UID:"));
  */

}

void loop() {

  gHttpServer.handleClient();
  gSocketServer.loop();

  


  // TODO: remove
  // debug analog 
  
  //uint32_t read = (uint32_t) analogRead(A0);
  //gSocketServer.sendTXT(0, WSOCK_COMMAND_A0 WSOCK_COMMAND_SEPARATOR + String(read) );

  /*
  uint8_t out[4] = {0};
  out[3] = (read & 0xff000000) >> 24;
  out[2] = (read & 0xff0000) >> 16;
  out[1] = (read & 0xff00) >> 8;
  out[0] = (read & 0xff);
  gSocketServer.sendBIN(0, out, 4);
  */
  
  /*

  /*
  // Look for new cards
  if ( ! mfrc522.PICC_IsNewCardPresent()) {
    delay(50);
    return;
  }
  // Select one of the cards
  if ( ! mfrc522.PICC_ReadCardSerial()) {
    delay(50);
    return;
  }
  // Show some details of the PICC (that is: the tag/card)
  Serial.print(F("Card UID:"));
  dump_byte_array(mfrc522.uid.uidByte, mfrc522.uid.size);
  Serial.println();*/
}



