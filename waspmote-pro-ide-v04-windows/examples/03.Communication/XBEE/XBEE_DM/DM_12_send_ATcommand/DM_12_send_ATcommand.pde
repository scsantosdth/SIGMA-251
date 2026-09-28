/*  
 *  ------ [DM_12] - send AT command to XBee module -------- 
 *  
 *  Explanation: This program shows how to send AT commands to the XBee
 *  modules
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
 
#include <WaspXBeeDM.h>


void setup()
{
  // init USB port
  USB.ON();
  USB.println(F("DM_12 example"));

  //////////////////////////
  // 1. init XBee
  //////////////////////////
  xbeeDM.ON();
  
  
  //////////////////////////
  // 2. Request channel
  //////////////////////////  
  if(!xbeeDM.sendCommandAT("CH#")) 
  {
    USB.print(F("Channel: "));
    USB.printHex(xbeeDM.commandAT[0]);
    USB.println();
  }
  else
  {
    USB.println(F("at error"));
  }
  
  
  //////////////////////////
  // 3. Request PAN ID
  //////////////////////////  
  if(!xbeeDM.sendCommandAT("ID#")) 
  {
    USB.print(F("PANID: "));
    USB.printHex(xbeeDM.commandAT[0]);
    USB.printHex(xbeeDM.commandAT[1]);
    USB.println();
  }
  else
  {
    USB.println(F("at error"));
  }
  
  
  //////////////////////////
  // 4. Request encryption mode
  //////////////////////////  
  if(!xbeeDM.sendCommandAT("EE#")) 
  {
    USB.print(F("encryption mode: "));
    USB.printHex(xbeeDM.commandAT[0]);
    USB.println();
  }
  else
  {
    USB.println(F("at error"));
  }
  
}


void loop()
{
  // Do nothing
  delay(5000);
}



