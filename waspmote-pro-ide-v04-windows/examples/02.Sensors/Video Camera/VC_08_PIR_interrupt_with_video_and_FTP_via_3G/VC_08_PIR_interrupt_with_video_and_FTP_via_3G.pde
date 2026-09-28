/*  
 *  ------ VC_08 - PIR interrupt with picture and FTP -------- 
 *  
 *  Explanation: This example shows how use the PIR interrupt taking a 
 *  picture and uploading it when the interrupt occurs.To use this example,
 *  a 3G + GPS module is required.
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
unsigned long time;

char video_name[30];

void setup(){

    USB.ON();
    USB.println(F("Starting"));

    answer = _3G.ON();
    if ((answer == 1) || (answer == -3))
    {
        USB.println(F("3G module ready..."));

        _3G.setTime();

        _3G.setMode(_3G_RF_OFF);
        USB.println(F("RF circuits disabled"));

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
            USB.println("SD card not available. Check that the SD card is inserted and reboot the Waspmote"); 
        }
    }
    else
    {
        USB.println(F("3G module NOT ready..."));
    }
}


void loop(){ 
    USB.print(F("Enabling PIR interrupt..."));
    _3G.enablePIRInterrupt();
    USB.println(F("ready"));

    // waits the interrupt
    do{
        PWR.sleep(0);  
    }
    while ( (intFlag & PIR_3G_INT) == 0);
    USB.println(F("PIR interrupt detected"));

    // disables the interrupt and start communications with the 3G module
    _3G.disablePIRInterrupt(1);

    USB.println(F("Changes power mode to full"));
    _3G.setMode(_3G_FULL);

    // sets pin code
    USB.println(F("Setting PIN code..."));
    if(_3G.setPIN("****") == 1)
    {
        USB.println(F("PIN code accepted"));
    }
    else
    {
        USB.println(F("PIN code incorrect"));
    }

    // starts the camera and configures it
    count = 3;
    do{
        answer = _3G.startCamera();
        count--;
    }while ((answer != 1) && (count > 0));


    if (answer == 1)
    {
        _3G.cameraResolution(3);
        _3G.cameraBrightness(3);
        _3G.cameraRotation("0");

        count = 3;
        do{
            // power on the LED light 
            _3G.autoLight();
            answer = _3G.startVideo();
            count--;
        }while ((answer != 1) && (count > 0));
        // saves the name of the picture
        strcpy(video_name, _3G.buffer_3G); 

        if (answer == 1){


            digitalWrite(MUX0, LOW);
            digitalWrite(MUX1, LOW);
            pinMode(PIR_3G_PIN_MON,INPUT);
            delay(500);
            while (digitalRead(PIR_3G_PIN_MON) == 1)
            {
                _3G.autoLight();
                delay(100);
            }

            pinMode(PIR_3G_PIN_MON,OUTPUT);
            digitalWrite(PIR_3G_PIN_MON,LOW);
            Utils.setMuxSocket1();
            _3G.stopVideo();

            // power off the LEDs
            _3G.powerIRLED(0);

            // stops the camera
            _3G.stopCamera();
            USB.println(F("Video captured!"));    
            USB.print(F("Connecting to the network..."));    
            answer = _3G.check(60);
            if (answer == 1)
            {
                USB.println(F("connected"));    

                // configures 3G onnection for FTP
                answer = _3G.configureFTP("ftp_server", "ftp_port", "username", "password", 1, "I");
                if (answer == 1)
                {

                    USB.print(F("Uploading the picture..."));
                    USB.println(video_name);

                    // uploads file from SD card to the FTP server:
                    answer = _3G.uploadFile(5, video_name);
                    if (answer == 1)
                    {
                        USB.println(F("Upload done"));
                    }
                    else if(answer == -2)
                    {
                        USB.print(F("Upload failed. Error code: "));
                        USB.println(answer, DEC);
                        USB.print(F("CME error code: "));
                        USB.println(_3G.CME_CMS_code, DEC);
                    }
                    else 
                    {
                        USB.print(F("Upload failed. Error code: "));
                        USB.println(answer, DEC);
                    }
                }
                else
                {
                    USB.print(F("Configuration failed. Error code:"));
                    USB.println(answer, DEC);
                }
            }
            else
            {
                USB.println(F("Error connecting to the network"));
            }
        }
        else
        {
            USB.print(F("Error taking the picture. Error code:"));
            USB.println(answer, DEC);
        }
    }
    else
    {
        USB.print("Error starting the camera. Error code: ");
        USB.println(answer, DEC);

        // stops the camera
        _3G.stopCamera();
    }

    _3G.setMode(_3G_RF_OFF);    
    USB.println(F("RF circuits disabled"));
}




