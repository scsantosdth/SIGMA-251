/*  
 *  ------ VC_07 - PIR interrupt with picture and FTP -------- 
 *  
 *  Explanation: This example shows how use the PIR interrupt taking a 
 *  picture and uploading it when the interrupt occurs. To use this example,
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

char ftp_server[] = "ftp_server";
char ftp_port[] = "ftp_port";
char username[] = "username";
char password[] = "password";

int count = 0;
int answer = 0;
unsigned long time;
int storage_unit;

char picture_name[30];

void setup(){

    USB.ON();
    USB.println(F("Starting"));

    USB.println(F("**************************"));
    // 1. sets operator parameters
    _3G.set_APN("apn", "login", "password");
    // And shows them
    _3G.show_APN();
    USB.println(F("**************************"));   

    // 2. activates the 3G module
    answer = _3G.ON();
    if ((answer == 1) || (answer == -3))
    {
        USB.println(F("3G module ready..."));

        // 3. sets pin code:
        USB.println(F("Setting PIN code..."));
        // **** must be substituted by the SIM code
        if (_3G.setPIN("****") == 1) 
        {
            USB.println(F("PIN code accepted"));
        }
        else
        {
            USB.println(F("PIN code incorrect"));
        }        

        _3G.setTime();


        // 4. disables RF to reduce the battery consumption
        _3G.setMode(_3G_RF_OFF);
        USB.println(F("RF circuits disabled"));

        // if there isn't a name the 3G module use the date and time for the picture's name
        _3G.pictureName("");


        // 5. selects storage
        USB.println(F("Waiting for SD..."));

        time = millis();
        answer = 0;
        while ((answer == 0) && ((millis() - time) < 60000))
        {
            answer = _3G.isSD();
            // Condition to avoid an overflow (DO NOT REMOVE)
            if (millis() < time)
            {
                time = millis();	
            }
            delay(2000);
        }

        if (answer == 1)
        {
            // Selects microSD to store the pictures
            answer = _3G.selectStorage(1);
            if (answer == 1)
            {
                storage_unit = 1;
                USB.println(F("SD selected to store data"));
            }
            else
            {
                storage_unit = 0;
                USB.println(F("SD failed. Using module memory to store data"));
            }
        }
        else
        {
            // Selects module memory to store the pictures
            _3G.selectStorage(0); 
            storage_unit = 0;  
            USB.println(F("SD card not available. Using module memory to store data")); 
        }
    }
    else
    {
        USB.println(F("3G module NOT ready..."));
    }
}


void loop(){ 


    // 6. Enables PIR interrupt
    USB.print(F("Enabling PIR interrupt..."));
    _3G.enablePIRInterrupt();
    USB.println(F("ready"));

    // 7. waits the interrupt
    do{
        PWR.sleep(0);  
    }
    while ( intFlag & PIR_3G_INT == 0);
    USB.println(F("PIR interrupt detected"));

    // 8. disables the interrupt and start communications with the 3G module
    _3G.disablePIRInterrupt(1);


    // 9. enables RF
    USB.println(F("Changes power mode to full"));
    _3G.setMode(_3G_FULL);

    // 10. Checks the micro SD and selects it if available
    answer = _3G.isSD();
    if ((answer == 1) && (storage_unit == 0))
    {
        // Selects microSD to store the pictures
        answer = _3G.selectStorage(1);
        if (answer == 1)
        {
            storage_unit = 1;
            USB.println(F("SD selected to store data"));
        }
        else
        {
            storage_unit = 0;
            USB.println(F("SD failed. Using module memory to store data"));
        }     
    }
    else if(answer == 0)
    {
        storage_unit = 0; 
        USB.println(F("SD not detected. Using module memory to store data"));       
    }

    // 11. starts the camera and configures it
    count = 3;
    do{
        answer = _3G.startCamera();
        count--;
    }
    while ((answer != 1) && (count > 0));


    if (answer == 1)
    {
        // 12. configures the camera
        _3G.autoLevel();
        _3G.cameraResolution(5);
        _3G.cameraBrightness(3);

        count = 3;
        do{
            // power on the LED light 
            _3G.autoLight();

            // 13. takes a picture
            answer = _3G.takePicture();

            // power off the LEDs
            _3G.powerIRLED(0);
            count--;
        }
        while ((answer != 1) && (count > 0));
        // 14. saves the name of the picture
        strcpy(picture_name, _3G.buffer_3G);

        // 15. stops the camera
        _3G.stopCamera();

        if (answer == 1)
        {
            USB.println(F("Picture captured!"));    
            USB.print(F("Connecting to the network..."));

            // 16. waits for connection to the network
            answer = _3G.check(180);
            if (answer == 1){
                USB.println(F("connected"));    

                // 17. configures 3G onnection for FTP
                answer = _3G.configureFTP(ftp_server, ftp_port, username, password, 1, "I");
                if (answer == 1)
                {

                    USB.print(F("Uploading the picture..."));
                    USB.println(picture_name);

                    // 18. uploads the file to the FTP server:
                    if (storage_unit == 1)
                    {                    
                        answer = _3G.uploadFile(4, picture_name);
                    }
                    else
                    {
                        answer = _3G.uploadFile(1, picture_name);
                    }

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

        // 19. Deletes the picture
        _3G.cd("Picture");
        answer = _3G.del(picture_name);
        if (answer == 1)
        {
            USB.println(F("File deleted"));   
        }
        else
        {
            USB.println(F("File NOT deleted"));  
        }        
        _3G.cd("..");

    }
    else
    {
        USB.print("Error starting the camera. Error code: ");
        USB.println(answer, DEC);
    }

    // 20. disables RF to reduce the battery consumption
    _3G.setMode(_3G_RF_OFF);    
    USB.println(F("RF circuits disabled"));
}









