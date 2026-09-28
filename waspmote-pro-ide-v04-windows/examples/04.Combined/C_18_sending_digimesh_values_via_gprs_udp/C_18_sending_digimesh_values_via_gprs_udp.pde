/*  
 *  ------ [C_18] -sending Digimesh values via GPRS UDP -------- 
 *  
 *  Explanation: This code receives packets via XBee Digimesh plugged 
 *  on socket 0 (during 20s). Then, the surce address of the received 
 *  packet is parsed and sent using GPRS module via UDP plugged 
 *  on socket 1.
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


#include <WaspXBeeDM.h>
#include <WaspFrame.h>
#include <WaspGPRS_Pro.h>


// Variables to store source's network address
uint8_t sourceAddress[8];
char sourceAddressString[17];

// Time to wait for new packets (milliseconds)
unsigned long timeout = 20000;

// Flag to know when a packet is received
bool packetReceived = false;
// Variable to store GPRS answers.
int8_t answer;
// define variable
uint8_t error;


// Sleeping time DD:hh:mm:ss
char sleepTime[] = "00:00:00:10";    

void setup()
{
  // 0. Init USB port for debugging
  USB.ON();
  USB.println(F("C_18 Example"));


  ////////////////////////////////////////////////
  // 1. Initial message composition
  ////////////////////////////////////////////////

  // 1.1 Set mote Identifier (16-Byte max)
  frame.setID("WASPMOTE_001");	

  // 1.2 Create new frame
  frame.createFrame(ASCII);  

  // 1.3 Set frame fields (String - char*)
  frame.addSensor(SENSOR_STR, (char*) "C_18 Example");

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

      // 2.4 Configures connection
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


  // 2.7 Turn OFF USB
  USB.OFF();

}

void loop()
{
  ////////////////////////////////////////////////
  // 3. Check for incoming packets via XBee Digimesh
  ////////////////////////////////////////////////
  // 3.1 Init XBee 
  xbeeDM.ON();
  delay(3000);
    
  // 3.2 Receive XBee packet (wait for 10 seconds)
  USB.println("Wait to receive packet");
  error = xbeeDM.receivePacketTimeout( 10000 );

  // 3.3 Check answer  
  if( error == 0 ) 
  {
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("Data: "));  
    USB.println( xbeeDM._payload, xbeeDM._length);
    
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("Length: "));  
    USB.println( xbeeDM._length,DEC);
    
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("Source MAC Address: "));  
    USB.printHex( xbeeDM._srcMAC[0] );
    USB.printHex( xbeeDM._srcMAC[1] );
    USB.printHex( xbeeDM._srcMAC[2] );
    USB.printHex( xbeeDM._srcMAC[3] );
    USB.printHex( xbeeDM._srcMAC[4] );
    USB.printHex( xbeeDM._srcMAC[5] );
    USB.printHex( xbeeDM._srcMAC[6] );
    USB.printHex( xbeeDM._srcMAC[7] );
    USB.println();    
    USB.println(F("--------------------------------"));
  }
  else
  {
    // Print error message:
    /*
     * '7' : Buffer full. Not enough memory space
     * '6' : Error escaping character within payload bytes
     * '5' : Error escaping character in checksum byte
     * '4' : Checksum is not correct	  
     * '3' : Checksum byte is not available	
     * '2' : Frame Type is not valid
     * '1' : Timeout when receiving answer   
    */
    USB.print(F("Error receiving a packet:"));
    USB.println(error,DEC);     
    USB.println(F("--------------------------------"));  
  }

  // 3.4 Turn DM module OFF
  xbeeDM.OFF();

  ////////////////////////////////////////////////
  // 4. Message composition
  ////////////////////////////////////////////////

  // 4.1 Create new frame
  frame.createFrame(ASCII);  

  // 4.2 Add frame fields depending if a packet is received or not.
  if ( packetReceived == 1 )
  {
    Utils.hex2str(xbeeDM._srcMAC, sourceAddressString);
    frame.addSensor(SENSOR_STR, "New packet received from:"); 
    frame.addSensor(SENSOR_MAC, sourceAddressString); 
  }
  else
  {
    USB.println(F("\nNo packets received:")); 
    frame.addSensor(SENSOR_STR, "No packets received."); 
  }

  // 4.3 Print frame
  // Example: <=>\0x80\0x02#35689884#WASPMOTE_001#1#STR:New packet received from:#MAC:0013A200406B4C9C#
  frame.showFrame();


  ////////////////////////////////////////////////
  // 5. Send message via GPRS
  ////////////////////////////////////////////////
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
      answer = GPRS_Pro.configureGPRS_TCP_UDP(SINGLE_CONNECTION, NON_TRANSPARENT);
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
          USB.println(F("Connected"));
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


}








