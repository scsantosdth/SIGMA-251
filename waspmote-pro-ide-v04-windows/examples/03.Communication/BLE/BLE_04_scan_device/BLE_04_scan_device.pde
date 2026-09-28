/*
 *  ------------------ [BLE_04] - scan device ------------------- 
 *
 *  Explanation: This example shows how to make a scan with 
 *  Bluetooth low energy and look for a specific BLE module, 
 *  printing number of discovered devices and scan results. 
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
 *  Version:		0.1
 *  Design:		David Gascón
 *  Implementation:	Javier Siscart
 */
#include <WaspBLE.h>

// Auxiliary variable
uint8_t aux = 0;
// MAC address of BLE device to find
char MAC[14] = "000780789EBF";

void setup() 
{  
  USB.println(F("BLE_04 Example"));  

  // 0. Turn BLE module ON
  BLE.ON(SOCKET0);
}


void loop() 
{
  // 1. Device scan
  USB.print("Look for device: ");
  USB.println(MAC);
  aux = BLE.scanDevice(MAC);
  if (aux == 1)
  {
    USB.println(F("Found "));
  }
  else
  {
    USB.println(F("Not found: "));
  }


  // 2. Device scan with a timeout
  USB.print("Look for device: ");
  USB.print(MAC);
  USB.println(" during 10 seconds");
  
  //aux = BLE.scanDevice(MAC, 10, TX_POWER_MAX);
  if (aux == 1)
  {
    USB.println(F("Found "));
  }
  else
  {
    USB.println(F("Not found: "));
  }




}












