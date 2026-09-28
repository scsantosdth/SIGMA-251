/*  
 *  ------ [C_13] - Sending bluetooth inquiries via GPRS ftp -------- 
 *  
 *  Explanation: This example uses bluetooth module (SOCKET0) to scan
 *  network till find two devices and then, send them via GPRS 
 *  module (SOCKET1) in ftp mode.
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
 *  Version:           0.2 
 *  Design:            David Gascón 
 *  Implementation:    Javier Siscart
 */
#include <WaspGPRS_Pro.h>
#include <WaspBT_Pro.h>

// Sleeping time DD:hh:mm:ss
char sleepTime[] = "00:00:00:10";

// Variable to store returning values
int answer;

void setup()
{
    // 0. Init USB port for debugging
    USB.ON();
    USB.println(F("C_13 Example"));

}

void loop()
{
    ////////////////////////////////////////////////
    // 1. Measure corresponding values
    ////////////////////////////////////////////////

    // 1.1 Turn On Bluetooth module
    BT_Pro.ON(SOCKET0);

    // 1.2 Limited scan to 2 devices
    USB.println("Scan till find 2 devices.");
    BT_Pro.scanNetworkLimited(2,TX_POWER_6);

    // 1.3 Print number of discovered devices
    USB.print("discovered devices=");
    USB.println(BT_Pro.numberOfDevices, DEC);

    // 1.4 Print data of last inquiry
    BT_Pro.printInquiry();

    // turn OFF Bluetooth module
    BT_Pro.OFF();

    ////////////////////////////////////////////////
    // 2. Send File
    ////////////////////////////////////////////////

    // 2.1 Activates the GPRS_Pro module:
    if (GPRS_Pro.ON() == 1)
    {
        USB.println(F("GPRS_Pro module ready..."));

        // 2.2 Sets pin code:
        // **** must be substituted by the SIM code
        if (GPRS_Pro.setPIN("****") == 1) 
        {
            USB.println(F("PIN code accepted"));
        }
        else
        {
            USB.println(F("PIN code incorrect"));
        }

        // 2.3 Waits for connection to the network:
        if (GPRS_Pro.check(60) == 1)
        {
            USB.println(F("GPRS_Pro module connected to the network..."));

            // 2.4 Configures GPRS Connection for HTTP or FTP applications:
            answer = GPRS_Pro.configureGPRS_HTTP_FTP(1);
            if (answer == 1)
            {
                USB.println(F("Uploading the file ..."));

                // Uploads file from SD card to the FTP server:
                // Note: some user data must be introduced here.
                answer=GPRS_Pro.uploadFile("/FILE.TXT", "/FILE.TXT", "w@libelium.com", "ftp1234", "54.76.243.55", "21", 1);
                if (answer == 1)
                {
                    USB.println(F("Upload done"));
                }
                else if(answer < -40)
                {
                    USB.print(F("Upload failed. Error code: "));
                    USB.println(answer, DEC);
                    USB.print(F("CME error code: "));
                    USB.println(GPRS_Pro.CME_CMS_code, DEC);
                }
                else 
                {
                    USB.print(F("Upload failed1. Error code: "));
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
            USB.println(F("GPRS_Pro module NOT connected to the network..."));
        }
    }
    else
    {
        USB.println(F("GPRS_Pro module NOT started"));
    }

    // 2.5 Powers off the GPRS_Pro module
    GPRS_Pro.OFF(); 

    ////////////////////////////////////////////////
    // 6. Entering Deep Sleep mode
    ////////////////////////////////////////////////
    USB.println(F("Going to sleep..."));
    USB.println();

    // Enter in sleep mode during "sleeptime"
    PWR.deepSleep(sleepTime,RTC_OFFSET,RTC_ALM1_MODE1, SOCKET0_OFF );


}


