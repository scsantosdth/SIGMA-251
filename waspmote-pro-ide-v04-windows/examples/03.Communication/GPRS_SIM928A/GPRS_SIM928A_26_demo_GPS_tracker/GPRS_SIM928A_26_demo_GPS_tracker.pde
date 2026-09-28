/*  
 *  ------ GPRS_SIM928A_26 - demo GPS tracker -------- 
 *  
 *  Explanation: This example shows how use Waspmote with GPRS SIM928A module 
 *  as tracker
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
#include <WaspFrame.h>

char url[] = "http://pruebas.libelium.com/demo_sim908.php?";
char GPS_data[250];
char moteID[] = "GPRS_tracker_01";

char apn[] = "apn";
char login[] = "login";
char password[] = "password";


int8_t answer;
int GPS_status = 0;
int GPS_FIX_status = 0;
int GPRS_status = 0;

char latitude[15], longitude[15], altitude[15], speedOG[15], courseOG[15];

void setup()
{

    USB.println(F("**************************"));
    // 1. sets operator parameters
    GPRS_SIM928A.set_APN(apn, login, password);
    // And shows them
    GPRS_SIM928A.show_APN();
    USB.println(F("**************************")); 

    // 2. activates the 3G module:
    answer = GPRS_SIM928A.ON();
    if ((answer == 1) || (answer == -3))
    {

        USB.println(F("GPRS_SIM928A module ready..."));

        // 3. starts the GPS:
        USB.println(F("Starting in stand-alone mode")); 
        GPS_status = GPRS_SIM928A.GPS_ON();
        if (GPS_status == 1)
        { 
            USB.println(F("GPS started"));
        }
        else
        {
            USB.println(F("GPS NOT started"));   
        }

        // 4. configures connection parameters
        GPRS_SIM928A.configureGPRS_HTTP_FTP(1);

    }
    else
    {
        // Problem with the communication with the GPRS_SIM928A module
        USB.println(F("GPRS_SIM928A module not started")); 
    }
}

void loop()
{
    memset(GPS_data, '\0', sizeof(GPS_data));
    // 5. checks the status of the GPS
    if (GPS_status == 1)
    {
		GPS_FIX_status = GPRS_SIM928A.waitForGPSSignal(15);
		
		if (GPS_FIX_status == 1)
		{
			answer = GPRS_SIM928A.getGPSData(1);
			Utils.setLED(LED0, LED_ON);
			if (answer == 1)
			{                
				// when it's available, shows it    
				USB.print(F("Latitude (degrees):"));
				USB.println(GPRS_SIM928A.latitude);
				USB.print(F("Longitude (degrees):"));
				USB.println(GPRS_SIM928A.longitude);
				USB.print(F("Speed over the ground"));
				USB.println(GPRS_SIM928A.speedOG);
				USB.print(F("Course over the ground:"));
				USB.println(GPRS_SIM928A.courseOG);
				USB.print(F("altitude (m):"));
				USB.println(GPRS_SIM928A.altitude);
				
				dtostrf(GPRS_SIM928A.latitude, 8 , 5, latitude);
				dtostrf(GPRS_SIM928A.longitude, 8 , 5, longitude);
				dtostrf(GPRS_SIM928A.altitude, 8 , 5, altitude);
				dtostrf(GPRS_SIM928A.speedOG, 3 , 2, speedOG);
				dtostrf(GPRS_SIM928A.courseOG, 3 , 2, courseOG);

				// 6a. add GPS data 
				// add GPS position field
				snprintf(GPS_data, sizeof(GPS_data), "%svisor=false&latitude=%s&longitude=%s&altitude=%s&time=20%c%c%c%c%c%c%s&satellites=%d&speedOTG=%s&course=%s",
					url,
					latitude,
					longitude,
					altitude,
					GPRS_SIM928A.date[4], GPRS_SIM928A.date[5], GPRS_SIM928A.date[2], GPRS_SIM928A.date[3], GPRS_SIM928A.date[0], GPRS_SIM928A.date[1], GPRS_SIM928A.UTC_time,
					GPRS_SIM928A.sats_in_use,
					speedOG,
					courseOG);
				
				USB.print(F("Data string: "));  
				USB.println(GPS_data);  
			}
			else
			{ 
				GPS_FIX_status = 0;
				Utils.setLED(LED0, LED_OFF);
				// 6b. add not GPS data string
				USB.println(F("GPS data not available"));  
			}
		}
		else
		{
			GPS_FIX_status = 0;
			Utils.setLED(LED0, LED_OFF);
			// 6c. add not GPS fixed string
			USB.println(F("GPS not fixed")); 		
		}
    }
    else
    {
        GPS_FIX_status = 0;
        Utils.setLED(LED0, LED_OFF);
        // 6d. add not GPS started string
        USB.println(F("GPS not started. Restarting"));
        GPS_status = GPRS_SIM928A.GPS_ON();
    }

    GPRS_status = GPRS_SIM928A.check(30);

    if((GPRS_status == 1) && (GPS_FIX_status == 1))
    {
        Utils.setLED(LED1, LED_ON);
        // 7. Sends the frame
        answer = GPRS_SIM928A.readURL(GPS_data, 1 );

        // checks the answer
        if ( answer == 1)
        {
            USB.println(F("Done"));  
            USB.println(GPRS_SIM928A.buffer_GPRS);
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


