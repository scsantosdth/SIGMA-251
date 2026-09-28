/*
 *  ------   [Ut_06] - Stack EEPROM Basic operation   -------- 
 *
 *  Explanation: This example shows how to use the Stack EEPROM
 *  library of Waspmote in order to store and get pending frames
 *  using the EEPROM memory of the Waspmote device
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
 *  Version:           0.1 
 *  Design:            David Gascon 
 *  Implementation:    Alejandro Gallego
 */


#include <WaspStackEEPROM.h>
#include <WaspFrame.h>       

int answer;

void setup() 
{
  
  // set Waspmote ID
  frame.setID("node_001");
  
  //////////////////////////////////////////////////
  // 1. inits the block size and the stack  
  //////////////////////////////////////////////////
  
  // init block size
  USB.println(F("Set Block Size to '100' Bytes"));
  stack.initBlockSize(100);
  
  // clear stack initializing to zeros
  USB.println(F("Clearing Stack..."));
  answer = stack.initStack();
  if (answer == 1)
  {   
    USB.println(F("Stack initialized"));
  }
  else
  {   
    USB.println(F("Stack NOT initialized"));
  }
  
  USB.print(F("Number of stored frames:"));
  USB.println(stack.getStoredFrames());

}



void loop() 
{

  //////////////////////////////////////////////////
  // 2. Create a frame
  //////////////////////////////////////////////////
  
  // Create new frame (ASCII)
  frame.createFrame(ASCII); 
  // set frame fields (String - char*)
  frame.addSensor(SENSOR_STR, (char*) "Stack_example");
  // set frame fields (Battery sensor - uint8_t)
  frame.addSensor(SENSOR_BAT, (uint8_t) PWR.getBatteryLevel());

  USB.println(F("Frame to store:"));
  frame.showFrame();


  //////////////////////////////////////////////////
  // 3. push frame into the stack
  //////////////////////////////////////////////////
  answer = stack.push( frame.buffer, frame.length);
  if (answer == 1)
  {   
    USB.println(F("Frame pushed"));
  }
  else if (answer == 2)
  {   
    USB.println(F("Stack is full, frame not pushed"));
  }
  else if (answer == 3)
  {   
    USB.println(F("Block size too small, frame not pushed"));
  }
  else
  {   
    USB.println(F("Error pushing the frame"));
  }


  USB.print(F("Number of stored frames:"));
  USB.println(stack.getStoredFrames());

  //////////////////////////////////////////////////
  // 4. pop frame from the stack
  //////////////////////////////////////////////////
  frame.length = stack.pop( frame.buffer );
  
  if (frame.length > 2)
  {   
    USB.println(F("Frame extracted:"));
    frame.showFrame();
  }
  else if (frame.length == 0)
  {   
    USB.println(F("Stack is empty, frame not extracted"));
  }
  else if (frame.length == 1)
  {   
    USB.println(F("Error reading the EEPROM, frame not extracted"));
  }
  else
  {   
    USB.println(F("Error updating the new pointer"));
  }

  USB.print(F("Number of stored frames:"));
  USB.println(stack.getStoredFrames());
  
  USB.println();
  USB.println();
  delay(5000);

}






