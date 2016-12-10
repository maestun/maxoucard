#include <ESP8266WiFi.h>
#include <WiFiClient.h> 
#include <ESP8266WebServer.h>
#include <SPI.h>
#include <EEPROM.h>
#include "MFRC522.h"
#include <WebSocketsServer.h>
#include <WebSocketsClient.h>

// ===================================================================
// Debug stuff
// ===================================================================

#  define dprint_init(x)  Serial.begin(x); delay(100); Serial.println("Startup.")
#  define dprint(x)       Serial.print(x)
#  define dprintln(x)     Serial.println(x)
 

// ===================================================================
// Configuration
// ===================================================================
#define AP_NAME             "Borne1"
#define AP_PASS             "12345678"

#define WEB_SERVER_PORT     80
#define SOCKET_SERVER_PORT  81

#define GPIO2               2

#define EEPROM_WIFI_ADDR    0x0
#define EEPROM_WIFI_LEN     64

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

const char *ssid =  "paprika2";     // change according to your Network - cannot be longer than 32 characters!
const char *pass =  "WIFI12Stones"; // change according to your Network

MFRC522 mfrc522(SS_PIN, RST_PIN); // Create MFRC522 instance

WebSocketsServer    gSocketServer = WebSocketsServer(SOCKET_SERVER_PORT);  // creation d'un serveur WebSocket
WebSocketsClient    gSocketClient;

ESP8266WebServer  gWebServer(WEB_SERVER_PORT); // creation d'un serveur web sur le port 80

// serveur web
void handleRoot() {
  gWebServer.send(200, "text/html", "<h1>Hello World, Web Server !</h1>");
}

char buf[256] = {0};
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

      // copy payload to buffer
      for(int i=0; i< lenght; i++) {
        buf[i] = payload[i];
      }
      buf[lenght] = '\0';
 
  if(!strcmp(buf, "L1")) {
    dprintln("led ON!!!");
    pinMode(GPIO2, OUTPUT);
    digitalWrite(GPIO2, HIGH);
  }
  else if(!strcmp(buf,"L0")) {
    dprintln("led OFF!!!");
    pinMode(GPIO2, OUTPUT);
    digitalWrite(GPIO2, LOW);
  }
  else {
    // save wifi info onto EEPROM ?
    if(!strncmp(buf, "WIFI", 4)) {
      dprintln("Saving wifi into EEPROM");
      uint8_t addr = EEPROM_WIFI_ADDR;
      for(int i = 0; i< lenght; i++) {
        EEPROM.write(addr++, payload[i]);
      }
      for(int i = lenght; i< EEPROM_WIFI_LEN; i++) {
        EEPROM.write(addr++, 0x0);
      }
      dprintln("wifi info saved, reset...");
      ESP.reset();
    }
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
  delay(2000);
  
  // démarrage out put série pour debug
  dprint_init(115200);
  dprintln(F("Booting...."));

  // connexion au réseau WiFi
  // read EEPROM contents
  dprintln(F("Read EEPROM...."));
  char buf[EEPROM_WIFI_LEN] = {0};
  for(int i = EEPROM_WIFI_ADDR; i < EEPROM_WIFI_LEN; i++) {
    buf[i] = EEPROM.read(i);
  }

  if(!strncmp(buf, "WIFI", 4)) {
    dprintln(F("Found WiFi connection info: "));
    const char delim[2] = ";";
    char * ssid = strtok(NULL, delim);
    char * pass = strtok(NULL, delim);
    dprintln(ssid);
    dprintln(pass);

      dprint("Connecting to ");
      dprint(ssid);
      WiFi.begin(ssid, pass);
      while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        dprint(".");
      }
      dprintln("");
      dprint("WiFi connected, ");  
      dprint("IP address: ");
      dprintln(WiFi.localIP());
  }
  
  /*
  dprint("Connecting to ");
  dprint(ssid);
  WiFi.begin(ssid, pass);
  while (WiFi.status() != WL_CONNECTED) {
    delay(100);
    dprint(".");
  }
  dprintln("");
  dprint("WiFi connected, ");  
  dprint("IP address: ");
  dprintln(WiFi.localIP());
  */

  // configuration en tant que AP
  dprint("Creating soft AP ");
  dprintln(AP_NAME);
  WiFi.softAP(AP_NAME, AP_PASS);
  IPAddress ap_ip = WiFi.softAPIP();
  dprint("Created soft AP with IP ");
  dprintln(ap_ip);

  // démarrage du serveur Web
  gWebServer.on("/", handleRoot);
  gWebServer.begin();
  dprintln("HTTP server started");

  // démarrage serveur WebSocket local
  gSocketServer.begin();
  gSocketServer.onEvent(onServerSocketEvent);
  dprintln("WebSocket Server started");

  // démarrage client websocket
  
  

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

// Helper routine to dump a byte array as hex values to Serial
void dump_byte_array(byte *buffer, byte bufferSize) {
  for (byte i = 0; i < bufferSize; i++) {
    Serial.print(buffer[i] < 0x10 ? " 0" : " ");
    Serial.print(buffer[i], HEX);
  }
}
