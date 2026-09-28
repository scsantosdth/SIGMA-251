/*  
 *  ------ [868_01] - configure basic XBee parameters -------- 
 *  
 *  Explanation: This program shows how to set the basic networking
 *  parameters to a XBee module.
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

#include <WaspXBee868.h>

// PAN (Personal Area Network) Identifier
uint8_t  panID[2] = {0x12,0x34}; 

// Define the Encryption mode: 1 (enabled) or 0 (disabled)
uint8_t encryptionMode = 0;

// Define the AES 16-byte Encryption Key
char  encryptionKey[] = "WaspmoteLinkKey!"; 


void setup()
{
  // open USB port
  USB.ON();

  USB.println(F("-------------------------------"));
  USB.println(F("Configure XBee 868"));
  USB.println(F("-------------------------------"));

  // init XBee 
  xbee868.ON();


  /////////////////////////////////////
  // 1. set PANID
  /////////////////////////////////////
  xbee868.setPAN( panID );

  // check the AT commmand execution flag
  if( xbee868.error_AT == 0 ) 
  {
    USB.print(F("1. PAN ID set OK to: 0x"));
    USB.printHex( xbee868.PAN_ID[0] ); 
    USB.printHex( xbee868.PAN_ID[1] ); 
    USB.println();
  }
  else 
  {
    USB.println(F("1. Error calling 'setPAN()'"));  
  }

  /////////////////////////////////////
  // 2. set encryption mode (1:enable; 0:disable)
  /////////////////////////////////////
  xbee868.setEncryptionMode( encryptionMode );

  // check the AT commmand execution flag
  if( xbee868.error_AT == 0 ) 
  {
    USB.print(F("2. AES encryption configured (1:enabled; 0:disabled):"));
    USB.println( xbee868.encryptMode, DEC );
  }
  else 
  {
    USB.println(F("2. Error calling 'setEncryptionMode()'"));
  }

  /////////////////////////////////////
  // 3. set encryption key
  /////////////////////////////////////
  xbee868.setLinkKey( encryptionKey );

  // check the AT commmand execution flag
  if( xbee868.error_AT == 0 ) 
  {
    USB.println(F("3. AES encryption key set OK"));
  }
  else 
  {
    USB.println(F("3. Error calling 'setLinkKey()'")); 
  }

  /////////////////////////////////////
  // 4. write values to XBee module memory
  /////////////////////////////////////
  xbee868.writeValues();

  // check the AT commmand execution flag
  if( xbee868.error_AT == 0 ) 
  {
    USB.println(F("4. Changes stored OK"));
  }
  else 
  {
    USB.println(F("4. Error calling 'writeValues()'"));   
  }

  USB.println(F("-------------------------------")); 
}



void loop()
{

  /////////////////////////////////////
  // 1. get PANID
  /////////////////////////////////////
  xbee868.getPAN();
  USB.print(F("panid: "));
  USB.printHex(xbee868.PAN_ID[0]); 
  USB.printHex(xbee868.PAN_ID[1]); 
  USB.println(); 

  /////////////////////////////////////
  // 2. get encryption mode (1:enable; 0:disable)
  /////////////////////////////////////
  xbee868.getEncryptionMode();
  USB.print(F("encryption mode: "));
  USB.printHex(xbee868.encryptMode);
  USB.println(); 

  USB.println(F("-------------------------------")); 

  delay(3000);
}



