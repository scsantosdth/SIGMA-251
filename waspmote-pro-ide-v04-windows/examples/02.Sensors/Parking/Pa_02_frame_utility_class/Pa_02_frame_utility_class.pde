/* 
 *  --------------------[Pa_2] - Frame class utility--------------------
 *  
 *  Explanation: This is the basic code to create a frame for Parking
 *  Sensor Board     
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
 *  Implementation:    Luis Miguel Martí
 */

#include <WaspSensorParking.h>
#include <WaspFrame.h>

// Variable to store temperature
int temperature;

// Variable to store status
boolean status;

char node_ID[] = "Node_01";

void setup()
{
  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("Frame Utility Example for Parking"));
  delay(5000);

  // The reference coefficients are loaded
  SensorParking.loadReference();
  
  // Turn on the board
  SensorParking.ON();
  delay(100);
  
  // Proceed to calibrate
  SensorParking.calibration();  
  delay(100);
  
  // Set the Waspmote ID
  frame.setID(node_ID);
}

void loop()
{
  ///////////////////////////////////////////
  // 1. Turn board
  /////////////////////////////////////////// 
  SensorParking.ON();
  delay(100);
  temperature = SensorParking.readTemperature();
  SensorParking.readParkingSetReset();
  
  ///////////////////////////////////////////
  // 2. Read sensor
  ///////////////////////////////////////////  
  SensorParking.calculateReference(temperature);
  status = SensorParking.estimateState();

  ///////////////////////////////////////////
  // 3. Turn off the board
  /////////////////////////////////////////// 
  SensorParking.OFF();
  
  ///////////////////////////////////////////
  // 4. Create ASCII frame
  /////////////////////////////////////////// 
  // Create new frame (ASCII)
  frame.createFrame(ASCII);

  // Add temperature
  frame.addSensor(SENSOR_PS, status);
  frame.addSensor(SENSOR_MF,
  SensorParking.initialX,
  SensorParking.initialY, 
  SensorParking.initialZ);
  
  // Show the frame
  frame.showFrame();

  //wait 2 seconds
  delay(2000);
}
