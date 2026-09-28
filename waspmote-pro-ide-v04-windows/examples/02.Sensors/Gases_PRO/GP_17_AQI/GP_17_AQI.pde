/*  
 *  ------------  [GP_017] - AQM  -------------- 
 *  
 *  Explanation: This is the basic code to manage and read CO, O3, SO2 and NO2
 *  gas sensors. This gases are commonly meassured in air quality monitors.
 *  The concentration and the enviromental variables will be stored in a 
 *  frame. Cycle time: 5 minutes.
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

// Each object will be used by each gas sensor
Gas CO(SOCKET_1);
Gas O3(SOCKET_3);
Gas SO2(SOCKET_4);
Gas NO2(SOCKET_6);


float conc_CO;		// Stores the concentration level of CO in ppm
float conc_O3;		// Stores the concentration level of O3 in ppm
float conc_SO2;		// Stores the concentration level of SO2 in ppm
float conc_NO2;		// Stores the concentration level of NO2 in ppm
float temperature;	// Stores the temperature in ºC
float humidity;		// Stores the realitve humidity in %RH
float pressure;		// Stores the pressure in Pa

char node_ID[] = "AQI_example";

void setup()
{
    USB.println(F("AQI example"));
    // Set the Waspmote ID
    frame.setID(node_ID); 
}	


void loop()
{
    ///////////////////////////////////////////
    // 1. Turn on sensors
    ///////////////////////////////////////////  

    // Power on the sensors. 
    // If the gases PRO board is off, turn it on automatically.
    CO.ON();
    O3.ON();
    SO2.ON();
    NO2.ON();

    // The sensor needs time to warm up and get a response from gas
    // To reduce the battery consumption, use deepSleep instead delay
    // After 2 minutes, Waspmote wakes up thanks to the RTC Alarm
    PWR.deepSleep("00:00:02:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);


    ///////////////////////////////////////////
    // 2. Read sensors
    ///////////////////////////////////////////  

    // Read the sensors and compensate with the temperature internally
    conc_CO = CO.getConc();
    conc_O3 = O3.getConc();
    conc_SO2 = SO2.getConc();
    conc_NO2 = NO2.getConc();

    // Read enviromental variables
    // In this case, CO objet has been used.
    // O3, SO2 or NO2 objects could be used with the same result
    temperature = CO.getTemp(1);
    humidity = CO.getHumidity();
    pressure = CO.getPressure();

    // And print the values via USB
    USB.println(F("***************************************"));
    USB.print(F("CO concentration: "));
    USB.print(conc_CO);
    USB.println(F(" ppm"));
    USB.print(F("O3 concentration: "));
    USB.print(conc_O3);
    USB.println(F(" ppm"));
    USB.print(F("SO2 concentration: "));
    USB.print(conc_SO2);
    USB.println(F(" ppm"));
    USB.print(F("NO2 concentration: "));
    USB.print(conc_NO2);
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

    // Power off the sensors sensor. If there aren't more gas sensors powered, 
    // turn off the board automatically
    CO.OFF();
    O3.OFF();
    SO2.OFF();
    NO2.OFF();


    ///////////////////////////////////////////
    // 4. Create ASCII frame
    /////////////////////////////////////////// 

    // Create new frame (ASCII)
    frame.createFrame(ASCII);

    // Add CO concentration
    frame.addSensor(SENSOR_GP_CO, conc_CO);
    // Add O3 concentration
    frame.addSensor(SENSOR_GP_O3, conc_O3);
    // Add SO2 concentration
    frame.addSensor(SENSOR_GP_SO2, conc_SO2);
    // Add NO2 concentration
    frame.addSensor(SENSOR_GP_NO2, conc_NO2);
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

