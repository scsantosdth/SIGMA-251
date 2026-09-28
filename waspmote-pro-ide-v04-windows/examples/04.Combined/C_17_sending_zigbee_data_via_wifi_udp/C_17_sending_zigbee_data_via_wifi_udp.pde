/*  
 *  ------ [C_17] - Sending Zigbee data via WIFI UDP -------- 
 *  
 *  Explanation: This code receives packets via XBeeZigbee plugged 
 *  on socket 0 (during 20s). Then, the surce address of the received 
 *  packet is parsed and sent using WIFI module via UDP plugged 
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
 *  Version:           0.3
 *  Design:            David Gascón 
 *  Implementation:    Javier Siscart
 */

#include <WaspXBeeZB.h>
#include <WaspFrame.h>
#include <WaspWIFI.h>

// Variables to store source's network address
uint8_t sourceAddress[8];
char sourceAddressString[17];

// Time to wait for new packets (milliseconds)
unsigned long timeout = 20000;

// Flag to know when a packet is received
bool packetReceived = false;

// Sleeping time DD:hh:mm:ss
char sleepTime[] = "00:00:00:10";    

void setup()
{
    // 0. Init USB port for debugging
    USB.ON();
    USB.println(F("C_17 Example"));


    ////////////////////////////////////////////////
    // 1. Initial message composition
    ////////////////////////////////////////////////

    // 1.1 Set mote Identifier (16-Byte max)
    frame.setID("WASPMOTE_001");	

    // 1.2 Create new frame
    frame.createFrame(ASCII);  

    // 1.3 Set frame fields (String - char*)
    frame.addSensor(SENSOR_STR, (char*) "C_17 Example");

    // 1.4 Print frame
    frame.showFrame();


    ////////////////////////////////////////////////
    // 2. Send initial message
    ////////////////////////////////////////////////
    USB.println(F("Turning WIFI module ON"));

    // 2.1 Switch on the WIFI module on the desired socket.
    WIFI.ON(SOCKET1);

    // 2.2 Configure the transport protocol (UDP, TCP, FTP, HTTP...) 
    WIFI.setConnectionOptions(UDP); 
    
    // 2.3 Configure the way the modules will resolve the IP address. 
    WIFI.setDHCPoptions(DHCP_ON); 

    // 2.4 Sets WPA1 encryptation // 1-64 Characters 
    WIFI.setAuthKey(WPA1, "password"); 

    // 2.5 Configure how to connect the AP.
    WIFI.setJoinMode(MANUAL);
    
    // 2.6 Save configuration
    WIFI.storeData();
    
    if (WIFI.join("libelium_AP")) 
    {
        // 2.7 Call the function to create UDP connection to IP adress  

        if (WIFI.setUDPclient("IP",2000,2000)) 
        {  
            // 2.8 Now we can use send UDP messages. 
            WIFI.send(frame.buffer, frame.length); 

            USB.println(F("Initial message sent"));

            // 2.9 Closes the UDP and enters in command mode. 
            WIFI.close(); 
        } 
    } 

    // 2.10 Turn OFF USB
    USB.OFF();

}

