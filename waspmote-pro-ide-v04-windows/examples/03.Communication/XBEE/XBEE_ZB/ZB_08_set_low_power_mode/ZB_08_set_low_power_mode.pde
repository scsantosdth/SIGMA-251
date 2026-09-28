/*  
 *  ------ [ZB_08] - set low power state in XBee module  -------- 
 *  
 *  Explanation: This program shows how to set different a low power 
 *  states in XBee-ZigBee End Devices modules
 *       
 *   SM=1: Pin Sleep Mode
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
 *  Version:           0.2
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */

#include <WaspXBeeZB.h>


void setup()
{  
  // init USB port
  USB.ON();
  USB.println(F("ZB_08 example"));
  
  // init XBee
  xbeeZB.ON();  
  
  ////////////////////////////////////
  // 1. Set sleep mode
  ////////////////////////////////////
 
  // 1.1. it is supposed that XBee SM=1 (Pin hibernate)
  xbeeZB.wake();
    
  // 1.2. set sleep mode
  xbeeZB.setSleepMode(1); 
  
  // check flag
  if( xbeeZB.error_AT == 0 )
  {
    USB.println(F("sleep mode set"));
  }
  else
  {
    USB.println(F("Error while setting sleep mode")); 
  }
  
  
  // 1.3. set sleep mode
  xbeeZB.getSleepMode(); 
  USB.print("sleep mode:");
  USB.println(xbeeZB.sleepMode,HEX);
  
  // 1.4. wake XBee up
  xbeeZB.wake();
  
  // 1.5. get firmware version
  xbeeZB.getSoftVersion();
  USB.print(F("XBee module firmware version:"));
  USB.print(xbeeZB.softVersion[0],HEX);
  USB.println(xbeeZB.softVersion[1],HEX);
  
  // 1.6. check firmware version
  if( xbeeZB.softVersion[0] == 0x29 )
  {
    USB.println(F("XBee module is an End Device"));    
  }
  else 
  {
    USB.println(F("\n*** WARNING ***\n--> XBee module is NOT an End Device\n--> Impossible to set low power modes"));
    while(1){};
  } 
      
}



void loop()
{
  ////////////////////////////////////
  // 1. Set sleep mode
  ////////////////////////////////////
    
  // 1.1. put XBee to sleep
  xbeeZB.sleep();  
  USB.println(F("1. XBee in sleep mode"));
  
  // 1.2. set red LED during sleep time 
  USB.println(F("RED LED switched on"));
  Utils.setLED(LED0, LED_ON);
  
  // 1.3. wait 20 seconds in sleep mode  
  USB.println(F("While XBee is in sleep mode --> wait for 20 seconds...\n"));
  delay(20000);  


  ////////////////////////////////////
  // 2. Wake up the XBee module
  ////////////////////////////////////
  
  // 2.1. wake XBee up
  xbeeZB.wake();  
  USB.println(F("2. XBee wakes-up"));  
  
  // 2.2. switch LED off when leaving sleep mode
  USB.println(F("RED LED switched off"));
  Utils.setLED(LED0, LED_OFF);
 
  // 2.3. wait 5 seconds
  USB.println(F("While XBee is in normal mode --> wait for 5 seconds...\n"));
  delay(5000);
  
  /* In the case of using the XBee module after waking up
  it is necessary to wait for the module to join the network
  this may last for several seconds depending on each case*/
}





