/*  
 *  ------ [C_12] - Sending bluetooth inquiries via wifi ftp -------- 
 *  
 *  Explanation: This example uses bluetooth module (SOCKET1) to scan
 *  network till find two devices and then, a file is sent via WIFI 
 *  module (SOCKET0 and ftp mode) containing the Bluetooth scan.
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
 *  Version:           0.3
 *  Design:            David Gascón 
 *  Implementation:    Javier Siscart
 */

#include <WaspWIFI.h>
#include <WaspBT_Pro.h>


// Sleeping time DD:hh:mm:ss
char sleepTime[] = "00:00:00:10";

// FTP server settings 
/////////////////////////////////
#define USER "w@libelium.com"
#define PASS "ftp1234"
#define IP_ADDRESS "54.76.243.55"
#define PORT 21
#define SERVER_FOLDER "."
/////////////////////////////////

// WiFi AP settings (CHANGE TO USER'S AP)
/////////////////////////////////
#define ESSID "libelium_AP"
#define AUTHKEY "password"
/////////////////////////////////


void setup()
{
  // 0. Init USB port for debugging
  USB.ON();
  USB.println(F("C_12 Example"));

}

void loop()
{
  ////////////////////////////////////////////////
  // 1. Measure corresponding values
  ////////////////////////////////////////////////

  // 1.1 Turn On Bluetooth module
  BT_Pro.ON(SOCKET1);

  // 1.2 Limited scan to 2 devices
  USB.println("Scan till find 1 devices.");
  BT_Pro.scanNetworkLimited(1,TX_POWER_6);

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

  // 2.1 Switch on the WIFI module on the desired socket.
  WIFI.ON(SOCKET0);

  USB.println(F("Switched ON"));

  // If it is manual, call join giving the name of the AP     
  if( WIFI.join(ESSID) )
  {
    USB.println(F("Joined AP.\nUploading file...")); 

    // **** UPLOAD  ****
    if(WIFI.uploadFile("FILE.TXT", ".", SERVER_FOLDER) == 1)
    {  
      USB.println(F("UPLOAD OK")); 
    } 
    else
    {
      USB.println(F("UPLOAD ERROR"));        
    }
  }
  else
  {
    USB.println(F("ERROR joining"));
  }

  //2.2 Exit and power off the module.
  WIFI.OFF();


  ////////////////////////////////////////////////
  // 3. Entering Deep Sleep mode
  ////////////////////////////////////////////////
  USB.println(F("Going to sleep..."));
  USB.println();
  PWR.deepSleep(sleepTime, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

  USB.ON();
  USB.println(F("wake up"));

}




/**********************************************************
 *
 *  wifiSetup - It sets the proper configuration to the WiFi 
 *  module prior to the attemp of uploading the file
 *
 ************************************************************/
void wifiSetup()
{
  // Switch ON the WiFi module on the desired socket
  WIFI.ON(SOCKET0);


  // 1. Configure the transport protocol (UDP, TCP, FTP, HTTP...) 
  WIFI.setConnectionOptions(CLIENT_SERVER); 
  // 2. Configure the way the modules will resolve the IP address. 
  WIFI.setDHCPoptions(DHCP_ON); 
  // 3. Set the Flush buffer to 700 Bytes (DO NOT CHANGE)
  WIFI.setCommSize(700); 
  // 4. Set the Flush Timer to 50ms (DO NOT CHANGE)
  WIFI.setCommTimer(50);
  // 5. Set TX rate to 1Mbps (DO NOT CHANGE)
  WIFI.setTXRate(0);

  // 6. Set the server IP address, ports and FTP mode 
  WIFI.setFTP(IP_ADDRESS,PORT,FTP_PASIVE,20); 

  // 7. Set the server account with the username and password 
  WIFI.openFTP(USER,PASS); 

  // 8. Configure how to connect the AP 
  WIFI.setJoinMode(MANUAL); 

  // 9. Set the AP authentication key
  WIFI.setAuthKey(WPA1,AUTHKEY); 

  // 10. Save Data to module's memory
  WIFI.storeData();


}
