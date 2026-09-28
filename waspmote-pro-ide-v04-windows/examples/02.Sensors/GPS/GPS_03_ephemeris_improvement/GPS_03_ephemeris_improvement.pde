/*  
 *  ------ [GPS_03] - Ephemeris improvement  -------- 
 *  
 *  Explanation: This example shows the different time for connecting to
 *  satellites using ephemeris.
 *  Firstly, time elapsed is measured until GPS module is connected to 
 *  satellites. 
 *  Secondly, ephemeris are stored and  loaded to the GPS module, and then
 *  time to connection is measured again to be compared with the first one.
 *  
 *  Copyright (C) 2012 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Implementation:    Yuri Carmona
 */

#include <WaspGPS.h>

// define GPS timeout when connecting to satellites
// this time is defined in seconds (240sec = 4minutes)
#define TIMEOUT 240

// define status variable for GPS connection
bool status;

// variable to store running time
unsigned long previous=0;



void setup()
{  
    // open USB port
    USB.ON();

    // setup the GPS module
    USB.println(F("GPS_03 example"));

    // Inits SD pins
    SD.ON();

    // Turn GPS on
    GPS.ON();
}


void loop()
{
    ///////////////////////////////////////    
    // 1. store execution time
    ///////////////////////////////////////    
    USB.println(F("GPS is not connected to satellites yet"));
    previous=millis();


    ///////////////////////////////////////    
    // 2. wait for GPS signal for specific time
    ////////////////////////////////////// 
    status=GPS.waitForSignal(TIMEOUT);

    if( status == true )
    {
        USB.println(F("Connected"));

        // Time elapsed without ephemeris
        USB.print(F("Time elapsed without ephemeris(ms): "));
        USB.println(millis()-previous,DEC);
    }
    else
    {
        USB.println(F("GPS TIMEOUT. NOT connected"));
    }

    ///////////////////////////////////////////////////////////////////// 
    // 3. if GPS is connected then store/load ephemeris to compare times
    ///////////////////////////////////////////////////////////////////// 
    if( status == true )
    {        
        // store ephemeris in "EPHEM.TXT"
        if( GPS.saveEphems() == 1 )
        {
            USB.println(F("Ephemeris stored successfully"));

            // switch GPS off
            GPS.OFF();
            USB.println(F("GPS OFF"));
            delay(5000);

            // switch GPS on
            GPS.ON();   
            USB.println(F("GPS ON"));

            // store execution time
            previous=millis();

            // load ephemeris previously stored in SD    
            if( GPS.loadEphems() == 1 ) 
            {
                USB.println(F("Ephemeris loaded successfully"));

                // wait until GPS is connected to satellites
                status=GPS.waitForSignal(TIMEOUT);

                if( status == true )
                {
                    USB.println(F("Connected"));    
                }
                else
                {
                    USB.println(F("GPS TIMEOUT. NOT connected"));
                }

                // Time elapsed with ephemeris
                USB.print(F("Time elapsed with ephemeris (ms): "));
                USB.println(millis()-previous,DEC);

            }
            else 
            {
                USB.println(F("Ephemeris load failed"));
            }

        }
        else 
        {
            USB.println(F("Ephemeris storing failed"));
        }
    }


    ///////////////////////////////////////////////////////////////////// 
    // 4. switch GPS off
    ///////////////////////////////////////////////////////////////////// 

    GPS.OFF();
    SD.OFF();
    USB.println(F("GPS OFF"));
    delay(5000);

    USB.println(F("-------------------"));
    USB.println(RTC.getTime());
    USB.println(F("-------------------"));

    ///////////////////////////////////////////////////////////////////// 
    // 5. switch GPS on
    ///////////////////////////////////////////////////////////////////// 
    GPS.ON();
    SD.ON();
    USB.println(F("GPS ON")); 


}






