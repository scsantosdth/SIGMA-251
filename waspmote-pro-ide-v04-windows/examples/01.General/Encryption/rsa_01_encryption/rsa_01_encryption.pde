/*   
 *  ------ RSA 01 - Calculate encrypted message with RSA --------  
 *   
 *  Explanation: This example calculates an encrypted message 
 *  using the RSA algorithm. For encryption, only the public key is needed.
 *  The public key is determined by the modulus and the exponent. 
 *  The "public key" is (n,e). Where 'n' is the modulus and 'e' is the 
 *  exponent of the public key.
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
 *  along with this program.  If not, see .  
 *   
 *  Version:           0.2
 *  Design:            David Gascon  
 *  Implementation:    Alvaro Gonzalez, Yuri Carmona
 */


#include "WaspRSA.h"

// 1. Declaration of Public key variables 
char modulus[] = 
"7ebd3e97454cc46ebcf758a5b0b1ddfc" \ 
"4775878048968cf3b2aaa0e34b8b0553" \ 
"15005c21a4e31404ebe82485ee114918" \ 
"8a5b96605c3f4437ef7deeff30a5eaa4" \ 
"af944c4405a1c3ac1f0d54453194f212" \ 
"ea50d6c04aee07b1c8c9a37661ad9126" \ 
"604f754f7270503f7b61fa7b72367cac" \ 
"7c871203caa31d77aa0616571ecf388b" ; 


// define exponent for public key 'e'
// This key is defined as HEX format:
// 0x00010001 = 65537 which is a prime number
char public_exponent[] = "00010001"; 

// 2. Declaration message to encrypt. In the example, 
// 'message' stands for the HEX representation of "Libelium"
char message[] = "4C6962656C69756D"; 

// 3. variable to store the encrypted message
char enc_message[300];


void setup()
{ 
  USB.ON();
  USB.println(F("Example RSA_01\n"));  

  USB.print(F("message:"));
  USB.println(message);
  USB.println();  

  USB.print(F("public_exponent:"));
  USB.println(public_exponent);  
  USB.println();  

  USB.println(F("public_modulus:"));
  RSA.printMessage(modulus); 
  USB.println();

} 


void loop()
{

  // Calculating encrypted message 
  RSA.encrypt(message
    , public_exponent
    , modulus
    , enc_message
    , sizeof(enc_message)); 

  USB.println(F("-------------------------"));
  USB.println(F("Encrypted message:"));
  USB.println(F("-------------------------"));
  RSA.printMessage(enc_message);
  USB.println(F("-------------------------"));

  USB.println(F("-------------------------"));
  USB.print(F("Encrypted length:"));
  USB.println((int)strlen(enc_message)); 
  USB.println(F("-------------------------"));
  USB.println();

  delay(10000); 

}


