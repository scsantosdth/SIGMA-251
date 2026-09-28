/*  
 *  ------ [Ev_10] - Frame Class Utility -------- 
 *  
 *  Explanation: This is the basic code to create a frame with every
 * 	socket of Events Board
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
 *  Design:            David Gascon 
 *  Implementation:    Luis Miguel Martí
 */

#include <WaspSensorEvent_v20.h>
#include <WaspFrame.h>

// Variable to store the read value
float socket1;
float socket2;
float socket3;
uint8_t socket4;
float socket5;
float socket6;
uint8_t socket7;
uint8_t socket8;

char node_ID[] = "Node_1";

void setup() 
{
  USB.ON();
  USB.println(F("Frame Utility Example for Events Board"));
  
  // Turn on the sensor board
  SensorEventv20.ON();
  
  // Set the Waspmote ID
  frame.setID(node_ID); 
}

void loop()
{
  ///////////////////////////////////////////
  // 1. Read sensors
  ///////////////////////////////////////////  

  // Read Socket 1
  socket1 = SensorEventv20.readValue(SENS_SOCKET1, SENS_RESISTIVE);
  // Read Socket 2
  socket2 = SensorEventv20.readValue(SENS_SOCKET2, SENS_RESISTIVE);
  // Read Socket 3
  socket3 = SensorEventv20.readValue(SENS_SOCKET3, SENS_RESISTIVE);
  // Read Socket 4
  socket4 = SensorEventv20.readValue(SENS_SOCKET4);
  // Read Socket 5
  socket5 = SensorEventv20.readValue(SENS_SOCKET5, SENS_TEMPERATURE);
  // Read Socket 6
  socket6 = SensorEventv20.readValue(SENS_SOCKET6, SENS_HUMIDITY);
  // Read Socket 7
  socket7 = SensorEventv20.readValue(SENS_SOCKET7);
  // Read Socket 8
  socket8 = SensorEventv20.readValue(SENS_SOCKET8);

  ///////////////////////////////////////////
  // 2. Create ASCII frame
  /////////////////////////////////////////// 

  // Create new frame (ASCII)
  frame.createFrame(ASCII);

  // Add stretch
  frame.addSensor(SENSOR_ST, socket1);
  // Add luminosity
  frame.addSensor(SENSOR_LUM, socket2);
  // Add pressure
  frame.addSensor(SENSOR_PW, socket3);
  // Add vibration
  frame.addSensor(SENSOR_VBR, socket4);
  // Add temperature
  frame.addSensor(SENSOR_TCA, socket5);
  // Add humidity
  frame.addSensor(SENSOR_HUMA, socket6);
  // Add PIR
  frame.addSensor(SENSOR_PIR, socket7);
  // Add liquid presence
  frame.addSensor(SENSOR_LP_D, socket8);
  
  // Show the frame
  frame.showFrame();

  //wait 2 seconds
  delay(2000);
}
