/*
 *  ------Waspmote starting program------
 *
 *  Explanation: Send basic parameters through the corresponding 
 *  XBee module.
 *  For other communication modules please use on line code generator.
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
 *  Version:                0.6
 *  Design:                 David Gascón
 *  Implementation:         Yuri Carmona, Javier Siscart
 */

// Include libraries
#include <WaspXBee802.h>
#include <WaspXBeeZB.h>
#include <WaspXBeeDM.h>
#include <WaspFrame.h>
#include <WaspSX1272.h>


// Define the Waspmote default ID
char node_id[] = "node_default_id";

// Define the authentication key
char key_access[] = "LIBELIUM";

// Declare global variables
packetXBee* packet;
char macHigh[10];
char macLow[11];
char filename[]="TestSD.txt";
uint8_t out0;
uint8_t out1;

// Broadcast address
uint8_t destination[8]={ 
  0x00,0x00,0x00,0x00,0x00,0x00,0xFF,0xFF};

// PAN ID to set in order to search a new coordinator, in case of ZigBee protocol
uint8_t  PANID[8]={ 
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};

//ATBD7: 7E 00 05 08 01 42 44 07 69
uint8_t ATBD7[9] = {
  0x7E, 0x00, 0x05, 0x08, 0x01, 0x42, 0x44, 0x07, 0x69};

//ATAP2: 7E 00 05 08 01 41 50 02 63
uint8_t ATAP2[9] = {
  0x7E, 0x00, 0x05, 0x08, 0x01, 0x41, 0x50, 0x02, 0x63};

//ATWR: 7E 00 04 08 01 57 52 4D
uint8_t ATWR[8] = {
  0x7E, 0x00, 0x04, 0x08, 0x01, 0x57, 0x52, 0x4D};

// Declare the XBEE_type
// 0 - 802.15.4 
// 1 - 900 MHz - 868 MHz
// 2 - DigiMesh
// 3 - XBee ZB
// 4 - No XBee
// 5 - 900 MHz Intl
int XBEE_type = 0;

// Declare the ZigBee_type, when needed
// 0 - Coordinator API
// 1 - Router API
// 2 - other
int ZIGBEE_type = 0;

// Declare the LoRa_type
boolean LoRa_type = false;


