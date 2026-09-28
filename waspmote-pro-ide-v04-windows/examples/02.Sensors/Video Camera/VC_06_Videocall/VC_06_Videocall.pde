/*  
 *  ------ VC_06 - Videocall -------- 
 *  
 *  Explanation: This code does a videcall of 30 seconds.
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
            
            delay(30000);
            
            USB.println(F("Hangs the videocall..."));
            _3G.hangVideoCall();
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
        
        USB.println(F("Power off the 3G module"));
        _3G.OFF();
}


void loop(){ 
    

}










