/*
 *  ------ [RFID1356_06] RFID/NFC Single Card Counter --------
 *
 *  Explanation:This sketch counts the number of times a particular
 *  card has been read. It reads a card and compares if it is the
 *  previously defined one.
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
 *  Version:                0.2
 *  Design:                 David Gascón
 *  Implementation:         Ahmad Saad, Javier Solobera 
 */


#include <WaspRFID13.h>  

// stores the status of the executed command:
uint8_t state;

// little buffer for the ATQ-A (answer to request):
ATQ ans;

// stores the UID (unique identifier) of a card:
UIdentifier UID;

// EDIT: UID of the card that we have:
UIdentifier myCard = {
  0xFA, 0xC8, 0x2E, 0x40};

// for storing the hits:
int hits = 0;


void setup()
{
  USB.ON();
  USB.println(F("RFID_06 Example"));

  //Swithcs ON the module and asign the socket
  RFID13.ON(SOCKET0); 
  USB.println(F("RFID/NFC @ 13.56 MHz module started")); 
}



void loop()
{
  USB.print(F("\r\n++++++++++++++++++++++++++++++++++++"));

  //////////////////////////
  // 1. Init the RFID reader 
  //////////////////////////
  state = RFID13.init(UID, ans);

  if (state == 1)
  {
    USB.print(F("\r\n Request error - Card not found"));
  }  
  else 
  {
    USB.print(F("\r\n Request | Answer: "));
    RFID13.print(ans, 2); // show the ATQ (answer to request) 

    USB.print(F(" UID: "));   
    RFID13.print(UID, 4); // show the UID 

    if (state == 0)  // if so, we can be sure that we read correctly one UID
    {
      /////////////////////////////////////////////////////
      // 2. Compare UID from card with myCard to count hits
      /////////////////////////////////////////////////////
      if (RFID13.equalUIDs(myCard, UID) == 0) 
      { // if so, this is OUR card
        USB.print(F("\r\n  Card identified. Access granted. "));
        hits++; // increment the hit counter

        Utils.blinkLEDs(100);
      } 
      else 
      { // the read card is not OUR card
        USB.print(F("\r\n  ** Card not valid. Access denied. "));
        for (int i=0; i<10; i++) // blink the LED fast to show not-OK
        {
          Utils.blinkLEDs(100);
        }
      }
    } 
    else 
    {  // if state is not 0, then the card was not properly read   
      USB.print(F("\r\n  ** Card not properly read. Please retry. "));

      for (int i=0; i<10; i++) // blink the LED fast to show not-OK
      {
        Utils.blinkLEDs(100);
      }    
    }
  }

  USB.print(F("\r\n  Number of hits: ")); // show the accumulated hits
  USB.println(hits);

  delay(500); // wait a half second in each loop
}
