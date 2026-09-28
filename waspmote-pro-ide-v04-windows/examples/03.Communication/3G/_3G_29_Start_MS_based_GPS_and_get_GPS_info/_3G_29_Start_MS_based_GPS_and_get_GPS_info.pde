/*  
 *  ------ 3G_29 - Start MS-based GPS and get GPS info -------- 
 *  
 *  Explanation: This example shows how start the GPS in MS-based
 *  mode and it waits for GPS data is available. When the GPS data is 
 *  available shows it every two seconds
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

char apn[] = "apn";
char login[] = "login";
char password[] = "password";

int8_t answer, GPS_status = 0;

void setup()
{
    // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));

    USB.println(F("**************************"));
    // 1. sets operator parameters
    _3G.set_APN(apn, login, password);
    // And shows them
    _3G.show_APN();
    USB.println(F("**************************"));

    // 2. activates the 3G module:
    answer = _3G.ON();
    if ((answer == 1) || (answer == -3))
    {

        USB.println(F("3G module ready..."));

        // 3. sets pin code
        USB.println(F("Setting PIN code..."));
        // **** must be substituted by the SIM code
        if(_3G.setPIN("") == 1)
        {
            USB.println(F("PIN code accepted"));
        }
        else
        {
            USB.println(F("PIN code incorrect"));
        }

        // 4. waits for connection to the network
        answer = _3G.check(180);    
        if (answer == 1)
        { 
            USB.println(F("3G module connected to the network..."));

            // 5. starts the GPS in MS-based mode:
            USB.println(F("Starting in MS-based mode")); 
            GPS_status = _3G.startGPS(2, "supl.google.com", "7276");
            if (GPS_status == 1)
            { 
                USB.println(F("GPS started"));
            }
            else
            {
                USB.println(F("GPS NOT started"));   
            }
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
}

void loop()
{

    USB.println(F("\n********************************"));

    if (GPS_status == 1)
    {
        // 3. Gets GPS info
        answer = _3G.getGPSinfo();
        if (answer == 1)
        {            
            // 4. when it's available, shows it
            USB.print(F("Latitude (in degrees): "));
            USB.println(_3G.convert2Degrees(_3G.latitude));
            USB.print(F("Longitude (in degrees): "));
            USB.println(_3G.convert2Degrees(_3G.longitude));
            USB.print(F("Date: "));
            USB.println(_3G.date);
            USB.print(F("UTC_time: "));
            USB.println(_3G.UTC_time);
            USB.print(F("Altitude: "));
            USB.println(_3G.altitude);
            USB.print(F("SpeedOG: "));
            USB.println(_3G.speedOG);
            USB.print(F("Course: "));
            USB.println(_3G.course);
            USB.println(F(""));
        }
        else
        {
            USB.print(F("Data not available...."));  
        }
    }
    else
    {
        USB.print(F("GPS not started"));  
        delay(58000);      
    }
    delay(2000);


}

