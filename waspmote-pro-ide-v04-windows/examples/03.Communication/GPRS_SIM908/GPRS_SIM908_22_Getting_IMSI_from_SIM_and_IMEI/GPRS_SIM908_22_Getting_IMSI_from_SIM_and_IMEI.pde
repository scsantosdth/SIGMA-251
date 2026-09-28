/*  
 *  ------ GPRS_SIM908_22 - Getting IMSI from SIM and IMEI -------- 
 *  
 *  Explanation: This example shows how to get IMSI form SIM card, IMEI and 
 * 	firmware version from GPRS_Pro module and APN parameters
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
 *  Version:           0.1 
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego 
 */

#include "WaspGPRS_SIM908.h"

int answer;

void setup()
{
    // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));

    // 1. activates the GPRS_SIM908 module:
    answer = GPRS_SIM908.ON(); 
    if ((answer == 1) || (answer == -3))
    {
        USB.println(F("GPRS SIM908 module ready..."));

        // 2. gets IMSI:
        while (GPRS_SIM908.getIMSI() != 1);
        USB.print(F("IMSI: "));
        USB.println(GPRS_SIM908.buffer_GPRS);

        // 3. gets IMEI:
        while (GPRS_SIM908.getIMEI() != 1);
        USB.print(F("IMEI: "));
        USB.println(GPRS_SIM908.buffer_GPRS);

        // 4. shows firmware:
        while (GPRS_SIM908.firmware_version() != 1);
        USB.print(F("Firmware version: "));
        USB.println(GPRS_SIM908.buffer_GPRS);

        // 5. show operator parameters:
        GPRS_SIM908.show_APN();

    }
    else
    {
        USB.println(F("GPRS SIM908 module not ready"));    
    }

    // 6. powers off the GPRS_SIM908 module
    GPRS_SIM908.OFF(); 
}

void loop()
{

}

