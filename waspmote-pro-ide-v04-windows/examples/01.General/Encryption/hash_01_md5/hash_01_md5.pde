/*
 *  ------Waspmote HASH_01 MD5 Message Digest--------
 *
 *  This example shows how to calculate MD5 message digest to
 *  provide INTEGRITY to the sending of information. Both data
 *  must be sent over the network: MESSAGE + HASH_MESSAGE
 *
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
uint8_t hash_message_md5[16];
  
  
void setup()
{
  USB.ON();
  USB.println(F("HASH_01 example"));
  USB.println();
}


void loop()
{	 

  USB.print(F("Original message: "));
  USB.println(message);
  
  // Calculate hash of original message with MD5 Algorithm  
  HASH.md5( hash_message_md5, (uint8_t*)message, strlen(message)*8); 
 
  // Printing message digest MD5  
  USB.println(F("The message digest created for the original message is: "));
  HASH.printMessageDigest("MD5:", hash_message_md5 , 16); 

  delay(5000);
  USB.println();
  USB.println(F("*******************"));
}
