/*  
 *  ------  GPRS_05 - Changing power mode from RF_OFF to minimum  -------- 
 *  
 *  Explanation: This example shows how change the power mode from RF_OFF 
 *  to minimum consumption mode. 
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
 *  Version:           0.3
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego
 */

#include "WaspGPRS_Pro.h"
int answer;

void setup()
{
    // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));

    // 1. activates the GPRS_SIM908 module:
    answer = GPRS_Pro.ON(); 
    if ((answer == 1) || (answer == -3))
    {
        USB.println(F("GPRS_Pro module ready..."));
    
        // 2. changes the power mode to RF_OFF:
        if(GPRS_Pro.setMode(GPRS_PRO_RF_OFF) == 1)
        {
            USB.println(F("Power mode ==> RF_OFF"));
    
            // 3. to change from RF_OFF to minimum consumption FIRST we need to change to FULL mode
            USB.println(F("First change to FULL power mode")); 
            
            if(GPRS_Pro.setMode(GPRS_PRO_FULL) == 1)
            {
                USB.println(F("Mode changed succesfully to FULL mode"));
                
                // 4. now we can change to minimum consumption mode:
                USB.println(F("Now, we change to minimum power mode")); 
                
                if (GPRS_Pro.setMode(GPRS_PRO_MIN) == 1)
                {
                    USB.println(F("Mode changed succesfully to minimum consumption"));
                }
                else
                {
                    USB.println(F("Error changing power mode"));
                }
            }
            else
            {
                USB.println(F("Error changing power mode"));
            }
        }
        else
        {
            USB.println(F("Error changing power mode"));
        }
    }
    else
    {
        USB.println(F("GPRS_Pro module NOT ready..."));
    }
    
    GPRS_Pro.OFF();


}

void loop()
{
}



