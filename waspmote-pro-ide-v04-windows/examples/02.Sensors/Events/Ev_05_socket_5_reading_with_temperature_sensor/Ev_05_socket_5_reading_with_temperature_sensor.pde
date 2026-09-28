/*  
 *  ------ [Ev_5] - Socket 5 Reading for Gases v20-------- 
 *  
 *  Explanation: Turn on the Events Board v20 configuring the threshold
 *  of the socket 5 stage and wait for an interruption from this sensor
 *  to read its value, convert into temperature (MCP9700A sensor) and
 *  print it
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
 *  Version:           0.2
 *  Design:            David Gascon 
 *  Implementation:    Manuel Calahorra
 */

#include <WaspSensorEvent_v20.h>


// THRESHOLD for interruption from the sensor
// Equivalent to 27ºC in this case
// GENERIC FORMULA: degrees(C) = ( volts - 0.5 )* 100;
const float THRESHOLD = 0.77;

// Variable to store the temperature read value
float value;

// define variable
unsigned long previous;



void setup()
{
  // 1. Initialization of the modules

  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("start"));

  // Turn on the sensor board
  SensorEventv20.ON();

  // Turn on the RTC
  RTC.ON();

  // Configure the socket 5 threshold
  SensorEventv20.setThreshold(SENS_SOCKET5, THRESHOLD);

  // Enable interruptions from the board
  SensorEventv20.attachInt();

}

void loop()
{
  ///////////////////////////////////////
  // 1. Read the sensor voltage output
  ///////////////////////////////////////

  // Read the sensor voltage output
  value = SensorEventv20.readValue(SENS_SOCKET5);
    
  // Print the info
  USB.print(F("Sensor output: "));    
  USB.print(value);
  USB.println(F(" Volts"));
  
  
  // Read the sensor output
  value = SensorEventv20.readValue(SENS_SOCKET5, SENS_TEMPERATURE);
    
  // Print the info
  USB.print(F("Temperature: "));    
  USB.print(value);
  USB.println(F(" Celsius\n"));


  
  ///////////////////////////////////////
  // 2. Go to deep sleep mode  
  ///////////////////////////////////////
  USB.println(F("enter deep sleep"));
  PWR.deepSleep("00:00:00:10",RTC_OFFSET,RTC_ALM1_MODE1,SOCKET0_OFF);

  USB.ON();
  USB.println(F("wake up\n"));



  ///////////////////////////////////////
  // 3. Check Interruption Flags
  ///////////////////////////////////////
   
  // 3.1. Check interruption from Sensor Board
  if(intFlag & SENS_INT)
  {
    interrupt_function();
  }

  // 3.2. Check interruption from RTC alarm
  if( intFlag & RTC_INT )
  {   
    USB.println(F("-----------------------------"));
    USB.println(F("RTC INT captured"));
    USB.println(F("-----------------------------"));
  
    // clear flag
    intFlag &= ~(RTC_INT);
  }
}


/**********************************************
*
* interrupt_function()
*  
* Local function to treat the temperature interruption
*
*
***********************************************/
void interrupt_function()
{  
  // Disable interruptions from the board
  SensorEventv20.detachInt();

  // Load the interruption flag
  SensorEventv20.loadInt();

  // Read the sensor
  value = SensorEventv20.readValue(SENS_SOCKET5, SENS_TEMPERATURE);


  // In case the interruption came from socket 5    
  if( SensorEventv20.intFlag & SENS_SOCKET5)
  {
    USB.println(F("-----------------------------"));
    USB.println(F("Interruption from socket 5"));
    USB.println(F("-----------------------------"));
  }

  // Print the temperature read
  USB.print(F("Temperature: "));    
  USB.print(value);
  USB.println(F(" Celsius\n"));

  // Clean the interruption flag
  intFlag &= ~(SENS_INT);

  // Enable interruptions from the board
  SensorEventv20.attachInt();

}

