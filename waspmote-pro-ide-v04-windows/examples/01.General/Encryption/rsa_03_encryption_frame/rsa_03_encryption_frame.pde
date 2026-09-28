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
#include "WaspFrame.h"

// 1. Declaration of Public key variables 
char public_modulus[] = 
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


char private_exponent[] = 
"4ea5689dbe27310df6bd16895ae844f4" \ 
"33f3beade05d6c021db0bc3dcfb6e90a" \ 
"f15153da9cd33cad012700e30b2436d3" \ 
"bfa7addd05e14c97d949b07132e30283" \ 
"663f39a32662d951d7d53ef92ef39d2e" \ 
"a791689065f656f5ffb5f60c92f91b98" \ 
"1f8127a90235a05d9b82c223d43bce92" \ 
"002b097e6634be3141f480d4e5333341" ;  

char p[] = 
"cada49cc750e4ff40bad216aa2ff3a69" \ 
"c5cbcc6d2a320dd81a098e5a995e30dc" \ 
"f40a0a775130471f3a4ebd364a003f6a" \ 
"65b2a02be98f7394258c51c324f1da03" ;                 

char q[] = 
"9ff1e238eb0217b573239fd0b98fac6a" \ 
"97907f0534e2c59356e637e400e0b8a2" \ 
"497d7f53a614a29991dfb630e5d74b7f" \ 
"95e10c9663a34f67fc65009f51b724d9" ; 

char dp[] = 
"39924a6fa4a93337e83872cb790746e4" \ 
"ce2651168a6b3a52a2d1237dc3196074" \ 
"d52e245a48c892e6e1fd86e5e98ab874" \ 
"d1f8284d4e3450713356e7bda2b6a151" ; 

char dq[] = 
"6c08eafffd2525b4873819dbd76b074f" \ 
"dc5e5a9dbeb22a38326b40773e6c8be9" \ 
"fa6fcd50480f0a2166d9cfeb496459f7" \ 
"acda1d317bcdb4760d927f901d96f249" ;           

char qp[] = 
"513c04961d1c7c762b49f37d02b12538" \ 
"569fc1ad0a158f7ba8c2a1217158b9d9" \ 
"c4b9ca80a989466544d497c233c2dd43" \ 
"51ffe83b760fe8a6de4737ecef77b0ba" ;  


// variable to store the encrypted message
char enc_message[300];



void setup()
{ 
  USB.ON();
  USB.println(F("Example RSA_03\n"));  

  USB.print(F("public_exponent:"));
  USB.println(public_exponent);  
  USB.println();  

  USB.println(F("public_modulus:"));
  RSA.printMessage(public_modulus); 
  USB.println();

} 


void loop()
{
  ////////////////////////////////////////////////
  // 1. Create a new Frame
  ////////////////////////////////////////////////
  USB.println(F("1. Creating an ASCII frame"));

  // Create new frame (ASCII)
  frame.createFrame(ASCII,"WASP_encrypted"); 

  // set frame fields (String - char*)
  frame.addSensor(SENSOR_STR, (char*) "XBee frame");
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

  // Calculating encrypted message 
  RSA.encrypt(frame.buffer
    , frame.length
    , public_exponent
    , public_modulus
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



