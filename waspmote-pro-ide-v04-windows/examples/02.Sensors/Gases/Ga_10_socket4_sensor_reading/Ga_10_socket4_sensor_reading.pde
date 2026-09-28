/*  
 *  ------ [Ga_10] - Socket4 Reading for Gases v20-------- 
 *  
 *  Explanation: Turn on the Gases Board v20 and reads the sensor
 *  placed on socket 4A every second, printing the result
 *  through the USB
 *  
 *  Copyright (C) 2012 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Design:            David Gascón 
 *  Implementation:    
 */

#include <WaspSensorGas_v20.h>

#define GAIN  1      // GAIN of the sensor stage
#define RESISTOR 20  // LOAD RESISTOR of the sensor stage

// Variable to store the read value
float socket4AVal;

void setup()
{
  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("start"));
  delay(100);

  // Turn on the sensor board
  SensorGasv20.ON();

  // Turn on the RTC
  RTC.ON();

  // Configure the 4A sensor socket
  SensorGasv20.configureSensor(SENS_SOCKET4A, GAIN, RESISTOR);

  
  // Turn on the sensor on socket 4A and wait for stabilization and
  // sensor response time
  SensorGasv20.setSensorMode(SENS_ON, SENS_SOCKET4A);
  delay(40000);
 
  
}
 
void loop()
{
  
  // Read the sensor 
  socket4AVal = SensorGasv20.readValue(SENS_SOCKET4A);
  
  // Print the result through the USB
  USB.print(F("SOCKET4A: "));
  USB.print(socket4AVal);
  USB.print(F("V - "));

  // Conversion from voltage into kiloohms  
  socket4AVal = SensorGasv20.calculateResistance(SENS_SOCKET4A, socket4AVal, GAIN, RESISTOR);
  USB.print(socket4AVal);
  USB.println(F("kohms"));
  
  delay(1000);
}
