/*   
 *  ------ [RFID1356_04] RFID/NFC Get UID -------- 
 *   
 *  Explanation: This sketch shows how to read UID's with the module. 
 *  This is the most simple example, because for getting the UID of 
 *  a tag is not necessary any authentication or key access. 
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
 *  Version:         0.2
 *  Design:          David Gascon 
 *  Implementation:  Ahmad Saad, Javier Solobera
 */ 
 
#include <WaspRFID13.h>  
 
// stores the UID (unique identifier) of a card: 
UIdentifier UID; 

// stores the answer to request: 
ATQ ans;  

// stores the result of init()
uint8_t state; 
 
 
void setup() 
{ 
  USB.ON();
  USB.println(F("RFID_04 Example"));
  
  ////////////////////////////////////////////////////////////////
  // switch on the RFID/NFC @ 13.56 MHz module, and select the socket. 
  ////////////////////////////////////////////////////////////////  
  RFID13.ON(SOCKET0); 
  USB.println(F("RFID/NFC @ 13.56 MHz module started")); 
}  
 
 
void loop() 
{ 
  USB.print(F("\n")); 
  USB.println(F("Waiting for card...")); 
   
  ///////////////////////////////////////////
  // 1. Init the RFID reader and get card UID
  ///////////////////////////////////////////
  state = RFID13.init(UID, ans); 
  
  
  ////////////////
  // 2. Print UID
  ////////////////
  if (state == 0)
  {
    USB.print(F("The UID: ")); 
    RFID13.print(UID, 4); 
    
    for (int i=0; i<2; i++)  // blink the LED fast to show not-OK
    {
      Utils.blinkLEDs(50);
    }
  }
  else
  {
    USB.println(F("Card not found")); 
  }
  delay(1000); // wait some time in each loop
}
