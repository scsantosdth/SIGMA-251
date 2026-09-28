/*  
 *  ------ [ZB_12b] - enable encryption in XBee module  -------- 
 *  
 *  Explanation: This program shows how to configure the encryption
 *  mode in the XBee module with router firmware
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
#include <WaspXBeeZB.h>

// 16-Byte Link key 
char  LINKKEY[] = "WaspmoteLinkKey!";
 
void setup()
{  
  // init USB port
  USB.ON();
  USB.println(F("ZB_12b example"));
  
  // init XBee
  xbeeZB.ON();  
  
  delay(3000);  
  USB.println(F("---------------------------------"));  
  
  
  ////////////////////////////////////////////////////////
  // 1. Enabling security
  ////////////////////////////////////////////////////////
  
  // 1.1. set encryption mode
  xbeeZB.setEncryptionMode(1);
  
  // 1.2. check flag
  if( xbeeZB.error_AT == 0 ) 
  {
    USB.println(F("1. Security enabled"));
  }
  else 
  {
    USB.println(F("1. Error while enabling security"));  
  }
  
  
  ////////////////////////////////////////////////////////
  // 2. Setting pre-configured Link Key
  ////////////////////////////////////////////////////////
  
  // 2.1. Setting pre-configured Link Key
  xbeeZB.setLinkKey(LINKKEY);
 
  // 2.2. check flag
  if( xbeeZB.error_AT == 0 ) 
  {
    USB.println(F("2. Link Key set OK"));
  }
  else 
  {
    USB.println(F("2. Error while setting Key")); 
  }
  
  
  ////////////////////////////////////////////////////////
  // 3. Setting APS encryption
  ////////////////////////////////////////////////////////  
  
  // 3.1. APS encryption is an optional layer of security that 
  // uses the link key to encrypt the data payload.
  // The XBee must be configured with security enabled 
  // (call xbeeZB.encryptionMode(1) to 1) to use APS encryption
  xbeeZB.setAPSencryption(XBEE_ON);
  
  // 3.2. check flag
  if( xbeeZB.error_AT == 0 ) 
  {
    USB.println(F("3. APS Encryption set OK"));
  }
  else 
  {
    USB.println(F("3. Error while setting APS Encryption"));
  }
  

  
  ////////////////////////////////////////////////////////
  // 4. Save values
  ////////////////////////////////////////////////////////  
  
  // 4.1. Keep values
  xbeeZB.writeValues();
 
  // 4.2. check flag
  if( xbeeZB.error_AT == 0 ) 
  {
    USB.println(F("4. Changes stored OK"));
  }
  else 
  {
    USB.println(F("4. Error while storing values"));  
  }
  
  
  USB.println(F("---------------------------------")); 
  delay(3000);
  
}


void loop()
{   
  // check XBee's network parameters
  checkNetworkParams();
    
  USB.println(F("\n---------------------------------")); 
  
  delay(3000);
}




/*******************************************
 *
 *  checkNetworkParams - Check operating
 *  network parameters in the XBee module
 *
 *******************************************/
void checkNetworkParams()
{
  // 1. get operating 64-b PAN ID
  xbeeZB.getOperating64PAN();

  // 2. wait for association indication
  xbeeZB.getAssociationIndication();
 
  while( xbeeZB.associationIndication != 0 )
  { 
    delay(2000);
    
    // get operating 64-b PAN ID
    xbeeZB.getOperating64PAN();

    USB.print(F("operating 64-b PAN ID: "));
    USB.printHex(xbeeZB.operating64PAN[0]);
    USB.printHex(xbeeZB.operating64PAN[1]);
    USB.printHex(xbeeZB.operating64PAN[2]);
    USB.printHex(xbeeZB.operating64PAN[3]);
    USB.printHex(xbeeZB.operating64PAN[4]);
    USB.printHex(xbeeZB.operating64PAN[5]);
    USB.printHex(xbeeZB.operating64PAN[6]);
    USB.printHex(xbeeZB.operating64PAN[7]);
    USB.println();     
    
    xbeeZB.getAssociationIndication();
  }

  USB.println(F("\nJoined a network!"));

  // 3. get network parameters 
  xbeeZB.getOperating16PAN();
  xbeeZB.getOperating64PAN();
  xbeeZB.getChannel();

  USB.print(F("operating 16-b PAN ID: "));
  USB.printHex(xbeeZB.operating16PAN[0]);
  USB.printHex(xbeeZB.operating16PAN[1]);
  USB.println();

  USB.print(F("operating 64-b PAN ID: "));
  USB.printHex(xbeeZB.operating64PAN[0]);
  USB.printHex(xbeeZB.operating64PAN[1]);
  USB.printHex(xbeeZB.operating64PAN[2]);
  USB.printHex(xbeeZB.operating64PAN[3]);
  USB.printHex(xbeeZB.operating64PAN[4]);
  USB.printHex(xbeeZB.operating64PAN[5]);
  USB.printHex(xbeeZB.operating64PAN[6]);
  USB.printHex(xbeeZB.operating64PAN[7]);
  USB.println();

  USB.print(F("channel: "));
  USB.printHex(xbeeZB.channel);
  USB.println();

}

