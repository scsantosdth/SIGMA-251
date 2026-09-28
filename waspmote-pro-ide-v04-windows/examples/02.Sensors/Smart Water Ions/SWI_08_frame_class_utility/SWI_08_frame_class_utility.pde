/*  
 *  ------------  [SWI_08] - Frame Class Utility  ------------
 *  
 *  Explanation: This is the basic code to create a frame with some
 *  Smart Water sensors
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
 *  Version:           0.1
 *  Design:            David Gascón 
 *  Implementation:    Luis Miguel Marti
 */

#include <smartWaterIons.h>
#include <WaspFrame.h>

// All Ion sensors can be connected in the four sockets
// In Plug&Sense SOCKETE is reserved for reference probe
//======================================================================
// Plug&Sense SOCKETS
//====================================================================== 
ionSensorClass calciumSensor(SOCKETA);
ionSensorClass NO3Sensor(SOCKETB);
ionSensorClass pHSensor(SOCKETC);
ionSensorClass fluorideSensor(SOCKETD);
pt1000Class tempSensor;
//======================================================================
// Calibration concentrations solutions used in the process
//======================================================================
#define point1 10.0
#define point2 100.0
#define point3 1000.0
//======================================================================
// Calibration voltage values for Calcium sensor
//======================================================================
#define point1_volt_Ca 2.163
#define point2_volt_Ca 2.296
#define point3_volt_Ca 2.425
//======================================================================
// Calibration voltage values for NO3 sensor
//======================================================================
#define point1_volt_NO3 3.080
#define point2_volt_NO3 2.900
#define point3_volt_NO3 2.671
//======================================================================
// Calibration voltage values for Fluor sensor
//======================================================================
#define point1_volt_F 3.115
#define point2_volt_F 2.834
#define point3_volt_F 2.557
//======================================================================
// Calibration values for pH sensor
//======================================================================
#define cal_point_10 1.405
#define cal_point_7  2.048
#define cal_point_4 2.687
#define cal_temperature 22.0
//======================================================================
// Define the number of calibration points
//======================================================================
#define NUM_POINTS 3

//======================================================================
const float concentrations[] = { 
  point1, point2, point3 };
const float voltages_Ca[] = { 
  point1_volt_Ca, point2_volt_Ca, point3_volt_Ca}; 
const float voltages_NO3[] = { 
  point1_volt_NO3, point2_volt_NO3, point3_volt_NO3 }; 
const float voltages_F[] = { 
  point1_volt_F, point2_volt_F, point3_volt_F }; 
//======================================================================


void setup()
{
  // Turn ON the Smart Water Ions Board and USB
  SWIonsBoard.ON();
  USB.ON();  
  
  USB.println(F("Frame Utility Example for Smart Water Ions"));

  // Calibrate the Calcium sensor
  calciumSensor.setCalibrationPoints(voltages_Ca, concentrations, NUM_POINTS); 
  // Calibrate the NO3 sensor
  NO3Sensor.setCalibrationPoints(voltages_NO3, concentrations, NUM_POINTS);  
  // Calibrate the Fluoride sensor
  fluorideSensor.setCalibrationPoints(voltages_F, concentrations, NUM_POINTS);  
  // Calibrate the pH sensor
  pHSensor.setpHCalibrationPoints(cal_point_10, cal_point_7, cal_point_4, cal_temperature);
}

void loop()
{
  ///////////////////////////////////////////
  // 1. Turn on the board
  /////////////////////////////////////////// 

  SWIonsBoard.ON();
  delay(2000);

  ///////////////////////////////////////////
  // 2. Read sensors
  ///////////////////////////////////////////  

  // Read the Calcium sensor
  float CaVolts = calciumSensor.read();
  float calciumValue = calciumSensor.calculateConcentration(CaVolts);
  delay(500);
  // Read the NO3 sensor
  float NO3Volts = NO3Sensor.read();
  float NO3Value = NO3Sensor.calculateConcentration(NO3Volts);
  delay(500);
  // Read the Fluoride sensor
  float flourVolts = fluorideSensor.read();
  float flourideValue = fluorideSensor.calculateConcentration(flourVolts);
  delay(500);
  // Read the Temperature sensor
  float tempValue = tempSensor.read();
  delay(500);
  // Read the pH sensor
  float pHVolts = pHSensor.read();
  float pHValue = pHSensor.pHConversion(pHVolts, tempValue);
  delay(500);

  ///////////////////////////////////////////
  // 3. Turn off the sensors
  /////////////////////////////////////////// 

  SWIonsBoard.OFF();

  ///////////////////////////////////////////
  // 4. Create ASCII frame
  /////////////////////////////////////////// 
  
  // Create new frame (ASCII)
  frame.createFrame(ASCII);
  
  // Add temperature
  frame.addSensor(SENSOR_WT, tempValue);
  // Add PH
  frame.addSensor(SENSOR_SWI_CA, calciumValue);
  // Add ORP value
  frame.addSensor(SENSOR_SWI_NO, NO3Value);
  // Add DI value
  frame.addSensor(SENSOR_SWI_FL, flourideValue);
  // Add DO value
  frame.addSensor(SENSOR_SWI_PH, pHValue);

  // Show the frame
  frame.showFrame();

  //wait 2 seconds
  delay(2000);
}





