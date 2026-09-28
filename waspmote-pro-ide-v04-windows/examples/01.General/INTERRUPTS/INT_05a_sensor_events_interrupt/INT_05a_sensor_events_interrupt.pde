/*
 *  ------ [INT_05a] Setting battery level interrupt example -------- 
 *
 *  Explanation: This example shows how to setup a threshold to the 
 *  Sensor Event Board and enter sleep mode until an interruption 
 *  occurs. Then show the value returned by the sensor board and print
 *  it.
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
 *  Version:                0.2
 *  Design:                 David Gascon
 *  Implementation:         Manuel Calahorra
 */


// Inclusion of the Events Sensor Board v20 library
#include <WaspSensorEvent_v20.h>

// Variable to store the sensor read value
float value = 0;



void setup()
{
  USB.ON();
  USB.println(F("INT_05a example"));

  // Turn on the Events Sensor Board
  SensorEventv20.ON();

  // Init the RTC
  RTC.ON();

  // Configure the sensor threshold
  SensorEventv20.setThreshold(SENS_SOCKET1, 1);
}



void loop()
{
  ///////////////////////////////////////////////////////////////////////
  // 1. Enable interruption: interruptions from the Sensor Board
  ///////////////////////////////////////////////////////////////////////
  SensorEventv20.attachInt();


  ///////////////////////////////////////////////////////////////////////
  // 2. Set low-power consumption state
  //////////////////////////////////////////////////////////////////////
  // Sensor board power supply is kept. Note the input argument for 
  // sleep function is: SOCKET0_OFF . But SENS_OFF has 
  // been omitted so as to keep the Board powered on
  USB.println(F("Enter sleep mode..."));  
  PWR.sleep( SOCKET0_OFF );

  // Interruption event happened

  ///////////////////////////////////////////////////////////////////////
  // 3. Disable interruption: from the board 
  //    This is done to avoid new interruptions
  ///////////////////////////////////////////////////////////////////////
  SensorEventv20.detachInt();  

  USB.ON();
  USB.println(F("Waspmote wakes up"));


  ///////////////////////////////////////////////////////////////////////
  // 4. Load the interruption register
  ///////////////////////////////////////////////////////////////////////
  // This is donde to load the shift register which permits to know which 
  // of the sensors in the board generated the interruption
  SensorEventv20.loadInt();


  ///////////////////////////////////////////////////////////////////////
  // 5. Check the interruption source
  ///////////////////////////////////////////////////////////////////////
  if( intFlag & SENS_INT )
  { 
    // print info
    USB.ON();
    USB.println(F("++++++++++++++++++++++++++++++++++"));
    USB.println(F("++ SENS interruption captured!! ++"));
    USB.println(F("++++++++++++++++++++++++++++++++++")); 

    // check the sensor which caused the interruption
    if( SensorEventv20.intFlag & SENS_SOCKET1 )
    {  
      // print info
      USB.ON();
      USB.println(F("------------------------------------------"));
      USB.println(F("-- SENS_SOCKET1 interruption captured!! --"));
      USB.println(F("------------------------------------------")); 
      USB.println(); 

      // blink LEDs
      for(int i=0; i<10; i++)
      {
        Utils.blinkLEDs(50);
      }

      /* 
       *  Insert your code here if more things needed
       */

      // Read the sensor
      value = SensorEventv20.readValue(SENS_SOCKET1, SENS_RESISTIVE);

      // Print the resistance of the sensor
      USB.print(F("Resistance: "));    
      USB.print(value);
      USB.println(F("kohms"));
    }
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






