/*  
 *  ------ [C_15] - Sending basic values via WIFI HTTP -------- 
 *  
 *  Explanation: This example sends Waspmote basic sensors values 
 *  using WIFI module plugged on SOCKET0
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
 *  Implementation:    Javier Siscart
 */


#include <WaspWIFI.h>
#include <WaspFrame.h>

// Sleeping time DD:hh:mm:ss
char sleepTime[] = "00:00:00:10";    

// Sensor variables
float temperature = 0.0;
float light = 0;
float humidity = 0;

// WEB server settings 
/////////////////////////////////
char HOST[] = "pruebas.libelium.com";
char URL[]  = "GET$/getpost_frame_parser.php?";
/////////////////////////////////

// Variable to store data to be sent
char data[200];
// Define variable for communication status
uint8_t status;

void setup()
{
  // 0. Init USB port for debugging
  USB.ON();
  USB.println(F("C_15 Example"));


  ////////////////////////////////////////////////
  // 1. Initial message composition
  ////////////////////////////////////////////////

  // 1.1 Set mote Identifier (16-Byte max)
  frame.setID("WASPMOTE_001");	

  // 1.2 Create new frame
  frame.createFrame(ASCII);  

  // 1.3 Set frame fields (String - char*)
  frame.addSensor(SENSOR_STR, (char*) "C_15 Example");

  // 1.4 Print frame
  frame.showFrame();


  ////////////////////////////////////////////////
  // 2. Send initial message
  ////////////////////////////////////////////////
  USB.println(F("Turning WIFI module ON"));

  // 2.1 Switch on the WIFI module on the desired socket.
  WIFI.ON(SOCKET0);

  // 2.2 Configure the transport protocol (UDP, TCP, FTP, HTTP...) 
  WIFI.setConnectionOptions(UDP); 
  
  // 2.3 Configure the way the modules will resolve the IP address. 
  WIFI.setDHCPoptions(DHCP_ON); 

  // 2.4 Sets WPA1 encryptation // 1-64 Characters 
  WIFI.setAuthKey(WPA1, "password"); 

  // 2.5 Configure how to connect the AP.
  // Note: Here some parameters should be specified
  WIFI.setJoinMode(MANUAL);
  
  // 2.6 Save configuration
  WIFI.storeData();
  
  if (WIFI.join("libelium_AP")) 
  {
    //Print join
    USB.println("Joined");
    
    // 2.7 Add GPS data
    // Example: sprintf(data, "GET$/radioWIFItest.php?gps=%s", frame.buffer);
    sprintf(data, "request=%s", frame.buffer);

    // 2.8 Send the HTTP get/post query (specifying the WEB server so DNS is used)
    status = WIFI.getURL(DNS, HOST, URL, data);

  } 
  if (status == 0)
  {
    USB.println("Send ok");
  }
  else
  {
    USB.println("Could not send");
  }

  // 2.9 Power off WIFI module
  WIFI.OFF();

  // 2.10 set up RTC 
  RTC.ON();

}

void loop()
{
  ////////////////////////////////////////////////
  // 3. Measure corresponding values
  ////////////////////////////////////////////////
  USB.println(F("Measuring sensors..."));

  temperature = Utils.readTemperature();
  humidity = Utils.readHumidity();
  light = Utils.readLight();


  ////////////////////////////////////////////////
  // 4. Message composition
  ////////////////////////////////////////////////

  // 4.1 Create new frame
  frame.createFrame(ASCII);  

  // 4.2 Add frame fields
  frame.addSensor(SENSOR_TCA, temperature);
  frame.addSensor(SENSOR_HUMA, humidity);
  frame.addSensor(SENSOR_LUM, light);
  frame.addSensor(SENSOR_STR, RTC.getTime());
  // 4.3 Print frame
  // Example: <=>\0x80\0x03#35689884#WASPMOTE_001#9#TCA:25.00#HUMA:60.0#LUM:27.000#
  frame.showFrame();


  ////////////////////////////////////////////////
  // 5. Send message
  ////////////////////////////////////////////////

  USB.println(F("Turning WIFI module ON"));

  // 5.1 Switch on the WIFI module on the desired socket.
  WIFI.ON(SOCKET0);

  if (WIFI.join("libelium_AP")) 
  {
    //Print join
    USB.println("Joined");
    
    // 5.2 Add GPS data
    // Example: sprintf(data, "GET$/radioWIFItest.php?gps=%s", frame.buffer);
    sprintf(data, "request=%s", frame.buffer);

    // 5.3 Send the HTTP get/post query (specifying the WEB server so DNS is used)
    status = WIFI.getURL(DNS, HOST, URL, data);
    if( status == 1)
    {
      USB.println(F("\nHTTP query OK."));
      USB.print(F("WIFI.answer:"));
      USB.println(WIFI.answer);
      
      /*
       * At this point, it could be possible
       * to parse the web server information
       */
    }
    else
    {
      USB.println(F("\nHTTP query ERROR"));
    }
  } 
  else
  {
    USB.println(F("NOT joined"));
  }
  
  // 5.4 Power off WIFI module
  WIFI.OFF();


  ////////////////////////////////////////////////
  // 6. Entering Deep Sleep mode
  ////////////////////////////////////////////////
  USB.ON();
  USB.println(F("Going to sleep..."));

  PWR.deepSleep(sleepTime, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

  USB.ON();
  RTC.ON();
  USB.println(F("wake"));

}

