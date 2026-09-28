/*  
 *  ------ 3G_31 - Demo GPS tracker -------- 
 *  
 *  Explanation: This example tracks the 3G+GPS and it will send the GPS to
 *  the php scripts when GPS gets the position
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
#include <WaspFrame.h>

char url[] = "http://pruebas.libelium.com";
uint16_t port = 80;
char GPS_data[250];
char moteID[] = "tracker_01";

char apn[] = "apn";
char login[] = "login";
char password[] = "password";


int8_t answer;
int GPS_status = 0;
int GPS_fix = 0;
int GPRS_status = 0;

void setup()
{

    USB.println(F("**************************"));
    // 1. sets operator parameters
    _3G.set_APN(apn, login, password);
    // And shows them
    _3G.show_APN();
    USB.println(F("**************************")); 

    // 2. activates the 3G+GPS module:
    answer = _3G.ON();
    if ((answer == 1) || (answer == -3))
    {

        USB.println(F("3G+GPS module ready..."));

        // 3. starts the GPS:
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
        // Problem with the communication with the 3G+GPS module
        USB.println(F("3G+GPS module not started")); 
    }
}

void loop()
{
    memset(GPS_data, '\0', sizeof(GPS_data));
    // 5. checks the status of the GPS
    if ((GPS_status == 1) && (_3G.getGPSinfo() == 1))
    {
        GPS_fix = 1;
        Utils.setLED(LED0, LED_ON);
        // when it's available, shows it
        USB.print(F("Latitude (degrees):"));
        USB.println(_3G.convert2Degrees(_3G.latitude));
        USB.print(F("Longitude (degrees):"));
        USB.println(_3G.convert2Degrees(_3G.longitude));
        USB.print(F("Speed over the ground"));
        USB.println(_3G.speedOG);
        USB.print(F("Course over the ground:"));
        USB.println(_3G.course);
        USB.print(F("altitude (m):"));
        USB.println(_3G.altitude);

        // 6a. add GPS data 
        // add GPS position field
        snprintf(GPS_data, sizeof(GPS_data), "GET /demo_sim908.php?%svisor=false&latitude=%s&longitude=%s&altitude=%s&time=20%c%c%c%c%c%c%s&satellites=7&speedOTG=%s&course=%s HTTP/1.1\r\nHost: %s\r\nContent-Length: 0\r\n\r\n",
            url,
            _3G.latitude,
            _3G.longitude,
            _3G.altitude,
            _3G.date[4], _3G.date[5], _3G.date[2], _3G.date[3], _3G.date[0], _3G.date[1], _3G.UTC_time,
            _3G.speedOG,
            _3G.course,
            url);

        USB.print(F("Data string: "));  
        USB.println(GPS_data);  
    }
    else if((GPS_status == 1) && (_3G.getGPSinfo() != 1))
    {
        GPS_fix = 0;
        Utils.setLED(LED0, LED_OFF);
        // 6c. add not GPS fixed string
        USB.println(F("GPS not fixed")); 		
    }
    else
    {
        GPS_fix = 0;
        Utils.setLED(LED0, LED_OFF);
        // 6d. add not GPS started string
        USB.println(F("GPS not started. Restarting"));
        GPS_status = _3G.startGPS();
    }

    GPRS_status = _3G.check(30);

    if((GPRS_status == 1) && (GPS_fix == 1))
    {
        Utils.setLED(LED1, LED_ON);
        // 7. Sends the frame
        answer = _3G.readURL(url, port, GPS_data);

        // checks the answer
        if ( answer == 1)
        {
            USB.println(F("Done"));  
            USB.println(_3G.buffer_3G);
            Utils.setLED(LED1, LED_ON);
            delay(300);
            Utils.setLED(LED1, LED_OFF);
        }
        else 
        {
            USB.println(F("Failed"));
            Utils.setLED(LED0, LED_ON);
            delay(300);
            Utils.setLED(LED0, LED_OFF);
        } 
    }
    else if(GPRS_status == 1)
    {
        Utils.setLED(LED1, LED_ON);
        USB.println(F("3G/GPRS connected"));
    }
    else
    {
        Utils.setLED(LED1, LED_OFF);
        USB.println(F("3G/GPRS not connected"));
    }

}

