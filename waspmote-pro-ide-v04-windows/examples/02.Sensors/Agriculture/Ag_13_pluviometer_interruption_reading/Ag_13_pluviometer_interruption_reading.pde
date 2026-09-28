/*  
 *  --[Ag_13] - Reading the Weather station at Agriculture v20 board-- 
 *  
 *  Explanation: Turn on the Agriculture v20 board and read the 
 *  Weather station on it once every second
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
 *  Version:           0.3
 *  Design:            David Gascón 
 *  Implementation:    Manuel Calahorra
 */

#include <WaspSensorAgr_v20.h>

// Variable to store the number of anemometer pulses
unsigned long pluviometerCounter = 0;

// Variable to store the precipitations value
float pluviometer;

// variable to store the number of pending pulses
int pendingPulses;


void setup()
{
  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("Example AG_13. Pluviometer sensor"));

  // Turn on the sensor board
  SensorAgrv20.ON();

  // Turn on the RTC
  RTC.ON();
  USB.print(F("Time:"));
  USB.println(RTC.getTime());
}



void loop()
{
  /////////////////////////////////////////////
  // 1. Enter sleep mode
  /////////////////////////////////////////////
  SensorAgrv20.sleepAgr("00:00:00:00", RTC_ABSOLUTE, RTC_ALM1_MODE4, SOCKET0_OFF, SENS_AGR_PLUVIOMETER);
  
  
  /////////////////////////////////////////////
  // 2.1. check pluviometer interruption
  /////////////////////////////////////////////
  if( intFlag & PLV_INT)
  {
    USB.println(F("+++ PLV interruption +++"));
    
    pendingPulses = intArray[PLV_POS];
    
    USB.print(F("Number of pending pulses:"));
    USB.println( pendingPulses );

    for(int i=0 ; i<pendingPulses; i++)
    {
      // Enter pulse information inside class structure
      SensorAgrv20.storePulse();
      
      // decrease number of pulses
      intArray[PLV_POS]--;
    }

    // Clear flag
    intFlag &= ~(PLV_INT); 
  }

  /////////////////////////////////////////////
  // 2.2. check RTC interruption
  /////////////////////////////////////////////
  if(intFlag & RTC_INT)
  {
    USB.println(F("+++ RTC interruption +++"));
    RTC.ON();
    USB.print(F("Time:"));
    USB.println(RTC.getTime());
        
    USB.println(F("----------------------------------------------------"));

    // Print the accumulated rainfall
    USB.print(F("Current hour accumulated rainfall (mm/h): "));
    USB.println( SensorAgrv20.readPluviometerCurrent() );

    // Print the accumulated rainfall
    USB.print(F("Previous hour accumulated rainfall (mm/h): "));
    USB.println( SensorAgrv20.readPluviometerHour() );

    // Print the accumulated rainfall
    USB.print(F("Last 24h accumulated rainfall (mm/day): "));
    USB.println( SensorAgrv20.readPluviometerDay() );

    USB.println(F("----------------------------------------------------\n"));

    // Clear flag
    intFlag &= ~(RTC_INT); 
  }

}



