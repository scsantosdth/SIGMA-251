/*  
 *  ------ [SWI_04] - SOCKET2 reading for Smart Water Ions-------- 
 *  
 *  Explanation: Turn on the Smart Water Board and reads the DI sensor
 *  connected in the SOCKET2 printing the result through the USB
 *  In this case we are going to measure NO3 Ion, but all Ions
 *  can be connected in the four available sockets
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

// Connect the Nitrates Sensor in the SOCKET2
// All Ion sensors can be connected in the four sockets
socket2Class NO3Sensor;

// Calibration concentrations solutions used in the process
#define point1 10.0
#define point2 100.0
#define point3 1000.0

// Calibration Voltage values
#define point1_volt_NO3 3.080
#define point2_volt_NO3 2.900
#define point3_volt_NO3 2.671

// Define the number of calibration points
#define numPoints 3

float calConcentrations[] = {point1, point2, point3};
float calVoltages[] = {point1_volt_NO3, point2_volt_NO3, point3_volt_NO3}; 

void setup()
{
  // Turn ON the Smart Water Ions Board and USB
  SWIonsBoard.ON();
  USB.ON();  

  // Calculate the slope and the intersection of the logarithmic function
  NO3Sensor.setCalibrationPoints(calVoltages, calConcentrations, numPoints);
}

void loop()
{
  // Reading of the NO3 sensor
  float NO3Voltage = NO3Sensor.read();

  // Print of the results
  USB.print(F(" NO3 Voltage: "));
  USB.print(NO3Voltage);
  USB.print(F("volts |"));

  float concentration = NO3Sensor.calculateConcentration(NO3Voltage);

  USB.print(F(" NO3 concentration Estimated: "));
  USB.print(concentration);
  USB.println(F(" ppm / mg * L-1"));

  delay(1000);  
}




