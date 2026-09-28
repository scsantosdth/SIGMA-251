/*  
 *  ------------  [SM_14] - Frame Class Utility  -------------- 
 *  
 *  Explanation: This is the basic code to create a frame with every
 *  Smart Metering sensor
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
 *  Version:            0.1
 *  Design:             David Gascón
 *  Implementation:     Luis Miguel Marti
 */

#include <WaspSensorSmart_v20.h>
#include <WaspFrame.h>

float temperature; 
float humidity; 
float analogLDRvoltage;
float current; 
float flow3v3; 
float flow5v; 
float ultrasound3v3;
float ultrasound5v; 
float DFSvalue;
float load; 
float tempDS18B20;
char node_ID[] = "Node_01";


void setup() 
{
  USB.ON();
  USB.println(F("Frame Utility Example for Smart Metering"));

  // Set the Waspmote ID
  frame.setID(node_ID); 
  
  //Power on board
  SensorSmartv20.ON();
}

void loop()
{
  ///////////////////////////////////////////
  // 1. Turn on the sensors
  /////////////////////////////////////////// 

  // Power on the temperature sensor
  SensorSmartv20.setSensorMode(SENS_ON, SENS_SMART_TEMPERATURE);
  // Power on the humidity sensor
  SensorSmartv20.setSensorMode(SENS_ON, SENS_SMART_HUMIDITY);
  // Power on the LDR sensor
  SensorSmartv20.setSensorMode(SENS_ON, SENS_SMART_LDR);
  // Power on the current sensor
  SensorSmartv20.setSensorMode(SENS_ON, SENS_SMART_CURRENT);
  // Power on the flow 3v3 sensor
  SensorSmartv20.setSensorMode(SENS_ON, SENS_SMART_FLOW_3V3);
  // Power on the flow 5v sensor
  SensorSmartv20.setSensorMode(SENS_ON, SENS_SMART_FLOW_5V);
  // Power on the ultrasound 3v3 sensor
  SensorSmartv20.setSensorMode(SENS_ON, SENS_SMART_US_3V3);
  // Power on the ultrasound 5 v sensor
  SensorSmartv20.setSensorMode(SENS_ON, SENS_SMART_US_5V);
  // Power on the DFS sensor
  SensorSmartv20.setSensorMode(SENS_ON, SENS_SMART_DFS_3V3);
  // Power on the load cell sensor
  SensorSmartv20.setSensorMode(SENS_ON, SENS_SMART_LCELLS_5V);
  // Power on the DS18B20 sensor
  SensorSmartv20.setSensorMode(SENS_ON, SENS_SMART_TEMP_DS18B20);
  delay(2000);


  ///////////////////////////////////////////
  // 2. Read sensors
  ///////////////////////////////////////////  

  // Read the temperature sensor
  temperature = SensorSmartv20.readValue(SENS_SMART_TEMPERATURE);
  // Read the humidity sensor
  humidity = SensorSmartv20.readValue(SENS_SMART_HUMIDITY);
  //First dummy reading for analog-to-digital converter channel selection
  SensorSmartv20.readValue(SENS_SMART_LDR);
  //Sensor LDR reading
  analogLDRvoltage = SensorSmartv20.readValue(SENS_SMART_LDR);
  // Read the current sensor
  current = SensorSmartv20.readValue(SENS_SMART_CURRENT);
  // Read the flow 3v3 sensor
  flow3v3 = SensorSmartv20.readValue(SENS_SMART_FLOW_3V3, SENS_FLOW_YFS401);
  // Read the flow 5v sensor
  flow5v = SensorSmartv20.readValue(SENS_SMART_FLOW_5V, SENS_FLOW_YFG1);
  // Read the ultrasound 3v3 sensor
  ultrasound3v3 = SensorSmartv20.readValue(SENS_SMART_US_3V3, SENS_US_WRA1);
  // Read the ultrasound 5v sensor 
  ultrasound5v = SensorSmartv20.readValue(SENS_SMART_US_5V, SENS_US_WRA1);
  // Read the DFS sensor
  DFSvalue = SensorSmartv20.readValue(SENS_SMART_DFS_3V3);
  // Read the load cell sensor 
  load = SensorSmartv20.readValue(SENS_SMART_LCELLS_5V);
  // Read the DS18B20 sensor 
  tempDS18B20 = SensorSmartv20.readValue(SENS_SMART_TEMP_DS18B20);


  ///////////////////////////////////////////
  // 3. Turn off the sensors
  /////////////////////////////////////////// 

  // Power off the temperature sensor
  SensorSmartv20.setSensorMode(SENS_OFF, SENS_SMART_TEMPERATURE);
  // Power off the humidity sensor
  SensorSmartv20.setSensorMode(SENS_OFF, SENS_SMART_HUMIDITY);
  // Power off the LDR sensor
  SensorSmartv20.setSensorMode(SENS_OFF, SENS_SMART_LDR);
  // Power off the current sensor
  SensorSmartv20.setSensorMode(SENS_OFF, SENS_SMART_CURRENT);
  // Power off the flow 3v3 sensor
  SensorSmartv20.setSensorMode(SENS_OFF, SENS_SMART_FLOW_3V3);
  // Power off the flow 5v sensor
  SensorSmartv20.setSensorMode(SENS_OFF, SENS_SMART_FLOW_5V);
  // Power off the ultrasound 3v3 sensor
  SensorSmartv20.setSensorMode(SENS_OFF, SENS_SMART_US_3V3);
  // Power off the ultrasound 5v sensor
  SensorSmartv20.setSensorMode(SENS_OFF, SENS_SMART_US_5V);
  // Power off the DFS sensor
  SensorSmartv20.setSensorMode(SENS_OFF, SENS_SMART_DFS_3V3);
  // Power off the load cell sensor
  SensorSmartv20.setSensorMode(SENS_OFF, SENS_SMART_LCELLS_5V);
  // Power off DS18B20 cell sensor
  SensorSmartv20.setSensorMode(SENS_OFF, SENS_SMART_TEMP_DS18B20);


  ///////////////////////////////////////////
  // 4. Create ASCII frame
  /////////////////////////////////////////// 

  // Create new frame (ASCII)
  frame.createFrame(ASCII);

  // Add temperature
  frame.addSensor(SENSOR_TCA, temperature);
  // Add humidity
  frame.addSensor(SENSOR_HUMA, humidity);
  // Add LDR value
  frame.addSensor(SENSOR_LUM, analogLDRvoltage);
  // Add current value
  frame.addSensor(SENSOR_CU, current);
  // Add flow 3v3 linear
  frame.addSensor(SENSOR_WF_C, flow3v3);
  // Add flow 5v
  frame.addSensor(SENSOR_WF_E, flow5v);
  // Add ultrasound 3v3
  frame.addSensor(SENSOR_US_3V3, ultrasound3v3);
  // Add ultrasound 5 V
  frame.addSensor(SENSOR_US_5V, ultrasound5v);
  // Add DFS sensor value
  frame.addSensor(SENSOR_DF, DFSvalue);
  // Add load cell value
  frame.addSensor(SENSOR_LC, load);
  // Add DS18B20 temperature
  frame.addSensor(SENSOR_TCC, tempDS18B20);

  // Show the frame
  frame.showFrame();

  //wait 2 seconds
  delay(2000);
}
