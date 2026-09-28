/*  
 *  ------   [802_14] - set/get the power level     -------- 
 *  
 *  Explanation: This program shows how to set and read the power mode
 *  at which the XBee module transmits at. Parameter Range: 0 - 4(default)
 *
 *  Parameter   XBee    XBee-PRO
 *      0      -10dBm    10dBm
 *      1      -6dBm     12dBm
 *      2      -4dBm     14dBm
 *      3      -2dBm     16dBm
 *      4       0dBm     18dBm
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
 
 #include <WaspXBee802.h>

// Define the power level value
////////////////////////////////////////////////
uint8_t powerValue=4;
////////////////////////////////////////////////

void setup()
{ 
  // Init USB port
  USB.ON();
  USB.println(F("802_15 example\n")); 
  USB.println(F("----------------------------------"));
  USB.println(F("\tPOWER LEVEL"));
  USB.println(F("----------------------------------\n"
               "  Parameter   XBee    XBee-PRO\n"
               "----------------------------------\n"
               "      0      -10dBm    10dBm\n"
               "      1      -6dBm     12dBm\n"
               "      2      -4dBm     14dBm\n"
               "      3      -2dBm     16dBm\n"
               "      4       0dBm     18dBm\n"
               "----------------------------------"));

  delay(1000);
  
  // init XBee
  xbee802.ON();
  
  // get the Power Level
  xbee802.getPowerLevel();
  
  USB.print(F("Current Power Level:"));
  USB.println(xbee802.powerLevel, DEC);
  USB.println();
  delay(1000);
  
}

void loop()
{   
  
  // 1. set the Power Level to powerValue
  USB.print(F("Set the Power Level to "));
  USB.println(powerValue, DEC);
  xbee802.setPowerLevel(powerValue);
  
    
  // 2. get the Power Level
  USB.print(F("Read the Power Level:"));
  xbee802.getPowerLevel();
  USB.println(xbee802.powerLevel, DEC);
  USB.println();
  delay(1000);
  
  // 3. write actual value to module
  USB.println(F("Write actual value to module"));
  xbee802.writeValues();
  
  USB.println(F("******************************"));
  delay(10000);
  
}
