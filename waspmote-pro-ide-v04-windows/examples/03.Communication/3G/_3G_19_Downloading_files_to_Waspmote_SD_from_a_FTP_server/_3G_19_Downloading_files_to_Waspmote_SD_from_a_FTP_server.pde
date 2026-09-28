/*  
 *  ----  3G_19 - Downloading files to Waspmote SD from a FTP server   ------ 
 *  
 *  Explanation: This example shows how to download a file to Waspmote's SD card
 *  from a FTP server.
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

char ftp_server[] = "ftp_server";
char ftp_port[] = "ftp_port";
char ftp_user_name[] = "ftp_user_name";
char ftp_password[] = "ftp_password";

int answer;

void setup()
{
    USB.println(F("**************************"));
    // 1. sets operator parameters
    _3G.set_APN(apn, login, password);
    // And shows them
    _3G.show_APN();
    USB.println(F("**************************"));
}

void loop()
{

    // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));

    // 2. activates the 3G module:
    answer = _3G.ON();
    if ((answer == 1) || (answer == -3))
    {
        USB.println(F("3G module ready..."));

        // 3. sets pin code:
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

        // 4. waits for connection to the network
        answer = _3G.check(180);    
        if (answer == 1)
        { 
            USB.println(F("3G module connected to the network..."));

            // 5. configures connection for FTP applications:
            answer = _3G.configureFTP(ftp_server, ftp_port, ftp_user_name, ftp_password, 1, "I");
            if (answer == 1)
            {     

                USB.println(F("Downloading the file 1..."));

                // 6a. downloads file to SD card from the FTP server:
                answer = _3G.downloadData("/ftp_path/ftp_filename", "/SD_path/filename");

                // checks the answer
                if (answer == 1)
                {
                    USB.println(F("Download done"));
                }
                else if(answer == -2)
                {
                    USB.print(F("Download failed. Error code: "));
                    USB.println(answer, DEC);
                    USB.print(F("CME error code: "));
                    USB.println(_3G.CME_CMS_code, DEC);
                }
                else 
                {
                    USB.print(F("Download failed1. Error code: "));
                    USB.println(answer, DEC);
                }

                // a little delay between downloads
                delay(5000);

                USB.println(F("Downloading the file 2..."));

                // 6b. downloads file to SD card from the FTP server:
                answer = _3G.downloadData("/ftp_filename", "SD_filename");

                // checks the answer
                if (answer == 1)
                {
                    USB.println(F("Download done"));
                }
                else if(answer == -2)
                {
                    USB.print(F("Download failed. Error code: "));
                    USB.println(answer, DEC);
                    USB.print(F("FTP error code: "));
                    USB.println(_3G.CME_CMS_code, DEC);
                }
                else 
                {
                    USB.print(F("Download failed. Error code: "));
                    USB.println(answer, DEC);
                }

            }
            else
            {
                USB.println(F("Configuration failed. Error code:"));
                USB.println(answer, DEC);
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

    // 7. powers off the GPRS_Pro module
    _3G.OFF(); 

    USB.println(F("Sleeping..."));

    // 8. sleeps one hour
    PWR.deepSleep("00:01:00:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

}

