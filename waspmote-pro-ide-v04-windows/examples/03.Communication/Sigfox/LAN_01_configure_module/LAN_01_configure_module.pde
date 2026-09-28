/*  
 *  ------ TD LAN Code Example -------- 
 *  
 *  Explanation: This example shows how to configure the module for 
 *  LAN operation. This example shows how to set/get:
 *    - LAN address
 *    - LAN mask
 *    - LAN frequency channel
 *    - LAN power level
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
 *  Version:           0.1
 *  Design:            David Gascon 
 *  Implementation:    Yuri Carmona  
 */
     
#include <WaspSigfox.h>

//////////////////////////////////////////////
uint8_t socket = SOCKET0;
//////////////////////////////////////////////

// ADDRESS: Define the LAN network address. Range: From 0x000000 to 0xFFFFFF. Default: 0x000000
// MASK: Define the Mask address. Range: From 0x000000 to 0xFFFFFF. Default: 0xFFFFFF
// FREQUENCY: Define the Frequency. Range: From 868000000 to 869700000. Default: 869700000
// POWER: Define the RF power level in dBm. Range: From -35 to 14. Default: 14
///////////////////////////////////////////////////////////////////////////////////////////
uint32_t address   = 0x000001;
uint32_t mask      = 0xFFFFFF;
uint32_t frequency = 869700000;
uint8_t  power     = 14;
///////////////////////////////////////////////////////////////////////////////////////////

uint8_t error;


void setup() 
{
  USB.ON();  
  
  //////////////////////////////////////////////
  // switch on
  //////////////////////////////////////////////
  error = Sigfox.ON(socket);
  
  // Check status
  if( error == 0 ) 
  {
    USB.println(F("Switch ON OK"));     
  }
  else 
  {
    USB.println(F("Switch ON ERROR")); 
  } 
  
  USB.println();
}



void loop() 
{
  //////////////////////////////////////////////
  // 1. Set/Get LAN address
  //////////////////////////////////////////////
  
  // 1.1. Set LAN address
  error = Sigfox.setAddressLAN(address);
    
  // Check status
  if( error == 0 ) 
  {
    USB.println(F("1. Set LAN Address OK"));   
  }
  else 
  {
    USB.println(F("1. Set LAN Address ERROR")); 
  } 
  
  // 1.2. Get LAN address
  error = Sigfox.getAddressLAN();
    
  // Check status
  if( error == 0 ) 
  {
    USB.print(F("2. Get LAN Address OK. LAN address: 0x"));
    USB.println(Sigfox._address, HEX);
  }
  else 
  {
    USB.println(F("2. Get LAN Address ERROR")); 
  }
  
  
  
  //////////////////////////////////////////////
  // 2. Set/Get Mask address
  //////////////////////////////////////////////
 
  // 2.1. Set mask
  error = Sigfox.setMask(mask);
    
  // Check status
  if( error == 0 ) 
  {
    USB.println(F("3. Set Mask OK"));   
  }
  else 
  {
    USB.println(F("3. Set Mask ERROR")); 
  } 
  
  // 2.2. Get mask
  error = Sigfox.getMask();
    
  // Check status
  if( error == 0 ) 
  {
    USB.print(F("4. Get LAN Address OK. Module ID: 0x"));
    USB.println(Sigfox._mask, HEX);
  }
  else 
  {
    USB.println(F("4. Get LAN Address ERROR")); 
  } 
  
      
  
  //////////////////////////////////////////////
  // 3. Set/Get Frequency band
  //////////////////////////////////////////////
 
  // 3.1. Set frequency
  error = Sigfox.setFrequency(frequency);
    
  // Check status
  if( error == 0 ) 
  {
    USB.println(F("5. Set frequency OK"));   
  }
  else 
  {
    USB.println(F("5. Set frequency ERROR")); 
  } 
  
  // 3.2. Get frequency
  error = Sigfox.getFrequency();
    
  // Check status
  if( error == 0 ) 
  {
    USB.print(F("6. Get frequency OK. Frequency: "));
    USB.println(Sigfox._frequency, DEC);
  }
  else 
  {
    USB.println(F("6. Get frequency ERROR")); 
  } 
   
      
  
  //////////////////////////////////////////////
  // 4. Set/Get Power level
  //////////////////////////////////////////////
 
  // 4.1. Set power level
  error = Sigfox.setPowerLAN(power);
    
  // Check status
  if( error == 0 ) 
  {
    USB.println(F("7. Set power level OK"));   
  }
  else 
  {
    USB.println(F("7. Set power level ERROR")); 
  } 
  
  // 4.2. Get power level
  error = Sigfox.getPowerLAN();
    
  // Check status
  if( error == 0 ) 
  {
    USB.print(F("8. Get power level OK. Power Level (dBm): "));
    USB.println(Sigfox._powerLAN, DEC);
  }
  else 
  {
    USB.println(F("8. Get power level ERROR")); 
  } 
 
 
  USB.println(F("-------------------------------")); 
  
  delay(5000);
}
