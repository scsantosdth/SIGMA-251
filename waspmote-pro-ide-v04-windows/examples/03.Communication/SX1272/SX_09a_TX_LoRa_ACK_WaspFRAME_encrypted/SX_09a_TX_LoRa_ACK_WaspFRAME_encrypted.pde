/*  
 *  ------ [SX_09a] - TX LoRa encrypted Frame -------- 
 *  
 *  Explanation: This example shows how to send an encrypted Waspmote 
 *  Frame using the SX1272 module. This encrypted frame can be sent to 
 *  Meshlium when the node has been registered with the proper AES key.
 *  Steps performed:
 *    - Configurate the LoRa mode
 *    - Create a new Waspmote Frame
 *    - Encrypt the Waspmote Frame
 *    - Send a packet with the encrypted frame    
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
#include <WaspAES.h>

// define the destination address to send packets
uint8_t rx_address = 1;

// Define private key to encrypt message  
char nodeID[] = "node_001"; 

// Define private 16-Byte key to encrypt message  
char password[] = "libeliumlibelium"; 

// define status variable
int e;



void setup()
{
  // Init USB port
  USB.ON();
  USB.println(F("SX_09a example"));
  USB.println(F("Semtech SX1272 module TX in LoRa, encryption example"));


  // set the node ID
  frame.setID(nodeID); 


  USB.println(F("----------------------------------------"));
  USB.println(F("Setting configuration:")); 
  USB.println(F("----------------------------------------"));

  // Init sx1272 module
  sx1272.ON();

  //// Options to configure: ////

  // Select frequency channel
  e = sx1272.setChannel(CH_12_868);
  USB.print(F("Setting Channel CH_12_868.\t state ")); 
  USB.println(e);

  // Select implicit (off) or explicit (on) header mode
  e = sx1272.setHeaderON();
  USB.print(F("Setting Header ON.\t\t state "));  
  USB.println(e); 

  // Select LoRa mode: from 1 to 10
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
  e = sx1272.setNodeAddress(2);
  USB.print(F("Setting Node Address to '2'.\t state "));
  USB.println(e);
  USB.println();

  delay(1000);  

  USB.println(F("----------------------------------------"));
  USB.println(F("Sending:")); 
  USB.println(F("----------------------------------------"));
}


void loop()
{   

  ////////////////////////////////////////////////
  // 1. Create a new Frame with sensor fields
  ////////////////////////////////////////////////
  USB.println(F("1. Creating an ASCII frame"));
  RTC.ON();
  ACC.ON();

  // get maximum frame size
  USB.print(F("Maximum Frame Size:"));
  USB.println(frame.getFrameSize(),DEC);

  // Create new frame (ASCII)
  frame.createFrame(ASCII); 

  // set frame fields (Battery sensor - uint8_t)
  frame.addSensor(SENSOR_BAT, (uint8_t) PWR.getBatteryLevel());
  // set ACC fields 
  frame.addSensor(SENSOR_ACC, ACC.getX(), ACC.getY(), ACC.getZ() );

  // Show the original frame via USB port
  frame.showFrame();


  ////////////////////////////////////////////////
  // 2. Create Frame with Encrypted contents
  ////////////////////////////////////////////////  
  USB.println(F("2. Encrypting Frame"));   

  /* Calculate encrypted message with ECB cipher mode and ZEROS padding
   The Encryption options are:
   - AES_128
   - AES_192
   - AES_256
   */
  frame.encryptFrame( AES_128, password ); 

  // Show the Encrypted frame via USB port
  frame.showFrame();
  USB.println();



  ////////////////////////////////////////////////////////////////
  // 3. Send encrypted message to another Waspmote
  ////////////////////////////////////////////////////////////////

  // Sending packet before ending a timeout and waiting for an ACK response  
  e = sx1272.sendPacketTimeoutACK( rx_address, frame.buffer, frame.length);

  // Check sending status
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
  USB.println();
  delay(5000);
}


