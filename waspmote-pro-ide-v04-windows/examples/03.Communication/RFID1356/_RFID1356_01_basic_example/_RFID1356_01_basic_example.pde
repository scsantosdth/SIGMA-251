/*   
 *  ------ [RFID1356_01] RFID/NFC Basic Example -------- 
 *   
 *  Explanation: This sketch shows how to use the most important features 
 *  of the RFID/NFC module in Waspmote. First, the program looks for tags. 
 *  After a tag was found, the program tries to authenticate a sector and 
 *  writes in one block. Finally, it reads the content of that block. 
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
 *  along with this program. If not, see <http://www.gnu.org/licenses/>. 
 *   
 *  Version:          0.4
 *  Design:           David Gascon 
 *  Implementation:   Ahmad Saad, Javier Solobera 
 */

#include <WaspRFID13.h>  

// stores the 16 bytes data to be written in a block: 
blockData writeData = {
  0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 
  0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F};

// stores the 16 bytes data read from a block: 
blockData readData; 

// stores the key or password: 
KeyAccess key = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF }; 

// 'address' stores the block address: 
uint8_t address = 0x09; 

// stores the UID (unique identifier) of a card: 
UIdentifier UID; 

// stores the answer to request: 
ATQ ans; 

// define variable to store authentication process result
uint8_t authentication;

// define variable to store init process result
uint8_t state;


void setup() 
{ 
  USB.ON();
  USB.println(F("RFID_01 Example"));
  
  ///////////////////////////////////////////////////////////////////
  // switch on the RFID/NFC @ 13.56 MHz module, and select the socket
  /////////////////////////////////////////////////////////////////// 
  RFID13.ON(SOCKET0);   
  USB.println(F("RFID/NFC @ 13.56 MHz module started")); 
}  


void loop() 
{ 
  USB.println(); 
  USB.println(F("Waiting for card...")); 


  //////////////////////////
  // 1. Init the RFID reader 
  //////////////////////////
  state = RFID13.init(UID, ans); 
  if (state == 0)
  {
    USB.print(F("The UID: ")); 
    RFID13.print(UID, 4); 
  }
  else
  {
    USB.println(F("Card not found"));
  }
  
  
  ///////////////////////////////////////////////////////////////////
  // 2. Authenticate sector number 4 with its access key (2nd sector)   
  ///////////////////////////////////////////////////////////////////
  authentication = RFID13.authenticate(UID, address, key);

  if( authentication == 0 && state == 0 ) 
  { 
    USB.println(F("Authentication OK")); 
  } 
  // init succeeded, authentication failed
  else if ( authentication == 1 && state == 0 )
  { 
    USB.println(F("Authentication failed")); 
  } 


  ////////////////////////////////////////////////////////////////
  // 3. If authentication is OK, write 'writeData' array in the block 
  ////////////////////////////////////////////////////////////////
  if( authentication == 0 ) 
  { 
    // Write process
    if( RFID13.write(address, writeData) == 1 ) 
    { 
      USB.println(F("Write failed")); 
    } 
    else   
    { 
      USB.println(F("Write block OK")); 

      // Read from address after write process
      if (RFID13.read(address, readData) == 1) 
      { 
        USB.println(F("Read failed")); 
      } 
      else  // success 
      { 
        USB.println(F("Read block OK")); 
        USB.print(F("Data read: ")); 
        RFID13.print(readData, 16); 
      } 
    } 
  } 

  USB.println(); 
  delay(1000); // wait some time each loop 
}
