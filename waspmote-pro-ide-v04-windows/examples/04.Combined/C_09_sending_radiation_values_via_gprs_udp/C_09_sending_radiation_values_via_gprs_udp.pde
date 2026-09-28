/*  
 *  ------ [C_09] - Sending radiation values via GPRS udp -------- 
 *  
 *  Explanation: This example measures radiation during five seconds 
 *  and send the radiation value in counts per minute (cpm) via GPRS,
 *  using an UDP connection.
 *  
 *  Copyright (C) 2012 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Version:           0.1 
 *  Design:            David Gascón 
 *  Implementation:    Javier Siscart
 */

#include <WaspSensorRadiation.h>
#include <WaspGPRS_Pro.h>
#include <WaspFrame.h>

// Variable to store measured radiation
float radiation;

// Variable to store function returns
int8_t answer;

// Variable to store sleeping period. Format DD:HH:MM:SS
char sleepTime[] = "00:00:00:10"; 

void setup()
{
  // 0. Init USB port for debugging
  USB.ON();
  USB.println(F("C_09 Example"));

  // 0.1 Clear pending interruptions
  clearIntFlag();
  RTC.ON();
  RTC.clearAlarmFlag();
  RTC.OFF();

  ////////////////////////////////////////////////
  // 1. Initial message composition
  ////////////////////////////////////////////////

  // 1.1 Set mote Identifier (16-Byte max)
  frame.setID("WASPMOTE_001");	

  // 1.2 Create new ASCII frame
  frame.createFrame(ASCII);  

  // 1.3 Set frame fields (String - char*)
  frame.addSensor(SENSOR_STR, (char*) "C_09 Example");

  // 1.4 Print frame
  frame.showFrame();


  ////////////////////////////////////////////////
    // 2. Send initial message
    ////////////////////////////////////////////////
    // 2.1 Activates the GPRS_Pro module:
    if (GPRS_Pro.ON() == 1)
    {
        USB.println(F("GPRS_Pro module ready..."));

        // 2.2 Sets pin code:
        // **** must be substituted by the SIM code
        if (GPRS_Pro.setPIN("****") == 1) 
        {
            USB.println(F("PIN code accepted"));
        }
        else
        {
            USB.println(F("PIN code incorrect"));
        }

        // 2.3 Waits for connection to the network:
        if (GPRS_Pro.check(60) == 1)
        {
            USB.println(F("GPRS_Pro module connected to the network..."));

            // 2.4 Configure conneciton
            answer = GPRS_Pro.configureGPRS_TCP_UDP(SINGLE_CONNECTION, TRANSPARENT);
            if (answer == 1)
            {
                // if configuration is success shows the IP address
                USB.print(F("Configuration success. IP address: ")); 
                USB.println(GPRS_Pro.IP_dir);
                USB.print(F("Opening UDP socket..."));  

                // 2.5 “IP” and “port” must be substituted by the IP address and the port
                answer = GPRS_Pro.createSocket(UDP_CLIENT, "IP", "port");
                if (answer == 1)
                {
                    USB.println(F("Conected"));
                    delay(1000);

                    // sending initial message
                    if (GPRS_Pro.sendData(frame.buffer, frame.length) == 1) 
                    {
                        USB.println(F("Sent"));
                    }
                    else
                    {
                        USB.println(F("Fail"));
                    }

                    // changes from data mode to command mode:
                    GPRS_Pro.switchtoCommandMode();

                    USB.print(F("Closing UDP socket..."));  

                    if (GPRS_Pro.closeSocket() == 1) // Closes socket
                    {
                        USB.println(F("Done"));
                    }
                    else
                    {
                        USB.println(F("Fail"));
                    }
                }
                else if (answer == -2)
                {
                    USB.print(F("Connection failed. Error code: "));
                    USB.println(answer, DEC);
                    USB.print(F("CME error code: "));
                    USB.println(GPRS_Pro.CME_CMS_code, DEC);
                }
                else 
                {
                    USB.print(F("Connection failed. Error code: "));
                    USB.println(answer, DEC);
                }           
            }
            else if (answer < -14)
            {
                USB.print(F("Configuration failed. Error code: "));
                USB.println(answer, DEC);
                USB.print(F("CME error code: "));
                USB.println(GPRS_Pro.CME_CMS_code, DEC);
            }
            else 
            {
                USB.print(F("Configuration failed. Error code: "));
                USB.println(answer, DEC);
            }
        }
        else
        {
            USB.println(F("GPRS_Pro module NOT connected to the network..."));
        }
    }
    else
    {
        USB.println(F("GPRS_Pro module NOT started"));
    }

  // 2.6 Powers off the GPRS_Pro module
  GPRS_Pro.OFF(); 


}

