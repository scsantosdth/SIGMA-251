/*  
 *  ------ LoRaWAN Code Example -------- 
 *  
 *  Explanation: This example shows how to configure the channels settings.
 *  There are 16 channels. The first three of them are always preconfigured 
 *  and cannot be changed: 868.1 MHz, 868.3 MHz and 868.5 MHz. Besides other
 *  parameters can be changed in all channels: Duty Cycle, Data rate range
 *  and channel status
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
  USB.println(F("LoRaWAN example - Channels configuration"));

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
  // 2. Set frequency for specific channel
  //////////////////////////////////////////////

  error = LoRaWAN.setChannelFreq(3, 865000000);

  // Check status
  if( error == 0 ) 
  {
    USB.print(F("2. Frequency set OK. "));    
    USB.print(F("Frequency:"));
    USB.println(LoRaWAN._freq[3]);
  }
  else 
  {
    USB.print(F("2. Enable data rate error = ")); 
    USB.println(error, DEC);
  }


  //////////////////////////////////////////////
  // 3. Set Duty Cycle for specific channel
  //////////////////////////////////////////////

  error = LoRaWAN.setChannelDutyCycle(3, 999);

  // Check status
  if( error == 0 ) 
  {
    USB.print(F("3. Adaptive Data Rate disabled OK. "));    
    USB.print(F("Duty Cycle:"));
    USB.println(LoRaWAN._dCycle[3], DEC);
  }
  else 
  {
    USB.print(F("3. Data rate set error = ")); 
    USB.println(error, DEC);
  }


  //////////////////////////////////////////////
  // 4. Set Data rate range for specific channel
  //////////////////////////////////////////////

  error = LoRaWAN.setChannelDRRange(3, 0, 2);

  // Check status
  if( error == 0 ) 
  {
    USB.print(F("4. Data Rate range set OK. "));    
    USB.print(F("Data Rate min:"));
    USB.print(LoRaWAN._drrMin[3], DEC); 
    USB.print(F(". Data Rate max:"));
    USB.println(LoRaWAN._drrMax[3], DEC);
  }
  else 
  {
    USB.print(F("4. Data rate set error = ")); 
    USB.println(error, DEC);
  }


  //////////////////////////////////////////////
  // 5. Set Data rate range for specific channel
  //////////////////////////////////////////////

  error = LoRaWAN.setChannelStatus(3, "on");

  // Check status
  if( error == 0 ) 
  {
    USB.print(F("5. Channel status set OK: "));
    USB.println(LoRaWAN._status[3], DEC);
  }
  else 
  {
    USB.print(F("5. Data rate set error = ")); 
    USB.println(error, DEC);
  }


  //////////////////////////////////////////////
  // 6. Save configuration
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


  ///////////////////////////////////////////////////////////
  // show configuration for all channels available
  ///////////////////////////////////////////////////////////

  USB.println(F("\n----------------------------"));

  for( int i=0; i<16; i++)
  {
    LoRaWAN.getChannelFreq(i);
    LoRaWAN.getChannelDutyCycle(i);
    LoRaWAN.getChannelDRRange(i);
    LoRaWAN.getChannelStatus(i);

    USB.print(F("Channel: "));
    USB.println(i);
    USB.print(F("  Freq: "));
    USB.println(LoRaWAN._freq[i]);
    USB.print(F("  Duty cycle: "));
    USB.println(LoRaWAN._dCycle[i]);
    USB.print(F("  DR min: "));
    USB.println(LoRaWAN._drrMin[i], DEC);
    USB.print(F("  DR max: "));
    USB.println(LoRaWAN._drrMax[i], DEC);
    USB.print(F("  Status: "));
    USB.println(LoRaWAN._status[i], DEC);
    USB.println(F("----------------------------"));
  } 
  

}


void loop() 
{


}





