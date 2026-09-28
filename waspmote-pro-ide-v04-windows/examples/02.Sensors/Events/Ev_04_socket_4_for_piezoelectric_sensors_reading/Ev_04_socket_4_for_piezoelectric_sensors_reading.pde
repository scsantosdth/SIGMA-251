/*  
 *  ------ [Ev_4] - Socket 4 Reading for Gases v20-------- 
 *  
 *  Explanation: Turn on the Events Board v20 configuring the threshold
 *  of the socket 4 stage and wait for an interruption from this sensor
 *  to read its value and print it
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
 *  Design:            David Gascón 
 *  Implementation:    Manuel Calahorra
 */

#include <WaspSensorEvent_v20.h>

// THRESHOLD for interruption from the sensor
const float THRESHOLD = 0.3;

// Variable to store the read value
float value;


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

  // Configure the socket 4 threshold
  SensorEventv20.setThreshold(SENS_SOCKET4, THRESHOLD);
  
  // Enable interruptions from the board
  SensorEventv20.attachInt();
  
}
 
void loop()
{
  ///////////////////////////////////////
  // 1. Read the sensor voltage output
  ///////////////////////////////////////
  
  // 1.1. Read the sensor voltage output
  value = SensorEventv20.readValue(SENS_SOCKET4);

  // Print the info
  USB.print(F("Sensor output: "));    
  USB.print(value);
  USB.println(F(" Volts"));

  
  
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
 * Local function to treat the sensor interruption
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
  value = SensorEventv20.readValue(SENS_SOCKET4);

  // In case the interruption came from socket 1
  if( SensorEventv20.intFlag & SENS_SOCKET4)
  {
    USB.println(F("-----------------------------"));
    USB.println(F("Interruption from socket 4"));
    USB.println(F("-----------------------------"));
  }

  // Printing and enabling interruptions

  // Print the resistance of the sensor
  USB.print(F("Voltage: "));
  USB.print(value);
  USB.println(F("V"));

  // Clean the interruption flag
  intFlag &= ~(SENS_INT);

  // Enable interruptions from the board
  SensorEventv20.attachInt();

}



