/*  
 *  --------------- 3G_14 - Sending AT commands ----------------- 
 *  
 *  Explanation: This example shows how to send AT commands to the
 *  3G + GPS module
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
 *  Version:           1.2
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego
 */

#include "Wasp3G.h"

char at_command[] = "+CGMR?";
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

        // 2. sends an AT command
        _3G.sendATCommand("AT command without AT");
        USB.println(_3G.buffer_3G);

        // 3. This command gets the version of the module
        _3G.sendATCommand(at_command);
        USB.println(_3G.buffer_3G);
    }
    else
    {
        // Problem with the communication with the 3G module
        USB.println(F("3G module not started"));
    }

    // 4. powers off the 3G module:
    _3G.OFF();

}

void loop()
{
}









