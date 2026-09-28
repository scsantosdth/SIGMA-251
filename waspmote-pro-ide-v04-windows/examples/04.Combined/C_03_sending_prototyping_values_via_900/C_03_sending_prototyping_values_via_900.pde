// Revisar campo del ADC de prototipado para FRAME

/*  
 *  ------ [C.03] - sending prototyping values via 900 -------- 
 *  
 *  Explanation: This examples shows how to send the ADC value of 
 *  the prototyping board (as a string) via XBee 900.
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

#include <WaspXBee900.h>
#include <WaspFrame.h>
#include <WaspSensorPrototyping_v20.h>

// Destination MAC address
char RX_ADDRESS[] = "0013A2004066EF95";

// Node identifier
char NODE_ID[] = "node_01";

// Sleeping time DD:hh:mm:ss
char sleepTime[] = "00:00:00:10";    

// sensor variable declaration
float ADCValue;
char ADCValueString[10];

// define variable
uint8_t error;

void setup()
{
  // 0. Init USB port for debugging
  USB.ON();
  USB.println(F("C_03 Example"));


  ////////////////////////////////////////////////
  // 1. Initial message composition
  ////////////////////////////////////////////////

  // 1.1 Set mote Identifier (16-Byte max)
  frame.setID(NODE_ID);	

  // 1.2 Create new frame
  frame.createFrame(ASCII);  

  // 1.3 Set frame fields (String - char*)
  frame.addSensor(SENSOR_STR, (char*) "C_03 Example");

  // 1.4 Print frame
  frame.showFrame();


  ////////////////////////////////////////////////
  // 2. Send initial message
  ////////////////////////////////////////////////

  // 2.1 Power XBee
  xbee900.ON();

  // 2.2 Send XBee packet
  error = xbee900.send( RX_ADDRESS, frame.buffer, frame.length ); 

  if( error == 0 ) 
  {
    USB.println(F("ok"));
  }
  else 
  {
    USB.println(F("error"));
  }

  // 2.3 Communication module to OFF
  xbee900.OFF();
  delay(100);

}

void loop()
{

  ////////////////////////////////////////////////
  // 3. Measure corresponding values
  ////////////////////////////////////////////////
  USB.println(F("Measuring sensors..."));

  SensorProtov20.ON();
  delay(100);

  ADCValue = SensorProtov20.readADC();

  Utils.float2String(ADCValue, ADCValueString, 2);

  SensorProtov20.OFF();
  
  // 3.1 Turn on the RTC
  RTC.ON();
  RTC.getTime(); 

  ////////////////////////////////////////////////
  // 4. Message composition
  ////////////////////////////////////////////////

  // 4.1 Create new frame
  frame.createFrame(ASCII);  

  // 4.2 Add frame fields
  frame.addSensor(SENSOR_STR, ADCValueString);
  frame.addSensor(SENSOR_TIME, RTC.hour, RTC.minute, RTC.second );
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel() );
  
  // 4.3 Print frame
  // Example:  <=>#35689391#N01#1#STR:-4.50#TIME:18-11-22#BAT:47#
  frame.showFrame();


  ////////////////////////////////////////////////
  // 5. Send message
  ////////////////////////////////////////////////

  // 5.1 Power XBee
  xbee900.ON();

  // 5.2 Send XBee packet
  error = xbee900.send( RX_ADDRESS, frame.buffer, frame.length );

  // 5.3 Check TX flag
  if( error == 0 ) 
  {
    USB.println(F("ok"));
  }
  else 
  {
    USB.println(F("error"));
  }

  // 5.4 Communication module to OFF
  xbee900.OFF();
  delay(100);


  ////////////////////////////////////////////////
  // 6. Entering Deep Sleep mode
  ////////////////////////////////////////////////
  USB.println(F("Going to sleep..."));
  USB.println();
  PWR.deepSleep(sleepTime, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);



}


