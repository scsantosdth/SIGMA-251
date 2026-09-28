/*
 *  ------Waspmote AES_02 Encryption 128 ECB PKCS --------
 *
 *  This example shows how to encrypt plain text using:
 *    - AES algorithm
 *    - 192-bit key size
 *    - PKCS Padding
 *    - ECB Cipher Mode  
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
 *  Version:                0.4
 *  Design:                 David Gascón
 *  Implementation:         Alvaro Gonzalez, Yuri Carmona
 */
 
#include "WaspAES.h"

// Define a 24-Byte (AES-192) private key to encrypt message  
char password[] = "libeliumlibeliumlibelium"; 

// original message on which the algorithm will be applied 
char message[] = "This_is_a_message"; 

// Variable for encrypted message's length
uint16_t encrypted_length;

// Declaration of variable encrypted message 
uint8_t encrypted_message[300]; 





void setup()
{  
  // init USB port 
  USB.ON();   
  USB.println(F("AES_02 example:"));
  USB.println(F("- 192-bit Key Size"));    
  USB.println(F("- ECB Cipher Mode"));   
  USB.println(F("- PKCS5 padding"));
  USB.println();

  USB.print(F("\nOriginal message:")); 
  USB.println(message);

  USB.print(F("Original length:")); 
  USB.println((int)strlen(message));
  USB.println();

} 

void loop()
{   
  ////////////////////////////////////////////////////////////////
  // 1. Encrypt message
  ////////////////////////////////////////////////////////////////
  USB.println(F("1. Encrypt message"));
  
  // 1.1. Calculate length in Bytes of the encrypted message 
  encrypted_length = AES.sizeOfBlocks(message);

  // 1.2. Calculate encrypted message with ECB cipher mode and PKCS5 padding. 
  AES.encrypt(  AES_192
              , password
              , message
              , encrypted_message
              , ECB
              , PKCS5); 

  // 1.3. Printing encrypted message    
  USB.print(F("AES Encrypted message:")); 
  AES.printMessage( encrypted_message, encrypted_length); 

  // 1.4. Printing encrypted message's length 
  USB.print(F("AES Encrypted length:")); 
  USB.println( (int)encrypted_length);
  USB.println();
  
  delay(5000);
  USB.println(F("***********************"));

}