void loop()
{
    ////////////////////////////////////////////////
    // 3. Check for incoming packets via XBee ZigBee
    ////////////////////////////////////////////////

    // 3.1 Turn ON USB for debug
    USB.ON();
    USB.println(freeMemory());

    // 3.2 Init XBee
    xbeeZB.ON();

    delay(3000);

    // 3.3 check XBee's network parameters
    checkNetworkParams();
    USB.println(F("Receiving packets via XBee ZigBee"));

    // 3.4 Receive XBee packet (wait for 10 seconds)
	packetReceived = xbeeZB.receivePacketTimeout( 10000 );

	// check answer  
    if( packetReceived == 0 ) 
    {
        // Show data stored in '_payload' buffer indicated by '_length'
        USB.print(F("Data: "));  
        USB.println( xbeeZB._payload, xbeeZB._length);
        
        // Show data stored in '_payload' buffer indicated by '_length'
        USB.print(F("Length: "));  
        USB.println( xbeeZB._length,DEC);
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
        USB.println(packetReceived,DEC);     
    }

    // 3.5 Turn ZigBee module OFF
    xbeeZB.OFF();


    ////////////////////////////////////////////////
    // 4. Message composition
    ////////////////////////////////////////////////

    // get time
    RTC.ON();
    RTC.getTime();

    // 4.1 Create new frame
    frame.createFrame(ASCII);  

    // 4.2 Add frame fields depending if a packet is received or not.
    if ( packetReceived == 0 )
    {
        Utils.hex2str(xbeeZB._srcMAC, sourceAddressString);
        frame.addSensor(SENSOR_TIME, RTC.hour, RTC.minute, RTC.second ); 
        frame.addSensor(SENSOR_MAC, sourceAddressString); 
    }
    else
    {
        USB.println(F("\nNo packets received:")); 
        frame.addSensor(SENSOR_TIME, RTC.hour, RTC.minute, RTC.second ); 
        frame.addSensor(SENSOR_STR, "No packets."); 
    }

    // 4.3 Print frame
    // Example: <=>\0x80\0x02#35689884#WASPMOTE_001#1#STR:New packet received from:#MAC:0013A200406B4C9C#
    frame.showFrame();


    ////////////////////////////////////////////////
    // 5. Send message via WIFI
    ////////////////////////////////////////////////
    USB.println(F("Turning WIFI module ON"));

    // 5.1 Turn ON wifi
    WIFI.ON(SOCKET1);
    
    if (WIFI.join("libelium_AP")) 
    {
        // 5.2 Call the function to create UDP connection to IP adress  

        if (WIFI.setUDPclient("***IP***",2000,2000)) 
        {  
            // 5.3 Now we can use send UDP messages. 
            WIFI.send(frame.buffer, frame.length); 

            // 5.4 Closes the UDP and enters in command mode. 
            WIFI.close(); 
        } 
    } 


    ////////////////////////////////////////////////
    // 6. Entering Deep Sleep mode
    ////////////////////////////////////////////////
    USB.println(F("Going to sleep..."));
    USB.println();
    PWR.deepSleep(sleepTime, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

}




/*******************************************
 *
 *  checkNetworkParams - Check operating
 *  network parameters in the XBee module
 *
 *******************************************/
void checkNetworkParams()
{
    // 1. get operating 64-b PAN ID
    xbeeZB.getOperating64PAN();

    // 2. wait for association indication
    xbeeZB.getAssociationIndication();

    while( xbeeZB.associationIndication != 0 )
    { 
        delay(2000);

        // get operating 64-b PAN ID
        xbeeZB.getOperating64PAN();

        USB.print(F("operating 64-b PAN ID: "));
        USB.printHex(xbeeZB.operating64PAN[0]);
        USB.printHex(xbeeZB.operating64PAN[1]);
        USB.printHex(xbeeZB.operating64PAN[2]);
        USB.printHex(xbeeZB.operating64PAN[3]);
        USB.printHex(xbeeZB.operating64PAN[4]);
        USB.printHex(xbeeZB.operating64PAN[5]);
        USB.printHex(xbeeZB.operating64PAN[6]);
        USB.printHex(xbeeZB.operating64PAN[7]);
        USB.println();     

        xbeeZB.getAssociationIndication();
    }

    USB.println(F("\nJoined a network!"));

    // 3. get network parameters 
    xbeeZB.getOperating16PAN();
    xbeeZB.getOperating64PAN();
    xbeeZB.getChannel();

    USB.print(F("operating 16-b PAN ID: "));
    USB.printHex(xbeeZB.operating16PAN[0]);
    USB.printHex(xbeeZB.operating16PAN[1]);
    USB.println();

    USB.print(F("operating 64-b PAN ID: "));
    USB.printHex(xbeeZB.operating64PAN[0]);
    USB.printHex(xbeeZB.operating64PAN[1]);
    USB.printHex(xbeeZB.operating64PAN[2]);
    USB.printHex(xbeeZB.operating64PAN[3]);
    USB.printHex(xbeeZB.operating64PAN[4]);
    USB.printHex(xbeeZB.operating64PAN[5]);
    USB.printHex(xbeeZB.operating64PAN[6]);
    USB.printHex(xbeeZB.operating64PAN[7]);
    USB.println();

    USB.print(F("channel: "));
    USB.printHex(xbeeZB.channel);
    USB.println();

}


