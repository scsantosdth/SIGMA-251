/*
 *  ------Waspmote RTC Complete Example--------
 *
 *  Explanation: This example shows the RTC complete example,
 *  setting/reading time, setting/reading alarms and reading
 *  temperature.
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
 *  Version:           0.3
 *  Design:            David Gascón 
 *  Implementation:    Marcos Yarza
 */

void setup(){
  
  // Setup for Serial port over USB
  USB.ON();
  USB.println(F("RTC_6 example"));

  // Powers RTC up, init I2C bus and read initial values
  USB.println(F("Init RTC"));
  RTC.ON();       
  
}

void loop()
{
  
  USB.println(F("\n+++++++++++++++++ Setting Alarm1 ++++++++++++++++++++++++"));
  
  // Setting time [yy:mm:dd:dow:hh:mm:ss]
  RTC.setTime("09:10:20:03:17:35:30");
  
  // Getting time
  USB.print(F("Time [Day of week, YY/MM/DD, hh:mm:ss]: "));
  USB.println(RTC.getTime());
  
  // Setting Alarm1
  RTC.setAlarm1("20:17:35:45",RTC_ABSOLUTE,RTC_ALM1_MODE2);
  
  // Getting Alarm1
  USB.print(F("Alarm1: "));
  USB.println(RTC.getAlarm1());  
  
  // Setting Waspmote to Low-Power Consumption Mode  
  USB.println(F("Waspmote goes to sleep..."));
  PWR.sleep(ALL_OFF);  
  USB.println(F("Waspmote wakes up!"));
  
  // After setting Waspmote to power-down, UART is closed, so it
  // is necessary to open it again
  USB.ON();
  
  // Waspmote wakes up at '17:35:15'
  if( intFlag & RTC_INT )
  {
    intFlag &= ~(RTC_INT); // Clear flag
    USB.println(F("-------------------------"));
    USB.println(F("RTC INT Captured"));
    USB.println(F("-------------------------"));
    Utils.blinkLEDs(1000); // Blinking LEDs
    Utils.blinkLEDs(1000); // Blinking LEDs
  }    
  
  
  
  USB.println(F("\n+++++++++++++++++ Setting Alarm2 ++++++++++++++++++++++++"));
  
  // Setting RTC on
  RTC.ON();
  
  // Getting time
  USB.print(F("Time [Day of week, YY/MM/DD, hh:mm:ss]: "));
  USB.println(RTC.getTime());
  
  // Setting RTC Alarm2
  RTC.setAlarm2("20:17:36",RTC_ABSOLUTE,RTC_ALM2_MODE2);
  
  // Getting Alarm2
  USB.print(F("Alarm2: "));  
  USB.println(RTC.getAlarm2());
  
  // Setting Waspmote to Low-Power Consumption Mode
  USB.println(F("Waspmote goes to sleep..."));
  PWR.sleep(ALL_OFF);  
  USB.println(F("Waspmote wakes up!"));
  
  // After setting Waspmote to power-down, UART is closed, so it
  // is necessary to open it again
  USB.ON();
  
  // Waspmote wakes up at '17:36'
  if( intFlag & RTC_INT )
  {
    intFlag &= ~(RTC_INT); // Clear flag
    USB.println(F("-------------------------"));
    USB.println(F("RTC INT Captured"));
    USB.println(F("-------------------------"));
    Utils.blinkLEDs(1000); // Blinking LEDs
    Utils.blinkLEDs(1000); // Blinking LEDs
  }    
  
  // Getting Temperature
  RTC.ON();
  USB.print(F("\nRTC Temperature: "));
  USB.println(RTC.getTemperature(),DEC);
    
  delay(5000);
  
  
}
