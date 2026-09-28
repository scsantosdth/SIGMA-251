/*  
 *  ------ [SWI_01] - Temperature Sensor Reading for Smart Water Ions-------- 
 *  
 *  Explanation: Turn on the Smart Water Ions Board and reads the Temperature
 *  sensor printing the result through the USB
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
 *  Version:           1.0
 *  Design:            David Gascón 
 *  Implementation:    Ahmad Saad
 */

#include <smartWaterIons.h>

// Create an instance of the class
pt1000Class TemperatureSensor;

void setup()
{
  // Turn on the Smart Water Sensor Board and start the USB
  SWIonsBoard.ON();
  USB.ON();  
}

void loop()
{
  // Reading of the Temperature sensor
  float temperature = TemperatureSensor.read();

  // Print of the results
  USB.print(F("Temperature (Celsius degrees): "));
  USB.println(temperature);
  
  // Delay
  delay(1000);  
}


