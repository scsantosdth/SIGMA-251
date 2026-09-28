/*  
 *  ------ [SW_02] - ORP sensor Reading for Smart Water-------- 
 *  
 *  Explanation: Turn on the Smart Water Board and reads the ORP sensor
 *  extracting the value from the calibration values and temperature
 *  compensation
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

float value_orp;
float value_calculated;

// Offset obtained from sensor calibration
#define calibration_offset 0.0

ORPClass ORPSensor;

void setup()
{
  // Turn on the Smart Water sensor board and start the USB
  SensorSW.ON();
  USB.ON();  
}

void loop()
{
  // Reading of the ORP sensor
  value_orp = ORPSensor.readORP();

  // Apply the calibration offset
  value_calculated = value_orp - calibration_offset;

  // Print of the results
  USB.print(F(" ORP Estimated: "));
  USB.print(value_calculated);
  USB.println(F(" volts"));  
}


