/*
 *  ------Waspmote HASH_04 SHA-256 Message Digest--------
 *
 *  This example shows how to calculate SHA-256 message digest to
 *  provide INTEGRITY to the sending of information. Both data
 *  must be sent over the network: MESSAGE + HASH_MESSAGE
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
 *  Version:                0.2
 *  Design:                 David Gascón
 *  Implementation:         Alvaro Gonzalez, Yuri Carmona
 */
 
#include "WaspHash.h"


// Original message
char message[] = "Libelium";

// Variable to store the hash message
uint8_t hash_message_sha256[32]; 
    
  
void setup()
{
  USB.ON();
  USB.println(F("HASH_04 example"));
  USB.println(F("- SHA-256 algorithm"));
  USB.println(F("- Message Digest length of 256 bits (32 Bytes)"));
  USB.println();
  
  USB.print(F("Original message: "));
  USB.println(message);
}

void loop()
{	

  // Calculate hash of original message with SHA-256 Algorithm  
  HASH.sha( SHA256, hash_message_sha256, (uint8_t*)message, strlen(message)*8); 
 
  // Printing message digest SHA-256 
  HASH.printMessageDigest("SHA-256:", hash_message_sha256, 32); 

  delay(5000);
}
