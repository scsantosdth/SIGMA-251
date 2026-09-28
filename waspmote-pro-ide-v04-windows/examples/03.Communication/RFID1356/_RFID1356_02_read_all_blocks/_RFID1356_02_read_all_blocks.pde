/*   
 *  ------[RFID1356_02] Read All Blocks -------- 
 *   
 *  Explanation: This sketch reads all the blocks in a RFID card. It is 
 *  supposed that all the sectors have the same key. 
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
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
 *  GNU General Public License for more details. 
 *   
 *  You should have received a copy of the GNU General Public License 
 *  along with this program. If not, see <http://www.gnu.org/licenses/>. 
 *   
 *  Version:                0.4
 *  Design:                 David Gascon 
 *  Implementation:         Ahmad Saad, Javier Solobera 
 */

#include <WaspRFID13.h>

// define variable to store init process result 
uint8_t state; 

// stores the 16 bytes data read from a block: 
blockData readData; 

// stores the answer to request: 
ATQ ans; 

// stores the UID (unique identifier) of a card: 
UIdentifier UID; 

// stores the key or password: 
KeyAccess keyAccess = { 
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}; 

// define variable to store authentication process result
uint8_t authentication;


void setup() 
{ 
  USB.ON();
  USB.println(F("RFID_02 Example"));

  ///////////////////////////////////////////////////////////////////
  // switch on the RFID/NFC @ 13.56 MHz module, and select the socket
  ///////////////////////////////////////////////////////////////////
  RFID13.ON(SOCKET0);   
  USB.println(F("RFID/NFC @ 13.56 MHz module started")); 
} 


void loop() 
{ 
  USB.print(F("\r\n++++++++++++++++++++++++++++++++++++")); 

  ///////////////////////////
  // 1. Init the RFID reader   
  ///////////////////////////
  state = RFID13.init(UID, ans); 


  ////////////////////////////////////////////////////////////
  // 2. If init result was correct perform the reading process
  ////////////////////////////////////////////////////////////
  if( state == 1 )  
  { 
    USB.println(F("\r\nRequest error-card not found")); 
  } 
  else  
  { 
    // A card was found 
    // Show the ATQ 
    USB.print(F("\r\nRequest|Answer: ")); 
    RFID13.print(ans, 2); 

    // Show the status of the executed init command (should be 0) 
    USB.print(F("\r\nAnticollSelect: ")); 
    USB.printHex(state); 
    USB.print(F("|Answer: ")); 

    // Show the UID (Unique IDentifier) of the read card (4 bytes) 
    RFID13.print(UID, 16); 

    ///////////////////////////////////
    // 3. Iterate through all 64 blocks
    ///////////////////////////////////
    for (int n=0; n<64; n++) 
    { 
      // 3.1. Authenticate the key A of each SECTOR 
      // only one authentication per sector is needed 
      // So, every 4 blocks a new authetication is needed
      if (n % 4 == 0) 
      {
        authentication = RFID13.authenticate(UID, n , keyAccess); // it is supposed all the blocks have the same key 
        USB.print(F("\r\nAuthentication block ")); 
        USB.printf("%02u",n); // show the number of the block [n = 0..63 in a 1 kB RFID card]
        USB.print(F(": ")); 
        USB.printHex(authentication); // show the state of the executed authentication command         
      }

      // 3.2. if passed authentication in the sector, 
      // we will be able to read the data in its blocks  
      if( authentication == 0 ) 
      { 
        state = RFID13.read(n, readData); 
        USB.print(F("\r\nRead block "));       
        USB.printf("%02u",n); // show the number of the block [n = 0..63] 
        USB.print(F(": ")); 
        USB.printHex(state); // show the state of the executed read command 
        USB.print(F("   ")); 

        // if the read command was successful, 
        // we show the data (16 bytes) 
        if (state == 0)
        { 
          USB.print(F(" | ")); 
          for (int i=0; i< 16; i++) 
          {            
            USB.printHex(readData[i]); // print the 16 bytes of the block 'n' 
            USB.print(F(" ")); 
          } 
          USB.print(F("  ")); 

          // print information about Card and trailer blocks 
          if( n==0 ) 
            USB.print(F("<--UID(first 4 bytes)")); 
          else if( ((n+1) % 4) == 0 ) 
            USB.print(F("<--Trailer block")); 
        } 
      }
    }   
    USB.println(); 
    delay(5000);
  } 

  USB.print(F("\r\n++++++++++++++++++++++++++++++++++++")); 
}

