/*  
 *  ------ [C_19] - Sending 802.15.4 values via bluetooth -------- 
 *  
 *  Explanation: This code receives packets via XBee 802.15.4 plugged 
 *  on socket 0 (during 20s). Then, the surce address of the received 
 *  packet is parsed and sent using bluetooth module plugged on socket 1.
 *  
 *  Copyright (C) 2015 Libelium Comunicaciones Distribuidas S.L. 
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

#include <WaspXBee802.h>
#include <WaspFrame.h>
#include <WaspBT_Pro.h>

// Destination MAC address (Bluetooth device)
char MAC_ADDRESS[]="00:07:80:6d:4d:5d";

// Variables to store source's network address
uint8_t sourceAddress[8];
char sourceAddressString[17];

// Time to wait for new packets (milliseconds)
unsigned long timeout = 20000;

// Flag to know when a packet is received
uint8_t packetReceived;

// Sleeping time DD:hh:mm:ss
char sleepTime[] = "00:00:00:10";    

// define variable
uint8_t error;

void setup()
{
  // 0. Init USB port for debugging
  USB.ON();
  USB.println(F("C_19 Example"));


  ////////////////////////////////////////////////
  // 1. Initial message composition
  ////////////////////////////////////////////////

  // 1.1 Set mote Identifier (16-Byte max)
  frame.setID("WASPMOTE_001");	

  // 1.2 Create new frame
  frame.createFrame(ASCII);  

  // 1.3 Set frame fields (String - char*)
  frame.addSensor(SENSOR_STR, (char*) "C_19 Example");

  // 1.4 Print frame
  frame.showFrame();


  ////////////////////////////////////////////////
  // 2. Send initial message
  ////////////////////////////////////////////////

  // 2.1 Turn On Bluetooth module
  BT_Pro.ON(SOCKET1);

  // 2.2 Make an scan for specific device.
  USB.print(F("Scan for device:"));
  USB.println(MAC_ADDRESS);

  if (BT_Pro.scanDevice(MAC_ADDRESS, 10, TX_POWER_6) == 1)
  {
    // 2.3 If found, make a transparent conenction.
    USB.println(F("Device found. Now connecting.."));

    if (BT_Pro.createConnection(MAC_ADDRESS) == 1)
    {
      // 2.4 If connected, send a dummy message.
      USB.println(F("Connected. Now sending data.."));
      if (BT_Pro.sendData(frame.buffer, frame.length) == 1) 
      {
        USB.println(F("Data sent"));
      }
      else
      {
        USB.println(F("Data not sent"));
      }

      // 2.5 End conneciton
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

  // 2.6 Turn off bluetooth module
  BT_Pro.OFF();

}

void loop()
{

  ////////////////////////////////////////////////
  // 3. Check for incoming packets via 802.15.4
  ////////////////////////////////////////////////
  USB.ON();
  USB.println(F("Receiving packets via 802.15.4"));


  // 3.1 Init XBee 
  xbee802.ON();

  // 3.2 Receive XBee packet (wait for 10 seconds)
  error = xbee802.receivePacketTimeout( 10000 );
  
  if (error == 0) 
  {
    packetReceived = 1;
    USB.println("Packet received");
  }
  
  // 3.3 Turn XBee module OFF
  xbee802.OFF();


  ////////////////////////////////////////////////
  // 4. Message composition
  ////////////////////////////////////////////////
  
  RTC.ON();
  RTC.getTime();
  

  // 4.1 Create new frame
  frame.createFrame(ASCII);  

  // 4.2 Add frame fields depending if a packet is received or not.
  if ( packetReceived == 1 )
  {
    Utils.hex2str(xbee802._srcMAC, sourceAddressString,8);
    frame.addSensor(SENSOR_TIME, RTC.hour, RTC.minute, RTC.second ); 
    frame.addSensor(SENSOR_MAC, sourceAddressString); 
  }
  else
  {
    USB.println(F("\nNo packets received:")); 
    frame.addSensor(SENSOR_TIME, RTC.hour, RTC.minute, RTC.second ); 
    frame.addSensor(SENSOR_STR, "No packets."); 
  }

  // 4.3 Print frame
  // Example: <=>\0x80\0x02#35689884#WASPMOTE_001#1#STR:New packet received from:#MAC:0013A200406B4C9C#
  frame.showFrame();


  ////////////////////////////////////////////////
  // 5. Send message
  ////////////////////////////////////////////////

  // Turn On Bluetooth module
  BT_Pro.ON(SOCKET1);

  // 5.1. Make an scan for specific device.
  USB.print(F("Scan for device:"));
  USB.println(MAC_ADDRESS);

  if (BT_Pro.scanDevice(MAC_ADDRESS, 10, TX_POWER_6) == 1)
  {
    // 5.2 If found, make a transparent conenction.
    USB.println(F("Device found. Now connecting.."));

    if (BT_Pro.createConnection(MAC_ADDRESS) == 1)
    {
      // 5.3 If connected, send a dummy message.
      USB.println(F("Connected. Now sending data.."));
      if (BT_Pro.sendData(frame.buffer, frame.length) == 1) 
      {
        USB.println(F("Data sent"));
      }
      else
      {
        USB.println(F("Data not sent"));
      }

      // 5.4 End conneciton
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

  // 5.5 Turn off bluetooth module
  BT_Pro.OFF();


  ////////////////////////////////////////////////
  // 6. Entering Deep Sleep mode
  ////////////////////////////////////////////////
  USB.println(F("Going to sleep..."));
  USB.println();
  PWR.deepSleep(sleepTime, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);


}










