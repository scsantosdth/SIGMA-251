/*  
 *  ----- [SX_06c] - TX to Meshlium (with ACKs) ----- 
 *
 *  Explanation: This example shows how to configure the semtech 
 *  module in LoRa mode and then send packets to Meshlium.
 *  For this purpose, Waspmote Frames must be used.
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

// Include this library to transmit with sx1272
#include <WaspSX1272.h>
#include <WaspFrame.h>

// define the Waspmote ID 
//////////////////////////////////////////
char nodeID[] = "node_01";
//////////////////////////////////////////

// Define the Meshlium address to send packets
// The default Meshlium address is '1'
uint8_t meshlium_address = 1;

// status variable
int e;


void setup()
{
  // Init USB port
  USB.ON();
  USB.println(F("SX_06c example"));
  USB.println(F("Semtech SX1272 module. TX in LoRa to MESHLIUM (with ACKs)"));

  // Switch ON RTC
  RTC.ON();

  // Switch ON ACC
  ACC.ON();

  // set the Waspmote ID
  frame.setID(nodeID);  

  USB.println(F("----------------------------------------"));
  USB.println(F("Setting configuration:")); 
  USB.println(F("----------------------------------------"));
  
  // Init sx1272 module
  sx1272.ON();

  // Select frequency channel
  e = sx1272.setChannel(CH_12_868);
  USB.print(F("Setting Channel CH_12_868.\t state ")); 
  USB.println(e);

  // Select implicit (off) or explicit (on) header mode
  e = sx1272.setHeaderON();
  USB.print(F("Setting Header ON.\t\t state "));  
  USB.println(e); 

  // Select mode (mode 1)
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
  e = sx1272.setNodeAddress(5);
  USB.print(F("Setting Node Address to '5'.\t state "));
  USB.println(e);
  USB.println();

  delay(1000);

  USB.println(F("----------------------------------------"));
  USB.println(F("Sending:")); 
  USB.println(F("----------------------------------------"));
}


void loop()
{

  // get Time from RTC
  RTC.getTime();

  ///////////////////////////////////////////
  // 1. Create ASCII frame
  ///////////////////////////////////////////  

  USB.println(F("Create a new Frame:"));
  
  // create new frame
  frame.createFrame(ASCII);  

  // add frame fields
  frame.addSensor(SENSOR_DATE, RTC.date, RTC.month, RTC.year);
  frame.addSensor(SENSOR_TIME, RTC.hour, RTC.minute, RTC.second);
  frame.addSensor(SENSOR_ACC, ACC.getX(), ACC.getY(), ACC.getZ());
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel()); 

  // Prints frame
  frame.showFrame();


  ///////////////////////////////////////////
  // 2. Send packet
  ///////////////////////////////////////////  

  // Sending packet before ending a timeout
  e = sx1272.sendPacketTimeoutACK( meshlium_address, frame.buffer, frame.length );
  
  // if ACK was received check signal strength
  if( e == 0 )
  {   
    USB.println(F("Packet sent OK"));     
    
    e = sx1272.getSNR();
    USB.print(F("-> SNR: "));
    USB.println(sx1272._SNR); 
    
    e = sx1272.getRSSI();
    USB.print(F("-> RSSI: "));
    USB.println(sx1272._RSSI);   
    
    e = sx1272.getRSSIpacket();
    USB.print(F("-> Last packet RSSI value is: "));    
    USB.println(sx1272._RSSIpacket); 
  }
  else 
  {
    USB.println(F("Error sending the packet"));  
    USB.print(F("state: "));
    USB.println(e, DEC);
  } 

  USB.println();
  delay(2500);
}



