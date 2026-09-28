/*  
 *  ------ [SWI_02] - pH sensor Reading for Smart Water Ions -------- 
 *  
 *  Explanation: Turn on the Smart Water Board and reads the pH sensor
 *  extracting the value from the calibration values and temperature
 *  compensation
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

// Calibration values
#define cal_point_10 1.405
#define cal_point_7  2.048
#define cal_point_4 2.687

// Temperature at which calibration was carried out
#define cal_temp 25.0

socket1Class pHSensor; //<------ Define the connection SOCKET
pt1000Class temperatureSensor;

void setup()
{
  // Configure the calibration points
  pHSensor.setpHCalibrationPoints(cal_point_10, cal_point_7, cal_point_4, cal_temp);
  
  // Turn ON the Smart Water Ions Sensor Board and start the USB
  SWIonsBoard.ON();  
  USB.ON();
}


void loop()
{
  // Read the pH sensor
  float pHVoltage = pHSensor.read();

  // Read the temperature sensor
  float temperature = temperatureSensor.read();

  // Print the output values
  USB.print(F("pH value: "));
  USB.print(pHVoltage);
  USB.print(F("volts  | "));  
  
  USB.print(F(" temperature: "));
  USB.print(temperature);
  USB.print(F("degrees  | "));  
  
  // Convert the value read with the information obtained in calibration
  float pHValue = pHSensor.pHConversion(pHVoltage, temperature);
  USB.print(F(" pH Estimated: "));
  USB.println(pHValue);
}



