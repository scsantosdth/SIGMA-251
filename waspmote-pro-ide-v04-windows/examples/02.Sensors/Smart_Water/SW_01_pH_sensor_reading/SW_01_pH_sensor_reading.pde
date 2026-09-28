/*  
 *  ------ [SW_01] - pH sensor Reading for Smart Water-------- 
 *  
 *  Explanation: Turn on the Smart Water Board and reads the pH sensor
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

float value_pH;
float value_temp;
float value_pH_calculated;

// Calibration values
#define cal_point_10 1.985
#define cal_point_7 2.070
#define cal_point_4 2.227

// Temperature at which calibration was carried out
#define cal_temp 23.7

pHClass pHSensor;
pt1000Class temperatureSensor;

void setup()
{
  pHSensor.setCalibrationPoints(cal_point_10, cal_point_7, cal_point_4, cal_temp);
  
  // Turn ON the Smart Water sensor board and start the USB
  SensorSW.ON();  
  USB.ON();
}


void loop()
{
  // Read the ph sensor
  value_pH = pHSensor.readpH();

  // Read the temperature sensor
  value_temp = temperatureSensor.readTemperature();

  // Print the output values
  USB.print(F("pH value: "));
  USB.print(value_pH);
  USB.print(F("volts  | "));  
  USB.print(F(" temperature: "));
  USB.print(value_temp);
  USB.print(F("degrees  | "));  
  
  // Convert the value read with the information obtained in calibration
  value_pH_calculated = pHSensor.pHConversion(value_pH,value_temp);
  USB.print(F(" pH Estimated: "));
  USB.println(value_pH_calculated);
}



