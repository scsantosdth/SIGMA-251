/*  
 *  ------ [DM_14] - send packets  -------- 
 *  
 *  Explanation: This program shows how to set RTC time from Meshlium
 *  settings
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
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>. 
 *  
 *  Version:           0.1
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */
 
#include <WaspXBeeDM.h>

// Destination MAC address
//////////////////////////////////////////
char MESHLIUM_ADDRESS[] = "0013A2004098FB30"; 
//////////////////////////////////////////

// define variable
uint8_t error;



void setup()
{
  // init USB port
  USB.ON();
  USB.println(F("Setting RTC time from Meshlium settings"));
  
  // init RTC  
  RTC.ON();
  
  // init XBee
  xbeeDM.ON();
  
}


void loop()
{    
  // set RTC time
  error = xbeeDM.setRTCfromMeshlium(MESHLIUM_ADDRESS);
      
  // check flag
  if( error == 0 )
  {
    USB.print(F("SET RTC ok. "));
  }
  else 
  {
    USB.print(F("SET RTC error. "));
  }  
  
  USB.print(F("RTC Time:"));
  USB.println(RTC.getTime());
  
  delay(5000);
}

