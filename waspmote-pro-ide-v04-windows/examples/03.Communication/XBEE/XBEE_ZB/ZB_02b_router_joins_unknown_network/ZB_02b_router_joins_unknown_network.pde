/*  
 *  ------ [ZB_02b] - router joins an unknown coordinator -------- 
 *  
 *  Explanation: This program shows how to search for a new coordinator
 *  when network parameters are unknown. It is necessary to scan a new 
 *  coordinator setting different channels to be scanned
 *  
 *  Copyright (C) 2012 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Version:           0.1 
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */

#include <WaspXBeeZB.h>

// PAN ID to set in order to search a new coordinator
uint8_t  PANID[8]={ 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};


void setup()
{  
  // init USB port
  USB.ON();
  USB.println(F("ZB_02b example"));

  // init XBee
  xbeeZB.ON();

  delay(1000);


  /////////////////////////////////////
  // 1. Dissociation process
  /////////////////////////////////////
  
  // 1.1. set PANID: 0x0000000000000000 
  xbeeZB.setPAN(PANID);
  
  // 1.2. check AT command flag
  if( xbeeZB.error_AT == 0 ) 
  {
    USB.println(F("PANID set OK"));
  }
  else 
  {
    USB.println(F("Error while setting PANID")); 
  }

  // 1.3. set all possible channels to scan 
  // channels from 0x0B to 0x18 (0x19 and 0x1A are excluded)
  /* Range:[0x0 to 0x3FFF]
  * Channels are scpedified as a bitmap where depending on 
  * the bit a channel is selected --> Bit (Channel): 
  *  0 (0x0B)  4 (0x0F)  8 (0x13)   12 (0x17)
  *  1 (0x0C)  5 (0x10)  9 (0x14)   13 (0x18)
  *  2 (0x0D)  6 (0x11)  10 (0x15)  
  *  3 (0x0E)  7 (0x12)	 11 (0x16)    */
  xbeeZB.setScanningChannels(0x3F, 0xFF);

  // 1.4. check AT command flag  
  if( xbeeZB.error_AT == 0 )
  {
    USB.println(F("scanning channels set OK"));
  }
  else 
  {
    USB.println(F("Error while setting scanning channels")); 
  }
  
  // 1.5. set channel verification JV=1 in order to make the 
  // XBee module to scan new coordinator
  xbeeZB.setChannelVerification(1);
  
  // 1.6. check AT command flag    
  if( xbeeZB.error_AT == 0 )
  {
    USB.println(F("verification channel set OK"));
  }
  else 
  {
    USB.println(F("Error while setting verification channel")); 
  }

  // 1.7. write values to XBee memory
  xbeeZB.writeValues();

  // 1.8 reboot XBee module
  xbeeZB.OFF();
  delay(3000); 
  xbeeZB.ON();

  delay(3000);

  /////////////////////////////////////
  // 2. Wait for Association 
  /////////////////////////////////////
  
  // 2.1. wait for association indication
  xbeeZB.getAssociationIndication();
 
  while( xbeeZB.associationIndication != 0 )
  { 
    delay(2000);
    
    // get operating 64-b PAN ID
    xbeeZB.getOperating64PAN();

    USB.print(F("operating 64-b PAN ID: "));
    USB.printHex(xbeeZB.operating64PAN[0]);
    USB.printHex(xbeeZB.operating64PAN[1]);
    USB.printHex(xbeeZB.operating64PAN[2]);
    USB.printHex(xbeeZB.operating64PAN[3]);
    USB.printHex(xbeeZB.operating64PAN[4]);
    USB.printHex(xbeeZB.operating64PAN[5]);
    USB.printHex(xbeeZB.operating64PAN[6]);
    USB.printHex(xbeeZB.operating64PAN[7]);
    USB.println();     
    
    xbeeZB.getAssociationIndication();
  }


  USB.println(F("\n\nJoined a coordinator!"));

  // 2.2. When XBee is associated print all network 
  // parameters unset channel verification JV=0
  xbeeZB.setChannelVerification(0);
  xbeeZB.writeValues();

  // 2.3. get network parameters 
  xbeeZB.getOperating16PAN();
  xbeeZB.getOperating64PAN();
  xbeeZB.getChannel();

  USB.print(F("operating 16-b PAN ID: "));
  USB.printHex(xbeeZB.operating16PAN[0]);
  USB.printHex(xbeeZB.operating16PAN[1]);
  USB.println();

  USB.print(F("operating 64-b PAN ID: "));
  USB.printHex(xbeeZB.operating64PAN[0]);
  USB.printHex(xbeeZB.operating64PAN[1]);
  USB.printHex(xbeeZB.operating64PAN[2]);
  USB.printHex(xbeeZB.operating64PAN[3]);
  USB.printHex(xbeeZB.operating64PAN[4]);
  USB.printHex(xbeeZB.operating64PAN[5]);
  USB.printHex(xbeeZB.operating64PAN[6]);
  USB.printHex(xbeeZB.operating64PAN[7]);
  USB.println();

  USB.print(F("channel: "));
  USB.printHex(xbeeZB.channel);
  USB.println();

}


void loop()
{

  // Do nothing 
  delay(3000);
}








