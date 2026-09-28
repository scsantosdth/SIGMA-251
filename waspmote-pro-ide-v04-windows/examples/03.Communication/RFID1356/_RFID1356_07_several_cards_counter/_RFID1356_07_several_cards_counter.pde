/*
 *  ------[RFID1356_07] RFID/NFC Several Cards Counter --------
 *
 *  Explanation: This sketch counts the number of times the reader has
 *  identified several cards which have been defined before. It reads
 *  a card and compares if it is inside a predefinied group of cards.
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

// little buffer for the ATQ (answer to request):
ATQ ans;

// stores the UID (Unique IDentifier) of a card:
UIdentifier UID;

// EDIT: number of possible cards:
#define nCards 3

// EDIT: the cards we have:
//   card 0: 0xFC,0x11,0x67,0x9B
//   card 1: 0x4C,0x37,0x4E,0x3C
//   card 2: 0xCE,0xC8,0x87,0x63

// EDIT: card vector (it is a pseudo-multidimensional matrix; size = nCards*4):
UIdentifier vCards [nCards] = { 
  {0xFC,0x11,0x67,0x9B},
  {0x4C,0x37,0x4E,0x3C},
  {0xCE,0xC8,0x87,0x63}
};

// store the hits in each card; size = nCards:
uint8_t hits[nCards] = {
  0, 0, 0};

// stores the index of the present card:
signed int card = -1;

void setup()
{
  USB.ON();
  USB.println(F("RFID_07 Example")); 

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
    USB.print(F("\r\nRequest error - no card found"));
  }  
  else
  { 
    USB.print(F("\r\nRequest | Answer: "));
    RFID13.print(ans, 2);

    USB.print(F(" UID: "));
    RFID13.print(UID, 4); // show the ATQ (answer to request) 

    if (state == 0)
    {
      /////////////////////////////////////////
      // 2. Search card UID amongst vCards UIDs
      /////////////////////////////////////////
      card = RFID13.searchUID(*vCards, UID, nCards); // search if the read card is inside the data base

      if (card != -1) 
      {// if so, this is one of OUR cards
        USB.print(F("\r\n  Card number "));
        USB.print(card);
        USB.print(F(" identified. Access granted."));
        hits[card]++;  // add one more hit for the read card

        Utils.blinkLEDs(100);    
      }  
      else 
      {// the read card is not one of OUR cards
        USB.print(F("\r\n  ** Card not present in the data base. Access denied."));
        for (int i=0; i<10; i++) {// blink the LED fast to show not-OK
          Utils.blinkLEDs(100);
        }
      }
    }
    else  
    {// if state is not 0, then the card was not properly read

      USB.print(F("\r\n  ** Card not properly read. Please retry. "));
      for (int i=0; i<10; i++) {// blink the LED fast to show not-OK
        Utils.blinkLEDs(100);
      }   
    }
  }

  USB.print(F("\r\n  Number of hits (cards 0, 1, 2, ..): ")); // write the accumulated hits

  RFID13.print(hits, nCards );

  delay(1000); // wait 1 second each loop
}

