/*  
 *  ------ [RTC_4] Setting the alarms in RTC example -------- 
 *  
 *  Explanation: This example shows how to set time alarms in
 *  the Waspmote RTC using different offset modes: RTC_ABSOLUTE 
 *  and RTC_OFFSET
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
  // Setup for Serial port over USB
  USB.ON();
  USB.println(F("RTC_4 example"));

  // Powers RTC up, init I2C bus and read initial values
  USB.println(F("Init RTC"));
  RTC.ON(); 
}

void loop()
{
  USB.println(F("\n++++++++++++++ Alarm 1 - ABSOLUTE MODE ++++++++++++++++"));
  
  // Setting time
  RTC.ON(); 
  RTC.setTime("12:07:20:06:11:25:00");
  USB.print(F("Time: "));
  USB.println(RTC.getTime());
  
  ///////////////////////////////////////////
  // Alarm 1 - ABSOLUTE MODE - Alarm mode 2
  ///////////////////////////////////////////
  
  // Setting alarm 1 in absolute mode:
  // 20:11:25:15 => Date 20
  // time 11:25:15 
  // Alarm 1 is set 15 seconds later
  RTC.setAlarm1("20:11:25:15",RTC_ABSOLUTE,RTC_ALM1_MODE2);
  
  // Checking Alarm 1  
  USB.println(F("Alarm1 is set to ABSOLUTE mode: "));
  USB.println(RTC.getAlarm1());
  
  // Setting Waspmote to Low-Power Consumption Mode
  USB.println(F("Waspmote goes into sleep mode until the RTC alarm causes an interrupt"));
  PWR.sleep(ALL_OFF);
  
  // After setting Waspmote to power-down, UART is closed, so it
  // is necessary to open it again
  USB.ON();
  RTC.ON(); 
  USB.println(F("\r\nWaspmote wake up!!"));
  USB.print(F("Time: "));
  USB.println(RTC.getTime());
  
  // Waspmote wakes up at '11:25:15'
  if( intFlag & RTC_INT )
  {
    intFlag &= ~(RTC_INT); // Clear flag
    Utils.blinkLEDs(1000); // Blinking LEDs
    Utils.blinkLEDs(1000); // Blinking LEDs
  }
  
  USB.println();

  
  
  ///////////////////////////////////////////
  // Alarm 1 - OFFSET MODE - Alarm mode 2
  ///////////////////////////////////////////
    
  USB.println(F("\n++++++++++++++ Alarm 1 - OFFSET MODE ++++++++++++++++"));
  
  // Setting alarm 1 in offset mode:
  // Alarm 1 is set 15 seconds later
  RTC.setAlarm1("00:00:00:15",RTC_OFFSET,RTC_ALM1_MODE2);
  
  // Checking Alarm 1  
  USB.println(F("Alarm1 is set to OFFSET mode: "));
  USB.println(RTC.getAlarm1());
  
  // Setting Waspmote to Low-Power Consumption Mode
  USB.println(F("Waspmote goes into sleep mode until the RTC alarm causes an interrupt"));
  PWR.sleep(ALL_OFF);
  
  // After setting Waspmote to power-down, UART is closed, so it
  // is necessary to open it again
  USB.ON();
  USB.println(F("\r\nWaspmote wake up!!"));
  USB.print(F("Time: "));
  RTC.ON(); 
  USB.println(RTC.getTime());
  
  // Waspmote wakes up at '11:25:30'
  if( intFlag & RTC_INT )
  {
    intFlag &= ~(RTC_INT); // Clear flag
    Utils.blinkLEDs(1000); // Blinking LEDs
    Utils.blinkLEDs(1000); // Blinking LEDs
  }  
  
  USB.println();
  delay(5000);
  
  
}

