/*
 *  ------Waspmote AES_07 Encryption 128 ECB PKCS --------
 *
 *  This example shows how to encrypt a Waspmote Frame to be sent to Meshlium:
 *    - AES algorithm
 *    - 128-bit key size
 *    - ZEROS Padding
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
 *  Version:                0.2
 *  Design:                 David Gascón
 *  Implementation:         Yuri Carmona
 */
 
#include "WaspAES.h"
#include "WaspFrame.h"
#include "WaspXBee802.h"

// Define private key to encrypt message  
char nodeID[] = "node_001"; 

// Define a 16-Byte (AES-128) private key to encrypt message  
char password[] = "libeliumlibelium"; 

// XBee packet structure 
packetXBee packet; 

// Destination MAC address
char MESHLIUM_ADDRESS[]="0013A2004052414C";


void setup()
{  
  // init USB port 
  USB.ON();   
  USB.println(F("AES_07 example:"));
  USB.println();
  
  // init RTC 
  RTC.ON();
  // init ACC
  ACC.ON();
  
  // set the node ID
  frame.setID(nodeID); 
} 


void loop()
{ 
  ////////////////////////////////////////////////
  // 1. Create a new Frame with sensor fields
  ////////////////////////////////////////////////
  USB.println(F("1. Creating an ASCII frame"));
  RTC.ON();

  // Set correct frame size depending on the networking protocol
  // In this case:
  //   -> XBee-802.15.4 module
  //   -> Unicast 64Byte addressing (MAC address)
  //   -> Link Encryption is disabled (HW encryption)
  //   -> AES Encryption is enabled (SW encryption)
  frame.setFrameSize(XBEE_802_15_4, UNICAST_64B, DISABLED, ENABLED);
  
  // get maximum frame size
  USB.print(F("Maximum Frame Size:"));
  USB.println(frame.getFrameSize(),DEC);
  
  // Create new frame (ASCII)
  frame.createFrame(BINARY); 

  // set frame fields (Battery sensor - uint8_t)
  frame.addSensor(SENSOR_BAT, (uint8_t) PWR.getBatteryLevel());
  // set frame fields (Temperature in Celsius sensor - float)
  frame.addSensor(SENSOR_IN_TEMP, (float) RTC.getTemperature());
  // set frame fields 
  frame.addSensor(SENSOR_ACC, ACC.getX(), ACC.getY(), ACC.getZ() );

  // Show the original frame via USB port
  frame.showFrame();
  USB.println();
  
  
  ////////////////////////////////////////////////
  // 2. Create Frame with Encrypted contents
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
  
  
  ////////////////////////////////////////////////
  // 3. Send Frame with encrypted contents to Meshlium
  ////////////////////////////////////////////////  

  // init XBee
  xbee802.ON();
  
  // clear packet structure
  memset( &packet, 0x00, sizeof(packet) );
  // Choose transmission mode: UNICAST or BROADCAST
  packet.mode = UNICAST; 
  
  // set destination XBee parameters to packet
  xbee802.setDestinationParams( &packet, MESHLIUM_ADDRESS, frame.buffer, frame.length );   
  
  // send XBee packet
  xbee802.sendXBee(&packet);
  
  // check TX flag
  if( xbee802.error_TX == 0 )
  {
    USB.println(F("sending ok"));
  }
  else 
  {
    USB.println(F("sending error"));
  }
  
  
  USB.println(F("*****************************"));
  // wait for five seconds
  delay(5000);
}

