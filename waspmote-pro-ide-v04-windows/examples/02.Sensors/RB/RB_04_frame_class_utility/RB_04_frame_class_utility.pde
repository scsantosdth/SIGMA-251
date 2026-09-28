/*  
 *  ------------  [RB_04] - Frame Class Utility  -------------- 
 *  
 *  Explanation: This is the basic code to create a frame for 
 *  Radiation Board
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
 *  Version:		    0.1
 *  Design:             David Gascón
 *  Implementation:     Luis Miguel Marti
 */

#include "WaspSensorRadiation.h"
#include <WaspFrame.h>

// Variable to store measured radiation
float radiationcpm;
float radiationusv;

char node_ID[] = "Node_01";


void setup() 
{
  USB.ON();
  USB.println(F("Frame Utility Example for Radiation Board"));

  // Set the Waspmote ID
  frame.setID(node_ID); 
  
  // Starting Radiation Board
  RadiationBoard.ON();
  delay(100);
}

void loop()
{
  ///////////////////////////////////////////
  // 1. Turn on the board
  /////////////////////////////////////////// 
  RadiationBoard.ON();
  delay(100);


  ///////////////////////////////////////////
  // 2. Read sensors
  ///////////////////////////////////////////  
  // Read radiation for 5 secs
  radiationcpm = RadiationBoard.getCPM(5000);
  radiationusv = RadiationBoard.getRadiation();
  

  ///////////////////////////////////////////
  // 3. Turn off the sensors
  /////////////////////////////////////////// 
  // Power off the board
  RadiationBoard.OFF();


  ///////////////////////////////////////////
  // 4. Create ASCII frame
  /////////////////////////////////////////// 

  // Create new frame (ASCII)
  frame.createFrame(ASCII);

  // Add temperature
  frame.addSensor(SENSOR_RAD, radiationcpm);
  frame.addSensor(SENSOR_RAD, radiationusv);

  // Show the frame
  frame.showFrame();

  //wait 2 seconds
  delay(2000);
}
