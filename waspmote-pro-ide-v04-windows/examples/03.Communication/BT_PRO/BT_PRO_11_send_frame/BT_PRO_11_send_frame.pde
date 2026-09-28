/*  
 *  --------------- [BT PRO_11] - Sending frames -------- 
 *  
 *  Explanation: Create a transparent link with a remote Bluetooth 
 *  module and send a frame with info
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
 *  Version:           0.2
 *  Design:            David Gascón 
 *  Implementation:    Javier Siscart 
 */

#include "WaspBT_Pro.h"
#include "WaspFrame.h"

// Variable to store Mac address of remote Bluetooth module
char mac[18] = "00:07:80:6d:4d:3d";


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

  ////////////////////////////////////////////////
  // 1. Create frame
  ////////////////////////////////////////////////  

  // 1.1 Create new frame
  frame.createFrame(ASCII, "WASPMOTE_BT");  

  // 1.2 Add frame fields
  frame.addSensor(SENSOR_STR, "Bluetooth frame");
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel()); 
  frame.showFrame();

  ////////////////////////////////////////////////
  // 2. Establish connection and send data
  ////////////////////////////////////////////////  

  // 2.1 Connect to the desired device
  USB.print(F("Scan for device:"));
  USB.println(mac);

  if(BT_Pro.scanDevice(mac,10,TX_POWER_6))
  {
    // 2.2 If found, make a transparent conenction.
    USB.println(F("Device found. Now connecting.."));

    if(BT_Pro.createConnection(mac))
    {
      // 2.3 If connected, send a dummy message.
      USB.println(F("Connected. Now sending data.."));
      if(BT_Pro.sendData(frame.buffer, frame.length)) 
      {
        USB.println(F("Data sent"));
      }

      // 2.4 Stay conencted 10 seconds.
      USB.println(F("Stay connected 10 seconds."));
      for(int i=0; i<10; i++) 
      {
        USB.print(F(".")); 
        BT_Pro.sendData(".");
        delay(1000);
        
      }

      // 2.5 Get Link received signal strength indicator (RSSI)
      BT_Pro.getRSSI(),     
      USB.print(F("Link RSSI: "));
      USB.println(BT_Pro.linkRSSI);

      // 2.6 End conneciton
      if(BT_Pro.removeConnection()) 
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

