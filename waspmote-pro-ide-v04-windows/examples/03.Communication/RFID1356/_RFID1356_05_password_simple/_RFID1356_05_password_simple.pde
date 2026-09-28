/*   
 *  ------[RFID1356_05] Password Simple -------- 
 *   
 *  Explanation: This sketch changes the keys and access conditions in a 
 *  block and checks the block can be accessed with the new conditions. 
 *  Then changes the keys and access conditions to the original values and 
 *  checks again. 
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
 *  Version:                0.3 
 *  Design:                 David Gascon 
 *  Implementation:         Javier Solobera, Ahmad Saad 
 */

#include <WaspRFID13.h>

// stores the status of the executed command: 
short state; 

// data buffer: 
blockData data; 

// little buffer for the ATQ-A (answer to request):
ATQ ans;

// stores the UID (unique identifier) of a card: 
UIdentifier UID;

// stores the key or password: 
KeyAccess keyOld= {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}; 
KeyAccess keyA  = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xF1}; 
KeyAccess keyB  = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}; 

// only edit if strong knowledge about the RFID/NFC module 
unsigned char config[] = { 0xFF, 0x07, 0x80, 0x69};  

// define SECTOR TRAILER address
// Possibilities are: 3/7/11/15/19/23...
///////////////////////////////////
int address = 19; 
///////////////////////////////////

void setup() 
{ 
  USB.ON(); 
  USB.println(F("RFID_05 Example")); 

  USB.println(F("************************************************"));
  USB.println(F("|                  --WARNING--                 |"));
  USB.println(F("|Do not remove card during key changing process|"));
  USB.println(F("************************************************"));

  ////////////////////////////////////////////////////////////////////
  // switchs on the RFID/NFC @ 13.56 MHZ module, and asigns the socket 
  ////////////////////////////////////////////////////////////////////
  RFID13.ON(SOCKET0); 
  USB.println(F("RFID/NFC @ 13.56 MHz module started")); 
} 



void loop() 
{ 
  USB.println(F("\r\n++++++++++++++++++++++++++++++++++++")); 

  //////////////////////////
  // 1. Init the RFID reader 
  //////////////////////////
  state = RFID13.init(UID, ans); 
  
  // if so, there is no card on the EM field 
  if (state == 1) 
  { 
    USB.print(F("\r\nRequest error - no card found")); 
  } 
  else // a card was found 
  { 
    USB.println(F("A card was found"));
    USB.print(F("Request | Answer: ")); 
    RFID13.print(ans, 2);  // show the ATQ  
    
    // show the UID (Unique IDentifier) of the read card (4 bytes) 
    USB.print(F("UID: ")); 
    RFID13.print(UID, 4);  
    
    // show the address to be 
    USB.print(F("Trailer block address: ")); 
    USB.println(address);   
    USB.println();   
    
    //////////////////   
    // 2. Set new keyA 
    //////////////////
    state = RFID13.setKeys(UID, keyOld, keyA, keyB, config, data, address); 
    
    USB.print(F("1) Write new key, state: ")); 
    USB.printHex(state); 
    
    // check state
    if (state == 0) 
    { 
      USB.println(F(" --> correct key change ")); 
    } 
    else 
    { 
      USB.println(F(" --> ** ERROR: keys not changed ** ")); 
    } 
  
    /////////////////////////////////////  
    // 3.  Authenticate with the new keyA
    /////////////////////////////////////   
    state = RFID13.authenticate(UID, address , keyA); 
    USB.print(F("2) Authentication block: ")); 
    USB.printHex(state); 

    // check state
    if (state == 0) 
    { 
      USB.println(F(" --> correct authentication ")); 
    } 
    else 
    { 
      USB.println(F(" --> ** ERROR: bad authentication ** ")); 
    } 
    
    /////////////////////////////////////////////////////////////////////////
    // 4. Read the content of the new control block ('keyA' always returns 0)
    ///////////////////////////////////////////////////////////////////////// 
    state = RFID13.read(address ,data); 
    USB.print(F("3) Read trailer block:   ")); 
    USB.printHex(state); 
    USB.print(F(" | Answer: ")); 
    RFID13.print(data, 16); 
    
    /////////////////////////////////////////////////////////      
    // 5. Authenticate again with keyA and read another block
    /////////////////////////////////////////////////////////  
   
    // authenticate again, now with the new key A 
    state = RFID13.authenticate(UID,address-1, keyA); 
    USB.print(F("4.1) Authentication block: ")); 
    USB.printHex(state);
    USB.println(); 
    
    // read previous block 
    state = RFID13.read(address-1 , data); 
    USB.print(F("4.2) Read previous block, state:  ")); 
    USB.printHex(state); 
    USB.print(F(" | Answer: ")); 
    if (state == 0) 
    { 
      RFID13.print(data, 16); 
    } 
    
    //////////////////////////////////////////     
    // 6. Set old original key instead of keyA
    ////////////////////////////////////////// 
    state = RFID13.setKeys(UID, keyA, keyOld, keyB, config, data, address); 
    USB.print(F("5) Write new key, state: ")); 
    USB.printHex(state); 
    
    // check state
    if (state == 0) 
    { 
      USB.println(F(" --> correct key change to the original")); 
    } 
    else 
    { 
      USB.println(F(" --> ** ERROR: keys not changed ** ")); 
    } 

    //////////////////////////////////////////     
    // 7. Authenticate with the original key A 
    //////////////////////////////////////////     
    state = RFID13.authenticate(UID, address , keyOld); 
    USB.print(F("6) Authentication mem block  : ")); 
    USB.printHex(state);
   
    // check state 
    if (state == 0) 
    { 
      USB.print(F(" --> success to authenticate with original key. All changes undone.")); 
    } 
    else 
    { 
      USB.print(F(" --> ** ERROR: bad authentication ** ")); 
    } 
  } 
  USB.println(F("\r\n++++++++++++++++++++++++++++++++++++")); 
  delay(3000); // wait some time in each loop 
}
