#include <SoftwareSerial.h>
#include <Wire.h> 

// ===================================================================
// Configuration
// ===================================================================
#define BLE_NAME          "Borne1"    // nom du device bluetooth, doit être unique !
#define BLE_PASS          "123456"
// #define NO_SERIAL                  // décommenter pour debug série
#define PIN_DEBUG_BUTTON  2



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
#define BLE_SEPARATOR     ";"
#define BLE_ENDLINE       "."

// data format is: NFC<separator><NFC_ID_STRING>
bool HM10_SendData(char * aData) {

  gBLE.write("NFC");
  gBLE.write(BLE_SEPARATOR);
  
  int len = strlen(aData);
  for(char i = 0; i < len; i++) {
    gBLE.write(aData[i]);
  }
  
  gBLE.write(BLE_ENDLINE);
  dprint(F("sending NFC: "));
  dprintln(aData);
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
  gBLE.write("AT+PASS" BLE_PASS);
  delay(BLE_DELAY_MS);
  dprint(F("BLE pin: "));
  dprintln(gBLE.readString());
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
}


void loop() {

  // scan NFC (TODO:)
  if(digitalRead(PIN_DEBUG_BUTTON) == HIGH) {
    dprintln(F("debug button!"));
    HM10_SendData("DUMMY_NFC_ID");
  }

  // teh wait !
  delay(500);
}
