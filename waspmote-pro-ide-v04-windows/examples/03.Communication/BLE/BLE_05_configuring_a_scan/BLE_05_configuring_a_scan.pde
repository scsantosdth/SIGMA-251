/*
 *  ------------------ [BLE_05] - Configuring a scan ------------------- 
 *
 *  Explanation: This example shows how to configure scan parameters and 
 *  making a scan with them, printing number of discovered devices 
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
void setup() 
{  
  USB.println(F("BLE_05 Example"));  

  // 0. Turn BLE module ON
  BLE.ON(SOCKET0);

  // 1. Configure a scan with desired parameters

  // 1.1 Set TX power to maximum 
  BLE.setTXPower(TX_POWER_MAX); 
  if (BLE.errorCode != 0) USB.println(F("TX Fail"));

  // 1.2 Set GAP Discover mode.
  BLE.setDiscoverMode(BLE_GAP_BROADCAST);
  if (BLE.errorCode != 0) USB.println(F("GAP Fail"));

  // 1.3 set scan interval to 75 and scan window to 50, 
  // and enable active scanning
  BLE.setScanningParameters(75,50,BLE_ACTIVE_SCANNING);
  if (BLE.errorCode != 0) USB.println(F("Active scanning not enabled"));

  // 1.4 enable mac filter
  BLE.setFiltering(BLE_MAC_FILTER_ENABLED);
  if (BLE.errorCode != 0) USB.println(F("Mac filter not enabled"));

}

void loop() 
{

  // 2. Make a scan with desired parameters
  USB.println(F("New scan..."));  
  BLE.scanNetwork(5);
  
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











