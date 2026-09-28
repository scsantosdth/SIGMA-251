/*  
 *  ------ [SW_06] - Temperature sensor Reading for Smart Water-------- 
 *  
 *  Explanation: Turn on the Smart Water Board and reads the Temperature
 *  sensor printing the result through the USB
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
 *  Version:           2.0
 *  Design:            David Gascón 
 *  Implementation:    Ahmad Saad
 */

#include <WaspSensorSW.h>

// This variable will store the temperature value
float value_temperature;

// Create an instance of the class
pt1000Class TemperatureSensor;

void setup()
{
  // Turn on the Smart Water Sensor Board and start the USB
  SensorSW.ON();
  USB.ON();  
}

void loop()
{
  // Reading of the Temperature sensor
  value_temperature = TemperatureSensor.readTemperature();

  // Print of the results
  USB.print(F("Temperature (celsius degrees): "));
  USB.println(value_temperature);
  
  // Delay
  delay(1000);  
}


