/*
 *  ------Waspmote OTA_07 Example--------
 *
 *  Explanation: This example shows how perform OTA programming using the
 *  3G+GPS module. It is necessary to specify the correct FTP settings.
 *
 *  Copyright (C) 2013 Libelium Comunicaciones Distribuidas S.L.
 *  http://www.libelium.com
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
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
 *  Version:                0.1
 *  Design:                 David Gascón
 *  Implementation:         Alejandro Gallego
 */

// include 3G+GPS library
#include <Wasp3G.h>
int answer, counter;

void setup(){
    
    //Check if the program has been programmed succesfully
    answer = Utils.checkNewProgram();    
    switch(answer)
    {
        case 0:
            USB.println(F("REPROGRAMMING ERROR"));
            break;    
        case  1:        
            USB.println(F("REPROGRAMMING OK"));
            break;    
        default:
            USB.println(F("RESTARTING"));
    }
    USB.print(F("Program version: "));
    USB.println(Utils.getProgramVersion(), DEC);
    
    
    // put your setup code here, to run once:
    
}


void loop(){
    
    //*****************************************************************
    //    User loop program
    //*****************************************************************
    
    // put your main code here, to run repeatedly:
    
    
    //*****************************************************************
    //    OTA standart loop
    //*****************************************************************
    
    //Starts the 3G + GPS module
    answer = _3G.ON();
    
    //Checks the start sequence: 1 for correct start and -3 for correct start with low battery level
    if ((answer == 1) || (answer == -3))
    {
        USB.println(F("3G+GPS module ready..."));
        USB.println(F("Connecting to the network")); 
        
        answer = _3G.check(60);
        
        if (answer == 1)
        {              
            USB.println(F("3G+GPS module connected to the network")); 
            USB.println(F("Starting OTA process")); 
            
            answer = _3G.requestOTA("FTP_address", "FTP_port", "FTP_user_name", "FTP_password");
            
            // If OTA process fails, show the error code
            USB.print(F("Error code:"));
            USB.println( answer, DEC);
        }
        else
        {
            USB.println(F("Error connecting to the network"));                
        }
    }
    else
    {
        USB.println(F("Error starting the 3G+GPS module"));        
    }
        
    _3G.OFF();
}




