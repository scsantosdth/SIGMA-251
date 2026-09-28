/*  
 *  ------ [C_05] - Sending agriculture pro values via digimesh -------- 
 *  
 *  Explanation: This example sends soil temperature and soil moisture values
 *  values measured with agriculture board, using XBee DigiMesh.
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

// Destination MAC address
char RX_ADDRESS[] = "0013A200406FDE68";

// Node identifier
char NODE_ID[] = "node_01";

// Sleeping time DD:hh:mm:ss
char sleepTime[] = "00:00:00:10";    

// Sensor variables
float soilTemperatureFloatValue;
float soilMoistureFloatValue;

// retries counter
int retries=0;

// maximum number of retries when sending
#define MAX_RETRIES 3

// variable declartaion
uint8_t error;

void setup()
{
  // 0. Init USB port for debugging
  USB.ON();
  USB.println(F("C_05 Example"));


  ////////////////////////////////////////////////
  // 1. Initial message composition
  ////////////////////////////////////////////////

  // 1.1 Set mote Identifier (16-Byte max)
  frame.setID(NODE_ID);	

  // 1.2 Create new frame
  frame.createFrame(ASCII);  

  // 1.3 Set frame fields (String - char*)
  frame.addSensor(SENSOR_STR, (char*) "C_05 Example");

  // 1.4 Print frame
  frame.showFrame();


  ////////////////////////////////////////////////
  // 2. Send initial message
  ////////////////////////////////////////////////

  // 2.1 Switch on the XBee module
  xbeeDM.ON(); 
  delay(2000); 

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
  RTC.getTime(); 

  // 3.3 Supply stabilization delay
  delay(100);

  // 3.4 Turn on the sensors
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_PT1000);
  delay(100);
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_WATERMARK_1);
  delay(100);

  // 3.5 Sensor temperature reading
  soilTemperatureFloatValue = SensorAgrv20.readValue(SENS_AGR_PT1000);

  // 3.6 Sensor moisture reading
  soilMoistureFloatValue = SensorAgrv20.readValue(SENS_AGR_WATERMARK_1);

  // 3.7 Turn off the sensors
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_PT1000);
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_WATERMARK_1);


  ////////////////////////////////////////////////
  // 4. Message composition
  ////////////////////////////////////////////////

  // 4.1 Create new frame
  frame.createFrame(ASCII);  

  // 4.2 Add frame fields
  frame.addSensor(SENSOR_SOILT, soilTemperatureFloatValue ); 
  frame.addSensor(SENSOR_SOIL, soilMoistureFloatValue);   
  frame.addSensor(SENSOR_TIME, RTC.hour, RTC.minute, RTC.second );  
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel() );

  // 4.3 Print frame
  // Example: <=>#35689511#N01#1#SOILT:25.91#SOIL:4424.77#TIME:16-0-59#BAT:78#
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

  // 5.4 check TX flag
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
