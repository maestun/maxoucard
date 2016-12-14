#include <SoftwareSerial.h>
#include <Wire.h> 
#include "ble_commands.h"
#include "maxoucard_config.h"

// ===================================================================
// Configuration
// ===================================================================
// #define NO_SERIAL                  // décommenter pour debug série
#define PIN_DEBUG_BUTTON  2
#define PIN_DEBUG_BUTTON2 3



// ===================================================================
// Debug stuff
// ===================================================================
#ifdef NO_SERIAL
#  define dprint_init(x)
#  define dprint(x)
#  define dprintln(x)
#else
#  define dprint_init(x)  Serial.begin(x); Serial.println("Startup.")
#  define dprint(x)       Serial.print(x)
#  define dprintln(x)     Serial.println(x)
#endif


// ===================================================================
// HM-10 BLE Module
// ===================================================================
#define PIN_BLE_RX        9
#define PIN_BLE_TX        8
SoftwareSerial            gBLE(PIN_BLE_TX, PIN_BLE_RX);
#define BLE_DELAY_MS      500

// data format is: NFC<separator><NFC_ID_STRING>
bool HM10_SendData(char * aData) {

  gBLE.write(BLE_COMMAND_NFC);
  gBLE.write(BLE_COMMAND_SEPARATOR);
  
  int len = strlen(aData);
  for(char i = 0; i < len; i++) {
    gBLE.write(aData[i]);
  }
  
  gBLE.write(BLE_COMMAND_TERMINATOR);
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

  gBLE.write("AT+VERS?");
  delay(BLE_DELAY_MS);
  dprint(F("BLE version: "));
  dprintln(gBLE.readString());  

  // get MAC address
  gBLE.write("AT+ADDR?");
  delay(BLE_DELAY_MS);
  dprint(F("BLE MAC addr: "));
  dprintln(gBLE.readString());

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
  gBLE.write("AT+MODE?");
  delay(BLE_DELAY_MS);
  dprint(F("BLE mode: "));
  dprintln(gBLE.readString());


  // get role (should be 0=peripheral)
  gBLE.write("AT+ROLE?");
  delay(BLE_DELAY_MS);
  dprint(F("BLE role: "));
  dprintln(gBLE.readString());


  gBLE.write("AT+SHOW?");
  delay(BLE_DELAY_MS);
  dprint(F("BLE show: "));
  dprintln(gBLE.readString());

  gBLE.write("AT+TEMP?");
  delay(BLE_DELAY_MS);
  dprint(F("BLE temp: "));
  dprintln(gBLE.readString());

  gBLE.write("AT+TYPE2"); // ask pin
  delay(BLE_DELAY_MS);
  dprint(F("BLE bond type: "));
  dprintln(gBLE.readString());

  dprint(F("Config done."));
}


// ===================================================================
// Main
// ===================================================================
#define PIN_LED_REF         13

void setup() {

  // init serial output
  dprint_init(9600);
  
  // init BLE + connect
  HM10_ConnectToMaster();

  // TODO: init NFC
  pinMode(PIN_DEBUG_BUTTON, INPUT_PULLUP);
  pinMode(PIN_DEBUG_BUTTON2, INPUT_PULLUP);
}


void loop() {

  // scan NFC (TODO:)
  /*
  if(digitalRead(PIN_DEBUG_BUTTON) == HIGH) {
    dprintln(F("debug button!"));
    HM10_SendData("DUMMY_NFC_ID");
  }
  */
  if(digitalRead(PIN_DEBUG_BUTTON2) == LOW) {
    dprintln(F("debug button 2!"));
    String str = String(BLE_COMMAND_NFC) + String(BLE_COMMAND_SEPARATOR) + "OLIVIER_NFC_ID";
    HM10_SendData("OLIVIER_NFC_ID");

    if(HM10_ReadACK()) {
        // all ok
        
    }
    else {
        // no ACK after timeout, re-send
    }
    
  }

  // teh wait !
  delay(100);
}
