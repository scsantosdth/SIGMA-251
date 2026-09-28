/*  
 *  ------ LoRaWAN Code Example -------- 
 *  
 *  Explanation: This example shows how to configure the power level
 *  LoRaWAN interface:
 *       868 MHz     433 MHz
 *    0:  N/A        10 dBm
 *    1:  14 dBm      7 dBm
 *    2:  11 dBm      4 dBm 
 *    3:   8 dBm      1 dBm
 *    4:   5 dBm     -2 dBm 
 *    5:   2 dBm     -5 dBm
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
  USB.println(F("LoRaWAN example - Power configuration"));

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
  // 2. Set Power level
  //////////////////////////////////////////////

  error = LoRaWAN.setPower(1);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("2. Power level set OK"));     
  }
  else 
  {
    USB.print(F("2. Power level set error = ")); 
    USB.println(error, DEC);
  }


  //////////////////////////////////////////////
  // 3. Get Device EUI
  //////////////////////////////////////////////

  error = LoRaWAN.getPower();

  // Check status
  if( error == 0 ) 
  {
    USB.print(F("3. Power level get OK. "));    
    USB.print(F("Power index:"));
    USB.println(LoRaWAN._powerIndex, DEC);
  }
  else 
  {
    USB.print(F("3. Power level set error = ")); 
    USB.println(error, DEC);
  }


  USB.println(F("------------------------------------"));
  USB.println(F("Keep in mind the power setting cannot"));
  USB.println(F("be saved in the module's memory. Every"));
  USB.println(F("time the module is powered on, the user"));
  USB.println(F("must set the parameter again"));
  USB.println(F("------------------------------------\n"));

}


void loop() 
{

}



