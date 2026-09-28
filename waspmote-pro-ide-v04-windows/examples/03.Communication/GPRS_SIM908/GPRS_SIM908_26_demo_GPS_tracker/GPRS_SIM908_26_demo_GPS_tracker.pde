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

char url[] = "http://pruebas.libelium.com/demo_sim908.php?";
char GPS_data[250];
char moteID[] = "GPRS_tracker_01";

char apn[] = "apn";
char login[] = "login";
char password[] = "password";


int8_t answer;
int GPS_status = 0;
int GPS_fix = 0;
int GPRS_status = 0;

char latitude[10], longitude[10], altitude[10], speedOG[10], courseOG[10];

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
    memset(GPS_data, '\0', sizeof(GPS_data));
    // 5. checks the status of the GPS
    if ((GPS_status == 1) && (GPRS_SIM908.checkGPS() > 2))
    {
        GPS_fix = 1;
        Utils.setLED(LED0, LED_ON);
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
            
            
              Utils.float2String (GPRS_SIM908.convert2Degrees(GPRS_SIM908.latitude, GPRS_SIM908.NS_indicator), latitude, 5);
              Utils.float2String (GPRS_SIM908.convert2Degrees(GPRS_SIM908.longitude, GPRS_SIM908.EW_indicator), longitude, 5);
              Utils.float2String (GPRS_SIM908.altitude, altitude, 2);
              Utils.float2String (GPRS_SIM908.speedOG, speedOG, 2);
              Utils.float2String (GPRS_SIM908.courseOG, courseOG, 2);

            // 6a. add GPS data 
            // add GPS position field
            snprintf(GPS_data, sizeof(GPS_data), "%svisor=false&latitude=%s&longitude=%s&altitude=%s&time=20%c%c%c%c%c%c%s&satellites=%d&speedOTG=%s&course=%s",
                url,
                latitude,
                longitude,
                altitude,
                GPRS_SIM908.date[4], GPRS_SIM908.date[5], GPRS_SIM908.date[2], GPRS_SIM908.date[3], GPRS_SIM908.date[0], GPRS_SIM908.date[1], GPRS_SIM908.UTC_time,
                GPRS_SIM908.num_sat,
                speedOG,
                courseOG);
            
            USB.print(F("Data string: "));  
            USB.println(GPS_data);  
        }
        else
        { 
            GPS_fix = 0;
            Utils.setLED(LED0, LED_OFF);
            // 6b. add not GPS data string
            USB.println(F("GPS data not available"));  
        }
    }
    else if((GPS_status == 1) && (GPRS_SIM908.checkGPS() <= 2))
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
        GPS_status = GPRS_SIM908.GPS_ON();
    }

    GPRS_status = GPRS_SIM908.check(30);

    if((GPRS_status == 1) && (GPS_fix == 1))
    {
        Utils.setLED(LED1, LED_ON);
        // 7. Sends the frame
        answer = GPRS_SIM908.readURL(GPS_data, 1 );

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
    else if(GPRS_status == 1)
    {
        Utils.setLED(LED1, LED_ON);
        USB.println(F("GPRS connected"));
    }
    else
    {
        Utils.setLED(LED1, LED_OFF);
        USB.println(F("GPRS not connected"));
    }

}


