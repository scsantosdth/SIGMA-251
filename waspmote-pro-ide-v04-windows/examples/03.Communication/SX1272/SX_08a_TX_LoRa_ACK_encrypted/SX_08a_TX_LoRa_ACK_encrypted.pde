/*  
 *  ------ [SX_08a] - TX LoRa encrypted message -------- 
 *  
 *  Explanation: This example shows how to encrypt a plain text message 
 *  and then send the ciphertext via SX1272 module. Steps performed:
 *    - Configurate the LoRa mode
 *    - Encrypt the text message
 *    - Send a packet with the encrypted message   
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
#include <WaspAES.h>

// define the destination address to send packets
uint8_t rx_address = 8;

// Define private a 16-Byte key to encrypt message  
char password[] = "libeliumlibelium"; 

// original message on which the algorithm will be applied 
char message[] = "Hello, this is a test";

// define status variable
int e;

// Declaration of variable encrypted message 
uint8_t encrypted_message[300]; 

// Variable for encrypted message's length
uint16_t encrypted_length;


void setup()
{
  // Init USB port
  USB.ON();
  USB.println(F("SX_08a example"));
  USB.println(F("Semtech SX1272 module TX in LoRa, encryption example"));

  USB.println(F("----------------------------------------"));
  USB.println(F("Setting configuration:")); 
  USB.println(F("----------------------------------------"));

  // Init sx1272 module
  sx1272.ON();

  //// Options to configure: ////

  // Select frequency channel
  e = sx1272.setChannel(CH_16_868);
  USB.print(F("Setting Channel CH_16_868.\t state ")); 
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

  ////////////////////////////////////////////////////////////////
  // 1. Encrypt message
  ////////////////////////////////////////////////////////////////
  USB.print(F("Original message:"));
  USB.println(message);

  // 1.1. Calculate length in Bytes of the encrypted message 
  encrypted_length = AES.sizeOfBlocks(message);

  // 1.2. Calculate encrypted message with ECB cipher mode and PKCS5 padding. 
  AES.encrypt(  AES_128
    , password
    , message
    , encrypted_message
    , ECB
    , PKCS5); 

  // 1.3. Printing encrypted message    
  USB.print(F("Encrypted message:")); 
  AES.printMessage( encrypted_message, encrypted_length); 

  // 1.4. Printing encrypted message's length 
  USB.print(F("Encrypted length:")); 
  USB.println( (int)encrypted_length);




  ////////////////////////////////////////////////////////////////
  // 2. Send encrypted message to another Waspmote
  ////////////////////////////////////////////////////////////////

  // 2.1. Sending packet before ending a timeout and waiting for an ACK response  
  e = sx1272.sendPacketTimeoutACK(rx_address, encrypted_message, encrypted_length);
  
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


