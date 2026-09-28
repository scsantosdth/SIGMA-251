/*  
 *  ------ 3G_28 - Start GPS and get GPS info -------- 
 *  
 *  Explanation: This example shows how start the GPS in stand-alone 
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
 *  Version:           1.1 
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego 
 */

#include "Wasp3G.h"

int8_t answer, GPS_status = 0;

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

        // 2. starts the GPS in MS-based mode:
        USB.println(F("Starting in stand-alone mode")); 
        GPS_status = _3G.startGPS();
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

