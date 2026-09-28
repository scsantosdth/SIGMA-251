/*  
 *  ------  GPRS_SIM928A_03 - Changing power mode from ON to minimum  -------- 
 *  
 *  Explanation: This example shows how change the power mode from ON 
 *  to minimum functionality
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
 *  Version:           0.1 
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego
 */

#include "WaspGPRS_SIM928A.h"
int answer;

void setup()
{
    // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));

    // 1. activates the GPRS_SIM928A module:
    answer = GPRS_SIM928A.ON();
    if ((answer == 1) || (answer == -3))
    {    
        USB.println(F("GPRS_SIM928A module ready..."));
             
        // 2. changes the power mode from ON to OFF:
        USB.println(F("Changing power mode to minimum functionality")); 
        
        if (GPRS_SIM928A.setMode(GPRS_PRO_MIN) == 1)
        {
            USB.println(F("Mode changed succesfully"));
        }
        else
        {
            USB.println(F("Error changing power mode"));
        }
    }
    else
    {
        USB.println(F("GPRS_SIM928A module NOT ready..."));
    }
}

void loop()
{
}

