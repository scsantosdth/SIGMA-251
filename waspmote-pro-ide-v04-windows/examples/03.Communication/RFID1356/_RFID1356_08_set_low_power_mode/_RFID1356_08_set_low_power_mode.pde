/*  
 *  ------ [RFID1356_08] RFID set low power state  -------- 
 *  
 *  Explanation: This program shows how to set low power mode in RFID1356 module
 *       
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
 *  Implementation:    Yuri Carmona, Luis Miguel Marti
 */

#include <WaspRFID13.h>


void setup()
{  
  // init USB port
  USB.ON();
  USB.println(F("RFID_08 Example"));  


  // switch on the RFID module
  RFID13.ON(SOCKET0); 
    
}


void loop()
{
  ////////////////////////////////////
  // 1. Set sleep mode
  ////////////////////////////////////
    
  // 1.1. put RFID to sleep
  RFID13.powerDown();  
  USB.println(F("1. RFID in sleep mode"));
  
  // 1.2. set red LED during sleep time 
  USB.println(F("RED LED switched off"));
  Utils.setLED(LED0, LED_OFF);
  
  // 1.3. wait 20 seconds in sleep mode  
  USB.println(F("While RFID is in sleep mode --> wait for 20 seconds...\n"));
  delay(20000);  


  ////////////////////////////////////
  // 2. Wake up the RFID module
  ////////////////////////////////////
  
  // 2.1. wake RFID up
  RFID13.wakeUp();  
  USB.println(F("2. RFID wakes-up"));  
  
  // 2.2. switch LED off when leaving sleep mode
  USB.println(F("RED LED switched on"));
  Utils.setLED(LED0, LED_ON);
 
  // 2.3. wait 5 seconds
  USB.println(F("While RFID is in normal mode --> wait for 5 seconds...\n"));
  delay(5000);
}
