/*  
 *  ------ [C_02] - sending events values via bluetooth -------- 
 *  
 *  Explanation: This example shows how to measure events board sensor
 *  values (PIR and liquid presence) and send them using the bluetooth module.
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
 *  Version:           0.3 
 *  Design:            David Gascón 
 *  Implementation:    Javier Siscart
 */

#include <WaspFrame.h>
#include <WaspBT_Pro.h>
#include <WaspSensorEvent_v20.h>

// Sensor variables
int presenceIntValue;
int liquidPresenceIntValue;

// Destination MAC address
char MAC_ADDRESS[] = "00:07:80:4b:2c:8d";

// Sleeping time DD:hh:mm:ss
char sleepTime[] = "00:00:00:10";    

// Define the Waspmote ID
char WASPMOTE_ID[] = "node_01";


void setup()
{

  // 0. Init USB port for debugging
  USB.ON();
  USB.println(F("C_02 Example"));


  ////////////////////////////////////////////////
  // 1. Initial message composition
  ////////////////////////////////////////////////

  // 1.1 Set mote Identifier (16-Byte max)
  frame.setID( WASPMOTE_ID );	

  // 1.2 Create new frame
  frame.createFrame(ASCII);  

  // 1.3 Set frame fields (String - char*)
  frame.addSensor(SENSOR_STR, (char*) "C_02 Example");

  // 1.4 Print frame
  frame.showFrame();


  ////////////////////////////////////////////////
  // 2. Send initial message
  ////////////////////////////////////////////////

  // Turn On Bluetooth module
  BT_Pro.ON(SOCKET0);

  // 2.1 Make an scan for specific device.
  USB.print(F("Scan for device:"));
  USB.println(MAC_ADDRESS);

  if (BT_Pro.scanDevice(MAC_ADDRESS, 10, TX_POWER_6) == 1)
  {
    // 2.2 If found, make a transparent conenction.
    USB.println(F("Device found. Now connecting.."));

    if (BT_Pro.createConnection(MAC_ADDRESS) == 1)
    {
      // 2.3 If connected, send a dummy message.
      USB.println(F("Connected. Now sending data.."));
      if (BT_Pro.sendData(frame.buffer, frame.length) == 1) 
      {
        USB.println(F("Data sent"));
      }
      else
      {
        USB.println(F("Data not sent"));
      }

      // 2.4 End conneciton
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

  // 2.5 Turn off bluetooth module
  BT_Pro.OFF();
}

void loop()
{

  ////////////////////////////////////////////////
  // 3. Measure corresponding values
  ////////////////////////////////////////////////
  USB.println(F("Measuring sensors..."));

  // 3.1 Turn on the sensor board
  SensorEventv20.ON();

  // 3.2 Turn on the RTC
  RTC.ON();

  // 3.3 Configure the interruptions to avoid non desired interruptions
  SensorEventv20.setThreshold(SENS_SOCKET1, 3.3);
  SensorEventv20.setThreshold(SENS_SOCKET2, 0);
  SensorEventv20.setThreshold(SENS_SOCKET3, 3.3);
  SensorEventv20.setThreshold(SENS_SOCKET4, 3.3);
  SensorEventv20.setThreshold(SENS_SOCKET5, 3.3);
  SensorEventv20.setThreshold(SENS_SOCKET6, 0);

  // 3.4 supply stabilization delay
  delay(100);

  // 3.5 Turn on the sensors
  SensorEventv20.setThreshold(SENS_SOCKET1, 1.5);
  
  // 3.6 Read the sensors
  // initialize variables
  presenceIntValue=0;
  liquidPresenceIntValue=0;
  
  //++++++++   PIR  ++++++++  
  if(intFlag & SENS_INT)
  {    
    presenceIntValue = ( SensorEventv20.intFlag & SENS_SOCKET7 ) >> 6;   
  }

  //++++++++   Liquid presence  ++++++++  
  if(intFlag & SENS_INT)
  {    
    liquidPresenceIntValue = ( SensorEventv20.intFlag & SENS_SOCKET1 ) >> 4;    
  }

  // 3.7 get time from RTC  
  RTC.getTime(); 

  ////////////////////////////////////////////////
  // 4. Message composition
  ////////////////////////////////////////////////

  // 4.1 Create new frame
  frame.createFrame(ASCII);  

  // 4.2 Add frame fields
  frame.addSensor(SENSOR_PIR, presenceIntValue);
  frame.addSensor(SENSOR_LP, liquidPresenceIntValue);
  frame.addSensor(SENSOR_TIME, RTC.hour, RTC.minute, RTC.second );
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel() );

  // 4.3 Print frame
  // Example: <=>?#35689495#WASPMOTE_001#1#PIR:0#LP:0#TIME:12-35-27#BAT:89#
  frame.showFrame();


  ////////////////////////////////////////////////
  // 5. Send message
  ////////////////////////////////////////////////

  // Turn On Bluetooth module
  BT_Pro.ON(SOCKET0);

  // 5.1 Make an scan for specific device.
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

  ////////////////////////////////////////////////
  // 6. Entering Deep Sleep mode
  ////////////////////////////////////////////////
  USB.println(F("Going to sleep..."));
  USB.println();

  //Clear the interruption flag
  clearIntFlag();

  //Enable interruptions from the events board
  SensorEventv20.attachInt();

  //Enter in sleep mode
  PWR.deepSleep(sleepTime,RTC_OFFSET,RTC_ALM1_MODE1, SOCKET0_OFF);

  //Disable interruptions while processing the data
  SensorEventv20.detachInt();    

  //Update the fomerLoadInt variable
  SensorEventv20.loadInt();

}







