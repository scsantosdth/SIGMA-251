/*
 *  ------ [SX_01] - Configure registers-------- 
 *
 *  Explanation: This example shows how to configure the 
 *  semtech module registers and read the settings used
 *
 *  Copyright (C) 2014 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Implementation:    Covadonga Albiñana
 */


#include <WaspSX1272.h>

// status variable
int8_t e;


void setup()
{
  // init USB port
  USB.ON();
  USB.println(F("SX_01 example"));
  USB.println(F("SX1272 module configuration in LoRa, complete example"));

  USB.println(F("----------------------------------------"));
  USB.println(F("Setting configuration:")); 
  USB.println(F("----------------------------------------"));

  // init SX1272 module  
  sx1272.ON();

  // Select channel
  e = sx1272.setChannel(CH_06_900);
  USB.print(F("Setting Channel CH_06_900.\t state ")); 
  USB.println(e);    

  // Set packet length
  e = sx1272.setPacketLength(83);
  USB.print(F("Setting Payload Length to '83'.\t state "));
  USB.println(e);

  // Set Header mode: OFF
  e = sx1272.setHeaderOFF();
  USB.print(F("Setting Header OFF.\t\t state "));  
  USB.println(e);

  // Set Mode 
  e = sx1272.setMode(2);
  USB.print(F("Setting Mode '2'.\t\t state "));
  USB.println(e);

  // Select output power (Max, High or Low)
  e = sx1272.setPower('H');
  USB.print(F("Setting Power to 'H'.\t\t state "));  
  USB.println(e);

  // Set CRC mode
  e = sx1272.setCRC_OFF();
  USB.print(F("Setting CRC OFF.\t\t state "));
  USB.println(e); 

  // Set Node Address: from 2 to 255
  e = sx1272.setNodeAddress(9);
  USB.print(F("Setting Node Address to '9'.\t state "));
  USB.println(e);  
  USB.println();
  delay(1000);

}


void loop()
{   
  
  USB.println(F("----------------------------------------"));
  USB.println(F("Reading configuration in module:")); 
  USB.println(F("----------------------------------------"));
  

  //////////////////////////  
  // Get channel
  //////////////////////////    
  e = sx1272.getChannel();   
  if( e == 0 ) 
  {
    USB.print(F("Getting Channel \t--> OK. ")); 
    USB.print(F("Channel is: 0x"));    
    USB.println(sx1272._channel,HEX);      
  }
  else 
  {
    USB.println(F("Getting Channel --> ERROR"));
  } 
  
  
  //////////////////////////  
  // Get packet length
  //////////////////////////  
  e = sx1272.getPayloadLength();
  if( e == 0 ) 
  {
    USB.print(F("Getting Payload Length \t--> OK. ")); 
    USB.print(F("Payload Length is: "));    
    USB.println(sx1272._payloadlength,DEC); 
  }
  else 
  {
    USB.println(F("Getting Payload Length --> ERROR"));
  }    
  

  //////////////////////////  
  // Get Header mode
  //////////////////////////  
  e = sx1272.getHeader();
  if( e == 0 ) 
  {
    USB.print(F("Getting Header \t\t--> OK. ")); 
    USB.print(F("Header (HeaderON = 0; HeaderOFF = 1): "));
    USB.println(sx1272._header,DEC);
  }
  else 
  {
    USB.println(F("Getting Header --> ERROR"));
  } 
    

  //////////////////////////  
  // Get power
  //////////////////////////    
  e = sx1272.getPower();
  if( e == 0 ) 
  {
    USB.print(F("Getting Power \t\t--> OK. ")); 
    USB.print(F("Power is ('M'=0x0F; 'L'=0x00; 'H'=0x07): 0x"));  
    USB.printHex(sx1272._power);  
    USB.println();
  }
  else 
  {
    USB.println(F("Getting Power --> ERROR"));
  } 


  //////////////////////////
  // Get CRC mode
  //////////////////////////    
  e = sx1272.getCRC(); 
  if( e == 0 ) 
  {
    USB.print(F("Getting CRC \t\t--> OK. ")); 
    USB.print(F("CRC (CRC_ON=1; CRC_OFF=0): "));
    USB.println(sx1272._CRC,DEC);        
  }
  else 
  {
    USB.println(F("Getting CRC --> ERROR"));
  }   
  
  
  //////////////////////////  
  // Get Node Address
  ////////////////////////// 
  e = sx1272.getNodeAddress();
  if( e == 0 ) 
  {
    USB.print(F("Getting Node Address \t--> OK. ")); 
    USB.print(F("Node Address is: "));    
    USB.println(sx1272._nodeAddress,DEC);  
  }
  else 
  {
    USB.println(F("Getting Node Address --> ERROR"));
  }     

  
  //////////////////////////  
  // Get Node Address
  ////////////////////////// 
  e = sx1272.getMode();
  if( e == 0 ) 
  {
    USB.print(F("Getting Mode \t\t--> OK. ")); 
    USB.print(F("Bandwidth is (BW_125=0; BW_250=1; BW_500=2): "));    
    USB.println(sx1272._bandwidth,HEX);
    USB.print(F("\t\t\t\tSpreading Factor is: "));    
    USB.println(sx1272._spreadingFactor,DEC);    
    USB.print(F("\t\t\t\tCoding Rate is ( CR_5=1 ; CR_6=2; CR_7=3; CR_8=4;): "));    
    USB.println(sx1272._codingRate,HEX);
  }
  else 
  {
    USB.println(F("Getting Mode --> ERROR"));
  }    

  USB.println(); 

  delay(5000);

}


