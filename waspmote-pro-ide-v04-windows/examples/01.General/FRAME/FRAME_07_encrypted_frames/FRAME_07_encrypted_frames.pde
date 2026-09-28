/*  
 *  ------ FRAME_07 - encrypt Frame -------- 
 *  
 *  Explanation: This example shows how to encrypt a 
 *  Waspmote Frame using the Encryption libraries. In this example
 *  AES-128 is used. But AES-192 and AES-256 are available too. 
 *  Regarding the Block Cipher mode, only ECB is supported. And 
 *  regarding the padding mode: only ZEROS padding is supported
 *  The result for encryption function is stored in 
 *  'frame.buffer' and 'frame.length'
 *
 *  Copyright (C) 2015 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Version:           0.2
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */

#include <WaspFrame.h>
#include <WaspAES.h>

// define the Waspmote ID 
char moteID[] = "node_01";

// Define private 16-Byte key to encrypt message  
char password[] = "libeliumlibelium"; 


  
void setup()
{
  // Init USB port & Accelerometer
  USB.ON();    
  USB.println(F("FRAME_07 example")); 
  
  // set RTC on
  RTC.ON();
  
  // set the Waspmote ID
  frame.setID(moteID);  
}


void loop()
{
  /////////////////////////////////////////////
  // 1. create a new Frame
  /////////////////////////////////////////////
  USB.println(F("1. Creating an ASCII frame"));
  
  // Create new frame (ASCII)
  frame.createFrame(ASCII);
  USB.println(F("new Waspmote Frame created"));
  
  // set frame fields (Battery sensor - uint8_t)
  frame.addSensor(SENSOR_BAT, (uint8_t) PWR.getBatteryLevel());
  USB.println(F("Battery Level added"));
  
  // set frame fields (Temperature in Celsius sensor - float)
  frame.addSensor(SENSOR_IN_TEMP, (float) RTC.getTemperature());
  USB.println(F("RTC temperature added"));

  // Prints frame
  frame.showFrame();
  USB.println();
  
  delay(2000);
    
    
  ////////////////////////////////////////////////
  // 2. Encrypt Waspmote Frame
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
      
  USB.println(F("*****************************"));
  delay(5000);

}

