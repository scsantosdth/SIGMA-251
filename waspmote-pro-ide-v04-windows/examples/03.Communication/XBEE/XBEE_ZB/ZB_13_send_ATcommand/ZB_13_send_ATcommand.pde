/*  
 *  ------ [ZB_13] - send AT command -------- 
 *  
 *  Explanation: This example shows how to send AT commmands to the 
 *  XBee modules
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


void setup()
{
  // init USB port
  USB.ON();
  USB.println("ZB_13 example");


  //////////////////////////
  // 1. init XBee
  //////////////////////////
  xbeeZB.ON();  
  
  delay(3000);
  
  
  //////////////////////////
  // 2. check XBee's network parameters
  //////////////////////////
  checkNetworkParams();
  
 
  USB.println(F("-----------------------------"));
 
  
  //////////////////////////
  // 3. Request channel
  //////////////////////////  
  if(!xbeeZB.sendCommandAT("CH#")) 
  {
    USB.print(F("Channel: "));
    USB.printHex(xbeeZB.commandAT[0]);
    USB.println();
  }
  else 
  {
    USB.println("at error");
  }
  
  
  //////////////////////////
  // 4. Request operating 16b pan id
  ////////////////////////// 
  if(!xbeeZB.sendCommandAT("OI#")) 
  {
    USB.print(F("Operating 16-b PANID: "));
    USB.printHex(xbeeZB.commandAT[0]);
    USB.printHex(xbeeZB.commandAT[1]);
    USB.println();
  }
  else 
  {
    USB.println("at error");
  }
  
  
  //////////////////////////
  // 4. Request operating 64b pan id
  ////////////////////////// 
  if(!xbeeZB.sendCommandAT("OP#")) 
  {
    USB.print(F("Operating 64-b PANID: "));
    USB.printHex(xbeeZB.commandAT[0]);
    USB.printHex(xbeeZB.commandAT[1]);
    USB.printHex(xbeeZB.commandAT[2]);
    USB.printHex(xbeeZB.commandAT[3]);
    USB.printHex(xbeeZB.commandAT[4]);
    USB.printHex(xbeeZB.commandAT[5]);
    USB.printHex(xbeeZB.commandAT[6]);
    USB.printHex(xbeeZB.commandAT[7]);
    USB.println();
  }
  else
  {
    USB.println("at error");
  }
  
  //////////////////////////
  // 4. Request encryption mode
  //////////////////////////  
  if(!xbeeZB.sendCommandAT("EE#")) 
  {
    USB.print(F("encryption mode: "));
    USB.printHex(xbeeZB.commandAT[0]);
    USB.println();
  }
  else
  {
    USB.println("at error");
  }

  USB.println(F("-----------------------------"));
}

void loop()
{
  // Do nothing
  delay(5000);
}







/*******************************************
 *
 *  checkNetworkParams - Check operating
 *  network parameters in the XBee module
 *
 *******************************************/
void checkNetworkParams()
{
  // 1. get operating 64-b PAN ID
  xbeeZB.getOperating64PAN();

  // 2. wait for association indication
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

  USB.println(F("\nJoined a network!"));


}




