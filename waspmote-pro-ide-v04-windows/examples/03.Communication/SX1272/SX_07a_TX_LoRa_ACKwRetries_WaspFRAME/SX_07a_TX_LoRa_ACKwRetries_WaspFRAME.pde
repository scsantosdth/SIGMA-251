/*  
 *  ------ [SX_07a] - TX LoRa with ACKs and Retries -------- 
 *  
 *  Explanation: This example shows how to send a Waspmote Frame
 *  via SX1272 module. Steps performed:
 *    - Configurate the LoRa mode
 *    - Create a new Waspmote Frame
 *    - Send a packet
 *  
 *  Copyright (C) 2014 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Implementation:    Covadonga Albiñana, Yuri Carmona
 */

// Include these libraries to transmit frames with sx1272
#include <WaspSX1272.h>
#include <WaspFrame.h>


// define the destination address to send packets
uint8_t rx_address = 2;


// define the Waspmtoe ID
////////////////////////////////
char nodeID[] = "node_001";
////////////////////////////////

// define status variable
int e;


void setup()
{
  // Init USB port
  USB.ON();
  USB.println(F("SX_07a example"));
  USB.println(F("Semtech SX1272 module. TX LoRa with Waspmote Frame, ACKs and Retries"));

  // set node ID
  frame.setID(nodeID);

  // Init Accelerometer
  ACC.ON();


  USB.println(F("----------------------------------------"));
  USB.println(F("Setting configuration:")); 
  USB.println(F("----------------------------------------"));

  // Init sx1272 module
  sx1272.ON();

  // Select frequency channel
  e = sx1272.setChannel(CH_11_868);
  USB.print(F("Setting Channel CH_11_868.\t state ")); 
  USB.println(e);

  // Select implicit (off) or explicit (on) header mode
  e = sx1272.setHeaderON();
  USB.print(F("Setting Header ON.\t\t state "));
  USB.println(e); 

  // Select mode: from 1 to 10
  e = sx1272.setMode(1);  
  USB.print(F("Setting Mode '1'.\t\t state ")); 
  USB.println(e);  

  // Select CRC on or off
  e = sx1272.setCRC_ON();
  USB.print(F("Setting CRC ON.\t\t\t state "));
  USB.println(e);  

  // Select output power (Max, High or Low)
  e = sx1272.setPower('H');
  USB.print(F("Setting Power to 'H'.\t\t state ")); 
  USB.println(e); 

  // Select the node address value: from 2 to 255
  e = sx1272.setNodeAddress(3);
  USB.print(F("Setting Node Address to '3'.\t state "));
  USB.println(e);

  // Select the maximum number of retries: from '0' to '5'
  e = sx1272.setRetries(3);
  USB.print(F("Setting Max retries to '3'.\t state "));
  USB.println(e);
  USB.println();

  delay(1000);  

  USB.println(F("----------------------------------------"));
  USB.println(F("Sending:")); 
  USB.println(F("----------------------------------------"));
}


void loop()
{  
  
  ///////////////////////////////////////////
  // 1. Create ASCII frame
  ///////////////////////////////////////////  

  // Creating frame to send
  frame.createFrame(ASCII);
  USB.println(F("Frame created"));

  // Adding sensor battery
  frame.addSensor(SENSOR_BAT, (uint8_t) PWR.getBatteryLevel());
  USB.println(F("Battery level added"));

  // Adding accelerometer
  frame.addSensor(SENSOR_ACC, ACC.getX(), ACC.getY(), ACC.getZ() );
  USB.println(F("Accelerometer added"));

  // Printing frame
  frame.showFrame(); 
  
  

  ///////////////////////////////////////////
  // 2. Send packet
  ///////////////////////////////////////////  
  
  // 2.1. Sending packet, with retries if failure, and waiting an ACK response
  e = sx1272.sendPacketTimeoutACKRetries( rx_address, frame.buffer, frame.length);
  
  
  // 2.2. Check sending status
  if( e == 0 ) 
  {
    USB.println(F("--> Packet sent OK"));     
  }
  else 
  {
    USB.println(F("--> Error sending the packet"));  
    USB.print(F("state: "));
    USB.println(e, DEC);
  } 

  USB.println();
  delay(5000);
}


