/*
 *  ------Waspmote WIFI_24 Example--------
 *
 *  Explanation: This example shows how to download files 
 *  from a server using FTP protocol. 
 *
 *  Copyright (C) 2013 Libelium Comunicaciones Distribuidas S.L.
 *  http://www.libelium.com
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
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
 *  Version:                0.3
 *  Design:                 David Gascón
 *  Implementation:         Joaquin Ruiz
 */

// Include WIFI library 
#include <WaspWIFI.h>

// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket=SOCKET0;
///////////////////////////////////////

// FTP server settings 
/////////////////////////////////
#define USER "w@libelium.com"        // FTP user
#define PASS "ftp1234"               // FTP password
#define IP_ADDRESS "212.142.132.78"  // FTP address: pruebas.libelium.com
#define PORT 21                      // FTP port
#define SERVER_FOLDER "."            // FTP server Root directory. 
                                     // If a folder is used i.e. "demo/test"
#define FILENAME "FILE.TXT"          // File name to be downloaded
/////////////////////////////////

// WiFi AP settings (CHANGE TO USER'S AP)
/////////////////////////////////
#define ESSID "libelium_AP"
#define AUTHKEY "password"
/////////////////////////////////

// set SD folder as Root Directory
#define SD_FOLDER "."


void setup()
{
  // Wifi module setup
  wifiSetup();  

} 

void loop()
{ 
  // Wifi module ON
  if( WIFI.ON(socket) == 1)
  {
    USB.println(F("Switched ON"));

    // If it is manual, call join giving the name of the AP  
    if(WIFI.join(ESSID))
    { 
      USB.println(F("Joined AP.\nDownloading file...")); 

      // ****** DOWNLOAD  *******
      if( WIFI.getFile(FILENAME,SD_FOLDER,SERVER_FOLDER) == 1 )
      {  
        USB.println(F("DOWNLOAD OK")); 
      } 
      else
      {
        USB.println(F("DOWNLOAD ERROR")); 
      }
    } 
    else
    {
      USB.println(F("ERROR joining"));
    }
  }
  else
  {
    USB.println(F("ERROR switching on"));
  }

  // switch off
  WIFI.OFF();  
  USB.println(F("************************"));
  delay(3000);

} 



/**********************************************************
 *
 * wifiSetup - This function sets up the WiFi module to 
 * download from an FTP server 
 *
 ************************************************************/
void wifiSetup()
{
  // Switch ON the WiFi module on the desired socket
  if( WIFI.ON(socket) == 1 )
  {    
    USB.println(F("WiFi switched ON"));
  }
  else
  {
    USB.println(F("WiFi did not initialize correctly"));
  }

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

  // 7.Set the server account with the username and password 
  WIFI.openFTP(USER,PASS); 

  // 8. Configure how to connect the AP 
  WIFI.setJoinMode(MANUAL); 

  // 9. Set the AP authentication key
  WIFI.setAuthKey(WPA1,AUTHKEY); 

  // 10. Save Data to module's memory
  WIFI.storeData();

}




