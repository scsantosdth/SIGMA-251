/*  
 *  ------   [802_13] - scan network     -------- 
 *  
 *  Explanation: This program shows how to scan the XBee's network
 *  in order to find other XBee modules. This example prints all
 *  available data within the API structures
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
 *  Version:           0.4
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */

#include <WaspXBee802.h>


void setup()
{ 
  // init USB port
  USB.ON();
  USB.println(F("802_13 example"));

  // init XBee
  xbee802.ON();
}

void loop()
{ 
  ///////////////////////////////
  // 1. scan network
  ///////////////////////////////
  xbee802.scanNetwork(); 

  ///////////////////////////////
  // 2. Print information
  /////////////////////////////// 
  
  USB.print(F("\n\ntotalScannedBrothers:"));
  USB.println(xbee802.totalScannedBrothers,DEC); 
  
  // print all scanned nodes information
  printScanInfo();
  
}  


/*
 *  printScanInfo
 *
 *  This function prints all info related to the scan 
 *  process given by the XBee module
 */
void printScanInfo()
{  
  USB.println(F("----------------------------"));

  for(int i=0; i<xbee802.totalScannedBrothers; i++)
  {  
    USB.print(F("MY:"));
    USB.printHex(xbee802.scannedBrothers[i].MY[0]);	
    USB.printHex(xbee802.scannedBrothers[i].MY[1]);

    USB.print(F("\nMAC:"));
    USB.printHex(xbee802.scannedBrothers[i].SH[0]);	
    USB.printHex(xbee802.scannedBrothers[i].SH[1]);	
    USB.printHex(xbee802.scannedBrothers[i].SH[2]);	
    USB.printHex(xbee802.scannedBrothers[i].SH[3]);
    USB.printHex(xbee802.scannedBrothers[i].SL[0]);	
    USB.printHex(xbee802.scannedBrothers[i].SL[1]);	
    USB.printHex(xbee802.scannedBrothers[i].SL[2]);	
    USB.printHex(xbee802.scannedBrothers[i].SL[3]);

    USB.print(F("\nNI:"));
    USB.print(xbee802.scannedBrothers[i].NI);		

    USB.print(F("\nRSSI(dBm):"));
    USB.print(xbee802.scannedBrothers[i].RSSI*(-1),DEC);
    USB.println(F("\n----------------------------"));
  }


}