void setup()
{

  ///////////////////////////////////////
  // Boards ON       ////////////////////
  ///////////////////////////////////////
  PWR.setSensorPower(SENS_3V3, SENS_ON); 
  
  /////////////////////////////////
  // 1. Test SD
  /////////////////////////////////    
  SD.ON();
  if(digitalRead(SD_PRESENT))
  {
    SD.del(filename);
    SD.create(filename);
    if(SD.writeSD(filename,"Test SD",0))
    {
      USB.println(F("SD OK"));
    }
    else
    {
      USB.println(F("Error SD"));
    }
  }
  else
  {
    USB.println(F("No SD card detected"));
  }
  SD.del(filename);


  /////////////////////////////////
  // 2. Store key access in EEPROM
  /////////////////////////////////
  Utils.setAuthKey(key_access);

  /////////////////////////////////
  // 3. Set up RTC and ACC
  /////////////////////////////////
  delay(500);
  RTC.ON();
  ACC.ON();

  /////////////////////////////////
  // 4. Set Waspmote setting for XBee module for first time.
  // (baudrate at 115200  and API mode enabled)
  ///////////////////////////////// 
  // Note: Only valid for SOCKET 0
  xbee802.ON();
  Utils.setMuxSocket0();
  delay(500);
  beginSerial(9600, 0);
  printString("+++", 0);
  delay(2000);
  printString("ATBD7,AP2,WR,CN\r\n", 0);
  delay(200);

  // 4.1 In case of Zigbee modules:
  for (uint8_t i = 0; i < 9; i++)
  {
    printByte(ATBD7[i], 0);	
  }
  delay(150);  
  closeSerial(0);
  delay(200);
  beginSerial(115200, 0);
  for (uint8_t i = 0; i < 9; i++)
  {
    printByte(ATAP2[i], 0);	
  }
  delay(150);  
  for (uint8_t i = 0; i < 8; i++)
  {
    printByte(ATWR[i], 0);	
  }
  delay(150);  
  closeSerial(0); 


  /////////////////////////////////
  // 5. LEDs management 
  /////////////////////////////////  
  Utils.setLED(LED0, LED_OFF);
  Utils.setLED(LED1, LED_OFF);
  for (int i = 0 ; i < 4 ; i++)
  {
    Utils.blinkLEDs(100);
  }

  /////////////////////////////////
  // 6. Get the XBee MAC address
  /////////////////////////////////  
  xbee802.OFF();
  delay(1000);  
  xbee802.ON();
  delay(1000);  
  xbee802.flush();

  // Get the XBee MAC address
  int counter = 0;
  while((xbee802.getOwnMac() != 0) && (counter < 12))
  {   
    xbee802.getOwnMac();
    counter++;
  }

  // convert mac address from array to string
  Utils.hex2str(xbee802.sourceMacHigh, macHigh, 4);
  Utils.hex2str(xbee802.sourceMacLow,  macLow,  4);  


  /////////////////////////////////
  // 7. Get the XBee firmware version
  /////////////////////////////////   
  counter = 0; 
  while((xbee802.getSoftVersion() != 0) && (counter < 12))
  {
    xbee802.getSoftVersion();
    counter++;
  } 
    
  // Set the XBee firmware type
  if( (xbee802.softVersion[0] < 0x20) && (xbee802.softVersion[1] > 0x80) )
  {
    XBEE_type = 0; // 802.15.4
  }
  else if( (xbee802.softVersion[0] < 0x20) && (xbee802.softVersion[0] > 0x00) )
  {
    XBEE_type = 1; // 868Mhz - 900Mhz
  }
  /*else if(  (xbee802.softVersion[3] > 0x60) && (xbee802.softVersion[3] < 0x70))
  {
    XBEE_type = 5; // 868Mhz - 900Mhz
  }*/
  else if( xbee802.softVersion[0] >= 0x80 )
  {
    XBEE_type = 2; // DM
  }
  else if( (xbee802.softVersion[0] >= 0x20) && (xbee802.softVersion[0] < 0x80) )
  {
    XBEE_type = 3; //ZB

    switch (xbee802.softVersion[0])
    {
    case 0x21:
      ZIGBEE_type = 0; // coordinator API 
      break;
    case 0x23:
      ZIGBEE_type = 1; // router API 
      break;
    default:
      ZIGBEE_type = 2; // other 
      break;
    }

  }
  else if (xbee802.softVersion[0] == 0x00 && xbee802.softVersion[1] >= 0x02)
  {
    XBEE_type = 4;
  }
  else
  {
    // no XBee, maybe LoRa module
    XBEE_type = 5;
    xbee802.OFF();

    // checking if it is a LoRa module
    sx1272.ON();  
    if( sx1272.getPower() == 0 )
    {
      out0 = sx1272.setLORA();
      out1 = sx1272.setMode(1);
      if( out0 == 0 )
      {
        LoRa_type = true;
      }
    }  
  }


  /////////////////////////////////
  // 8. Print module information
  /////////////////////////////////     
  USB.println(F("\nStarting program by default"));

  if( LoRa_type == false )
  {
    if( XBEE_type < 4 )
    {
      USB.println(F("XBee module is plugged on socket 0:"));
      USB.print(F("   MAC address:\t\t"));
      USB.print(macHigh);
      USB.println(macLow);
      USB.print(F("   Firmware version:\t"));
      USB.print(xbee802.softVersion[0],HEX);
      USB.println(xbee802.softVersion[1],HEX);
    }

    if ( XBEE_type == 4 )
    {
      USB.println(F("XBee module is plugged on socket 0:"));
      USB.print(F("   MAC address:\t\t"));
      USB.print(macHigh);
      USB.println(macLow);
      USB.print(F("   Firmware version:\t"));
      USB.printHex(xbee802.softVersion[0]);
      USB.printHex(xbee802.softVersion[1]);
      USB.printHex(xbee802.softVersion[2]);
      USB.printHex(xbee802.softVersion[3]);
      USB.println();     
    }


    USB.print(F("   XBee type: "));
    switch(XBEE_type)
    {
    case 0:  
      USB.print(F("802.15.4"));
      break;
    case 1:  
      USB.print(F("900/868"));
      break;
    case 2:  
      USB.print(F("DigiMesh"));
      break;
    case 3:  
      USB.print(F("ZigBee - "));
      switch(ZIGBEE_type)
      {
      case 0:  
        USB.print(F("Coordinator ZigBee plugged on Waspmote. Coordinators are meant for Gateway/Meshlium. Plug a Router/ED ZigBee in Waspmote instead."));
        break;
      case 1:  
        USB.print(F("Router"));
        break;
      case 2:  
        USB.print(F("Other"));
        break;
      }
      break;
    case 4:  
      USB.print(F("900 International"));
      break;
    case 5:  
      USB.print(F("No XBee plugged on SOCKET 0"));
      break;
    }
  }
  else
  {    
    // LoRa_type is TRUE
    USB.println(F("SX1272 module is plugged on socket 0:"));
    if( out1 == 0 )
    {
      USB.println(F("   Configuration:"));
      USB.println(F("     Mode: 1"));
      out0 = sx1272.setChannel(CH_12_868);
      if( out0 == 0 )
      {
        USB.println(F("     Channel: 12_868"));
      }      
      out0 = sx1272.setHeaderON();
      if( out0 == 0 )
      {
        USB.println(F("     Header: ON"));
      }    
      out0 = sx1272.setCRC_ON();
      if( out0 == 0 )
      {
        USB.println(F("     CRC: ON"));
      }  
      out0 = sx1272.setPower('H');
      if( out0 == 0 )
      {
        USB.println(F("     Power: 'H'"));
      }  
      out1 = sx1272.setNodeAddress(3);
      if( out1 == 0 )
      {
        USB.println(F("     Node Address: 3"));
      }
    }
  }

  USB.println();
  USB.println(F("==============================="));


  // 8.1 case ZB router, Start association process
  if( LoRa_type == false )
  {
    if ((XBEE_type == 3) && (ZIGBEE_type > 0 )) 
    { 

      USB.println(F("starting ZigBee association process:"));
      USB.println(F("note: this process disassociates the module from previous ZigBee network"));
      // turn XBee on 
      xbeeZB.ON();
      delay(1000);

      /////////////////////////////////////
      // 8.2 Dissociation process
      /////////////////////////////////////

      // 8.2.1. set PANID: 0x0000000000000000 
      xbeeZB.setPAN(PANID);

      // 8.2.2. check AT command flag
      if( xbeeZB.error_AT == 0 ) 
      {
        USB.println(F("   PAN ID set to zero"));
      }
      else 
      {
        USB.println(F("Error while setting PAN ID")); 
      }

      // 8.2.3. set all possible channels to scan 
      // channels from 0x0B to 0x18 (0x19 and 0x1A are excluded)
      /* Range:[0x0 to 0x3FFF]
       * Channels are specified as a bitmap where depending on 
       * the bit a channel is selected --> Bit (Channel): 
       *  0 (0x0B)  4 (0x0F)  8 (0x13)   12 (0x17)
       *  1 (0x0C)  5 (0x10)  9 (0x14)   13 (0x18)
       *  2 (0x0D)  6 (0x11)  10 (0x15)  
       *  3 (0x0E)  7 (0x12)	 11 (0x16)    */
      xbeeZB.setScanningChannels(0x3F, 0xFF);

      // 8.2.4. check AT command flag  
      if( xbeeZB.error_AT == 0 )
      {
        USB.println(F("   scanning channel range set OK"));
      }
      else 
      {
        USB.println(F("Error while setting scanning channel range")); 
      }

      // 8.2.5. set channel verification JV=1 in order to make the 
      // XBee module to scan new coordinator
      xbeeZB.setChannelVerification(1);

      // 8.2.6. check AT command flag    
      if( xbeeZB.error_AT == 0 )
      {
        USB.println(F("   coordinator searching process enabled (channel verification = JV = 1)"));
      }
      else 
      {
        USB.println(F("Error while enabling coordinator searching process")); 
      }

      // 8.2.7. write values to XBee memory
      xbeeZB.writeValues();

      // 8.2.8 reboot XBee module
      xbeeZB.OFF();
      delay(3000); 
      xbeeZB.ON();

      delay(3000);

      /////////////////////////////////////
      // 8.3. Wait for Association 
      /////////////////////////////////////

      // 8.3.1. wait for association indication
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

        xbeeZB.getAssociationIndication();

        if( xbeeZB.associationIndication != 0 )
        {
          USB.print(F("; Coordinator not found. Please turn on the Coordinator (Gateway / Meshlium)."));
        }

        USB.println();
      }


      USB.println(F("\n\nWaspmote ZigBee joined a Coordinator:"));

      // 8.3.2. When XBee is associated print all network 
      // parameters unset channel verification JV=0
      xbeeZB.setChannelVerification(0);
      xbeeZB.writeValues();

      // 8.3.3. get network parameters 
      xbeeZB.getOperating16PAN();
      xbeeZB.getOperating64PAN();
      xbeeZB.getChannel();

      USB.print(F("   operating 16-b PAN ID: "));
      USB.printHex(xbeeZB.operating16PAN[0]);
      USB.printHex(xbeeZB.operating16PAN[1]);
      USB.println();

      USB.print(F("   operating 64-b PAN ID: "));
      USB.printHex(xbeeZB.operating64PAN[0]);
      USB.printHex(xbeeZB.operating64PAN[1]);
      USB.printHex(xbeeZB.operating64PAN[2]);
      USB.printHex(xbeeZB.operating64PAN[3]);
      USB.printHex(xbeeZB.operating64PAN[4]);
      USB.printHex(xbeeZB.operating64PAN[5]);
      USB.printHex(xbeeZB.operating64PAN[6]);
      USB.printHex(xbeeZB.operating64PAN[7]);
      USB.println();

      USB.print(F("   channel: "));
      USB.printHex(xbeeZB.channel);
      USB.println();
    }

    USB.OFF();
  }
}


