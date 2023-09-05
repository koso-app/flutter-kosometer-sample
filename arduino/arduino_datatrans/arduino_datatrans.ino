/*
  Battery Monitor

  This example creates a BLE peripheral with the standard battery service and
  level characteristic. The A0 pin is used to calculate the battery level.

  The circuit:
  - Arduino MKR WiFi 1010, Arduino Uno WiFi Rev2 board, Arduino Nano 33 IoT,
    Arduino Nano 33 BLE, or Arduino Nano 33 BLE Sense board.

  You can use a generic BLE central app, like LightBlue (iOS and Android) or
  nRF Connect (Android), to interact with the services and characteristics
  created in this sketch.

  This example code is in the public domain.
*/

#include <ArduinoBLE.h>

// data not auth
byte data[40] = { 0xff, 0x10, 0x24, 0x45, 0x45, 0x37, 0x36, 0x32, 0x44, 0x33,
                    0x46, 0x30, 0x41, 0x46, 0x36, 0x34, 0x30, 0x37, 0x43, 0x45,
                    0x34, 0x33, 0x45, 0x38, 0x45, 0x35, 0x41, 0x38, 0x37, 0x43,
                    0x44, 0x34, 0x38, 0x46, 0x34, 0x00, 0x00, 0x01, 0xff, 0x10 };
                    
                    
 // BLE Battery Service
BLEService myService("92faec07-c075-4b7c-a6c2-bbd1d1a150f5");

// BLE Battery Level Characteristic
BLECharacteristic rxChar("acf1b15c-10f9-4942-a32d-f9e019b95402", BLEWrite, 242); // remote clients will be able to get notifications if this characteristic changes
BLECharacteristic txChar("3aabbb34-eac0-40f5-9d50-3a1ee6787136", BLERead | BLENotify, 242);

int oldBatteryLevel = 0;  // last battery level reading from analog input
long previousMillis = 0;  // last time the battery level was checked, in ms

void setup() {
  Serial.begin(9600);    // initialize serial communication
  while (!Serial);

  pinMode(LED_BUILTIN, OUTPUT); // initialize the built-in LED pin to indicate when a central is connected

  // begin initialization
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");

    while (1);
  }

  /* Set a local name for the BLE device
     This name will appear in advertising packets
     and can be used by remote devices to identify this BLE device
     The name can be changed but maybe be truncated based on space left in advertisement packet
  */
  BLE.setLocalName("Datatrans emulator");
  BLE.setAdvertisedService(myService); // add the service UUID
  myService.addCharacteristic(rxChar); // add the battery level characteristic
  myService.addCharacteristic(txChar);
  BLE.addService(myService); // Add the battery service


  /* Start advertising BLE.  It will start continuously transmitting BLE
     advertising packets and will be visible to remote BLE central devices
     until it receives a new connection */

  // start advertising
  BLE.advertise();

//  Serial.println("Bluetooth device active, waiting for connections...");
}

void loop() {
  // wait for a BLE central
  BLEDevice central = BLE.central();

  // if a central is connected to the peripheral:
  if (central) {
    Serial.print("Connected to central: ");
    // print the central's BT address:
    Serial.println(central.address());
    // turn on the LED to indicate the connection:
    digitalWrite(LED_BUILTIN, HIGH);

    // check the battery level every 200ms
    // while the central is connected:
    while (central.connected()) {
      long currentMillis = millis();
      // if 200ms have passed, check the battery level:
    
      if(rxChar.written()){
        
        char buffer[242];
        const uint8_t* data = rxChar.value();
        
        sprintf(buffer,"[%02x,%02x,%02x,%02x,%02x,%02x,%02x,%02x]",data[0],data[1],data[2],data[3],data[4],data[5],data[6],data[7]);
        Serial.println( buffer);

        txChar.writeValue(data, 40);

        //central.disconnect();
        digitalWrite(LED_BUILTIN, LOW);

      }
 
      if (currentMillis - previousMillis >= 10000) {
        previousMillis = currentMillis;
        writeData();
      }

      
    }
    // when the central disconnects, turn off the LED:
    digitalWrite(LED_BUILTIN, LOW);
    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
    BLE.advertise();
  }
}

void writeData() {

  txChar.writeValue(data, 100);  // and update the battery level characteristic
  
  Serial.println("data send");
}
