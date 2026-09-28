/*  
 *  ------ [868_07] - set low power state in XBee module  -------- 
 *  
 *  Explanation: This program shows how to set different a low power 
 *  states in XBee-868 modules
 *       
 *   SM=0: Normal Mode
 *   SM=1: Asynchronous Pin Sleep Mode
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

#include <WaspXBee868.h>


void setup()
{  
  // init USB port
  USB.ON();
  USB.println(F("Sleep mode example"));  


  // switch on the XBee module
  xbee868.ON(); 
  
  // enable awake mode before managing the module
  // this is done to make sure the module is not in
  // sleep mode when we try to manage it
  xbee868.wake();    
  
  // set sleep mode
  xbee868.setSleepMode(1); 
  
  // check flag
  if( xbee868.error_AT == 0 )
  {
    USB.println(F("sleep mode set"));
  }
  else
  {
    USB.println(F("Error while setting sleep mode")); 
  }
  USB.println();
  
}


void loop()
{
  ////////////////////////////////////
  // 1. Set sleep mode
  ////////////////////////////////////
    
  // 1.1. put XBee to sleep
  xbee868.sleep();  
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
  xbee868.wake();  
  USB.println(F("2. XBee wakes-up"));  
  
  // 2.2. switch LED off when leaving sleep mode
  USB.println(F("RED LED switched off"));
  Utils.setLED(LED0, LED_OFF);
 
  // 2.3. wait 5 seconds
  USB.println(F("While XBee is in normal mode --> wait for 5 seconds...\n"));
  delay(5000);
}

