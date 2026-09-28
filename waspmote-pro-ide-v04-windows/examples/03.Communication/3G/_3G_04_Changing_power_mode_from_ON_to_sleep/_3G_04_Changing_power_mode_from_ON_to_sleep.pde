/*  
 *  ------  3G_04 - Changing power mode from ON to sleep  -------- 
 *  
 *  Explanation: This example shows how change the power mode from ON 
 *  to sleep mode. At this mode the power consumption of the 3G/GPRS
 *  board is around 1mA. 
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
 *  Version:           1.1
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego
 */

#include "Wasp3G.h"

int8_t answer;

void setup()
{
    // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));

    // 1. activates the 3G module:
    answer = _3G.ON();
    if ((answer == 1) || (answer == -3))
    {
        USB.println(F("3G module ready..."));

        // 2. changes the power mode from ON to sleep mode:
        USB.println(F("Changing power mode to sleep mode"));  
        USB.println(F("SIM card and RF functionalities are active"));

        if (_3G.setMode(_3G_SLEEP) == 1)
        {
            USB.println(F("Mode changed succesfully"));
            USB.println(F("For communicate with the module, change the power mode"));
        }
        else
        {
            USB.println(F("Error changing power mode"));
        }

        delay(5000);

        USB.println(F("Wake up the 3G/GPRS module"));   
        // 3. changes the power mode from sleep to full mode:
        if (_3G.setMode(_3G_FULL) == 1)
        {
            USB.println(F("Mode changed succesfully"));
        }
        else
        {
            USB.println(F("Error changing power mode"));
        }

        delay(5000);

        // 4. changes the power mode from full to minimum mode:
        USB.println(F("Now, changing power mode to sleep mode with RF and SIM disabled"));
        USB.println(F("First deactivate RF and SIM card"));
        if (_3G.setMode(_3G_MINIMUM) == 1)
        {
            USB.println(F("Mode changed succesfully"));
        }
        else
        {
            USB.println(F("Error changing power mode"));
        }  

        // 5. changes the power mode from minimum to sleep mode:
        USB.println(F("SIM card and RF functionalities are NOT active"));

        if (_3G.setMode(_3G_SLEEP) == 1)
        {
            USB.println(F("Mode changed succesfully. Consumption around 1mA"));
            USB.println(F("For communicate with the module, change the power mode"));    
        }
        else
        {
            USB.println(F("Error changing power mode"));
        }

        delay(5000);

        // 6. changes the power mode from sleep to full mode:
        USB.println(F("Wake up the 3G/GPRS module"));           
        if (_3G.setMode(_3G_FULL) == 1)
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
        // Problem with the communication with the 3G module
        USB.println(F("3G module not started"));
    }

    // 7. power off the 3G module
    _3G.OFF();

}

void loop()
{
}


