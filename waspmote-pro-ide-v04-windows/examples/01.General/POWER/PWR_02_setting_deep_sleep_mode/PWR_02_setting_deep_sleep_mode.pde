/*  
 *  ------ [PWR_2] Setting Deep Sleep Mode -------- 
 *  
 *  Explanation: This example shows how to set Waspmote in a low-power
 *  consumption mode waking up using the RTC
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

void setup()
{
  USB.ON();
  USB.println(F("PWR_2 example"));

  // Init RTC
  RTC.ON();
  
  // Setting time [yy:mm:dd:dow:hh:mm:ss]
  RTC.setTime("12:07:17:02:17:25:00");

}

void loop()
{
  USB.println(F("enter deep sleep"));

  // Go to sleep disconnecting all the switches and modules
  // After 10 seconds, Waspmote wakes up thanks to the RTC Alarm
  PWR.deepSleep("00:00:00:10",RTC_OFFSET,RTC_ALM1_MODE1,ALL_OFF);

  USB.ON();
  USB.println(F("\nwake up"));

  // After wake up I check intFlag and blink LEDs
  if( intFlag & RTC_INT )
  {    
    USB.println(F("---------------------"));
    USB.println(F("RTC INT captured"));
    USB.println(F("---------------------"));
    Utils.blinkLEDs(300);
    Utils.blinkLEDs(300);
    Utils.blinkLEDs(300);
    intFlag &= ~(RTC_INT);
  }

}