void loop()
{

  ////////////////////////////////////////////////
  // 3. Measure corresponding values
  ////////////////////////////////////////////////
  USB.println(F("Measuring sensors..."));

  // 3.1 Starting Radiation Board
  RadiationBoard.ON();

  // 3.2 Measure radiation in cpm, during 5s (5000 millisecods)
  radiation = RadiationBoard.getCPM(5000);
  USB.print(F("radiation[cpm]: "));
  USB.println(radiation);
  USB.println();
  delay(2000);

  // 3.3 Turning OFF Radiation Board
  RadiationBoard.OFF();


  ///////////////////////////////////////////////
  // 4. Message composition
  ////////////////////////////////////////////////

  // 4.1 Set mote Identifier (16-Byte max)
  frame.setID("WASPMOTE_001");	

  // 4.2 Create new frame
  frame.createFrame(ASCII);  

  // 4.3 Add frame fields
  frame.addSensor(SENSOR_RAD, radiation);

  // 4.4 Print frame
  // Example: <=>\0x80\0x03#35689884#WASPMOTE_001#
  frame.showFrame();


  ////////////////////////////////////////////////
  // 5. Send message
  ////////////////////////////////////////////////

  USB.println(F("Sending data."));

  // 5.1 Activates the GPRS_Pro module:
    if (GPRS_Pro.ON() == 1)
    {
        USB.println(F("GPRS_Pro module ready..."));

        // 5.2 Sets pin code:
        // **** must be substituted by the SIM code
        if (GPRS_Pro.setPIN("****") == 1) 
        {
            USB.println(F("PIN code accepted"));
        }
        else
        {
            USB.println(F("PIN code incorrect"));
        }

        // 5.3 Waits for connection to the network:
        if (GPRS_Pro.check(60) == 1)
        {
            USB.println(F("GPRS_Pro module connected to the network..."));

            // 5.4 Configure conneciton
            answer = GPRS_Pro.configureGPRS_TCP_UDP(SINGLE_CONNECTION, TRANSPARENT);
            if (answer == 1)
            {
                // if configuration is success shows the IP address
                USB.print(F("Configuration success. IP address: ")); 
                USB.println(GPRS_Pro.IP_dir);
                USB.print(F("Opening UDP socket..."));  

                // 5.5 “IP” and “port” must be substituted by the IP address and the port
                answer = GPRS_Pro.createSocket(UDP_CLIENT, "IP", "port");
                if (answer == 1)
                {
                    USB.println(F("Conected"));
                    delay(1000);

                    // sending initial message
                    if (GPRS_Pro.sendData(frame.buffer, frame.length) == 1) 
                    {
                        USB.println(F("Sent"));
                    }
                    else
                    {
                        USB.println(F("Fail"));
                    }

                    // changes from data mode to command mode:
                    GPRS_Pro.switchtoCommandMode();

                    USB.print(F("Closing UDP socket..."));  

                    if (GPRS_Pro.closeSocket() == 1) // Closes socket
                    {
                        USB.println(F("Done"));
                    }
                    else
                    {
                        USB.println(F("Fail"));
                    }
                }
                else if (answer == -2)
                {
                    USB.print(F("Connection failed. Error code: "));
                    USB.println(answer, DEC);
                    USB.print(F("CME error code: "));
                    USB.println(GPRS_Pro.CME_CMS_code, DEC);
                }
                else 
                {
                    USB.print(F("Connection failed. Error code: "));
                    USB.println(answer, DEC);
                }           
            }
            else if (answer < -14)
            {
                USB.print(F("Configuration failed. Error code: "));
                USB.println(answer, DEC);
                USB.print(F("CME error code: "));
                USB.println(GPRS_Pro.CME_CMS_code, DEC);
            }
            else 
            {
                USB.print(F("Configuration failed. Error code: "));
                USB.println(answer, DEC);
            }
        }
        else
        {
            USB.println(F("GPRS_Pro module NOT connected to the network..."));
        }
    }
    else
    {
        USB.println(F("GPRS_Pro module NOT started"));
    }

  // 5.6 Powers off the GPRS_Pro module   
  GPRS_Pro.OFF();


  ////////////////////////////////////////////////
  // 6. Entering Deep Sleep mode
  ////////////////////////////////////////////////
  USB.println(F("Going to sleep..."));
  USB.println();
  PWR.deepSleep(sleepTime, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

  USB.ON();
  USB.println(F("wake"));



}




