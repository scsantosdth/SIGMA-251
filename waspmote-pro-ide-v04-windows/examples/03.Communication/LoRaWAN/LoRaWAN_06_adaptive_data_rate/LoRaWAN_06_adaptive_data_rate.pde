/*  
 *  ------ LoRaWAN Code Example -------- 
 *  
 *  Explanation: This example shows how to enable / disable the 
 *  adaptive data rate.
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
 *  Implementation:    Luismi Marti  
 */

#include <WaspLoRaWAN.h>

//////////////////////////////////////////////
uint8_t socket = SOCKET0;
//////////////////////////////////////////////

// variable
uint8_t error;


void setup() 
{
  USB.ON();
  USB.println(F("LoRaWAN example - Data Rate configuration"));

  //////////////////////////////////////////////
  // 1. switch on
  //////////////////////////////////////////////

  error = LoRaWAN.ON(socket);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("1. Switch ON OK"));     
  }
  else 
  {
    USB.print(F("1. Switch ON error = ")); 
    USB.println(error, DEC);
  }


  //////////////////////////////////////////////
  // 2. Enable Adaptive Data Rate (ADR)
  //////////////////////////////////////////////

  error = LoRaWAN.setADR("on");

  // Check status
  if( error == 0 ) 
  {
    USB.print(F("2. Adaptive Data Rate enabled OK. "));    
    USB.print(F("ADR:"));
    USB.println(LoRaWAN._adr, DEC);   
  }
  else 
  {
    USB.print(F("2. Enable data rate error = ")); 
    USB.println(error, DEC);
  }


  //////////////////////////////////////////////
  // 3. Disable Adaptive Data Rate (ADR)
  //////////////////////////////////////////////

  error = LoRaWAN.setADR("off");

  // Check status
  if( error == 0 ) 
  {
    USB.print(F("3. Adaptive Data Rate disabled OK. "));    
    USB.print(F("ADR:"));
    USB.println(LoRaWAN._adr, DEC);
  }
  else 
  {
    USB.print(F("3. Data rate set error = ")); 
    USB.println(error, DEC);
  }


  //////////////////////////////////////////////
  // 4. Save configuration
  //////////////////////////////////////////////

  error = LoRaWAN.saveConfig();

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("4. Save configuration OK"));     
  }
  else 
  {
    USB.print(F("4. Save configuration error = ")); 
    USB.println(error, DEC);
  }

}


void loop() 
{

}




