/*  
 *  ------ 3G_25 - Getting IMSI from SIM and IMEI -------- 
 *  
 *  Explanation: This example shows how to get IMSI form SIM card and IMEI 
 *  from 3G module
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
int answer;

void setup()
{
    // Setup for Serial port over USB:
    USB.ON();
    USB.println("USB port started...");

    // 1. activates the 3G module:
    answer = _3G.ON();
    if ((answer == 1) || (answer == -3))
    {        
        USB.println("3G module ready...");

        // 2. Gets IMSI:
        if (_3G.getIMSI() == 1)
        {
            USB.print("IMSI: ");
            USB.println(_3G.buffer_3G);
        }

        // 3. Gets IMEI:
        if (_3G.getIMEI() == 1)
        {
            USB.print("IMEI: ");
            USB.println(_3G.buffer_3G);
        }

        // 4. Gets firmware version:
        if (_3G.firmware_version() == 1)
        {
            USB.print("Firmware version: ");
            USB.println(_3G.buffer_3G);
        }

        // 5. Shows operator parameters
        _3G.show_APN();
    }
    else
    {
        // Problem with the communication with the 3G module
        USB.println(F("3G module not started"));
    }

}

void loop()
{

}


