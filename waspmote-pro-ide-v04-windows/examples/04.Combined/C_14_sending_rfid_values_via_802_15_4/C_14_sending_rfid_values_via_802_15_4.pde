/*  
 *  ------ [C_14] - Sending RFID values via 802.15.4 -------- 
 *  
 *  Explanation: This example uses RFID module to read some 
 *  data and then send it via 802.15.4.
 *  
 *  Copyright (C) 2015 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify 
 *  it under the terms of the GNU General Public License as published by 
 *  the Free Software Foundation, either version 3 of the License, or 
 *  (at your option) any later version. 
 *  
 *  This program is distributed in the hope that it will be useful, 
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of 
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
 *  GNU General Public License for more details. 
 *  
 *  You should have received a copy of the GNU General Public License 
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>. 
 *  
 *  Version:           0.2 
 *  Design:            David Gascón 
 *  Implementation:    Javier Siscart
 */

#include <WaspFrame.h>
#include <WaspRFID13.h>  
#include <WaspXBee802.h>

// Sleep time [dd:hh:mm:ss]
char sleepTime[] = "00:00:00:10";           

// Destination MAC address
char MAC_ADDRESS[]="0013A20040B4DCDB";

// Variable to store data read
char readDataChar[16];

// stores the 16 bytes data to be written in a block: 
blockData writeData = {
  0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 
  0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F}; 
// stores the 16 bytes data read from a block: 
blockData readData; 
// stores the key or password: 
uint8_t keyAccess[] = {
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF }; 
// stores the block address: 
uint8_t address = 0x09; 
// stores the UID (unique identifier) of a card: 
UIdentifier UID; 
// stores the answer to request: 
uint8_t anstoreq[2];  
// define variable
uint8_t error;

void setup()
{
  // 0. Init USB port for debugging
  USB.ON();
  USB.println(F("C_14 Example"));


  ////////////////////////////////////////////////
  // 1. Initial message composition
  ////////////////////////////////////////////////

  // 1.1 Set mote Identifier (16-Byte max)
  frame.setID("WASPMOTE_001");	

  // 1.2 Create new frame
  frame.createFrame(ASCII);  

  // 1.3 Set frame fields (String - char*)
  frame.addSensor(SENSOR_STR, (char*) "C_14 Example");

  // 1.4 Print frame
  frame.showFrame();


  ////////////////////////////////////////////////
  // 2. Send initial message
  ////////////////////////////////////////////////

  // 2.1 Switch on the XBee module
  xbee802.ON();  

  // 2.2 Set destination XBee parameters to packet
  error = xbee802.send( MAC_ADDRESS, frame.buffer, frame.length );

  // 2.3 Check TX flag
  if( error == 0 ) 
  {
    USB.println("ok");
  }
  else 
  {
    USB.println("error");
  }

  // 2.4 Communication module to OFF
  xbee802.OFF();
  delay(100);
  
  
}
 
void loop()
{
   ////////////////////////////////////////////////
  // 3. Measure corresponding values
  ////////////////////////////////////////////////
  USB.println(F("Reading RFID card..."));

  RFID13.ON(SOCKET1); 
  delay(200); 

  USB.println(F("Ready to read...")); 

  // get the UID 
  RFID13.init(UID, anstoreq); 
  USB.print(F("\n")); 
  USB.print(F("The UID: ")); 
  RFID13.print(UID, 4); 
  
  // auntenticate block number 4 with its access key (2nd sector) 
  if (RFID13.authenticate(UID, address, keyAccess) == 1) 
  { 
    USB.print(F("Authentication failed")); 
  } 
  else  
  { 
    // success 
    USB.print(F("Authentication OK")); 
    
    // after authentication, write blockData in the block 
    if (RFID13.write(address, writeData) == 1) 
    { 
      USB.print(F("Write failed")); 
    } 
    else  
    { 
      // success 
       USB.print(F("Write block OK")); 
      // read from address after write 
      if (RFID13.read(address, readData) == 1) 
      { 
        USB.print(F("Read failed")); 
      } 
      else  
      { 
        // success 
        USB.println(F("Read block OK")); 
        USB.println(F("Data read: ")); 
        RFID13.print(readData, 16); 
        
        for (int i=0; i<16; i++)
       { 
        readDataChar[i] = (char) readData[i];
       }            
      } 
    } 
  } 
  


  ////////////////////////////////////////////////
  // 4. Message composition
  ////////////////////////////////////////////////

  // 4.1 Create new frame
  frame.createFrame(ASCII);  

  // 4.2 Add frame fields
  frame.addSensor(SENSOR_RB, readDataChar);
  
  // 4.3 Print frame
  // Example: <=>\0x80\0x03#35689884#WASPMOTE_001#9#TCA:25.00#HUMA:60.0#LUM:27.000#
  frame.showFrame();


  ////////////////////////////////////////////////
  // 5. Send message
  ////////////////////////////////////////////////

  // 5.1 Switch on the XBee module
  xbee802.ON();  

  // 5.2 Set destination XBee parameters to packet
  error = xbee802.send( MAC_ADDRESS, frame.buffer, frame.length );

  // 5.3 Check TX flag
  if ( error == 0 ) 
  {
    USB.println("ok");
  }
  else 
  {
    USB.println("error");
  }
  
  // 5.4 Communication module to OFF 
  xbee802.OFF();

  ////////////////////////////////////////////////
  // 6. Entering Deep Sleep mode
  ////////////////////////////////////////////////
  USB.ON();
  USB.println(F("Going to sleep..."));
  
  PWR.deepSleep(sleepTime, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
 
  USB.ON();
  USB.println(F("wake"));
}
