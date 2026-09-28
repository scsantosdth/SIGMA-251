/*  
 *  ------------  [Ga_15] - Frame Class Utility  -------------- 
 *  
 *  Explanation: This is the basic code to create a frame with some
 * 	Gases Sensor Board sensors
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

#include <WaspSensorGas_v20.h>
#include <WaspFrame.h>

#define GAINCO2  7  //GAIN of the sensor stage
#define GAINO2  100 //GAIN of the sensor stage
#define GAINSOCKET2A  1      //GAIN of the sensor stage
#define RESISTOR2A 20  //LOAD RESISTOR of the sensor stage
#define GAINSOCKET2B  1      //GAIN of the sensor stage
#define RESISTOR2B 20  //LOAD RESISTOR of the sensor stage
#define GAINSOCKET3A  1      //GAIN of the sensor stage
#define RESISTOR3A 20  //LOAD RESISTOR of the sensor stage
#define GAINSOCKET3B  1      //GAIN of the sensor stage
#define RESISTOR3B 20  //LOAD RESISTOR of the sensor stage
#define GAINSOCKET4A  1      //GAIN of the sensor stage
#define RESISTOR4A 20  //LOAD RESISTOR of the sensor stage
#define GAINCO  1      // GAIN of the sensor stage
#define RESISTORCO 100  // LOAD RESISTOR of the sensor stage
#define GAINNH3  1      // GAIN of the sensor stage
#define RESISTORNH3 10  // LOAD RESISTOR of the sensor stage

float temperature; 
float humidity; 
float pressure;
float co2Val;
float o2Val;
float socket2AVal;
float socket2BVal;
float socket3AVal;
float socket3BVal;
float socket4AVal;
float socketCOVal;
float socketNH3Val;
float coVal;

char node_ID[] = "Node_01";


void setup() 
{
  USB.ON();
  USB.println(F("Frame Utility Example for Gases Sensor Board"));

  // Set the Waspmote ID
  frame.setID(node_ID); 
  
  //Power gases board and wait for stabilization and sensor response time
  SensorGasv20.ON();
}

void loop()
{
  //////////////////////////////////////////////////////////////////////
  // 1. Turn on and configure sensors and wait for stabilization 
  //	and sensor response time
  ////////////////////////////////////////////////////////////////////// 

  // Power on the atmospheric pressure sensor
  SensorGasv20.setSensorMode(SENS_ON, SENS_PRESSURE);
  // Configure the CO2 sensor socket
  SensorGasv20.configureSensor(SENS_CO2, GAINCO2);
  // Power on the CO2 sensor
  SensorGasv20.setSensorMode(SENS_ON, SENS_CO2);
  // Configure the O2 sensor socket
  SensorGasv20.configureSensor(SENS_O2, GAINO2);
  // Power on the O2 sensor
  SensorGasv20.setSensorMode(SENS_ON, SENS_O2);
  // Configure the 2A sensor socket
  SensorGasv20.configureSensor(SENS_SOCKET2A, GAINSOCKET2A, RESISTOR2A);
  // Power on the 2A sensor socket
  SensorGasv20.setSensorMode(SENS_ON, SENS_SOCKET2A);
  // Configure the 2B sensor socket
  SensorGasv20.configureSensor(SENS_SOCKET2B, GAINSOCKET2B, RESISTOR2B);
  // Power on the 2B sensor socket
  SensorGasv20.setSensorMode(SENS_ON, SENS_SOCKET2B);
  // Configure the 3B sensor socket
  SensorGasv20.configureSensor(SENS_SOCKET3B, GAINSOCKET3B, RESISTOR3B);
  // Power on the 3B sensor socket
  SensorGasv20.setSensorMode(SENS_ON, SENS_SOCKET3B);
  // Configure the CO sensor socket
  SensorGasv20.configureSensor(SENS_SOCKET4CO, GAINCO, RESISTORCO);
  // Power on the 3A sensor socket
  SensorGasv20.setSensorMode(SENS_ON, SENS_SOCKET3A);
  // Configure the NH3 sensor on socket 3
  SensorGasv20.configureSensor(SENS_SOCKET3NH3, GAINNH3, RESISTORNH3);
  delay(40000); 


  ///////////////////////////////////////////
  // 2. Read sensors
  ///////////////////////////////////////////  

  // Read the temperature sensor
  temperature = SensorGasv20.readValue(SENS_TEMPERATURE);
  // Read the humidity sensor
  humidity = SensorGasv20.readValue(SENS_HUMIDITY);
  // Read the pressure sensor
  pressure = SensorGasv20.readValue(SENS_PRESSURE);
  // Read the CO2 sensor 
  co2Val = SensorGasv20.readValue(SENS_CO2);
  // Read the sensor 
  o2Val = SensorGasv20.readValue(SENS_O2);
  // Read the 2A sensor socket
  socket2AVal = SensorGasv20.readValue(SENS_SOCKET2A);
  // Conversion from voltage into kiloohms
  socket2AVal = SensorGasv20.calculateResistance(	SENS_SOCKET2A, 
							socket2AVal, 
							GAINSOCKET2A, 
							RESISTOR2A);
  // Read the 2B sensor socket
  socket2BVal = SensorGasv20.readValue(SENS_SOCKET2B);
  // Conversion from voltage into kiloohms
  socket2BVal = SensorGasv20.calculateResistance(	SENS_SOCKET2B, 
							socket2BVal, 
							GAINSOCKET2B, 
							RESISTOR2B);
  // Read the 3B sensor socket
  socket3BVal = SensorGasv20.readValue(SENS_SOCKET3B);
  // Conversion from voltage into kiloohms
  socket3BVal = SensorGasv20.calculateResistance(	SENS_SOCKET3B, 
							socket3BVal, 
							GAINSOCKET3B, 
							RESISTOR3B);
  // Read the CO sensor socket
  socketCOVal = SensorGasv20.readValue(SENS_SOCKET4CO);
  // Conversion from voltage into kiloohms
  socketCOVal = SensorGasv20.calculateResistance(	SENS_SOCKET4CO, 
							socketCOVal, 
							GAINCO, 
							RESISTORCO);												
  // Read the NH3 sensor socket
  socketNH3Val = SensorGasv20.readValue(SENS_SOCKET3NH3);
  // Conversion from voltage into kiloohms
  socketNH3Val = SensorGasv20.calculateResistance(	SENS_SOCKET3NH3, 
							socketNH3Val, 
							GAINNH3, 
							RESISTORNH3);

  ///////////////////////////////////////////
  // 3. Turn off the sensors
  /////////////////////////////////////////// 

  // Power off the atmospheric pressure sensor
  SensorGasv20.setSensorMode(SENS_OFF, SENS_PRESSURE);
  // Power off the CO2 sensor
  SensorGasv20.setSensorMode(SENS_OFF, SENS_CO2);
  // Power off the O2 sensor
  SensorGasv20.setSensorMode(SENS_OFF, SENS_O2);
  // Power off the 2A sensor socket
  SensorGasv20.setSensorMode(SENS_OFF, SENS_SOCKET2A);
  // Power off the 2B sensor socket
  SensorGasv20.setSensorMode(SENS_OFF, SENS_SOCKET2B);
  // Power off the 3B sensor socket
  SensorGasv20.setSensorMode(SENS_OFF, SENS_SOCKET3B);


  ///////////////////////////////////////////
  // 4. Create ASCII frame
  /////////////////////////////////////////// 

  // Create new frame (ASCII)
  frame.createFrame(ASCII);

  // Add temperature
  frame.addSensor(SENSOR_GP_TC, temperature);
  // Add humidity
  frame.addSensor(SENSOR_GP_HUM, humidity);
  // Add pressure value
  frame.addSensor(SENSOR_GP_PRES, pressure);
  // Add CO2 value
  frame.addSensor(SENSOR_GP_CO2, co2Val);
  // Add O2 value
  frame.addSensor(SENSOR_GP_O2, o2Val);
  // Add CO value
  frame.addSensor(SENSOR_GP_CO, socketCOVal);
  // Add NH3 value
  frame.addSensor(SENSOR_GP_NH3, socketNH3Val);
  // Add NO2 value
  frame.addSensor(SENSOR_GP_NO2, socket3BVal);
  // Add CO2 value
  frame.addSensor(SENSOR_GP_O3, socket2BVal);
  // Add NH4 value
  frame.addSensor(SENSOR_CH4, socket2AVal);

  // Show the frame
  frame.showFrame();

  //wait 2 seconds
  delay(2000);
}
