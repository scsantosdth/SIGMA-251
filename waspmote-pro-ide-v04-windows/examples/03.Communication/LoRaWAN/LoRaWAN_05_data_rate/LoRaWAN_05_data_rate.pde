/*  
 *  ------ LoRaWAN Code Example -------- 
 *  
 *  Explanation: This example shows how to configure the data rate.
 *  The possibilities are:
 *    0: SF = 12, BW = 125 kHz, BitRate = 250 bps
 *    1: SF = 11, BW = 125 kHz, BitRate = 440 bps
 *    2: SF = 10, BW = 125 kHz, BitRate = 980 bps
 *    3: SF =  9, BW = 125 kHz, BitRate = 1760 bps
 *    4: SF =  8, BW = 125 kHz, BitRate = 3125 bps
 *    5: SF =  7, BW = 125 kHz, BitRate = 5470 bps
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
  USB.println(F("\nData Rate options:"));
  USB.println(F("------------------------------------------------------"));
  USB.println(F("  0: SF = 12, BW = 125 kHz, BitRate =   250 bps"));
  USB.println(F("  1: SF = 11, BW = 125 kHz, BitRate =   440 bps"));
  USB.println(F("  2: SF = 10, BW = 125 kHz, BitRate =   980 bps"));
  USB.println(F("  3: SF =  9, BW = 125 kHz, BitRate =  1760 bps"));
  USB.println(F("  4: SF =  8, BW = 125 kHz, BitRate =  3125 bps"));
  USB.println(F("  5: SF =  7, BW = 125 kHz, BitRate =  5470 bps"));
  USB.println(F("------------------------------------------------------\n"));

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
  // 2. Set Data Rate
  //////////////////////////////////////////////

  error = LoRaWAN.setDataRate(5);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("2. Data rate set OK"));     
  }
  else 
  {
    USB.print(F("2. Data rate set error = ")); 
    USB.println(error, DEC);
  }


  //////////////////////////////////////////////
  // 3. Get Data Rate
  //////////////////////////////////////////////

  error = LoRaWAN.getDataRate();

  // Check status
  if( error == 0 ) 
  {
    USB.print(F("3. Data rate get OK. "));    
    USB.print(F("Data rate index:"));
    USB.println(LoRaWAN._dataRate, DEC);
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




