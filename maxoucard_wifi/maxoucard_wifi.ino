#include <ESP8266WiFi.h>
#include <WiFiClient.h> 
#include <ESP8266WebServer.h>
#include <WiFiManager.h>
#include <SPI.h>
#include <EEPROM.h>
#include "MFRC522.h"
#include <WebSocketsServer.h>

 
// ===================================================================
// Configuration
// ===================================================================
#define SOFTAP_NAME               "Borne1"
#define SOFTAP_PASS               "12345678"
#define AUTOCONNECT_NAME          SOFTAP_NAME "-Config"
#define AUTOCONNECT_PASS          "12345678"

#define WEB_SERVER_PORT           80
#define SOCKET_SERVER_PORT        81

#define GPIO2                     0x2



// ===================================================================
// Debug stuff
// ===================================================================
#  define dprint_init(x)  Serial.begin(x); delay(100); Serial.println("Startup.")
#  define dprint(x)       Serial.print(x)
#  define dprintln(x)     Serial.println(x)


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


char                gBuffer[256] = {0};
MFRC522             gRC522(SS_PIN, RST_PIN); // Create MFRC522 instance
WebSocketsServer    gSocketServer = WebSocketsServer(SOCKET_SERVER_PORT);  // creation d'un serveur WebSocket
ESP8266WebServer    gWebServer(WEB_SERVER_PORT); // creation d'un serveur web sur le port 80

// serveur web
void handleRoot() {
  gWebServer.send(200, "text/html", "<h1>Hello World, Web Server !</h1>");
}


// Tries to connect to previously saved AP (unless aReset is set to true).
// If no previous configuration found, this will create a softAP named AUTOCONNECT_NAME.
// Then, connect any browser-enabled device to this softAP, and configure your AP.
void autoconnect(bool aReset) {
    WiFiManager wifiManager;

    if(aReset) {
      wifiManager.resetSettings();
    }
    wifiManager.autoConnect(AUTOCONNECT_NAME, AUTOCONNECT_PASS);
}


// Creates a softAP
void createSoftAP(char * aName, char * aPass) {
    dprint("Creating soft AP ");
    dprintln(aName);
    WiFi.softAP(aName, aPass);
    IPAddress ap_ip = WiFi.softAPIP();
    dprint("Created soft AP with IP ");
    dprintln(ap_ip);
}



// serveur socket
void onServerSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t lenght) {

    switch(type) {
        case WStype_DISCONNECTED:
            dprintln("Disconnected!");
            break;
        case WStype_CONNECTED: {
                IPAddress ip = gSocketServer.remoteIP(num);
                Serial.printf("[%u] Connected from %d.%d.%d.%d url: %s\n", num, ip[0], ip[1], ip[2], ip[3], payload);
                // send message to client
                gSocketServer.sendTXT(num, "Connected");
            }
            break;
        case WStype_TEXT:
            Serial.printf("[%u] get Text: %s\n", lenght, payload);

            // copy payload to string buffer
            for(int i = 0; i < lenght; i++) {
              gBuffer[i] = payload[i];
            }
            gBuffer[lenght] = '\0';
 
            if(!strcmp(gBuffer, "L1")) {
              dprintln("led ON!!!");
              pinMode(GPIO2, OUTPUT);
              digitalWrite(GPIO2, HIGH);
            }
            else if(!strcmp(gBuffer,"L0")) {
              dprintln("led OFF!!!");
              pinMode(GPIO2, OUTPUT);
              digitalWrite(GPIO2, LOW);
            }

            // send message to client
            gSocketServer.sendTXT(num, "coucou ici :)");

            // send data to all connected clients
            // webSocket.broadcastTXT("message here");
            break;
        case WStype_BIN:
            Serial.printf("[%u] get binary lenght: %u\n", num, lenght);
            hexdump(payload, lenght);

            // send message to client
            // webSocket.sendBIN(num, payload, lenght);
            break;
    }

}

void setup() {
  delay(1000);
  
  // démarrage out put série pour debug
  dprint_init(115200);

  // connexion au réseau WiFi
  autoconnect(false);  

  // creation softAP
  createSoftAP(SOFTAP_NAME, SOFTAP_PASS);

  // démarrage du serveur Web
  gWebServer.on("/", handleRoot);
  gWebServer.begin();
  dprintln("HTTP server started");

  // démarrage serveur WebSocket local
  gSocketServer.begin();
  gSocketServer.onEvent(onServerSocketEvent);
  dprintln("WebSocket Server started");

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


  gWebServer.handleClient();
  gSocketServer.loop();


  
  uint32_t read = (uint32_t) analogRead(A0);
  uint8_t out[4] = {0};
  out[3] = (read & 0xff000000) >> 24;
  out[2] = (read & 0xff0000) >> 16;
  out[1] = (read & 0xff00) >> 8;
  out[0] = (read & 0xff);
  gSocketServer.sendBIN(0, out, 4);
  delay(100);
  

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

