/*  
 *  ------ [RTC_9] Get triggered alarm information  -------- 
 *  
 *  Explanation: This example shows how to identify which one of the 
 *  RTC alarms was generated:
 *    1: Alarm1 triggered
 *    2: Alarm2 triggered
 *    3: Both alarms triggered
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
 *  Design:            David Gascon 
 *  Implementation:    Luismi Marti
 */


void setup()
{
  // Setup for Serial port over USB
  USB.ON();
  USB.println(F("RTC_9 example"));

  // Init RTC
  USB.println(F("Init RTC"));
  RTC.ON(); 

  // Set time [yy:mm:dd:dow:hh:mm:ss]
  RTC.setTime("12:07:20:06:11:25:30");
  USB.print(F("Time: "));

  // Get time
  USB.println(RTC.getTime());

  // Set Alarm1 and Alarm2
  RTC.setAlarm1("20:11:25:40", RTC_ABSOLUTE, RTC_ALM1_MODE2);
  RTC.setAlarm2("20:11:26", RTC_ABSOLUTE, RTC_ALM2_MODE2);
}


void loop()
{
  USB.println(F("Waspmote goes into sleep mode until the RTC alarm causes an interrupt"));
  PWR.sleep(ALL_OFF);
  

  // After setting Waspmote to power-down, UART is closed, 
  // so it is necessary to open it again
  USB.ON();
  RTC.ON(); 
  USB.println(F("Waspmote wakes up!!"));
  USB.print(F("Time: "));
  USB.println(RTC.getTime());


  // Check Interruption register
  if( intFlag & RTC_INT )
  {
    intFlag &= ~(RTC_INT); // Clear flag
    
    USB.println(F("-------------------------"));
    USB.println(F("RTC INT Captured"));
    USB.println(F("-------------------------"));
    
    if (RTC.alarmTriggered == 1) 
    {
      USB.println(F("+++ Alarm1 triggered +++\n\n"));
      RTC.setAlarm1("00:00:00:40",RTC_OFFSET,RTC_ALM1_MODE2);
    }
    else if (RTC.alarmTriggered == 2) 
    {
      USB.println(F("+++ Alarm2 triggered +++\n\n"));
      RTC.setAlarm2("00:00:01",RTC_OFFSET,RTC_ALM2_MODE2);
    }
    else if (RTC.alarmTriggered == 3)
    {
      USB.println(F("+++ Alarm1 & Alarm2 triggered +++\n\n"));
      RTC.setAlarm1("00:00:00:40",RTC_OFFSET,RTC_ALM1_MODE2);
      RTC.setAlarm2("00:00:01",RTC_OFFSET,RTC_ALM2_MODE2);
    }
  }




}


