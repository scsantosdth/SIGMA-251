/*  
 *  ------ GPRS_SIM928A_24 - Getting_GPS_info -------- 
 *  
 *  Explanation: This example shows how to get parsed NMEA strings and 
 *  shows them by serial monitor
 *  
 *  Copyright (C) 2015 Libelium Comunicaciones Distribuidas S.L. 
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

#include <WaspGPRS_SIM928A.h>

int8_t answer, x, y;
int8_t GPS_status = 0;

void setup()
{
    // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));

    // 1. activates the GPRS_SIM928A module:
    answer = GPRS_SIM928A.ON();
    if ((answer == 1) || (answer == -3))
    {

        USB.println(F("GPRS_SIM928A module ready..."));

        // 2. starts the GPS in MS-based mode:
        USB.println(F("Starting in stand-alone mode")); 
        GPS_status = GPRS_SIM928A.GPS_ON();
        if (GPS_status == 1)
        { 
            USB.println(F("GPS started"));
            // 3. waits to fix satellites
            GPRS_SIM928A.waitForGPSSignal(30);
        }
        else
        {
            USB.println(F("GPS NOT started"));   
        }
    }
    else
    {
        // Problem with the communication with the GPRS_SIM928A module
        USB.println(F("GPRS_SIM928A module not started")); 
    }
}

void loop()
{
    USB.println(F("\n********************************"));

    // 4. checks the status of the GPS
    if ((GPS_status == 1) && (GPRS_SIM928A.waitForGPSSignal(30) == 1))
    {
        // 5. reads GPS data
        answer = GPRS_SIM928A.getGPSData(1);

        if (answer == 1)
        {
            // 6. Shows all GPS data collected          
            USB.print(F("Latitude (in degrees): "));
            USB.print(GPRS_SIM928A.latitude);
            USB.print(F("\t\tLongitude (in degrees): "));
            USB.println(GPRS_SIM928A.longitude);
            USB.print(F("Date: "));
            USB.print(GPRS_SIM928A.date);
            USB.print(F("\t\tUTC_time: "));
            USB.println(GPRS_SIM928A.UTC_time);
            USB.print(F("Altitude: "));
            USB.print(GPRS_SIM928A.altitude);
            USB.print(F("\t\tSpeedOG: "));
            USB.print(GPRS_SIM928A.speedOG);
            USB.print(F("\t\tCourse: "));
            USB.println(GPRS_SIM928A.courseOG);
            
            USB.print(F("\t\tSatellites in use: "));
            USB.println(GPRS_SIM928A.sats_in_use, DEC);
            USB.print(F("\t\tSatellites in view: "));
            USB.println(GPRS_SIM928A.sats_in_use, DEC); 
    
            USB.print("PDOP: ");
            USB.print(GPRS_SIM928A.PDOP);
            USB.print("\t\tHDOP: ");
            USB.print(GPRS_SIM928A.HDOP);
            USB.print("\t\tVDOP: ");
            USB.print(GPRS_SIM928A.VDOP);
            USB.print("\t\tSNR: ");
            USB.println(GPRS_SIM928A.SNR, DEC);
    
            
            USB.println("");
        }    
    }
    else
    {
        USB.println(F("GPS not started"));  
        delay(10000);      
    }
    delay(5000);

}

