/*  
 *  --------------- [BT PRO_10] - Creating a transparent connection -------- 
 *  
 *  Explanation: Create a transparent link with a remote Bluetooth module.
 *      
 *  Copyright (C) 2012 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Implementation:    Javier Siscart 
 */

#include "WaspBT_Pro.h"

// Variable to store Mac address of remote Bluetooth module
char mac[18] = "00:07:80:4b:2c:8d";

void setup()
{

  // setup for Serial port over USB
  USB.ON();
  USB.println(F("USB port started...")); 

  // Turn On Bluetooth module
  BT_Pro.ON(SOCKET1);

}

void loop()
{
  // 1. Make an scan for specific device.
  USB.print(F("Scan for device:"));
  USB.println(mac);

  if (BT_Pro.scanDevice(mac,10,TX_POWER_6) == 1)
  {
    // 2. If found, make a transparent conenction.
    USB.println(F("Device found. Now connecting.."));

    if (BT_Pro.createConnection(mac) == 1)
    {
      // 3. Connection success.
      USB.println(F("Connected."));
      
      // 4. Stay connected 10 seconds.
      USB.println(F("Stay connected 10 seconds."));
      for (int i=0; i<10; i++) 
      {
        USB.print(F(".")); 
        delay(1000);
      }

      // 5. Get Link received signal strength indicator (RSSI)
      BT_Pro.getRSSI();     
      USB.print(F("Link RSSI: "));
      USB.println(BT_Pro.linkRSSI);

      // 6. End conneciton
      if (BT_Pro.removeConnection() == 1)
      {
        USB.println(F("Connection removed"));
      }
      else 
      {
        USB.println(F("Not removed"));
      }
    }
    else
    {
      USB.println(F("Not conencted"));
    }
  }
  else 
  {
    USB.println(F("Device not found"));
  }

  USB.println();

}
