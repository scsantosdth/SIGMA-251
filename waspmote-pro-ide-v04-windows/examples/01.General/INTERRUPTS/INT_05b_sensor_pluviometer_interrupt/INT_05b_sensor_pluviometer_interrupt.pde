/*
 *  ------ [INT_05b] Pluviometer interrupt example -------- 
 *
 *  Explanation: This example shows how to setup the pluviometer 
 *  interruption 
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
 *  Version:                0.1
 *  Design:                 David Gascon
 *  Implementation:         Yuri Carmona
 */


// Inclusion of the Agriculture Sensor Board v20 library
#include <WaspSensorAgr_v20.h>




void setup()
{
  USB.ON();
  USB.println(F("INT_05b example"));

  // Turn on the sensor board 
  SensorAgrv20.ON();  
}



void loop()
{
  ///////////////////////////////////////////////////////////////////////
  // 1. Enable interruption: pluviometer sensor
  ///////////////////////////////////////////////////////////////////////
  SensorAgrv20.attachPluvioInt();


  ///////////////////////////////////////////////////////////////////////
  // 2. Set low-power consumption state
  //////////////////////////////////////////////////////////////////////
  // Sensor board power supply is kept. Note the input argument for 
  // sleep function is: SOCKET0_OFF. But SENS_OFF has 
  // been omitted so as to keep the Board powered on
  USB.println(F("Enter sleep mode..."));  
  SensorAgrv20.sleepAgr("00:00:00:30", RTC_OFFSET, RTC_ALM1_MODE3, SOCKET0_OFF, SENS_AGR_PLUVIOMETER);

  // Interruption event happened

  ///////////////////////////////////////////////////////////////////////
  // 3. Disable interruption: from the board 
  //    This is done to avoid new interruptions
  ///////////////////////////////////////////////////////////////////////
  SensorAgrv20.detachPluvioInt();  

  USB.ON();
  USB.println(F("Waspmote wakes up"));


  ///////////////////////////////////////////////////////////////////////
  // 4. Check the interruption source
  ///////////////////////////////////////////////////////////////////////
  
  // check Pluviometer interruption
  if( intFlag & PLV_INT )
  { 
    // print info
    USB.ON();
    USB.println(F("++++++++++++++++++++++++++++++++++"));
    USB.println(F("++ PLV interruption captured!! ++"));
    USB.println(F("++++++++++++++++++++++++++++++++++")); 

    // blink LEDs
    for(int i=0; i<10; i++)
    {
      Utils.blinkLEDs(50);
    }

    /* 
     *  Insert your code here if more things needed
     */
  } 
  
  // check RTC interruption
  if( intFlag & RTC_INT )
  { 
    // print info
    USB.ON();
    USB.println(F("++++++++++++++++++++++++++++++++++"));
    USB.println(F("++ RTC interruption captured!! ++"));
    USB.println(F("++++++++++++++++++++++++++++++++++")); 
  }
  
  ///////////////////////////////////////////////////////////////////////
  // 5. Clear 'intFlag' 
  ///////////////////////////////////////////////////////////////////////
  // This is mandatory, if not this interruption will not be deleted and 
  // Waspmote could think in the future that a not existing interruption arrived
  clearIntFlag(); 

  ///////////////////////////////////////////////////////////////////////
  // 6. Clear interruption pin   
  ///////////////////////////////////////////////////////////////////////
  // This function is used to make sure the interruption pin is cleared
  // if a non-captured interruption has been produced
  PWR.clearInterruptionPin();

}







