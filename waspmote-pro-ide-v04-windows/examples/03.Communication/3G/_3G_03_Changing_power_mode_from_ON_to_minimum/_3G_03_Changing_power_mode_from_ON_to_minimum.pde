/*  
 *  ------  3G_03 - Changing power mode from ON to minimum  -------- 
 *  
 *  Explanation: This example shows how change the power mode from ON 
 *  to minimum functionality
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
        // 2. changes the power mode from ON to minimum functionality:
        USB.println(F("Changing power mode to minimum functionality"));  
        USB.println(F("SIM card and RF functionalities are not active"));

        if (_3G.setMode(_3G_MINIMUM) == 1)
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

    // 3. powers off the 3G module
    _3G.OFF();

}

void loop()
{
}


