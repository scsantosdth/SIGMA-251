/*  
 *  ------------  [SC_11] - Frame Class Utility  -------------- 
 *  
 *  Explanation: This is the basic code to create a frame with every
 *  Smart Cities sensor
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

#include <WaspSensorCities.h>
#include <WaspFrame.h>

float temperature; 
float humidity; 
float analogLDRvoltage;
float dust; 
float crackLin; 
float crackPro; 
float crackDet;
float ultrasound; 
float audio;
float tempDS18B20; 
char node_ID[] = "Node_01";


void setup() 
{
  USB.ON();
  USB.println(F("Frame Utility Example for Smart Cities"));

  // Set the Waspmote ID
  frame.setID(node_ID); 
  
  //Power on board
  SensorCities.ON();
}

void loop()
{
  ///////////////////////////////////////////
  // 1. Turn on the sensors
  /////////////////////////////////////////// 

  // Power on the temperature sensor
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_TEMPERATURE);
  // Power on the humidity sensor
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_HUMIDITY);
  // Power on the LDR sensor
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_LDR);
  // Power on the dust sensor
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_DUST);
  // Power on the crack linear sensor
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_LD);
  // Power on the crack propagation sensor
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_CP);
  // Power on the crack detection sensor
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_CD);
  // Power on the ultrasound sensor
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_ULTRASOUND_3V3);
  // Power on the audio sensor
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_AUDIO);
  // Power on the DS18B20 sensor
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_TEMP_DS18B20);
  delay(2000);


  ///////////////////////////////////////////
  // 2. Read sensors
  ///////////////////////////////////////////  

  // Read the temperature sensor
  temperature = SensorCities.readValue(SENS_CITIES_TEMPERATURE);
  // Read the humidity sensor
  humidity = SensorCities.readValue(SENS_CITIES_HUMIDITY);
  //First dummy reading for analog-to-digital converter channel selection
  SensorCities.readValue(SENS_CITIES_LDR);
  //Sensor LDR reading
  analogLDRvoltage = SensorCities.readValue(SENS_CITIES_LDR);
  // Read the dust sensor
  dust = SensorCities.readValue(SENS_CITIES_DUST);
  // Read the crack linear sensor
  crackLin = SensorCities.readValue(SENS_CITIES_LD);
  // Read the crack propagation sensor
  crackPro = SensorCities.readValue(SENS_CITIES_CP);
  // Read the crack detection sensor
  crackDet = SensorCities.readValue(SENS_CITIES_CD);
  // Read the ultrasound sensor 
  ultrasound = SensorCities.readValue(SENS_CITIES_ULTRASOUND_3V3, SENS_US_WRA1);
  // Read the audio sensor
  audio = SensorCities.readValue(SENS_CITIES_AUDIO);
  // Read the DS18B20 sensor 
  tempDS18B20 = SensorCities.readValue(SENS_CITIES_TEMP_DS18B20);


  ///////////////////////////////////////////
  // 3. Turn off the sensors
  /////////////////////////////////////////// 

  // Power off the temperature sensor
  SensorCities.setSensorMode(SENS_OFF, SENS_CITIES_TEMPERATURE);
  // Power off the humidity sensor
  SensorCities.setSensorMode(SENS_OFF, SENS_CITIES_HUMIDITY);
  // Power off the LDR sensor
  SensorCities.setSensorMode(SENS_OFF, SENS_CITIES_LDR);
  // Power off the dust sensor
  SensorCities.setSensorMode(SENS_OFF, SENS_CITIES_DUST);
  // Power off the crack linear sensor
  SensorCities.setSensorMode(SENS_OFF, SENS_CITIES_LD);
  // Power off the crack propagation sensor
  SensorCities.setSensorMode(SENS_OFF, SENS_CITIES_CP);
  // Power off the crack detection sensor
  SensorCities.setSensorMode(SENS_OFF, SENS_CITIES_CD);
  // Power off the ultrasound sensor
  SensorCities.setSensorMode(SENS_OFF, SENS_CITIES_ULTRASOUND_3V3);
  // Power off the audio sensor
  SensorCities.setSensorMode(SENS_OFF, SENS_CITIES_AUDIO);
  // Power off the DS18B20 sensor
  SensorCities.setSensorMode(SENS_OFF, SENS_CITIES_TEMP_DS18B20);


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
  // Add dust value
  frame.addSensor(SENSOR_DUST, dust);
  // Add crack linear
  frame.addSensor(SENSOR_LD, crackLin);
  // Add crack propagation
  frame.addSensor(SENSOR_CPG, crackPro);
  // Add crack detection
  frame.addSensor(SENSOR_CDG, crackDet);
  // Add ultrasound
  frame.addSensor(SENSOR_US, ultrasound);
  // Add audio
  frame.addSensor(SENSOR_MCP, audio);
  // Add DS18B20 temperature
  frame.addSensor(SENSOR_TCC, tempDS18B20);

  // Show the frame
  frame.showFrame();

  //wait 2 seconds
  delay(2000);
}
