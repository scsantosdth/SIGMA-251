/*
 *  ------Waspmote WIFI_03 Example--------
 *
 *  Explanation: This example shows how to get the status of the different
 *  WIFI module features.
 *  Remarks: DEBUG mode must be enabled before compiling this example. Please
 *  check the WaspWIFI.h file and uncomment the "#define DEBUG_WIFI" definition
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
 *  Version:                0.2
 *  Design:                 David Gascón
 *  Implementation:         Joaquin Ruiz
 */
 
// Include WIFI library 
#include <WaspWIFI.h>

/****************************************
REMEMBER TO UNCOMMENT THE DEFINITON 
OF DEBUG_MODE IN WaspWIFI.h
*****************************************/

// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket=SOCKET0;
///////////////////////////////////////

void setup()
{
  // Switch ON the WiFi module on the desired socket
  if( WIFI.ON(SOCKET0) == 1 )
  {    
    USB.println(F("Wifi switched ON"));
  }
  else
  {
    USB.println(F("Wifi did not initialize correctly"));
  }

}

void loop()
{
  // Displays Firmware version
  USB.println(F("\n----------------------"));
  USB.println(F("Firmware Version:"));
  USB.println(F("----------------------"));
  WIFI.getVersion();
  
  // Displays connection status.  
  USB.println(F("\n----------------------"));
  USB.println(F("Connection Info:"));
  USB.println(F("----------------------"));
  WIFI.getConnectionInfo();
  
  // Displays Access Point status.
  USB.println(F("\n----------------------"));
  USB.println(F("AP Status:"));
  USB.println(F("----------------------"));
  WIFI.getAPstatus();
  
  // Displays singal strenght information.
  USB.println(F("\n----------------------"));
  USB.println(F("RSSI:"));
  USB.println(F("----------------------"));
  WIFI.getRSSI();
  
  // Displays the statistics of the sent and received packets.
  USB.println(F("\n----------------------"));
  USB.println(F("Statistics:"));
  USB.println(F("----------------------"));
  WIFI.getStats();
  
  // Diplays the seconds since last powerup or reboot.
  USB.println(F("\n----------------------"));
  USB.println(F("Up Time:"));
  USB.println(F("----------------------"));
  WIFI.getUpTime();
  
  // Diplays adhoc settings.
  USB.println(F("\n----------------------"));
  USB.println(F("Adhoc Settings:"));
  USB.println(F("----------------------"));
  WIFI.getAdhocSettings();
  
  // Displays broadcast settings.
  USB.println(F("\n----------------------"));
  USB.println(F("Broadcast Settings:"));
  USB.println(F("----------------------"));
  WIFI.getBroadcastSettings();
  
  // Displays communications settings.
  USB.println(F("\n----------------------"));
  USB.println(F("Communication Settings:"));
  USB.println(F("----------------------"));
  WIFI.getComSettings();
  
  // Displays DNS settings.
  USB.println(F("\n----------------------"));
  USB.println(F("DNS Settings:"));
  USB.println(F("----------------------"));
  WIFI.getDNSsettings();
  
  // Displays FTP settings.
  USB.println(F("\n----------------------"));
  USB.println(F("FTP Settings:"));
  USB.println(F("----------------------"));
  WIFI.getFTPsettings();
  
  // Displays IP settings.
  USB.println(F("\n----------------------"));
  USB.println(F("IP Settings:"));
  USB.println(F("----------------------"));
  WIFI.getIP();
  
  // Displays the MAC address.
  USB.println(F("\n----------------------"));
  USB.println(F("MAC Settings:"));
  USB.println(F("----------------------"));
  WIFI.getMAC();
  
  // Displays option settings.
  USB.println(F("\n----------------------"));
  USB.println(F("Option Settings:"));
  USB.println(F("----------------------"));
  WIFI.getOptionSettings();
  
  // Displays system settings.
  USB.println(F("\n----------------------"));
  USB.println(F("System Settings:"));
  USB.println(F("----------------------"));
  WIFI.getSystemSettings();


  USB.println(F("\n*******************************************"));
  delay(10000);
}
