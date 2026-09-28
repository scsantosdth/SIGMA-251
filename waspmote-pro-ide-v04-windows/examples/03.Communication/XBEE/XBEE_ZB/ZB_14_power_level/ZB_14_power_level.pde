/*  
 *  ------   [ZB_14] - set/get the power level     -------- 
 *  
 *  Explanation: This program shows how to set and read the power mode
 *  at which the XBee module transmits at. Parameter Range: 0 - 4(default)
 *
 *  XBee (S2) (boost mode enabled)
 *    0 = -8 dBm
 *    1 = -4 dBm
 *    2 = -2 dBm
 *    3 =  0 dBm
 *    4 = +2 dBm
 * ----------------------------------
 *  XBee-PRO (S2)
 *    4 = 17 dBm
 * ----------------------------------
 *  XBee-PRO (S2) - International variant -
 *    4 = 17 dBm
 * ----------------------------------
 *  XBee-PRO (S2B) (boost mode enabled)
 *    4 = 18 dBm
 *    3 = 16 dBm
 *    2 = 14 dBm
 *    1 = 12 dBm
 *    0 = 10 dBm
 * ----------------------------------
 *  XBee-PRO (S2B)- International variant - (boost mode enabled)
 *    4 = 10 dBm
 *    3 =  8 dBm
 *    2 =  6 dBm
 *    1 =  4 dBm
 *    0 =  2 dBm
 * ----------------------------------
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
 
 #include <WaspXBeeZB.h>

// Define the power level value
////////////////////////////////////////////////
uint8_t powerValue=4;
////////////////////////////////////////////////

void setup()
{ 
  // Init USB port
  USB.ON();
  USB.println(F("ZB_14 example\n")); 
  USB.println(F("----------------------------------"));
  USB.println(F("\tPOWER LEVEL"));
  USB.println(F("----------------------------------\n"
                "XBee (S2) (boost mode enabled)\n"
                "0 = -8 dBm\n"
                "1 = -4 dBm\n"
                "2 = -2 dBm\n"
                "3 =  0 dBm\n"
                "4 = +2 dBm\n"
               "----------------------------------\n"
                "XBee-PRO (S2)\n"
                "4 = 17 dBm\n"
               "----------------------------------\n"
                "XBee-PRO (S2) - International variant -\n"
                "4 = 17 dBm\n"
               "----------------------------------\n"
                "XBee-PRO (S2B) (boost mode enabled)\n"
                "4 = 18 dBm\n"
                "3 = 16 dBm\n"
                "2 = 14 dBm\n"
                "1 = 12 dBm\n"
                "0 = 10 dBm\n"
               "----------------------------------\n"
                "XBee-PRO (S2B)- International variant - (boost mode enabled)\n"
                "4 = 10 dBm\n"
                "3 =  8 dBm\n"
                "2 =  6 dBm\n"
                "1 =  4 dBm\n"
                "0 =  2 dBm\n"
               "----------------------------------"));

  delay(1000);
  
  // init XBee
  xbeeZB.ON();
  
  // get the Power Level
  xbeeZB.getPowerLevel();
  
  USB.print(F("Current Power Level:"));
  USB.println(xbeeZB.powerLevel, DEC);
  USB.println();
  delay(1000);
  
}

void loop()
{   
  
  // 1. set the Power Level to powerValue
  USB.print(F("Set the Power Level to "));
  USB.println(powerValue, DEC);
  xbeeZB.setPowerLevel(powerValue);
  
    
  // 2. get the Power Level
  USB.print(F("Read the Power Level:"));
  xbeeZB.getPowerLevel();
  USB.println(xbeeZB.powerLevel, DEC);
  USB.println();
  delay(1000);
  
  // 3. write actual value to module
  USB.println(F("Write actual value to module"));
  xbeeZB.writeValues();
  
  USB.println(F("******************************"));
  delay(10000);
  
}
