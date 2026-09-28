/*  
 *  ------ GPRS_SIM908_24 - Getting_GPS_info -------- 
 *  
 *  Explanation: This example shows how to get parsed NMEA strings and 
 *  shows them by serial monitor
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

#include <WaspGPRS_SIM908.h>

int8_t answer, x, y;
int8_t GPS_status = 0;

void setup()
{
    // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));

    // 1. activates the GPRS_SIM908 module:
    answer = GPRS_SIM908.ON();
    if ((answer == 1) || (answer == -3))
    {

        USB.println(F("GPRS_SIM908 module ready..."));

        // 2. starts the GPS in MS-based mode:
        USB.println(F("Starting in stand-alone mode")); 
        GPS_status = GPRS_SIM908.GPS_ON();
        if (GPS_status == 1)
        { 
            USB.println(F("GPS started"));
            // 3. waits to fix satellites
            while (GPRS_SIM908.checkGPS() < 3)
            {
                USB.print(".");
                 delay(5000);   
            }
        }
        else
        {
            USB.println(F("GPS NOT started"));   
        }
    }
    else
    {
        // Problem with the communication with the GPRS_SIM908 module
        USB.println(F("GPRS_SIM908 module not started")); 
    }
}

void loop()
{
    USB.println(F("\n********************************"));

    // 4. checks the status of the GPS
    if ((GPS_status == 1) && (GPRS_SIM908.checkGPS() > 2))
    {
        // 5. reads GPS data
        answer = 0;
        answer += GPRS_SIM908.getGPSData(BASIC, 1);
        answer += GPRS_SIM908.getGPSData(GGA, 1);
        answer += GPRS_SIM908.getGPSData(GLL, 1);
        answer += GPRS_SIM908.getGPSData(GSA, 1);
        answer += GPRS_SIM908.getGPSData(GSV, 1);
        answer += GPRS_SIM908.getGPSData(RMC, 1);
        answer += GPRS_SIM908.getGPSData(VTG, 1);
        answer += GPRS_SIM908.getGPSData(ZDA, 1);

        if (answer == 8)
        {
            // 6. Shows all GPS data collected
            USB.print(F("Latitude (DDmm.mmmmmm): "));
            USB.print(GPRS_SIM908.latitude);
            USB.print(F(" "));
            USB.print(GPRS_SIM908.NS_indicator);
            USB.print(F("\t\tLongitude (DDDmm.mmmmmm): "));
            USB.print(GPRS_SIM908.longitude);
            USB.print(F(" "));
            USB.println(GPRS_SIM908.EW_indicator);
            USB.print(F("Latitude (in degrees): "));
            USB.print(GPRS_SIM908.convert2Degrees(GPRS_SIM908.latitude, GPRS_SIM908.NS_indicator));
            USB.print(F("\t\tLongitude (in degrees): "));
            USB.println(GPRS_SIM908.convert2Degrees(GPRS_SIM908.longitude, GPRS_SIM908.EW_indicator));
            USB.print(F("Date: "));
            USB.print(GPRS_SIM908.date);
            USB.print(F("\t\tUTC_time: "));
            USB.println(GPRS_SIM908.UTC_time);
            USB.print(F("Altitude: "));
            USB.print(GPRS_SIM908.altitude);
            USB.print(F("\t\tSpeedOG: "));
            USB.print(GPRS_SIM908.speedOG);
            USB.print(F("\t\tCourse: "));
            USB.println(GPRS_SIM908.courseOG);
    
            USB.print(F("TTFF: "));
            USB.print(GPRS_SIM908.TTFF, DEC);
            
            USB.print(F("\t\tSatellites in use: "));
            USB.println(GPRS_SIM908.num_sat, DEC);
    
            USB.print(F("MSL_altitude: "));
            USB.println(GPRS_SIM908.MSL_altitude);
            USB.print(F("Geoid separation: "));
            USB.println(GPRS_SIM908.geoid_separation);   
            USB.print(F("Ellipsoid altitude: "));
            USB.println(GPRS_SIM908.MSL_altitude + GPRS_SIM908.geoid_separation);     
    
            USB.print(F("Mode: "));
            USB.println(GPRS_SIM908.mode);      
            USB.print(F("Manual/auto mode: "));
            USB.println(GPRS_SIM908.manual_auto);
            USB.print(F("2D/3D mode: "));
            USB.println(GPRS_SIM908.FIX_2D_3D);     
    
            USB.print("PDOP: ");
            USB.print(GPRS_SIM908.PDOP);
            USB.print("\t\tHDOP: ");
            USB.print(GPRS_SIM908.HDOP);
            USB.print("\t\tVDOP: ");
            USB.println(GPRS_SIM908.VDOP);
    
            USB.print("Satellite ID\t|");            
            for (x = 0; x < GPRS_SIM908.num_sat; x++)
            { 
                USB.print(GPRS_SIM908.sat_info[0][x], DEC);
                USB.print("\t");
            }
    
            USB.print("\r\nElevation\t|");            
            for (x = 0; x < GPRS_SIM908.num_sat; x++)
            { 
                USB.print(GPRS_SIM908.sat_info[1][x], DEC);
                USB.print("\t");
            }
    
            USB.print("\r\nAzimuth\t\t|");            
            for (x = 0; x < GPRS_SIM908.num_sat; x++)
            { 
                USB.print(GPRS_SIM908.sat_info[2][x], DEC);
                USB.print("\t");
            }
            USB.print("\r\nSNR (C/N0)\t|");            
            for (x = 0; x < GPRS_SIM908.num_sat; x++)
            { 
                USB.print(GPRS_SIM908.sat_info[3][x], DEC);
                USB.print("\t");
            }
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

