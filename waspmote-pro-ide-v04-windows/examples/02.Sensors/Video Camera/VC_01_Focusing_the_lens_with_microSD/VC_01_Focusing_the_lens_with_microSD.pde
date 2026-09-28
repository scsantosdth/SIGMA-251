/*  
 *  ------ VC_01 - Focusing the lens with microSD -------- 
 *  
 *  Explanation: This code helps you to focus the lens.
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
 *  Version:           1.1
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego 
 */


#include "Wasp3G.h"

/*******************************************************************************
********************************************************************************
 BEFORE TO COMPILE this sketch and others that use the Videocamera Sensor Board,
 be sure that the CAMERA_FUSE is set to 1. Otherwise, sketch will not compile.
 This fuse is located in the file Wasp3G.h, inside /libraries/Wasp3G folder.
********************************************************************************
*******************************************************************************/

int count=0;
int answer=0;
int status_3G;
unsigned long time;


void setup(){

  USB.ON();
  USB.println(F("Starting"));

  status_3G = _3G.ON();
  if ((status_3G == 1) || (status_3G == -3))
  {

    USB.println(F("3G module ready..."));

    _3G.setTime();

    _3G.setMode(_3G_RF_OFF);
    USB.println(F("RF circuits disabled"));

    // if there isn't a name the 3G module use the date and time for the picture's name
    _3G.pictureName("");

    USB.println(F("*********************************************************************"));
    USB.println(F("Focus scketch 01. This program uses the microSD to focus the lens."));
    USB.println(F("Keys with special functions:"));
    USB.println(F("  'a': IR LEDs off"));
    USB.println(F("  's': IR LED block 1 on, block 2 off"));
    USB.println(F("  'd': IR LED block 2 on, block 1 off"));
    USB.println(F("  'f': all IR LEDs on"));
    USB.println(F("  'q': IR cut filter enabled"));
    USB.println(F("  'w': IR cut filter disabled"));
    USB.println(F("*********************************************************************"));

    while(USB.available() > 0)
    {
      USB.read();    
    }
  }
  else
  {
    USB.println(F("3G module NOT ready..."));
  }
}


void loop(){ 

  if ((status_3G == 1) || (status_3G == -3))
  {
    do{
      USB.println(F("Waiting for SD..."));
        
      time = millis();
      answer = _3G.isSD();
      while ((answer == 0) && ((millis() - time) < 60000))
      {
        answer = _3G.isSD();
        // Condition to avoid an overflow (DO NOT REMOVE)
        if (millis() < time)
        {
          time = millis();	
        }
      }

      if (answer == 1)
      {
        // Selects microSD to store the pictures
        _3G.selectStorage(1);
      }
      else
      {
        // Selects microSD to store the pictures
        _3G.selectStorage(0);   
        USB.println("SD card not available"); 
      }

      // Starts the camera and configures it
      do{
        answer = _3G.startCamera();
        if(answer == -3){
          _3G.stopCamera();   
        }
      }
      while (answer != 1);
      _3G.cameraResolution(5);
      _3G.cameraBrightness(3);

      // take the picture and power off the camera
      do{
        answer = _3G.takePicture();
      }
      while (answer != 1);


      _3G.stopCamera();  

      USB.println(_3G.buffer_3G);
      USB.println(F("Picture ready. Extract the microSD card and check the picture."));
      USB.println(F("If necessary, recalibrate the lens and press any key to take another picture"));
      USB.flush();
      while(USB.available() == 0);

      do{
        answer = USB.read();
        switch (answer)
        {
        case 'a':
          _3G.powerIRLED(0);
          break;
        case 's':
          _3G.powerIRLED(1);
          break;
        case 'd':
          _3G.powerIRLED(2);
          break;
        case 'f':
          _3G.powerIRLED(3);
          break;
        case 'q':
          _3G.selectFilter(0);
          break;
        case 'w':
          _3G.selectFilter(1);
          break;
        }
        delay(100);
      }
      while(USB.available() > 0);

    }
    while(1);   
  }
  else
  {
    USB.println("3G not started");
  }


}











