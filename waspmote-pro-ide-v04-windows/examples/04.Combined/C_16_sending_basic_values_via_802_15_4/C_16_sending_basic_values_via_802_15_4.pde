/*  
 *  ------ [C_16] - Sending basic values via 802.15.4 -------- 
 *  
 *  Explanation:  This example sends Waspmote basic sensors values 
 *  via XBee module with 802.15.4 protocol
 *
 *
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

// Node identifier
char NODE_ID[]="N01";

// Destination MAC address
char MAC_ADDRESS[]="0013A20040B4DCDB";

// Sleeping time DD:hh:mm:ss
char sleepTime[] = "00:00:01:00";    

// Sensor variables
float temperature = 0.0;
float light = 0;
float humidity = 0;

// define variable
uint8_t error;

void setup()
{
  // 0. Init USB port for debugging
  USB.ON();
  USB.println(F("C_16 Example"));


  ////////////////////////////////////////////////
  // 1. Initial message composition
  ////////////////////////////////////////////////

  // 1.1 Set mote Identifier (16-Byte max)
  frame.setID(NODE_ID);	

  // 1.2 Create new frame
  frame.createFrame(ASCII);  

  // 1.3 Set frame fields (String - char*)
  frame.addSensor(SENSOR_STR, (char*) "C_16 Example");

  // 1.4 Print frame
  frame.showFrame();


  ////////////////////////////////////////////////
  // 2. Send initial message
  ////////////////////////////////////////////////

  // 2.1 Switch on the XBee module
  xbee802.ON();  

  // 2.2 Set destination XBee parameters to packet
  error = xbee802.send( MAC_ADDRESS, frame.buffer, frame.length );

  // 2.3 Check TX flag
  if( error == 0 ) 
  {
    USB.println(F("ok"));
  }
  else 
  {
    USB.println(F("error"));
  }

  // 2.4 Communication module to OFF
  xbee802.OFF();
  delay(100);
  
  // 2.5 set up RTC 
  RTC.ON();
  
}
 
void loop()
{
   ////////////////////////////////////////////////
  // 3. Measure corresponding values
  ////////////////////////////////////////////////
  USB.println(F("Measuring sensors..."));

  temperature = Utils.readTemperature();
  humidity = Utils.readHumidity();
  light = Utils.readLight();  
  RTC.getTime();


  ////////////////////////////////////////////////
  // 4. Message composition
  ////////////////////////////////////////////////

  // 4.1 Create new frame
  frame.createFrame(ASCII);  

  // 4.2 Add frame fields
  frame.addSensor(SENSOR_TCA, temperature);
  frame.addSensor(SENSOR_HUMA, humidity);
  frame.addSensor(SENSOR_LUM, light);
  frame.addSensor(SENSOR_TIME, RTC.hour, RTC.minute, RTC.second );
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
  
  // 4.3 Print frame
  // Example: <=>#35689391#N01#1#TCA:20.64#HUMA:39.0#LUM:75.000#TIME:16-17-16#BAT:52#
  frame.showFrame();


  ////////////////////////////////////////////////
  // 5. Send message
  ////////////////////////////////////////////////

  // 5.1 Switch on the XBee module
  xbee802.ON();  

  // 5.2 Set destination XBee parameters to packet
  error = xbee802.send( MAC_ADDRESS, frame.buffer, frame.length );

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
  xbee802.OFF();

  ////////////////////////////////////////////////
  // 6. Entering Deep Sleep mode
  ////////////////////////////////////////////////
  USB.ON();
  USB.println(F("Going to sleep..."));
  
  PWR.deepSleep(sleepTime, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
 
  USB.ON();
  RTC.ON();
  USB.println(F("wake"));
  
}
