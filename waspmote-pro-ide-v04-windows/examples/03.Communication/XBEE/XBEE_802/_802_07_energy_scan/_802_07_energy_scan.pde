/*  
 *  ------ [802_07] - energy scan  -------- 
 *  
 *  Explanation: This program shows how to scan all XBee channels
 *  in order to show the energy level of each channel
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
 
 #include <WaspXBee802.h>


void setup()
{ 
  // Init USB port
  USB.ON();
  USB.println(F("802_07 example"));

  // init XBee
  xbee802.ON();
}

void loop()
{ 

  // set the list of channels to scan as a Bitmap. 
  // 0xFFFF scan all possible channels
  xbee802.setScanningChannels(0xFF,0xFF); 
  
  // get the maximal energy on each scanned channel
  // The actual scan time on each channel is measured as 
  //   Time = [3000 + (2 ^ input) x 16 x 100] ms
  // Range: from 0 to 6
  xbee802.setDurationEnergyChannels(6);

  // print information
  printEnergyChannel();

}  



/*
*  printEnergyChannel 
*
*  This function prints all stored energy 
*  for each channel in units of dBm
*/
void printEnergyChannel()
{
  USB.print(F("\n\n----------------------"));
  USB.print(F("\nEnergy Scan (dBm)"));
  USB.print(F("\n----------------------"));
  
  USB.print(F("\nchannel 0x0C: "));
  USB.print(xbee802.energyChannel[0]*(-1),DEC);
  
  USB.print(F("\nchannel 0x0D: "));
  USB.print(xbee802.energyChannel[1]*(-1),DEC);
  
  USB.print(F("\nchannel 0x0E: "));
  USB.print(xbee802.energyChannel[2]*(-1),DEC);
  
  USB.print(F("\nchannel 0x0F: "));
  USB.print(xbee802.energyChannel[3]*(-1),DEC);
  
  USB.print(F("\nchannel 0x10: "));
  USB.print(xbee802.energyChannel[4]*(-1),DEC);
  
  USB.print(F("\nchannel 0x11: "));
  USB.print(xbee802.energyChannel[5]*(-1),DEC);
  
  USB.print(F("\nchannel 0x12: "));
  USB.print(xbee802.energyChannel[6]*(-1),DEC);
  
  USB.print(F("\nchannel 0x13: "));
  USB.print(xbee802.energyChannel[7]*(-1),DEC);
  
  USB.print(F("\nchannel 0x14: "));
  USB.print(xbee802.energyChannel[8]*(-1),DEC);
  
  USB.print(F("\nchannel 0x15: "));
  USB.print(xbee802.energyChannel[9]*(-1),DEC);
  
  USB.print(F("\nchannel 0x16: "));
  USB.print(xbee802.energyChannel[10]*(-1),DEC);
  
  USB.print(F("\nchannel 0x17: "));
  USB.print(xbee802.energyChannel[11]*(-1),DEC);
  
}



