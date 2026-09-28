/*  
 *  ------   [ZB_10] - scan network     -------- 
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
 *  Version:           0.2
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */

#include <WaspXBeeZB.h>


void setup()
{     
  // init USB port
  USB.ON();
  USB.println(F("ZB_10 example"));
  
  //////////////////////////
  // 1. init XBee
  //////////////////////////
  xbeeZB.ON();  
  
  delay(3000);
  
  //////////////////////////
  // 2. check XBee's network parameters
  //////////////////////////
  checkNetworkParams();
  
}

void loop()
{ 
  ////////////////////////////////
  // 3. scan network
  ////////////////////////////////
  xbeeZB.scanNetwork(); 
  
  ////////////////////////////////
  // 4. print info
  ////////////////////////////////  

  USB.print(F("\n\ntotalScannedBrothers:"));
  USB.println(xbeeZB.totalScannedBrothers,DEC); 

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

  for(int i=0; i<xbeeZB.totalScannedBrothers; i++)
  {  
    USB.print(F("MAC:"));
    USB.printHex(xbeeZB.scannedBrothers[i].SH[0]);	
    USB.printHex(xbeeZB.scannedBrothers[i].SH[1]);	
    USB.printHex(xbeeZB.scannedBrothers[i].SH[2]);	
    USB.printHex(xbeeZB.scannedBrothers[i].SH[3]);
    USB.printHex(xbeeZB.scannedBrothers[i].SL[0]);	
    USB.printHex(xbeeZB.scannedBrothers[i].SL[1]);	
    USB.printHex(xbeeZB.scannedBrothers[i].SL[2]);	
    USB.printHex(xbeeZB.scannedBrothers[i].SL[3]);

    USB.print(F("\nNI:"));
    USB.print(xbeeZB.scannedBrothers[i].NI);		

    USB.print(F("\nDevice Type:"));
    switch(xbeeZB.scannedBrothers[i].DT)
    {
    case 0: 
      USB.print(F("Coordinator"));
      break;
    case 1: 
      USB.print(F("Router"));
      break;
    case 2: 
      USB.print(F("End Device"));
      break;
    }

    USB.print(F("\nPMY:"));
    USB.printHex(xbeeZB.scannedBrothers[i].PMY[0]);	
    USB.printHex(xbeeZB.scannedBrothers[i].PMY[1]);

    USB.print(F("\nPID:"));
    USB.printHex(xbeeZB.scannedBrothers[i].PID[0]);	
    USB.printHex(xbeeZB.scannedBrothers[i].PID[1]);

    USB.print(F("\nMID:"));
    USB.printHex(xbeeZB.scannedBrothers[i].MID[0]);	
    USB.printHex(xbeeZB.scannedBrothers[i].MID[1]);
    
    USB.println(F("\n----------------------------"));

  }
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





