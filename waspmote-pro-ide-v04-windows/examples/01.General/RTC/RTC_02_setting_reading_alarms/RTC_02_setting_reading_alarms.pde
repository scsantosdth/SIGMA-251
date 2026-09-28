/*  
 *  ------ [RTC_2] Setting and reading alarms of RTC -------- 
 *  
 *  Explanation: This example shows how to set and read alarms using
 *  the Waspmote RTC, the alarm will cause an interruption.
 *  
 *  Copyright (C) 2013 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Implementation:    Marcos Yarza
 */

void setup(){
  
  // Setup for Serial port over USB
  USB.ON();
  USB.println(F("RTC_2 example"));

  // Powers RTC up, init I2C bus and read initial values
  USB.println(F("Init RTC"));
  RTC.ON();       
  
  // Setting time
  RTC.setTime("12:07:18:04:13:35:00");
  USB.print(F("RTC was set to this time: "));
  USB.println(RTC.getTime());
}

void loop(){
  
  // 
  USB.println(F("---------------------------"));

  // Setting and getting Alarm1
  RTC.setAlarm1("20:17:36:00",RTC_ABSOLUTE,RTC_ALM1_MODE2);
  USB.println("Check Alarm number 1 was setup with Mode2: ");
  USB.println(RTC.getAlarm1());
  USB.println();
  
  // Setting and getting Alarm1
  RTC.setAlarm1(0,0,0,10,RTC_OFFSET,RTC_ALM1_MODE2);
  USB.println("Check Alarm number 1 was setup with Mode2: ");
  USB.println(RTC.getAlarm1());
  USB.println();
  
  // Setting and getting Alarm2
  RTC.setAlarm2("20:17:37",RTC_ABSOLUTE,RTC_ALM2_MODE2);
  USB.println("Check Alarm number 2 was setup with Mode2: ");  
  USB.println(RTC.getAlarm2());
  USB.println();
  
  // Setting and getting Alarm2
  RTC.setAlarm2(0,0,10,RTC_OFFSET,RTC_ALM2_MODE2);
  USB.println("Check Alarm number 2 was setup with Mode2: ");  
  USB.println(RTC.getAlarm2());
  USB.println();
    
  delay(5000);
  
  
}

