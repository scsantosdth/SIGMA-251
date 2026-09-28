/*  
 *  ------ [C_04] - send agriculture values via dm900 -------- 
 *  
 *  Explanation: This example sends Smar Agriculture sensor values 
 *  (sensirion and soil moisture) and send its values via Digimesh 900
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

#include <WaspXBeeDM.h>
#include <WaspFrame.h>
#include <WaspSensorAgr_v20.h>

// Global variable declarations

// Sensor variables
float soilMoistureFloatValue;            
float digitalTemperature;    
float digitalHumidity;         

// Destination MAC address
char RX_ADDRESS[] = "0013A2004066EDEB";

// Node identifier
char NODE_ID[] = "node_01";

// Sleeping time DD:hh:mm:ss
char sleepTime[] = "00:00:00:10";    

// retries counter
int retries=0;

// define variable
uint8_t error;

// maximum number of retries when sending
#define MAX_RETRIES 3


void setup()
{
  // 0. Init USB port for debugging
  USB.ON();
  USB.println(F("C_04 Example"));


  ////////////////////////////////////////////////
  // 1. Initial message composition
  ////////////////////////////////////////////////

  // 1.1 Set mote Identifier (16-Byte max)
  frame.setID(NODE_ID);	
  
  // 1.3 Create new frame
  frame.createFrame(ASCII);  

  // 1.4 Set frame fields (String - char*)
  frame.addSensor(SENSOR_STR, (char*) "C_04 Example");

  // 1.5 Print frame
  frame.showFrame();


  ////////////////////////////////////////////////
  // 2. Send initial message
  ////////////////////////////////////////////////

  // 2.1 Switch on the XBee module
  xbeeDM.ON();  

  // 2.2 Initial message transmission
  error = xbeeDM.send( RX_ADDRESS, frame.buffer, frame.length );   

  // 2.3 Check TX flag
  if ( error == 0 ) 
  {
    USB.println(F("ok"));
  }
  else 
  {
    USB.println(F("error"));
  }

  // 2.4 Communication module to OFF
  xbeeDM.OFF();
  delay(100);

}

void loop()
{

  ////////////////////////////////////////////////
  // 3. Measure corresponding values
  ////////////////////////////////////////////////
  USB.println(F("Measuring sensors..."));

  // 3.1 Turn on the sensor board
  SensorAgrv20.ON();

  // 3.2 Turn on the RTC
  RTC.ON();

  // 3.3 Supply stabilization delay
  delay(100);

  // 3.4 Turn on the sensors and wait till they are ready
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_SENSIRION);
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_WATERMARK_3);
  USB.println(F("Warming sensors"));
  unsigned long previous = millis();
  while (millis() - previous < 10000)
  {
    USB.print(".");
    delay(2000);
    // Condition to avoid an overflow (DO NOT REMOVE)
	if (millis() < previous)
	{
	  previous = millis();	
	}   
  }

  // 3.5 Read the sensors
  //Sensor temperature reading
  digitalTemperature = SensorAgrv20.readValue(SENS_AGR_SENSIRION, SENSIRION_TEMP);
 
  //Sensor humidty reading
  digitalHumidity = SensorAgrv20.readValue(SENS_AGR_SENSIRION, SENSIRION_HUM);
  
  USB.println();
  USB.println(F("Reading Soil moisture..."));
  
  //Sensor temperature reading
  soilMoistureFloatValue = SensorAgrv20.readValue(SENS_AGR_WATERMARK_3);
  
  // 3.6 Turn off the sensors
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_SENSIRION);
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_WATERMARK_3);


  ////////////////////////////////////////////////
  // 4. Message composition
  ////////////////////////////////////////////////

  // 4.1 Create new frame
  frame.createFrame(ASCII);  

  // 4.2 Add frame fields
  frame.addSensor(SENSOR_TCB, digitalTemperature ); 
  frame.addSensor(SENSOR_HUMB, digitalHumidity); 
  frame.addSensor(SENSOR_SOIL, soilMoistureFloatValue); 
  frame.addSensor(SENSOR_TIME, RTC.hour, RTC.minute, RTC.second );  
  
  // 4.3 Print frame
  // Example: <=>#42949672#N01#3#TCB:23.05#HUMB:37.1#SOIL:1273.88#TIME:10-25-40#
  frame.showFrame();


  ////////////////////////////////////////////////
  // 5. Send message
  ////////////////////////////////////////////////

  // 5.1 Switch on the XBee module
  xbeeDM.ON();  
  delay(2000);

  // 5.2 Send XBee packet
  error = xbeeDM.send( RX_ADDRESS, frame.buffer, frame.length );
   
  // 5.3 retry sending if necessary for a maximum of MAX_RETRIES
  retries=0;
  while( error != 0 ) 
  {
    if( retries >= MAX_RETRIES )
    {
      break;
    }
    
    retries++;
    delay(1000);
    error = xbeeDM.send( RX_ADDRESS, frame.buffer, frame.length );         
  }
  

  // 5.4 Check TX flag 
  if( error == 0 ) 
  {
    USB.println(F("ok"));
  }
  else 
  {
    USB.println(F("error"));
  }

  // 5.5 Communication module to OFF
  xbeeDM.OFF();
  delay(100);


  ////////////////////////////////////////////////
  // 6. Entering Deep Sleep mode
  ////////////////////////////////////////////////
  USB.println(F("Going to sleep..."));
  USB.println();
  PWR.deepSleep(sleepTime, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

}



