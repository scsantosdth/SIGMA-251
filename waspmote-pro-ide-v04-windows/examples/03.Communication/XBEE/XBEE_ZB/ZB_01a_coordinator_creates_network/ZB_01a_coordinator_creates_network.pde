/*  
 *  ------ [ZB_01] - coordinator creates a network -------- 
 *  
 *  Explanation: This program shows how to set a new PAN ID to a 
 *  coordinator. 
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

/**************************************************
* IMPORTANT: Beware of the channel selected by the 
* coordinator because routers are not able to scan 
* both 0x19 and 0x1A channels
**************************************************/


// coordinator's 64-bit PAN ID to set
//////////////////////////////////////////////////////////////////
uint8_t  PANID[8]={ 0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88};
//////////////////////////////////////////////////////////////////


void setup()
{
  // init USB 
  USB.ON();
  USB.println(F("ZB_01 example"));

  // init XBee
  xbeeZB.ON();

  delay(1000);

  // set PANID
  xbeeZB.setPAN(PANID);
    
  // check at command flag
  if( xbeeZB.error_AT == 0 ) 
  {
    USB.println(F("PANID set OK"));
  }
  else 
  {
    USB.println(F("Error while setting PANID"));
  }

  // set channels to be scanned before creating network 
  /* Range:[0x0 to 0x3FFF]
  * Channels are scpedified as a bitmap where depending on 
  * the bit a channel is selected --> Bit (Channel): 
  *  0 (0x0B)  4 (0x0F)  8 (0x13)   12 (0x17)
  *  1 (0x0C)  5 (0x10)  9 (0x14)   13 (0x18)
  *  2 (0x0D)  6 (0x11)  10 (0x15)  
  *  3 (0x0E)  7 (0x12)	 11 (0x16)    */
  xbeeZB.setScanningChannels(0x03,0xFF);

  // save values
  xbeeZB.writeValues();

  // wait for the module to set the parameters
  delay(10000);

}


void loop()
{
  // get network parameters 
  xbeeZB.getOperating16PAN();
  xbeeZB.getOperating64PAN();
  xbeeZB.getChannel();

  USB.print(F("operating 16-bit PAN: "));
  USB.printHex(xbeeZB.operating16PAN[0]);
  USB.printHex(xbeeZB.operating16PAN[1]);
  USB.println();

  USB.print(F("operating 64-bit PAN: "));
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

  delay(3000);
}