void loop()
{
  // set Green LED
  Utils.setLED(LED1,LED_ON);
  
  
  ////////////////////////////////////////////////
  // 9. Message composition
  ////////////////////////////////////////////////

  // 9.1 Create new frame (No mote id)
  frame.setID(node_id);
  frame.createFrame(ASCII);  

  // 9.2 Add frame fields
  if( LoRa_type == false )
  {
    if( (XBEE_type != 2) && (XBEE_type < 5) )
    {
      // add low MAC address in the case it is not a DigiMesh firmware
      frame.addSensor(SENSOR_MAC, macLow);
    }
  }
  frame.addSensor(SENSOR_ACC, ACC.getX(), ACC.getY(), ACC.getZ() );
  frame.addSensor(SENSOR_IN_TEMP, RTC.getTemperature());
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());

  // 9.3 Print frame
  // Example:<=>#35690399##5#MAC:4066EF6B#ACC:-47;-26;1000#IN_TEMP:26.25#BAT:59#
  frame.showFrame();


  ////////////////////////////////////////////////
  // 10. Send the packet
  ////////////////////////////////////////////////

  if( LoRa_type == true )
  {
    out0 = sx1272.sendPacketTimeout(BROADCAST_0, frame.buffer, frame.length);
    if( out0 == 0 )
    {
      USB.println(F("the frame above was sent"));
    }
    else 
    {
      USB.println(F("sending error"));
    } 
  }
  else
  {
    if( XBEE_type == 5 ) 
    {
      USB.println(F("the frame above is printed just by USB (it is not sent because no XBee is plugged)"));  
    }
    if( XBEE_type < 5 ) 
    {
      // 10.1 set packet to send
      packet=(packetXBee*) calloc(1,sizeof(packetXBee)); // memory allocation
      packet->mode=BROADCAST; // set Unicast mode

      // 10.2 send the packet via the correct object depending on the protocol

      // case 802.15.4
      if (XBEE_type == 0) 
      { 
        // turn XBee on
        xbee802.ON();  
        // sets Destination parameters
        xbee802.setDestinationParams(packet, destination, frame.buffer, frame.length); 
        // send data
        xbee802.sendXBee(packet);

        // check TX flag
        if( xbee802.error_TX == 0 )
        {
          USB.println(F("the frame above was sent"));
        }
        else 
        {
          USB.println(F("sending error"));
        }    
      } 

      // case DM or 868/900
      if( (XBEE_type == 1) || (XBEE_type == 2) || (XBEE_type == 4) ) 
      {
        // turn XBee on
        xbeeDM.ON();
        // sets Destination parameters
        xbeeDM.setDestinationParams(packet, destination, frame.buffer, frame.length); 
        // send data
        xbeeDM.sendXBee(packet);

        // check TX flag
        if( xbeeDM.error_TX == 0 )
        {
          USB.println(F("the frame above was sent"));
        }
        else 
        {
          USB.println(F("sending error"));
        }
      }  

      // case ZB Router (not coordinator)
      if ((XBEE_type == 3) && (ZIGBEE_type > 0))
      { 
        // turn XBee on 
        xbeeZB.ON();

        // sets Destination parameters
        xbeeZB.setDestinationParams(packet, destination, frame.buffer, frame.length); 
        // send data
        xbeeZB.sendXBee(packet);

        // check TX flag
        if( xbeeZB.error_TX == 0 )
        {
          USB.println(F("the frame above was sent"));
        }
        else 
        {
          USB.println(F("sending error"));
        }
      }

      // 10.3 free memory
      free(packet);
      packet = NULL;
    }
  }
  delay(5000);
}


