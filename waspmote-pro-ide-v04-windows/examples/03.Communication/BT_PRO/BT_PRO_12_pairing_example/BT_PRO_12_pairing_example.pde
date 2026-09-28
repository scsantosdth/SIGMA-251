/*  
 *  --------------- [BT PRO_12] - Pairing example -------- 
 *  
 *  Explanation: This example shows how to use pairing functions.
 *      
 *  Copyright (C) 2013 Libelium Comunicaciones Distribuidas S.L. 
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
char mac[18] = "2c:44:01:7f:f8:03";

void setup()
{
  // Initial message
  USB.println(F("BT_PRO_12 example...")); 

  // Turn On Bluetooth module
  BT_Pro.ON(SOCKET1);
}

void loop()
{
  ////////////////////////////////////////////////
  // 1. Using pairing functions
  ////////////////////////////////////////////////  

  USB.print("Pairing with device:");
  USB.println(mac);

  // 1.1 pair with device, using default code "123456"
  if(BT_Pro.pair(mac) == 1)
  {    
    USB.print("Device ");
    USB.print(mac);
    USB.println(" paired succesfully.");
  }  
  else 
  {
    USB.println(F("Device not paired"));
  }

  // 1.2 check if device is paired
  if(BT_Pro.isPaired(mac) == 1)
  {    
    USB.print("Device ");
    USB.print(mac);
    USB.println(" already paired.");
  }  
  else 
  {
    USB.print("Device ");
    USB.print(mac);
    USB.println(" is not paired.");
  }

  // 1.3 Do necessary actions
  // Insert here your code, like connecting to a device, etc.


  // 1.4 Remove paired devices
  USB.println(F("Removing paired devices..."));
  BT_Pro.removePairedDevices();

  // 1.5 check if device is paired
  USB.println(F("After removing all pairs, check if it is paired:"));
  if(BT_Pro.isPaired(mac) == 1)
  {    
    USB.print("Device ");
    USB.print(mac);
    USB.println(" already paired.");
  }  
  else 
  {
    USB.print("Device ");
    USB.print(mac);
    USB.println(" is not paired.");
  }

  USB.println();

  // End loop delay
  delay(10000);  
}



