/*  
 *  ------ [C_06] - Sending smart meetering values via wifi udp -------- 
 *  
 *  Explanation: This example shows how to send some values of smart 
 *  metering board (liquid flow and ultrasound sensors) via WIFI udp
 *  plugged on socket 0.
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

#include <WaspFrame.h>
#include <WaspSensorSmart_v20.h>
#include <WaspWIFI.h>

// Sensor variable declaration
float ultrasoundFloatValue;
float liquidFlowFloatValue;

// Constant for sleeping time with format DD:HH:MM:SS
char sleepTime[] = "00:00:00:10";     


void setup()
{
  ////////////////////////////////////////////////
  // 0. Init USB port for debugging
  ////////////////////////////////////////////////
  USB.ON();
  USB.println(F("C_06 example"));


  ////////////////////////////////////////////////
  // 1. Initial message composition
  ////////////////////////////////////////////////

  // 1.1 Set mote Identifier (16-Byte max)
  frame.setID("node01");	

  // 1.2 Create new ASCII frame
  frame.createFrame(ASCII);  

  // 1.3 Set frame fields (String - char*)
  frame.addSensor(SENSOR_STR, (char*) "C_06 Example");

  // 1.4 Print frame
  frame.showFrame();


  ////////////////////////////////////////////////
  // 2. Send initial message
  ////////////////////////////////////////////////
  USB.println(F("Turning WIFI module ON"));

  // 2.1 Switch on the WIFI module on the desired socket.
  WIFI.ON(SOCKET0);
  // 2.2 If we don't know what configuration had the module, reset it.
  WIFI.resetValues();

  // 2.3 Configure the transport protocol (UDP, TCP, FTP, HTTP...) 
  WIFI.setConnectionOptions(UDP); 
  // 2.4 Configure the way the modules will resolve the IP address. 
  WIFI.setDHCPoptions(DHCP_ON); 

    // 2.5 Sets WPA1 encryptation // 1-64 Characters 
  WIFI.setAuthKey(WPA1, "password"); 

  // 2.6 Configure how to connect the AP.
  WIFI.setJoinMode(MANUAL);
  
  // 2.7 Saves current configuration.
  WIFI.storeData();
  
  if (WIFI.join("libelium_AP")) 
  {
    // 2.8 Call the function to create UDP connection to IP adress  
    // "192.168.1.150:2000" from local port 2000 
    if (WIFI.setUDPclient("192.168.1.150",2000,2000)) 
    {  
      // 2.9 Now we can use send UDP messages. 
      WIFI.send(frame.buffer, frame.length); 

      // 2.10 Closes the UDP and enters in command mode. 
      WIFI.close(); 
    } 
  } 

  // 2.11 Power off WIFI module
  WIFI.OFF();

}

void loop()
{
  ////////////////////////////////////////////////
  // 3. Measure corresponding values
  ////////////////////////////////////////////////
  USB.println(F("Measuring sensors..."));


  // 3.1 Turn on the sensors
  SensorSmartv20.setSensorMode(SENS_ON, SENS_SMART_US_3V3);
  SensorSmartv20.setSensorMode(SENS_ON, SENS_SMART_FLOW_3V3);
  delay(100);

  // 3.2 Read sensors
  //++++++  Ultrasound  +++++++
  // First dummy reading for analog-to-digital converter channel selection
  SensorSmartv20.readValue(SENS_SMART_US_3V3, SENS_US_WRA1);
  //Sensor temperature reading
  ultrasoundFloatValue = SensorSmartv20.readValue(SENS_SMART_US_3V3, SENS_US_WRA1);

  //++++++  Temperature  +++++++
  // Sensor temperature reading
  liquidFlowFloatValue = SensorSmartv20.readValue(SENS_SMART_FLOW_3V3, SENS_FLOW_FS200);


  // 3.3 Turn off the sensors
  SensorSmartv20.setSensorMode(SENS_OFF, SENS_SMART_FLOW_3V3);
  SensorSmartv20.setSensorMode(SENS_OFF, SENS_SMART_US_3V3);


  ////////////////////////////////////////////////
  // 4. Message composition
  ////////////////////////////////////////////////

  // 4.1 Create new ASCII frame
  frame.createFrame(ASCII);  

  // 4.2 Add frame fields
  frame.addSensor(SENSOR_WF, liquidFlowFloatValue); 
  frame.addSensor(SENSOR_US, ultrasoundFloatValue); 


  // 4.3 Print frame
  // Example:  <=>#35689633#n1#1#WF:0.000#US:87.70#
  frame.showFrame();


  ////////////////////////////////////////////////
  // 5. Send message
  ////////////////////////////////////////////////

  // 5.1 Switch on the WIFI module on the desired socket.
  WIFI.ON(SOCKET0);
  
  if (WIFI.join("libelium_AP")) 
  {
    // 5.2 Call the function to create UDP connection to IP adress  
    // "192.168.1.150:2000" from local port 2000 
    if (WIFI.setUDPclient("192.168.1.150",2000,2000)) 
    {  
      // 5.3 Now we can use send and read functions to send UDP messages. 
      WIFI.send(frame.buffer, frame.length); 

      // 5.4 Closes the UDP and enters in command mode. 
      WIFI.close(); 
    } 
  } 

  // 5.5 Power off WIFI module
  WIFI.OFF();

  ////////////////////////////////////////////////
  // 6. Entering Deep Sleep mode
  ////////////////////////////////////////////////
  USB.println(F("Going to sleep..."));
  USB.println();
  PWR.deepSleep(sleepTime, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

  USB.ON();
  USB.println(F("wake up"));

}
