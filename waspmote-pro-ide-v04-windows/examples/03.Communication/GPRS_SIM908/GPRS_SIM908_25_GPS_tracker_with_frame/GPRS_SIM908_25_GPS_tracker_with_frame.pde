/*  
 *  ------ GPRS_SIM908_25 - GPS tracker with frame-------- 
 *  
 *  Explanation: This example shows how use Waspmote with GPRS SIM908 module 
 *  as tracker with frame
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
#include <WaspFrame.h>

char url[] = "http://pruebas.libelium.com/getpost_frame_parser.php?";
char moteID[] = "GPRS_tracker_01";

char apn[] = "apn";
char login[] = "login";
char password[] = "password";

int8_t answer;
int GPS_status = 0;
int GPRS_status = 0;

void setup()
{

    USB.println(F("**************************"));
    // 1. sets operator parameters
    GPRS_SIM908.set_APN(apn, login, password);
    // And shows them
    GPRS_SIM908.show_APN();
    USB.println(F("**************************")); 

    // 2. activates the 3G module:
    answer = GPRS_SIM908.ON();
    if ((answer == 1) || (answer == -3))
    {

        USB.println(F("GPRS_SIM908 module ready..."));

        // 3. starts the GPS:
        USB.println(F("Starting in stand-alone mode")); 
        GPS_status = GPRS_SIM908.GPS_ON();
        if (GPS_status == 1)
        { 
            USB.println(F("GPS started"));
        }
        else
        {
            USB.println(F("GPS NOT started"));   
        }

        // 4. configures connection parameters
        GPRS_SIM908.configureGPRS_HTTP_FTP(1);

    }
    else
    {
        // Problem with the communication with the GPRS_SIM908 module
        USB.println(F("GPRS_SIM908 module not started")); 
    }
}

void loop()
{

    // 5. create new frame
    frame.createFrame(ASCII, moteID);
    
    // 6. checks the status of the GPS
    if ((GPS_status == 1) && (GPRS_SIM908.checkGPS() > 2))
    {
        answer = GPRS_SIM908.getGPSData(BASIC, 1);
        if (answer == 1)
        {            
            // when it's available, shows it
            USB.print(F("Basic: "));
            USB.println(GPRS_SIM908.buffer_GPRS);      
            USB.print(F("Latitude (degrees):"));
            USB.println(GPRS_SIM908.convert2Degrees(GPRS_SIM908.latitude, GPRS_SIM908.NS_indicator));
            USB.print(F("Longitude (degrees):"));
            USB.println(GPRS_SIM908.convert2Degrees(GPRS_SIM908.longitude, GPRS_SIM908.EW_indicator));
            USB.print(F("Speed over the ground"));
            USB.println(GPRS_SIM908.speedOG);
            USB.print(F("Course over the ground:"));
            USB.println(GPRS_SIM908.courseOG);
            USB.print(F("altitude (m):"));
            USB.println(GPRS_SIM908.altitude);

            // 7a. add GPS data 
            // add GPS position field
            frame.addSensor(SENSOR_GPS, 
            GPRS_SIM908.convert2Degrees(GPRS_SIM908.latitude, GPRS_SIM908.NS_indicator),
            GPRS_SIM908.convert2Degrees(GPRS_SIM908.longitude, GPRS_SIM908.EW_indicator) ); 			

            // add GPS speed over the ground field
            frame.addSensor(SENSOR_SPEED, GPRS_SIM908.speedOG); 

            // add GPS course over the ground field
            frame.addSensor(SENSOR_COURSE, GPRS_SIM908.courseOG); 

            // add GPS altitude field
            frame.addSensor(SENSOR_ALTITUDE, GPRS_SIM908.altitude); 
        }
        else
        { 
            // 7b. add not GPS data string
            frame.addSensor(SENSOR_STR, "GPS data not available");
            USB.println(F("GPS data not available"));  
        }
    }
    else if((GPS_status == 1) && (GPRS_SIM908.checkGPS() <= 2))
    {
        // 7c. add not GPS fixed string
        frame.addSensor(SENSOR_STR, "GPS not fixed");
        USB.println(F("GPS not fixed")); 		
    }
    else
    {
        // 7d. add not GPS started string
        USB.println(F("GPS not started. Restarting"));
        frame.addSensor(SENSOR_STR, "GPS not started. Restarting");
        GPS_status = GPRS_SIM908.GPS_ON();
    }

    GPRS_status = GPRS_SIM908.check(30);

    if(GPRS_status == 1)
    {
        // 8. Sends the frame
        answer = GPRS_SIM908.readURL(url, frame.buffer, frame.length, 1, GET);

        // checks the answer
        if ( answer == 1)
        {
            USB.println(F("Done"));  
            USB.println(GPRS_SIM908.buffer_GPRS);
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
    else
    {
        USB.println(F("GPRS not connected"));
    }

}







