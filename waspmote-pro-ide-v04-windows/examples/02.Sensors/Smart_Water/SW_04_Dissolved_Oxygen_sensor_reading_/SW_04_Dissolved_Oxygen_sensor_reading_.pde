/*  
 *  ------ [SW_04] - Dissolved Oxygen sensor Reading for Smart Water-------- 
 *  
 *  Explanation: Turn on the Smart Water Board and reads the Dissolved Oxygen
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

float value_do;
float value_calculated;

// Calibration of the sensor in normal air
#define air_calibration 2.65
// Calibration of the sensor under 0% solution
#define zero_calibration 0.0

DOClass DOSensor;

void setup()
{
  // Turn ON the Smart Water sensor board and start the USB
  SensorSW.ON();
  USB.ON();  
  
  // Configure the calibration values
  DOSensor.setCalibrationPoints(air_calibration, zero_calibration);
}

void loop()
{
  // Reading of the ORP sensor
  value_do = DOSensor.readDO();

  // Print of the results
  USB.print(F("DO Output Voltage: "));
  USB.print(value_do);

  // Conversion from volts into dissolved oxygen percentage
  value_calculated = DOSensor.DOConversion(value_do);

  // Print of the results
  USB.print(F(" DO Percentage: "));
  USB.println(value_calculated);
  
}


