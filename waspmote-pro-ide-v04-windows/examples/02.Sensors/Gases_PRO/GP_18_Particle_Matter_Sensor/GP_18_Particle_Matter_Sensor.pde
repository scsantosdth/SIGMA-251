/*  
 *  ------------  [GP_18] - Particle Matter Sensor  -------------- 
 *  
 *  Explanation: This is the basic code to manage and read the particle
 *  sensor. 
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

#include <WaspOPC_N2.h>
#include <WaspFrame.h>

/*
 * P&S! Possibilities for this sensor:
 * 	- SOCKET_D
 */

char info_string[61];
int status;
int measure;

char node_ID[] = "Particle_sensor";

void setup()
{
    USB.println(F("Particle Matter Sensor example"));
    // Set the Waspmote ID
    frame.setID(node_ID);

    status = OPC_N2.ON();
    if (status == 1)
    {
        status = OPC_N2.getInfoString(info_string);
        if (status == 1)
        {
            USB.println(F("Information string extracted:"));
            USB.println(info_string);

        }
        else
        {
            USB.println(F("Error reading the particle sensor"));
        }

        OPC_N2.OFF();
    }
    else
    {
        USB.println(F("Error starting the particle sensor"));
    }
}	


void loop()
{
    ///////////////////////////////////////////
    // 1. Turn on the sensors
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
    // 2. Read sensors
    ///////////////////////////////////////////  

    if (status == 1)
    {
        // Power the fan and the laser and perform a measure of 5 seconds
        measure = OPC_N2.getPM(5000);
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
    // 3. Turn off the sensors
    /////////////////////////////////////////// 

    // Power off the OPC_N2 sensor. If there aren't other sensors powered, 
    // turn off the board automatically
    OPC_N2.OFF();


    ///////////////////////////////////////////
    // 4. Create ASCII frame
    /////////////////////////////////////////// 

    // Create new frame (ASCII)
    frame.createFrame(ASCII);

    // Add PM 1
    frame.addSensor(SENSOR_OPC_PM1,OPC_N2._PM1); 
    // Add PM 2.5
    frame.addSensor(SENSOR_OPC_PM2_5,OPC_N2._PM2_5); 
    // Add PM 10
    frame.addSensor(SENSOR_OPC_PM10,OPC_N2._PM10); 

    // Show the frame
    frame.showFrame();


    ///////////////////////////////////////////
    // 5. Sleep
    /////////////////////////////////////////// 

    // Go to deepsleep	
    // After 3 minutes, Waspmote wakes up thanks to the RTC Alarm
    PWR.deepSleep("00:00:03:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

}

