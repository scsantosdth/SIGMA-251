/*  
 *  ------  GPRS_SIM908_10 - Getting RSSI and cellID  -------- 
 *  
 *  Explanation: This example shows how to gets RSSI and cell ID and
 *  shows it
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
    // 1. activates the GPRS_SIM908 module:
    answer = GPRS_SIM908.ON(); 
    if ((answer == 1) || (answer == -3))
    {
        USB.println(F("GPRS_SIM908 module ready..."));
    
        // 2. sets pin code
        USB.println(F("Setting PIN code..."));
        // **** must be substituted by the SIM code
        if (GPRS_SIM908.setPIN("****") == 1) 
        {
            USB.println(F("PIN code accepted"));
        }
        else
        {
            USB.println(F("PIN code incorrect"));
        }    
    }
    else
    {
        USB.println(F("GPRS_SIM908 module NOT ready..."));
    }

}

void loop()
{
    // 3. waits for connection to the network
    answer = GPRS_SIM908.check(20);    
    if (answer == 1)
    {
        USB.println(F("GPRS_SIM908 module connected to the network..."));           
    }
    else
    {
        USB.println(F("GPRS_SIM908 module cannot connect to the network..."));
    }
    
    // 4. reads cell info
    if (GPRS_SIM908.getCellInfo() == 1)
    {
        USB.print(F("RSSI: "));
        USB.print(GPRS_SIM908.RSSI,DEC);
        USB.println(F("dBm"));
        USB.print(F("Cell ID: "));
        USB.println(GPRS_SIM908.cellID);
    }
    delay(3000);

}
