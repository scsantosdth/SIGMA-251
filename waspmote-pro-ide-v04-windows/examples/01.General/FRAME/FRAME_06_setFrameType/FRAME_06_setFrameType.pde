/*  
 *  ------ FRAME_06 - set Frame Type -------- 
 *  
 *  Explanation: This example shows how to set the frame Type. This field
 *  is included inside the frame's header in order to distinguish between
 *  different sort of frames
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
 *  Implementation:    Yuri Carmona
 */

#include <WaspFrame.h>

// define the Waspmote ID 
char moteID[] = "node_01";

  
void setup()
{
  // Init USB port & Accelerometer
  USB.ON();    
  USB.println(F("FRAME_06 example")); 
  
  // set the Waspmote ID
  frame.setID(moteID);  
}


void loop()
{
  /////////////////////////////////////////////
  // 1. create a TIMEOUT frame type
  /////////////////////////////////////////////
  
  // Create new frame (ASCII)
  frame.createFrame(ASCII);
 
  // set frame type 
  frame.setFrameType(TIMEOUT_FRAME);

  // Prints frame
  frame.showFrame();
  
  delay(500);
  
  
  /////////////////////////////////////////////
  // 2. create a EVENT frame type
  /////////////////////////////////////////////
  
  // Create new frame (ASCII)
  frame.createFrame(ASCII);
 
  // set frame type 
  frame.setFrameType(EVENT_FRAME);

  // Prints frame
  frame.showFrame();
  
  delay(500);  
  
    
  /////////////////////////////////////////////
  // 3. create a ALARM frame type
  /////////////////////////////////////////////
  
  // Create new frame (ASCII)
  frame.createFrame(ASCII);
 
  // set frame type 
  frame.setFrameType(ALARM_FRAME);

  // Prints frame
  frame.showFrame();
  
  delay(500);
    
    
  /////////////////////////////////////////////
  // 4. create a SERVICE1 frame type
  /////////////////////////////////////////////
  
  // Create new frame (ASCII)
  frame.createFrame(ASCII);
 
  // set frame type 
  frame.setFrameType(SERVICE1_FRAME);

  // Prints frame
  frame.showFrame();
  
  delay(500);
  
    
    
  /////////////////////////////////////////////
  // 5. create a SERVICE2 frame type
  /////////////////////////////////////////////
  
  // Create new frame (ASCII)
  frame.createFrame(ASCII);
 
  // set frame type 
  frame.setFrameType(SERVICE2_FRAME);

  // Prints frame
  frame.showFrame();
  
  delay(500);

  USB.println(F("\n\n\n"));

  delay(5000);
}

