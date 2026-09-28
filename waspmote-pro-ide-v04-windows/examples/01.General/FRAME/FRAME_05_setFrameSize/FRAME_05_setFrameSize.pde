/*  
 *  ------ FRAME_05 - set Frame Size simple -------- 
 *  
 *  Explanation: This example shows how to set the maximum frame size
 *  automatically by giving the following parameters: Xbee protocol,
 *  addressing, link encryption mode, AES encryption mode.
 *  NOTE: Only must be used when using XBee modules
 *  
 *  Copyright (C) 2012 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Version:           0.1 
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */

#include <WaspFrame.h>

  
void setup()
{
  // Init USB port & Accelerometer
  USB.ON();    
  USB.println(F("FRAME_05 example"));
  
  delay(2000);
}

void loop()
{
  /////////////////////////////////////////////
  // 1. set frame size for:
  /////////////////////////////////////////////
  //    XBee 802.15.4
  //    unicast 16-b addressing
  //    XBee encryption Disabled
  //    AES encryption Disabled
  frame.setFrameSize(XBEE_802_15_4, UNICAST_16B, DISABLED, DISABLED);

  USB.print(F("\nframe size (802_15_4, UNICAST_16B, XBee encryp Disabled, AES encryp Disabled):"));
  USB.println(frame.getFrameSize(),DEC);  
  delay(500);
  
  
  
  /////////////////////////////////////////////
  // 2. set frame size for:
  /////////////////////////////////////////////
  //    XBee 868
  //    unicast 64-b addressing (default)
  //    XBee encryption Enabled
  //    AES encryption Enabled
  frame.setFrameSize(XBEE_868, ENABLED, ENABLED);

  USB.print(F("\nframe size (868, UNICAST_64B, XBee encryp Enabled, AES encryp Enabled):"));
  USB.println(frame.getFrameSize(),DEC);  
  delay(500);
  
  
  
  /////////////////////////////////////////////
  // 3. set frame size for:
  /////////////////////////////////////////////
  //    XBee ZigBee
  //    Broadcast addressing
  //    XBee encryption Enabled
  //    AES encryption Disabled
  frame.setFrameSize(ZIGBEE, BROADCAST, ENABLED, DISABLED);

  USB.print(F("\nframe size (ZigBee, UNICAST_64B, XBee encryp Enabled, AES encryp Disabled):"));
  USB.println(frame.getFrameSize(),DEC);  
  delay(500);
  
  
  
  /////////////////////////////////////////////
  // 4. set frame size for:
  /////////////////////////////////////////////
  //    XBee 900
  //    unicast 64-b addressing (default)
  //    XBee encryption Disabled
  //    AES encryption Enabled
  frame.setFrameSize(XBEE_900, DISABLED, ENABLED);

  USB.print(F("\nframe size (900, UNICAST_64B, XBee encryp Disabled, AES encryp Enabled):"));
  USB.println(frame.getFrameSize(),DEC);  
  delay(500);
  
  
  
  /////////////////////////////////////////////
  // 5. set frame size for:
  /////////////////////////////////////////////
  //    XBee-Digimesh
  //    Broadcast addressing
  //    XBee encryption Enabled
  //    AES encryption Enabled
  frame.setFrameSize(DIGIMESH, BROADCAST, ENABLED, ENABLED);

  USB.print(F("\nframe size (Digimesh, UNICAST_64B, XBee encryp Enabled, AES encryp Enabled):"));
  USB.println(frame.getFrameSize(),DEC);  
  delay(500);
  
  
  
  /////////////////////////////////////////////
  // 6. set frame size via parameter given by the user
  /////////////////////////////////////////////
  frame.setFrameSize(125);

  USB.print(F("\nframe size given by the user (125):"));
  USB.println(frame.getFrameSize(),DEC);  
  delay(500);
   
  
  USB.println(F("---------------------------------------"));
     
  

  delay(5000);
}

