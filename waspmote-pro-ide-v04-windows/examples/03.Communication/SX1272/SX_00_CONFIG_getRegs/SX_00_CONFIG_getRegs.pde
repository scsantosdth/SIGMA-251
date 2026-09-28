/*
 *  ------ [SX_00] - Configure registers -------- 
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
  USB.println(F("SX_00 example"));
  USB.println(F("SX1272 module configuration in LoRa, complete example"));

  USB.println(F("----------------------------------------"));
  USB.println(F("Setting configuration:")); 
  USB.println(F("----------------------------------------"));

  // init SX1272 module  
  sx1272.ON();

  // Choose channel
  e = sx1272.setChannel(CH_06_900);
  USB.print(F("Setting Channel CH_06_900.\t state ")); 
  USB.println(e);    

  // Set Packet length
  e = sx1272.setPacketLength(83);
  USB.print(F("Setting Payload Length to '83'.\t state "));
  USB.println(e);

  // Disable Header
  e = sx1272.setHeaderOFF();
  USB.print(F("Setting Header OFF.\t\t state "));    
  USB.println(e);

  // Select LoRa mode: from 1 to 10
  e = sx1272.setMode(1);  
  USB.print(F("Setting Mode '1'.\t\t state "));
  USB.println(e); 

  // Set Power level (choose between 'H', 'L' and 'M') 
  e = sx1272.setPower('H');
  USB.print(F("Setting Power to 'H'.\t\t state "));   
  USB.println(e);

  // Disable CRC
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
  // Get registers
  e = sx1272.getRegs();
  USB.print(F("Getting Registers: state ")); 
  USB.println(e);

  // Check status
  if( e == 0 ) 
  {    
    // 1. Power
    USB.print(F("--> Power is ('M'=0x0F; 'L'=0x00; 'H'=0x07): 0x"));  
    USB.printHex(sx1272._power);  
    USB.println();

    // 2. Channel
    USB.print(F("--> Channel is: 0x"));    
    USB.print(sx1272._channel, HEX);  
    USB.println();

    // 3. CRC
    USB.print(F("--> CRC (CRC_ON=1; CRC_OFF=0): "));
    USB.println(sx1272._CRC,DEC); 

    // 4. Header
    USB.print(F("--> Header (HeaderON=0; HeaderOFF=1): "));
    USB.println(sx1272._header,DEC);

    // 5. Preamble length
    USB.print(F("--> Preamble length: "));
    USB.println(sx1272._preamblelength,DEC);

    // 6. Payload length
    USB.print(F("--> Payload Length is: "));    
    USB.println(sx1272._payloadlength,DEC); 

    // 7. Node Address
    USB.print(F("--> Node Address is: "));    
    USB.println(sx1272._nodeAddress,DEC);  
        
    // 8. Max current
    USB.print(F("--> Max current is (mA): "));    
    USB.println(sx1272._maxCurrent,DEC);  
        
    // 9. Temperature
    USB.print(F("--> Temperature is: "));
    USB.print(sx1272._temp);    

  }
  else 
  {
    USB.println(F("ERROR getting registers"));
  } 

  USB.println();
  USB.println(F("**********************************"));
  delay(5000);

}




