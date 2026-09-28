/*  
 *  ------[RFID1356_03] RFID Bus Example --------
 *
 *  Explanation: This sketch shows how Libelium's RFID/NFC 13.56 can be
 *  used for ticketing solutions, in this case we use the RFID/NFC to
 *  simulate a RFID access control inside a bus.
 *  First, we assignate a quantity of money to the card (with a secret
 *  password of course). After that, each trip will substract the fare.
 *  This can be also used for a gym or a parking, for example.
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
 *  Implementation:         Ahmad Saad, Javier Solobera 
 */


#include <WaspRFID13.h>

// stores the status of the executed command:
uint8_t state_init,state_auth,state_write,state_read;

// data buffer:
blockData data;

// little buffer for the ATQ-A (answer to request):
ATQ ans;

// stores the UID (unique identifier) of a card:
UIdentifier UID; 

// stores the key or password:
uint8_t keyAccess[] = {
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};

// EDIT: initial credit to put in the card (in cents!)
// it is also possible to put "credits"
int initialCredit = 800; // this is 8 euros (8*100 = 800)

// EDIT: the price per trip (in cents !)
// it is also possible to put 1 (if they are credits)
int tripFare = 105; // this is 1.05 euros (no problems with floats now)

// signal if the first credit write was done
boolean firstDone = false; 

// stores the money inside the card
int credit = 0;
int credit_before = 0;

// for changing from one format to the other
char text[16]; 

// signals if all the process was successfuly completed
boolean completed = false; 


void setup()
{
  USB.ON();
  USB.println(F("RFID_03 Example"));

  ///////////////////////////////////////////////////////////////////
  // switch on the RFID/NFC @ 13.56 MHz module, and select the socket
  ///////////////////////////////////////////////////////////////////
  RFID13.ON(SOCKET0);
  USB.println(F("RFID/NFC @ 13.56 MHz module started")); 
}


void loop()
{
  //////////////////////////////
  // 1. Init the RFID/NFC reader
  //////////////////////////////
  state_init = RFID13.init(UID, ans);

  //////////////////////////////////////////////////////////////////
  // 2. If there is a card initialize credit if it has not been done
  // otherwise read block to get credit of the card
  //////////////////////////////////////////////////////////////////
  if ( state_init == 0 && firstDone == false)
  {    
    // authenticate the key A of sector 1
    state_auth = RFID13.authenticate(UID, 1, keyAccess);

    if (state_auth == 0)  
    {
      // if passed authentication in block 1, we are able to set the inital credit
      sprintf(text, "%d", initialCredit);
      RFID13.string2vector(text, data);

      // write data in block number 1, and check afterwards
      state_write = RFID13.writeAndCheck(data, 1);

      if (state_write == 0)
      {
        for (int i=0; i<sizeof(text); i++) // clear this variable
        {
          text[i] = '\0';
        } 

        // check the 16 bytes in block 1
        state_read = RFID13.read(1, data);
      }
      // if the read command was successful, we show the data (16 bytes)
      if (state_read == 0 && state_init == 0 && state_auth == 0 && state_write == 0)  
      {
        USB.print(F("\r\n  Initial credit set:  "));
        for (int i=0; i<16; i++)
        {
          if (data[i] == '\0') // to avoid showing voids
            break;
          USB.print(data[i], BYTE); // print the 16 bits of block number 1, now in ASCII code
        }
        USB.println();
        firstDone = true;
        state_init = 1;

        delay(1000);
      }
    }
    else
    {
      USB.println(F("\r\n  Could not authenticate card"));
    }
    // end of "adding credit part"
  }
  if ( state_init == 0 && firstDone == true )
  {
    // authenticate the key A of sector 1
    state_auth = RFID13.authenticate(UID, 1, keyAccess);

    if (state_auth == 0)
    {
      ///////////////////////////////////////////////////
      // If passed authentication in block 1, we will be 
      // able to read the data in this block (the credit)
      ///////////////////////////////////////////////////
      state_read = RFID13.read(1, data);

      //if read was correctly done we get credit
      //and follow the process
      if (state_read == 0)
      {
        // convert the card data to int
        credit = RFID13.vector2int(data); 

        // check if there is enough credit
        if (credit >= tripFare)
        {
          sprintf(text, "%d", credit - tripFare);
          RFID13.string2vector(text, data);

          // clear this variable
          for (int i=0; i<sizeof(text); i++)  
          {
            text[i] = '\0';
          }

          // write data in block number 1, and check afterwards
          state_write = RFID13.writeAndCheck(data, 1);

          if (state_write == 0)
          {          
            // only substract if success happened
            credit_before = credit;

            // update 'completed' variable
            completed = true;
          }         
        }
        else
        {
          USB.println(F("\r\n  ** Not enough credit"));
          Utils.blinkRedLED(200,5);
        }
      }
    }
    else
    {
      USB.println(F("\r\n  Could not authenticate card"));
    }
  }
  if (completed == true)
  {
    // get actual credit
    USB.println();
    USB.print(F("  Credit before the trip: "));
    USB.println(credit_before,DEC);

    // if the read command was successful, we show the data (16 bytes) 
    USB.print(F("  Credit after the trip:  "));
    USB.println(credit_before-tripFare,DEC);

    USB.print(F("  ACCESS GRANTED !!"));
    USB.println();

    // blink the LED slow to show OK
    Utils.blinkGreenLED(100,5);

    completed = false;
  }
}
