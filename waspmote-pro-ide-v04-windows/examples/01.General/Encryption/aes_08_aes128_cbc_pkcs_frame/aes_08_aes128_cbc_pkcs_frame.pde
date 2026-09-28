/*
 *  ------Waspmote AES_08 Encryption 128 ECB PKCS --------
 *
 *  This example shows how to encrypt a binary message:
 *    - AES algorithm
 *    - 128-bit key size
 *    - PKCS Padding
 *    - CBC Cipher Mode  
 *  
 *  Copyright (C) 2014 Libelium Comunicaciones Distribuidas S.L.
 *  http://www.libelium.com
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
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
 *  Version:                0.3
 *  Design:                 David Gascón
 *  Implementation:         Yuri Carmona
 */
 
#include "WaspAES.h"
#include "WaspFrame.h"

// Define private key to encrypt message  
char nodeID[] = "node_001"; 

// Define a 16-Byte (AES-128) private key to encrypt message  
char password[] = "libeliumlibelium"; 

// Define Initial Vector
uint8_t IV[16] = { 0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F};

// Variable for encrypted message's length
uint16_t encrypted_length;

// 2. Declaration of variable encrypted message with enough memory space
uint8_t encrypted_message[300]; 



void setup()
{  
  // init USB port 
  USB.ON();   
  USB.println(F("AES_08 example:"));
  USB.println(F("- 128-bit Key Size"));    
  USB.println(F("- ECB Cipher Mode"));   
  USB.println(F("- PKCS5 padding"));
  USB.println();
  
  // set the node ID
  frame.setID(nodeID); 
} 


void loop()
{ 
  ////////////////////////////////////////////////
  // 1. Create a new Frame
  ////////////////////////////////////////////////
  USB.println(F("1. Creating an ASCII frame"));
  RTC.ON();

  // Create new frame (ASCII)
  frame.createFrame(ASCII); 

  // set frame fields (String - char*)
  frame.addSensor(SENSOR_STR, (char*) "this_is_a_message");
  // set frame fields (Battery sensor - uint8_t)
  frame.addSensor(SENSOR_BAT, (uint8_t) PWR.getBatteryLevel());
  // set frame fields (Temperature in Celsius sensor - float)
  frame.addSensor(SENSOR_IN_TEMP, (float) RTC.getTemperature());

  // Prints frame
  frame.showFrame();
  USB.println();
  
  
  ////////////////////////////////////////////////
  // 2. Encrypt Frame
  ////////////////////////////////////////////////  
  USB.println(F("2. Encrypting Frame"));
  
  
  // 2.1. Calculate length in Bytes of the encrypted message 
  encrypted_length = AES.sizeOfBlocks(frame.length); 
  
  // 2.2. Calculate encrypted message with ECB cipher mode and PKCS5 padding. 
  AES.encrypt(  128
              , password
              , frame.buffer
              , frame.length
              , encrypted_message
              , CBC
              , PKCS5
              , IV); 

  // 2.3. Printing encrypted message    
  USB.print(F("AES Encrypted message:")); 
  AES.printMessage( encrypted_message, encrypted_length); 

  // 2.4. Printing encrypted message's length 
  USB.print(F("AES Encrypted length:")); 
  USB.println( (int)encrypted_length);
  USB.println();
  

  delay(10000);   
  USB.println(F("***********************"));
}

