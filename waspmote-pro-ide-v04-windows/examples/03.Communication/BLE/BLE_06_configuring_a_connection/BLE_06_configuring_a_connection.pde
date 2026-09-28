/*
 *  ------------------ [BLE_06] - Configuring a connection ------------------- 
 *
 *  Explanation: This example configures the parameters involved when 
 *  connecting to a slave. It performs a device scan and if detected, 
 *  it connects to the BLE module with the selected parameters.
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
 *  MERCHANTABILITY or FITNESS ARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 * 
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  Version:		0.1
 *  Design:		David Gascón
 *  Implementation:	Javier Siscart
 */

#include <WaspBLE.h>

// Auxiliary variable
uint8_t aux = 0;

// MAC address of BLE device to find
char MAC[14] = "0007804aa902";

// Now define connection parameters
const uint16_t interval_minimum = 80; // 100 ms
const uint16_t interval_maximum = 80; // 100 ms
const uint16_t timeout = 100;         // 10 s
const uint16_t latency = 5;           // skip 5 intervals      

void setup() 
{  
  USB.println(F("BLE_06 Example"));  

  // 0. Turn BLE module ON
  BLE.ON(SOCKET0);
}

void loop() 
{

  // 1. Look for a specific device
  USB.println(F("First scan for device"));  
  USB.print("Look for device: ");
  USB.println(MAC);
  if (BLE.scanDevice(MAC) == 1)
  {
    //2. now try to connect with the defined parameters.
    USB.println(F("Device found. Connecting... "));
    char buffer[50] = "interval=%d, timeout=%d, latency=%d\r\n";
    USB.printf(buffer, interval_minimum, timeout, latency);

    aux = BLE.connectDirect(MAC, interval_minimum, interval_maximum, timeout, latency);

    if (aux == 1) 
    {
      USB.print("Connected. connection_handle: ");
      USB.println(BLE.connection_handle, DEC);
      delay(1000);  

      // 3. get RSSI of the link
      USB.print("RSSI:");
      USB.println(BLE.getRSSI(BLE.connection_handle), DEC);
      delay(1000);

      // 4. disconnect
      BLE.disconnect(BLE.connection_handle);
      if (BLE.errorCode != 0) 
      {
        USB.println(F("disconnect fail"));
      }
      else
      {
        USB.println(F("Disconnected."));
      } 
    }
    else
    {
      USB.println(F("NOT Connected"));  
    }
  }
  else
  {
    USB.println(F("Device not found: "));
  }

  USB.println();
  delay(5000);
}















