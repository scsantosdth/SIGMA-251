/*  
 *  ------------  [GP_11] - H2S  -------------- 
 *  
 *  Explanation: This is the basic code to manage and read the hydrogen 
 *  sulfide (H2S) gas sensor. The concentration and the enviromental variables
 *  will be stored in a frame. Cycle time: 5 minutes.
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
 *  Implementation:    Alejandro Gállego
 */

#include <WaspSensorGas_Pro.h>
#include <WaspFrame.h>

/*
 * Define object for sensor: H2S
 * Input to choose board socket. 
 * Waspmote OEM. Possibilities for this sensor:
 * 	- SOCKET_1 
 * 	- SOCKET_2
 * 	- SOCKET_3
 * 	- SOCKET_4
 * 	- SOCKET_5
 * 	- SOCKET_6
 * P&S! Possibilities for this sensor:
 * 	- SOCKET_A
 * 	- SOCKET_B
 * 	- SOCKET_C
 * 	- SOCKET_F
 */
Gas H2S(SOCKET_2);

float concentration;	// Stores the concentration level in ppm
float temperature;	// Stores the temperature in ºC
float humidity;		// Stores the realitve humidity in %RH
float pressure;		// Stores the pressure in Pa

char node_ID[] = "H2S_example";

void setup()
{
    USB.println(F("H2S example"));
    // Set the Waspmote ID
    frame.setID(node_ID);
}	


void loop()
{
    ///////////////////////////////////////////
    // 1. Turn on the sensors
    /////////////////////////////////////////// 

    // Power on the H2S sensor. 
    // If the gases PRO board is off, turn it on automatically.
    H2S.ON();

    // The sensor needs time to warm up and get a response from gas
    // To reduce the battery consumption, use deepSleep instead delay
    // After 2 minutes, Waspmote wakes up thanks to the RTC Alarm
    PWR.deepSleep("00:00:02:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);


    ///////////////////////////////////////////
    // 2. Read sensors
    ///////////////////////////////////////////  

    // Read the H2S sensor and compensate with the temperature internally
    concentration = H2S.getConc();

    // Read enviromental variables
    temperature = H2S.getTemp(1);
    humidity = H2S.getHumidity();
    pressure = H2S.getPressure();

    // And print the values via USB
    USB.println(F("***************************************"));
    USB.print(F("Gas concentration: "));
    USB.print(concentration);
    USB.println(F(" ppm"));
    USB.print(F("Temperature: "));
    USB.print(temperature);
    USB.println(F(" Celsius degrees"));
    USB.print(F("RH: "));
    USB.print(humidity);
    USB.println(F(" %"));
    USB.print(F("Pressure: "));
    USB.print(pressure);
    USB.println(F(" Pa"));


    ///////////////////////////////////////////
    // 3. Turn off the sensors
    /////////////////////////////////////////// 

    // Power off the H2S sensor. If there aren't more gas sensors powered, 
    // turn off the board automatically
    H2S.OFF();


    ///////////////////////////////////////////
    // 4. Create ASCII frame
    /////////////////////////////////////////// 

    // Create new frame (ASCII)
    frame.createFrame(ASCII);

    // Add H2S concentration
    frame.addSensor(SENSOR_GP_H2S, concentration);
    // Add temperature
    frame.addSensor(SENSOR_GP_TC, temperature);
    // Add humidity
    frame.addSensor(SENSOR_GP_HUM, humidity);
    // Add pressure
    frame.addSensor(SENSOR_GP_PRES, pressure);	

    // Show the frame
    frame.showFrame();


    ///////////////////////////////////////////
    // 5. Sleep
    /////////////////////////////////////////// 

    // Go to deepsleep	
    // After 3 minutes, Waspmote wakes up thanks to the RTC Alarm
    PWR.deepSleep("00:00:03:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

}

