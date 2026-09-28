/*
 *  ------------------ [BLE_02] - Name scan ------------------- 
 *
 *  Explanation: This example shows how to make a name scan with 
 *  Bluetooth low energy, printing number of discovered devices 
 *  and scan results stored in EEPROM. 
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
void setup() 
{  
  USB.println(F("BLE_02 Example"));  

  // 0. Turn BLE module ON
  BLE.ON(SOCKET0);
}


void loop() 
{

  // 1. Name scan
  USB.println(F("Name scan for 5 seconds.."));  
  BLE.scanNetworkName(5);

  // Printing information
  USB.print("discovered devices: ");
  USB.println(BLE.numberOfDevices, DEC);
  USB.println();

  USB.println(F("Printing Last inquiry saved on EEPROM:"));  
  aux = BLE.printInquiry();
  USB.print("devices printed: ");
  USB.println(aux, DEC);
  USB.println();

  // 2. Name scan at desired TX power
  USB.println(F("Name scan at MAX TX power.."));  
  BLE.scanNetworkName(5, TX_POWER_MAX);

  // Printing information
  USB.print("discovered devices: ");
  USB.println(BLE.numberOfDevices, DEC);
  USB.println();

  USB.println(F("Printing Last inquiry saved on EEPROM:"));  
  aux = BLE.printInquiry();
  USB.print("devices printed: ");
  USB.println(aux, DEC);
  USB.println();
}











