/*  
 *  ------------  [GP_019] - AQM with particle  -------------- 
 *  
 *  Explanation: This is the basic code to manage and read CO, O3, SO2, NO2
 *  gas sensors and a prticle sensor. This gases are commonly meassured in 
 *  air quality monitors. The concentration and the enviromental variables 
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
 *  Version:           0.2
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego
 */

#include <WaspOPC_N2.h>
#include <WaspSensorGas_Pro.h>
#include <WaspFrame.h>

// Each object will be used by each gas sensor
Gas CO(SOCKET_A);
Gas O3(SOCKET_B);
Gas SO2(SOCKET_C);
Gas NO2(SOCKET_F);


float conc_CO;		// Stores the concentration level of CO in ppm
float conc_O3;		// Stores the concentration level of O3 in ppm
float conc_SO2;		// Stores the concentration level of SO2 in ppm
float conc_NO2;		// Stores the concentration level of NO2 in ppm
float temperature;	// Stores the temperature in ºC
float humidity;		// Stores the realitve humidity in %RH
float pressure;		// Stores the pressure in Pa

int status;
int measure;

char node_ID[] = "AQM_OPCN2";

void setup()
{
    USB.println(node_ID);
    // Set the Waspmote ID
    frame.setID(node_ID); 

}	


void loop()
{
    ///////////////////////////////////////////
    // 1a. Turn on particle sensor
    ///////////////////////////////////////////  

    // Power on the OPC_N2 sensor. 
    // If the gases PRO board is off, turn it on automatically.
    status = OPC_N2.ON();
    if (status == 1)
    {
        USB.println(F("Particle sensor started"));

    }
    else
    {
        USB.println(F("Error starting the particle sensor"));
    }

    ///////////////////////////////////////////
    // 1b. Read the particle sensor
    ///////////////////////////////////////////  

    if (status == 1)
    {
        // Power the fan and the laser and perform a measure of 8 seconds
        measure = OPC_N2.getPM(8000);
        if (measure == 1)
        {
            USB.println(F("Measure performed"));
            USB.print(F("PM 1: "));
            USB.print(OPC_N2._PM1);
            USB.println(F(" ug/m3"));
            USB.print(F("PM 2.5: "));
            USB.print(OPC_N2._PM2_5);
            USB.println(F(" ug/m3"));
            USB.print(F("PM 10: "));
            USB.print(OPC_N2._PM10);
            USB.println(F(" ug/m3"));
        }
        else
        {
            USB.print(F("Error performing the measure. Error code:"));
            USB.println(measure, DEC);
        }
    }

    ///////////////////////////////////////////
    // 1c. Turn off the particle sensor
    /////////////////////////////////////////// 
    // Power off the OPC_N2 sensor. If there aren't other sensors powered, 
    // turn off the board automatically
    OPC_N2.OFF();

    delay(15000);

    ///////////////////////////////////////////
    // 2a. Turn on gas sensors
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
    // 2b. Read gas sensors
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
    // 2c. Turn off the gas sensors
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
    // Maybe it will be necessary to increase the MAX_FRAME constant
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
    // Add PM 1
    frame.addSensor(SENSOR_OPC_PM1,OPC_N2._PM1); 
    // Add PM 2.5
    frame.addSensor(SENSOR_OPC_PM2_5,OPC_N2._PM2_5); 
    // Add PM 10
    frame.addSensor(SENSOR_OPC_PM10,OPC_N2._PM10); 
    // Add PM 10
    frame.addSensor(SENSOR_BAT,PWR.getBatteryLevel()); 

    // Show the frame
    frame.showFrame();


    ///////////////////////////////////////////
    // 5. Sleep
    /////////////////////////////////////////// 

    // Go to deepsleep 
    // After 3 minutes, Waspmote wakes up thanks to the RTC Alarm
    PWR.deepSleep("00:00:02:37", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

}



