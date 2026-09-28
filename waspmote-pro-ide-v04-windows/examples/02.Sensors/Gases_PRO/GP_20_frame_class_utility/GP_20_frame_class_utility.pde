/*  
 *  ------------  [GP_20] - Frame Class Utility  -------------- 
 *  
 *  Explanation: This is the basic code to create a frame with some
 * 	Gases Pro Sensor Board sensors
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

#include <WaspSensorGas_Pro.h>
#include <WaspFrame.h>

Gas CO2(SOCKET_1);
Gas CO(SOCKET_2);
Gas O3(SOCKET_3);
Gas O2(SOCKET_4);
Gas NO(SOCKET_5);
Gas NO2(SOCKET_6);

float temperature; 
float humidity; 
float pressure;
float concCO2;
float concCO;
float concO3;
float concO2;
float concNO;
float concNO2;

char node_ID[] = "Node_01";


void setup() 
{
  USB.ON();
  USB.println(F("Frame Utility Example for Gases Pro Sensor Board"));

  // Set the Waspmote ID
  frame.setID(node_ID); 
  
}

void loop()
{
  ///////////////////////////////////////////
  // 1. Turn on sensors and wait
  ///////////////////////////////////////////

  //Power on sensors
  CO2.ON();
  CO.ON();
  O3.ON();
  O2.ON();
  NO.ON();
  NO2.ON();
  
  // Sensors need time to warm up and get a response from gas
  // To reduce the battery consumption, use deepSleep instead delay
  // After 2 minutes, Waspmote wakes up thanks to the RTC Alarm  
  PWR.deepSleep("00:00:02:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);


  ///////////////////////////////////////////
  // 2. Read sensors
  ///////////////////////////////////////////  
  
  // Read the CO2 sensor and compensate with the temperature internally
  concCO2 = CO2.getConc();
  // Read the CO sensor and compensate with the temperature internally
  concCO = CO.getConc();
  // Read the O3 sensor and compensate with the temperature internally
  concO3 = O3.getConc();
  // Read the O2 sensor and compensate with the temperature internally
  concO2 = O2.getConc();
  // Read the NO sensor and compensate with the temperature internally
  concNO = NO.getConc();
  // Read the NO2 sensor and compensate with the temperature internally
  concNO2 = NO2.getConc();
  
  // Read enviromental variables
  temperature = CO.getTemp();
  humidity = CO.getHumidity();
  pressure = CO.getPressure();

  ///////////////////////////////////////////
  // 3. Turn off the sensors
  /////////////////////////////////////////// 

  //Power off sensors
  CO2.OFF();
  CO.OFF();
  O3.OFF();
  O2.OFF();
  NO.OFF();
  NO2.OFF();


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
  frame.addSensor(SENSOR_GP_CO2, concCO2);
  // Add CO value
  frame.addSensor(SENSOR_GP_CO, concCO);
  // Add O3 value
  frame.addSensor(SENSOR_GP_O3, concO3);
  // Add O2 value
  frame.addSensor(SENSOR_GP_O2, concO2);
  // Add NO value
  frame.addSensor(SENSOR_GP_NO, concNO);
  // Add NO2 value
  frame.addSensor(SENSOR_GP_NO2, concNO2);


  // Show the frame
  frame.showFrame();

  //wait 2 seconds
  delay(2000);
}
