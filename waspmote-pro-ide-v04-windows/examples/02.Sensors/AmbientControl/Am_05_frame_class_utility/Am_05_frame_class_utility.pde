/*  
 *  ------------  [AM_05] - Frame Class Utility  -------------- 
 *  
 *  Explanation: This is the basic code to create a frame with every
 * 	Ambient Control sensor
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
 *  Version:		    0.1
 *  Design:             David Gascón
 *  Implementation:     Luis Miguel Marti
 */

#include <WaspSensorAmbient.h>
#include <WaspFrame.h>

float digitalTemperature; 
float digitalHumidity; 
float analogLDRvoltage;
float digitalLuxes; 
char node_ID[] = "Node_01";


void setup() 
{
  USB.ON();
  USB.println(F("Frame Utility Example for Ambient Control"));

  // Set the Waspmote ID
  frame.setID(node_ID); 
}

void loop()
{
  ///////////////////////////////////////////
  // 1. Turn on the sensors
  /////////////////////////////////////////// 

  // Power on the temperature sensor
  SensorAmbient.setSensorMode(SENS_ON, SENS_AMBIENT_TEMPERATURE);
  // Power on the humidity sensor
  SensorAmbient.setSensorMode(SENS_ON, SENS_AMBIENT_HUMIDITY);
  // Power on the LDR sensor
  SensorAmbient.setSensorMode(SENS_ON, SENS_AMBIENT_LDR);
  // Power on the Luxes sensor
  SensorAmbient.setSensorMode(SENS_ON, SENS_AMBIENT_LUX);
  delay(100);


  ///////////////////////////////////////////
  // 2. Read sensors
  ///////////////////////////////////////////  

  // Read the temperature sensor
  digitalTemperature = SensorAmbient.readValue(SENS_AMBIENT_TEMPERATURE);
  // Read the humidity sensor
  digitalHumidity = SensorAmbient.readValue(SENS_AMBIENT_HUMIDITY);
  //First dummy reading for analog-to-digital converter channel selection
  SensorAmbient.readValue(SENS_AMBIENT_LDR);
  //Sensor LDR reading
  analogLDRvoltage = SensorAmbient.readValue(SENS_AMBIENT_LDR);
  // Read the Luxes sensor
  digitalLuxes = SensorAmbient.readValue(SENS_AMBIENT_LUX);


  ///////////////////////////////////////////
  // 3. Turn off the sensors
  /////////////////////////////////////////// 

  // Power off the temperature sensor
  SensorAmbient.setSensorMode(SENS_OFF, SENS_AMBIENT_TEMPERATURE);
  // Power off the humidity sensor
  SensorAmbient.setSensorMode(SENS_OFF, SENS_AMBIENT_HUMIDITY);
  // Power off the LDR sensor
  SensorAmbient.setSensorMode(SENS_OFF, SENS_AMBIENT_LDR);
  // Power off the Luxes sensor
  SensorAmbient.setSensorMode(SENS_OFF, SENS_AMBIENT_LUX);


  ///////////////////////////////////////////
  // 4. Create ASCII frame
  /////////////////////////////////////////// 

  // Create new frame (ASCII)
  frame.createFrame(ASCII);

  // Add temperature
  frame.addSensor(SENSOR_TCB, digitalTemperature);
  // Add humidity
  frame.addSensor(SENSOR_HUMB, digitalHumidity);
  // Add LDR value
  frame.addSensor(SENSOR_LUM, analogLDRvoltage);
  // Add Luxes
  frame.addSensor(SENSOR_LUX, digitalLuxes);

  // Show the frame
  frame.showFrame();

  //wait 2 seconds
  delay(2000);
}
