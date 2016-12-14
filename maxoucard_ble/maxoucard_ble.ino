#include <SoftwareSerial.h>
#include <Wire.h> 
#include <SPI.h>
#include <MFRC522.h>
#include "ble_commands.h"
#include "maxoucard_config.h"

// ===================================================================
// Configuration
// ===================================================================
// #define NO_SERIAL                  // décommenter pour debug série
#define PIN_DEBUG_BUTTON      3


// ===================================================================
// Debug stuff
// ===================================================================
#ifdef NO_SERIAL
#  define dprint_init(x)
#  define dprint(x)
#  define dprintln(x)
#else
#  define dprint_init(x)      Serial.begin(x); Serial.println("Startup.")
#  define dprint(x)           Serial.print(x)
#  define dprintln(x)         Serial.println(x)
#endif


// ===================================================================
// RFID-RC522 Module
// ===================================================================
#define PIN_RFID_RST          9
#define PIN_RFID_SDA          10
#define PIN_RFID_MOSI         11
#define PIN_RFID_MISO         12
#define PIN_RFID_SCK          13
#define BUF_LEN               32
char gBuffer[BUF_LEN] =       {0};
MFRC522 gRC522(PIN_RFID_SDA, PIN_RFID_RST);


// ===================================================================
// HM-10 BLE Module
// ===================================================================
#define PIN_BLE_RX            7
#define PIN_BLE_TX            8
#define BLE_DELAY_MS          500
SoftwareSerial                gBLE(PIN_BLE_TX, PIN_BLE_RX);

// data format is: NFC<separator><NFC_ID_STRING>
bool HM10_SendString(char * aData) {

    int len = strlen(aData);
    for(char i = 0; i < len; i++) {
        gBLE.write(aData[i]);
    }

    dprint(F("sending NFC: "));
    dprintln(aData);
}


bool HM10_ReadACK() {
    String ret = gBLE.readString();

    // TODO: lire le retour w/ timeout

    return true;
    
}


// Configure the BLE peripheral
bool HM10_ConnectToMaster() {
    gBLE.begin(9600);
    
    // ping
    gBLE.write("AT");
    delay(BLE_DELAY_MS);
    dprint(F("BLE ping: "));
    dprintln(gBLE.readString());

    // gBLE.write("AT+VERS?");
    // delay(BLE_DELAY_MS);
    // dprint(F("BLE version: "));
    // dprintln(gBLE.readString());  

    // // get MAC address
    // gBLE.write("AT+ADDR?");
    // delay(BLE_DELAY_MS);
    // dprint(F("BLE MAC addr: "));
    // dprintln(gBLE.readString());

    // set name
    gBLE.write("AT+NAME" BLE_NAME);
    delay(BLE_DELAY_MS);
    dprint(F("BLE name: "));
    dprintln(gBLE.readString());

    // set pin
    gBLE.write("AT+PASS" BLE_PIN);
    delay(BLE_DELAY_MS);
    dprint(F("BLE pin: "));
    dprintln(gBLE.readString());

    // get mode (should be 0)
    // gBLE.write("AT+MODE?");
    // delay(BLE_DELAY_MS);
    // dprint(F("BLE mode: "));
    // dprintln(gBLE.readString());


    // // get role (should be 0=peripheral)
    // gBLE.write("AT+ROLE?");
    // delay(BLE_DELAY_MS);
    // dprint(F("BLE role: "));
    // dprintln(gBLE.readString());

    // gBLE.write("AT+SHOW?");
    // delay(BLE_DELAY_MS);
    // dprint(F("BLE show: "));
    // dprintln(gBLE.readString());

    // gBLE.write("AT+TEMP?");
    // delay(BLE_DELAY_MS);
    // dprint(F("BLE temp: "));
    // dprintln(gBLE.readString());

    // set ask pin
    gBLE.write("AT+TYPE2"); // ask pin
    delay(BLE_DELAY_MS);
    dprint(F("BLE bond type: "));
    dprintln(gBLE.readString());

    dprint(F("Config done."));
}


void sendUID(byte * aUID, byte aLength) {
    memset(gBuffer, 0, BUF_LEN);
    
    sprintf(gBuffer, "%s%s", BLE_COMMAND_NFC, BLE_COMMAND_SEPARATOR);
    char hex[3] = {0};
    for(int i = 0; i < aLength; i++) {
        sprintf(hex, "%02X", aUID[i]);
        strcat(gBuffer, hex);
    }
    strcat(gBuffer, BLE_COMMAND_TERMINATOR);
    HM10_SendString(gBuffer);
}


// ===================================================================
// Main
// ===================================================================
void setup() {

    // init serial output
    dprint_init(9600);
    
    // init BLE + connect
    HM10_ConnectToMaster();

    // init RFID
    SPI.begin();      // Init SPI bus
    gRC522.PCD_Init(); // Init MFRC522 card

    pinMode(PIN_DEBUG_BUTTON, INPUT_PULLUP);
}


void loop() {

    if(digitalRead(PIN_DEBUG_BUTTON) == LOW) {
        // debug, send fake UID
        memset(gBuffer, 0, BUF_LEN);
        sprintf(gBuffer, "%s%s%s%s", BLE_COMMAND_NFC, BLE_COMMAND_SEPARATOR, F("DEADBEEF"), BLE_COMMAND_TERMINATOR);
        HM10_SendString(gBuffer);
    }

    // Look for new cards
    if(gRC522.PICC_IsNewCardPresent()) {
        // Select one of the cards
          dprintln("New card");
        if(gRC522.PICC_ReadCardSerial()) {
            // Dump debug info about the card. PICC_HaltA() is automatically called.
            dprintln("Read card");
            // gRC522.PICC_DumpToSerial(&(gRC522.uid));
            sendUID(gRC522.uid.uidByte, gRC522.uid.size);
            if(HM10_ReadACK()) {
                // all ok
              
            }
            else {
                // no ACK after timeout, re-send
            }
        }
    }
  
    // teh wait !
    delay(100);
}
