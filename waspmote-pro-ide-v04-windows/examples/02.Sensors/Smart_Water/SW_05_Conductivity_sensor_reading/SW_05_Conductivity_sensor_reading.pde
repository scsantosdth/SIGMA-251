/*  
 *  ------ [SW_05] - Conductivity sensor Reading for Smart Water-------- 
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

float value_cond;
float value_calculated;

// Value 1 used to calibrate the sensor
#define point1_cond 10500
// Value 2 used to calibrate the sensor
#define point2_cond 40000

// Point 1 of the calibration 
#define point1_cal 197.00
// Point 2 of the calibration 
#define point2_cal 150.00

conductivityClass ConductivitySensor;

void setup()
{
  // Turn ON the Smart Water sensor board and start the USB
  SensorSW.ON();
  USB.ON();
  
  // Configure the calibration parameters
  ConductivitySensor.setCalibrationPoints(point1_cond, point1_cal, point2_cond, point2_cal);
  delay(2000);
}

void loop()
{
  // Reading of the Conductivity sensor
  value_cond = ConductivitySensor.readConductivity();

  // Print of the results
  USB.print(F("Conductivity Output Resistance: "));
  USB.print(value_cond);

  // Conversion from resistance into ms/cm
  value_calculated = ConductivitySensor.conductivityConversion(value_cond);
  // Print of the results
  USB.print(F(" Conductivity of the solution (mS/cm): "));
  USB.println(value_calculated); 
}
