/*  
 *  ------  3G_09 - Getting RSSI and network info  -------- 
 *  
 *  Explanation: This example shows how to get RSSI level and network info
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

#include <Wasp3G.h>

int8_t answer;

void setup()
{
}

void loop()
{

    // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));
    USB.println(F("**************************"));

    // 1. activates the 3G module:
    answer = _3G.ON();
    if ((answer == 1) || ( answer == -3))
    {
        USB.println(F("3G module ready..."));

        // 2. sets pin code:
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

        // 3. waits for connection to the network
        answer = _3G.check(180);    
        if (answer == 1)
        { 
            USB.println(F("3G module connected to the network..."));        

            // 4. shows GSM data
            USB.println(F("***********************************************"));
            USB.println(F("    ONLY GSM"));
            _3G.setNetworkMode(1);
            delay(15000);
            answer = _3G.getRSSI();
            if (answer != 1)
            {
                USB.print(F("RSSI: "));
                USB.print(answer,DEC);
                USB.println(F("dBm"));
            }    
            USB.println(F("UE system info"));
            _3G.getUEsysInfo();
            USB.println(_3G.buffer_3G);
            USB.print(F("Network mode: "));
            USB.println(_3G.showsNetworkMode(),DEC);
            USB.println(F("Cell system info"));
            _3G.getCellsysInfo();
            USB.println(_3G.buffer_3G);

            // 5. shows WCDMA data
            USB.println(F("***********************************************"));
            USB.println(F("    ONLY WCDMA"));
            _3G.setNetworkMode(2);
            delay(15000);    
            answer = _3G.getRSSI();
            if (answer != 1)
            {
                USB.print(F("RSSI: "));
                USB.print(answer,DEC);
                USB.println(F("dBm"));
            }
            USB.println(F("UE system info"));
            _3G.getUEsysInfo();
            USB.println(_3G.buffer_3G);
            USB.print(F("Network mode: "));
            USB.println(_3G.showsNetworkMode(),DEC);
            _3G.WCDMAsysInfo();
            USB.println(_3G.buffer_3G);
            USB.println(F("WCDMA system info"));
            _3G.WCDMAsysInfo();
            USB.println(_3G.buffer_3G);

            _3G.setNetworkMode(0);
        }
        else
        {
            USB.println(F("3G module cannot connect to the network..."));  
        }
    }    
    else    
    {
        // Problem with the communication with the 3G module
        USB.println(F("3G module not started"));
    }

    // 6. powers off the 3G module
    _3G.OFF(); 
    USB.println(F("Sleeping..."));

    // 7. sleeps one hour
    PWR.deepSleep("00:01:00:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

}

