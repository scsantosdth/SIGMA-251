/*  
 *  ------ [DM_01] - configure XBee basic parameters -------- 
 *  
 *  Explanation: This program shows how to configure basic XBee
 *  parameters in order to communicate between different XBee 
 *  devices using the same network. 
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

#include <WaspXBeeDM.h>
 
// PAN (Personal Area Network) Identifier
uint8_t  panID[2] = {0x12,0x34}; 

// Define Freq Channel to be set: 
// Digimesh 2.4Ghz. Range from 0x0B to 0x1A
// Digimesh 900Mhz. Range from 0x00 to 0x0B
uint8_t  channel = 0x0F;

// Define the Encryption mode: 1 (enabled) or 0 (disabled)
uint8_t encryptionMode = 0;

// Define the AES 16-byte Encryption Key
char  encryptionKey[] = "WaspmoteLinkKey!"; 
 
 
 
void setup()
{
  // open USB port
  USB.ON();

  USB.println(F("-------------------------------"));
  USB.println(F("Configure XBee Digimesh"));
  USB.println(F("-------------------------------"));
  
  
  // init XBee 
  xbeeDM.ON();    
  
  /////////////////////////////////////
  // 1. set channel 
  /////////////////////////////////////
  xbeeDM.setChannel( channel );

  // check at commmand execution flag
  if( xbeeDM.error_AT == 0 ) 
  {
    USB.print(F("1. Channel set OK to: 0x"));
    USB.printHex( xbeeDM.channel );
    USB.println();
  }
  else 
  {
    USB.println(F("1. Error calling 'setChannel()'"));
  }


  /////////////////////////////////////
  // 2. set PANID
  /////////////////////////////////////
  xbeeDM.setPAN( panID );

  // check the AT commmand execution flag
  if( xbeeDM.error_AT == 0 ) 
  {
    USB.print(F("2. PAN ID set OK to: 0x"));
    USB.printHex( xbeeDM.PAN_ID[0] ); 
    USB.printHex( xbeeDM.PAN_ID[1] ); 
    USB.println();
  }
  else 
  {
    USB.println(F("2. Error calling 'setPAN()'"));  
  }

  /////////////////////////////////////
  // 3. set encryption mode (1:enable; 0:disable)
  /////////////////////////////////////
  xbeeDM.setEncryptionMode( encryptionMode );

  // check the AT commmand execution flag
  if( xbeeDM.error_AT == 0 ) 
  {
    USB.print(F("3. AES encryption configured (1:enabled; 0:disabled):"));
    USB.println( xbeeDM.encryptMode, DEC );
  }
  else 
  {
    USB.println(F("3. Error calling 'setEncryptionMode()'"));
  }

  /////////////////////////////////////
  // 4. set encryption key
  /////////////////////////////////////
  xbeeDM.setLinkKey( encryptionKey );

  // check the AT commmand execution flag
  if( xbeeDM.error_AT == 0 ) 
  {
    USB.println(F("4. AES encryption key set OK"));
  }
  else 
  {
    USB.println(F("4. Error calling 'setLinkKey()'")); 
  }

  /////////////////////////////////////
  // 5. write values to XBee module memory
  /////////////////////////////////////
  xbeeDM.writeValues();

  // check the AT commmand execution flag
  if( xbeeDM.error_AT == 0 ) 
  {
    USB.println(F("5. Changes stored OK"));
  }
  else 
  {
    USB.println(F("5. Error calling 'writeValues()'"));   
  }

  USB.println(F("-------------------------------")); 
}

void loop()
{
    
  /////////////////////////////////////
  // 1. get channel 
  /////////////////////////////////////
  xbeeDM.getChannel();
  USB.print(F("channel: "));
  USB.printHex(xbeeDM.channel);
  USB.println();

  /////////////////////////////////////
  // 2. get PAN ID
  /////////////////////////////////////
  xbeeDM.getPAN();
  USB.print(F("panid: "));
  USB.printHex(xbeeDM.PAN_ID[0]); 
  USB.printHex(xbeeDM.PAN_ID[1]); 
  USB.println(); 
  
  /////////////////////////////////////
  // 3. get Encryption mode (1:enable; 0:disable)
  /////////////////////////////////////
  xbeeDM.getEncryptionMode();
  USB.print(F("encryption mode: "));
  USB.printHex(xbeeDM.encryptMode);
  USB.println(); 
  
  USB.println(F("-------------------------------")); 
     
  delay(3000);
}



