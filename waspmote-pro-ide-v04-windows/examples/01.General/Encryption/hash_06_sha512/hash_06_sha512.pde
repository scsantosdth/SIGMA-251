/*
 *  ------Waspmote HASH_06 SHA-512 Message Digest--------
 *
 *  This example shows how to calculate SHA-512 message digest to
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
uint8_t hash_message_sha512[62]; 


void setup()
{
  USB.ON();
  USB.println(F("HASH_06 example"));
  USB.println(F("- SHA-512 algorithm"));
  USB.println(F("- Message Digest length of 512 bits (62 Bytes)"));
  USB.println();
  
  USB.print(F("Original message: "));
  USB.println(message);
}

void loop()
{
  // Calculate hash of original message with MD5 Algorithm  
  HASH.sha( SHA512, hash_message_sha512, (uint8_t*)message, strlen(message)*8); 
 
  // Printing message digest SHA-512 
  HASH.printMessageDigest("SHA-512:", hash_message_sha512, 62); 

  delay(5000);
}


