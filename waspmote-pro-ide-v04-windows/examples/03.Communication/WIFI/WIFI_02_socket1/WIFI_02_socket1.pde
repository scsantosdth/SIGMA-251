/*
 *  ------Waspmote WIFI_01 Example--------
 *
 *  This example shows how to switch on the module in the SOCKET1.
 *  Besides, resetValues function is called in order to reset the 
 *  configuration of the module. 
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

// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket=SOCKET1;
///////////////////////////////////////


void setup()
{   
  // 1. Switch ON the WiFi module on the desired socket
  if( WIFI.ON(socket) == 1 )
  {    
    USB.println(F("WiFi switched ON"));
  }
  else
  {
    USB.println(F("WiFi did not initialize correctly"));
  }
  
  // 2. Reset to default values
  USB.println(F("Resetting to Default values..."));
  WIFI.resetValues();
  
  USB.println(F("setup done"));
  
}

void loop()
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
   
  
  // Switch OFF the WiFi module
  WIFI.OFF();
  USB.println(F("WiFi OFF"));

  // delay
  delay(2000);
}


