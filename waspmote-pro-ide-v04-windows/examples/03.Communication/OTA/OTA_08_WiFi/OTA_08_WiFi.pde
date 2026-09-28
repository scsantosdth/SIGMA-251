/*
 *  ------Waspmote OTA_08 Example--------
 *
 *  Explanation: This example shows how perform OTA programming using the
 *  WiFi module. It is necessary to specify the correct AP settings. 
 *  Besides, it is necessary to setup an FTP server and change the parameters
 *  defined in the example.
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
 *  Version:                0.1
 *  Design:                 David Gascón
 *  Implementation:         Yuri Carmona
 */

// include WiFi library
#include <WaspWIFI.h>

// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket=SOCKET0;
///////////////////////////////////////

// FTP server settings 
/////////////////////////////////
#define USER "ota"
#define PASS "libelium"
#define IP_ADDRESS "10.10.10.1"
#define PORT 21
/////////////////////////////////

// WiFi AP settings (CHANGE TO USER'S AP)
/////////////////////////////////
#define ESSID "libelium_AP"
#define AUTHKEY "password"
/////////////////////////////////

// define variables
int answer;

void setup()
{
  //*****************************************************************
  // 1. Check if the program has been programmed successfully
  //*****************************************************************
  answer = Utils.checkNewProgram();    
  switch(answer)
  {
  case 0:  
    USB.println(F("REPROGRAMMING ERROR"));
    break;   

  case 1:  
    USB.println(F("REPROGRAMMING OK"));
    break; 

  default: 
    USB.println(F("RESTARTING"));
  }      

  // Wifi module setup
  wifiSetup();  

  //*****************************************************************
  // 2. User setup
  //*****************************************************************
  
  // Put your setup code here, to run once:
}


void loop()
{   
  //*****************************************************************
  // 3. User loop program
  //*****************************************************************

  // put your main code here, to run repeatedly:


  //*****************************************************************
  // 4. OTA request
  //*****************************************************************

  // 4.1. Wifi module ON
  if( WIFI.ON(socket) == 1)
  {
    USB.println(F("WiFi module ready..."));

    // 4.2. If it is manual, call join giving the name of the AP  
    if(WIFI.join(ESSID))
    { 
      USB.println(F("Wifi module joined AP"));  

      // 4.3. Request OTA
      answer = WIFI.requestOTA();

      // If OTA fails, show the error code
      USB.print(F("Error:"));
      printError(answer);
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

  // 4.4. Reboot WiFi module
  WIFI.OFF();  
  delay(3000);   


}


/**********************************************************
 *
 * wifiSetup - It sets the main settings to the WiFi module
 *
 *
 ************************************************************/
void wifiSetup()
{
  // Switch ON the WiFi module on the desired socket
  if( WIFI.ON(socket) == 1 )
  {    
    USB.println(F("Wifi switched ON"));
  }
  else
  {
    USB.println(F("Wifi did not initialize correctly"));
  }

  // 1. Configure the transport protocol (UDP, TCP, FTP, HTTP...) 
  WIFI.setConnectionOptions(CLIENT_SERVER); 
  // 2. Configure the way the modules will resolve the IP address. 
  WIFI.setDHCPoptions(DHCP_ON); 
  // 3. Set the Flush buffer to 100 Bytes 
  WIFI.setCommSize(700);
  // 4. Set the Flush Timer to 50ms
  WIFI.setCommTimer(50);
  // 5. Set TX rate to 1Mbps
  WIFI.setTXRate(0);


  // 6. Set the server IP address, ports and FTP mode  
  WIFI.setFTP(IP_ADDRESS,PORT,FTP_PASIVE,20); 

  // 7.Set the server account with the username and password 
  WIFI.openFTP(USER,PASS); 

  // 8. Configure how to connect the AP 
  WIFI.setJoinMode(MANUAL); 

  // 9. Set the AP settings
  WIFI.setESSID(ESSID);
  WIFI.setAuthKey(WPA1,AUTHKEY); 

  // 10. Save Data to module's memory
  WIFI.storeData();

}



/**********************************************************
 *
 * printError - prints the error related to OTA
 *
 *
 ************************************************************/
void printError(int8_t err)
{
  switch(err)
  {
    case  0:  USB.println(F("error"));
              break;
    case -1:  USB.println(F("error downloading UPGRADE.TXT"));
              break;
    case -2:  USB.println(F("filename in UPGRADE.TXT is not a 7-byte name"));
              break;
    case -3:  USB.println(F("no FILE label is found in UPGRADE.TXT"));
              break;
    case -4:  USB.println(F("NO_FILE is defined as FILE in UPGRADE.TXT"));
              break;
    case -5:  USB.println(F("no PATH label is found in UPGRADE.TXT"));
              break;
    case -6:  USB.println(F("no SIZE label is found in UPGRADE.TXT"));
              break;
    case -7:  USB.println(F("no VERSION label is found in UPGRADE.TXT"));
              break;
    case -8:  USB.println(F("version indicated in UPGRADE.TXT is lower/equal to Waspmote's version"));
              break;
    case -9:  USB.println(F("file size does not match the indicated in UPGRADE.TXT"));
              break;
    case -10: USB.println(F("error downloading binary file"));
              break;
    default : USB.println(F("unkown"));  
  }
}

