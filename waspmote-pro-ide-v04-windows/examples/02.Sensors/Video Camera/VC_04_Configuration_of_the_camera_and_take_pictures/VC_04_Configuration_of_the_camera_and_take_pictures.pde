/*  
 *  ------ VC_04 - Configuration of the camera and take picture -------- 
 *  
 *  Explanation: This code configures the camera and take a picture.
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

int count = 0;
int answer = 0;
int status_3G = 0;
unsigned long time;


void setup(){

    USB.ON();
    USB.println(F("Starting"));

    status_3G = _3G.ON();
    if ((status_3G == 1) || (status_3G == -3))
    {
        USB.println(F("3G module ready..."));

        _3G.setTime();

        // if there isn't a name the 3G module use the date and time for the picture's name
        _3G.pictureName("");

        USB.println(F("Waiting for SD..."));

        time = millis();
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
    }
    else
    {
        USB.println(F("3G module NOT ready..."));
    }


}


void loop(){ 

    if (status_3G == 1)
    {
        // Starts the camera and configures it
        count = 3;
        do{
            answer = _3G.startCamera();
            if(answer == -3){
                _3G.stopCamera();   
            }
        }while ((answer != 1) && (count > 0));
        if (answer == 1)
        {
            _3G.cameraResolution(5);    // Sets VGA resolution
            _3G.cameraBrightness(3);    // Sets medium brightness
            _3G.cameraRotation("0");    // Rotation of 0 degrees
            _3G.pictureTimeStamp(0);    // Disables timestamp

            // take the picture and power off the camera
            _3G.takePicture();

            _3G.stopCamera();         
        }
        else
        {
            USB.println("Error starting the camera");            
        }
    }
    else
    {
        USB.println("3G not started");
    }
}













