/*  
 *  ------ [INT_02] Setting RTC interrupt example -------- 
 *  
 *  Explanation: This example shows how to set time alarms in
 *  the Waspmote RTC
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
 *  Implementation:    Marcos Yarza, Yuri Carmona
 */


void setup()
{
  // Setup for Serial port over USB
  USB.ON();
  USB.println(F("INT_02 example"));
}


void loop()
{

  ///////////////////////////////////////////////////////////
  // 1. Setting time
  ///////////////////////////////////////////////////////////
  RTC.ON(); 
  // Setting time [yy:mm:dd:dow:hh:mm:ss]
  RTC.setTime("12:07:20:06:11:25:00");
  USB.print(F("1. Set time: "));
  USB.println(RTC.getTime());


  ///////////////////////////////////////////////////////////
  // 2. Enable interruption: RTC interruption
  ///////////////////////////////////////////////////////////
  // Setting Alarm1 in absolute mode:
  // 20:11:25:15 => Date 20
  // Time: 11:25:15 
  // Alarm1 is set 15 seconds later
  RTC.setAlarm1("20:11:25:15",RTC_ABSOLUTE,RTC_ALM1_MODE2);
  USB.print(F("2. Set Alarm1: "));
  USB.println(RTC.getAlarm1());


  ///////////////////////////////////////////////////////////////////////
  // 3. Set low-power consumption state
  ///////////////////////////////////////////////////////////////////////
  USB.println(F("3. Set sleep mode until the RTC alarm causes an interrupt"));
  PWR.sleep(ALL_OFF);

  // Interruption event happened
  
  ///////////////////////////////////////////////
  // 4. Disable interruption: RTC interrupt 
  //    This is done to avoid new interruptions
  ///////////////////////////////////////////////
  RTC.ON();  // necessary to init RTC after sleep mode
  RTC.detachInt();
  
  USB.ON();
  USB.println(F("4. Waspmote wakes up"));
  USB.println();  

  ///////////////////////////////////////////////////////////
  // 5. Check the interruption source
  ///////////////////////////////////////////////////////////
  if( intFlag & RTC_INT )
  {    
    USB.println(F("++++++++++++++++++++++++++++"));
    USB.println(F("++ RTC interrupt detected ++"));
    USB.println(F("++++++++++++++++++++++++++++"));   
    USB.println(); 

    // blink LEDs
    for(int i=0; i<10; i++)
    {
      Utils.blinkLEDs(50);
    }
    
    /* 
     *  Insert your code here if more things needed
     */
  }

  ///////////////////////////////////////////////////////////////////////
  // 6. Clear 'intFlag' 
  ///////////////////////////////////////////////////////////////////////
  // This is mandatory, if not this interruption will not be deleted and 
  // Waspmote could think in the future that a not existing interruption arrived
  clearIntFlag(); 

  ///////////////////////////////////////////////////////////////////////
  // 7. Clear interruption pin   
  ///////////////////////////////////////////////////////////////////////
  // This function is used to make sure the interruption pin is cleared
  // if a non-captured interruption has been produced
  PWR.clearInterruptionPin();
}




