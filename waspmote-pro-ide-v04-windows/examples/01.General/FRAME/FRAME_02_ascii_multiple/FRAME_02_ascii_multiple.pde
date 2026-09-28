/*  
 *  ------ FRAME_02_ascii_multiple - WaspFrame Ascii multiple -------- 
 *  
 *  Explanation: This example Creates an ASCII frame with a 
 *  multiple-field sensor data and shows it.
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
 *  Version:           0.2
 *  Design:            David Gascón 
 *  Implementation:    Joaquín Ruiz, Yuri Carmona
 */ 

#include <WaspFrame.h>

// define the Waspmote ID 
char moteID[] = "node_01";

// hypothetical GPS values
float latitude  = 1.4465431234;
float longitude = -0.8842734321;


void setup()
{
  // Init USB port & Accelerometer
  USB.ON();    
  ACC.ON();
  
  // set the Waspmote ID
  frame.setID(moteID);
}

void loop()
{
  // Create new frame (ASCII)
  frame.createFrame(ASCII); 

  // set frame fields (multiple)
  frame.addSensor(SENSOR_ACC, (int) ACC.getX(), (int) ACC.getY(), (int) ACC.getZ());
  
  // set frame fields (multiple)
  frame.addSensor(SENSOR_GPS, latitude, longitude);
  
  // Print frame
  frame.showFrame();
  delay(5000);
}

