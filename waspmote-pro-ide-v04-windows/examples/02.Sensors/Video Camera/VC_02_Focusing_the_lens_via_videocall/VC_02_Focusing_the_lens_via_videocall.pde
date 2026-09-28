/*  
 *  ------ VC_02 - Focusing the lens via videocall -------- 
 *  
 *  Explanation: This code helps you to focus the lens via videocall.
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


char phone_number[]="*********";
int count = 0;
int answer = 0;
int status_3G = 0;


void setup(){

    USB.ON();
    USB.println(F("Starting"));

    status_3G = _3G.ON();
    if ((status_3G == 1) || (status_3G == -3))
    {

        USB.println(F("3G module ready..."));
    
        _3G.setTime();
    
        // Sets pin code:
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
    
        // Waits for connection to the network:
        status_3G = _3G.check(60);    
        if (status_3G == 1)
        {
            USB.println(F("3G module connected to the network..."));
            
            _3G.VideoCallQuality(5);
            Utils.setLED(LED0, LED_ON);
            
            USB.println(F("Starting videocall..."));
            answer = _3G.makeVideoCall(phone_number, 0);
            if (answer != 1)
            {
                USB.println(F("Error starting the videocall."));
                USB.print(F("Error code: "));
                USB.println(answer, DEC);
                USB.println(F("The code will stuck here. Reboot Waspmote to restart."));
                while(1);
            }
            
            Utils.setLED(LED1, LED_ON);
        
            USB.println(F("*********************************************************************"));
            USB.println(F("Focus scketch 02. This program does a videocall."));
            USB.println(F("Keys with special functions:"));
            USB.println(F("  'a': IR LEDs off"));
            USB.println(F("  's': IR LED block 1 on, block 2 off"));
            USB.println(F("  'd': IR LED block 2 on, block 1 off"));
            USB.println(F("  'f': all IR LEDs on"));
            USB.println(F("  'q': IR cut filter enabled"));
            USB.println(F("  'w': IR cut filter disabled"));
            USB.println(F("  'z': hang the videocall"));
            USB.println(F("*********************************************************************"));
        }
        else
        {
            USB.println(F("3G module NOT connected to the network..."));
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
            case 'z':
                _3G.hangVideoCall();
                break;
            }
            delay(100);
        }while(USB.available() > 0);
    }
    else
    {
        USB.println("3G not started");
    }


}











