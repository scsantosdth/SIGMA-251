/*  
 *  ------   [DM_13] - set/get the power level     -------- 
 *  
 *  Explanation: This program shows how to set and read the power mode
 *  at which the XBee module transmits at. Parameter Range: 0 - 4(default)
 *
 *  Parameter   XBee    XBee-PRO
 *      0      -7dBm     10dBm
 *      1      -1.7dBm   12dBm
 *      2      -0.77dBm  14dBm
 *      3      -0.62dBm  16dBm
 *      4       1.42dBm  18dBm
 *
 *  REMARKS: Check your country's Restrictions
 *
 *  Copyright (C) 2014 Libelium Comunicaciones Distribuidas S.L. 
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
 
// Define the power level value
////////////////////////////////////////////////
uint8_t powerValue=4;
////////////////////////////////////////////////


void setup()
{ 
  // Init USB port
  USB.ON();
  USB.println(F("DM_13 example")); 
  USB.println(F("\n----------------------------------\n"
               "  Parameter   XBee    XBee-PRO\n"
               "----------------------------------\n"
               "      0      -7dBm     10dBm\n"
               "      1      -1.7dBm   12dBm\n"
               "      2      -0.77dBm  14dBm\n"
               "      3      -0.62dBm  16dBm\n"
               "      4       1.42dBm  18dBm\n"
               "----------------------------------"));

  delay(1000);
  
  // init XBee
  xbeeDM.ON();
  
  // get the Power Level
  xbeeDM.getPowerLevel();
  
  USB.print(F("Current Power Level:"));
  USB.println(xbeeDM.powerLevel, DEC);
  USB.println();
  delay(1000);
  
}

void loop()
{   
  
  // 1. set the Power Level to powerValue
  USB.print(F("Set the Power Level to "));
  USB.println(powerValue, DEC);
  xbeeDM.setPowerLevel(powerValue);
  
    
  // 2. get the Power Level
  USB.print(F("Read the Power Level:"));
  xbeeDM.getPowerLevel();
  USB.println(xbeeDM.powerLevel, DEC);
  USB.println();
  delay(1000);
  
  // 3. write actual value to module
  USB.println(F("Write actual value to module"));
  xbeeDM.writeValues();
  
  USB.println(F("******************************"));
  delay(10000);
  
}
