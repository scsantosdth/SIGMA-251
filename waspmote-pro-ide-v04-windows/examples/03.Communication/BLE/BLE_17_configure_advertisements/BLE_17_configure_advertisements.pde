/*
 *  ------------------ [BLE_17] - Configure advertisements ------------------- 
 *
 *  Explanation: This example changes the advertisement parameters to show the 
 *  ability of sending data in the advertisement payload. Remember that maximum 
 *  advertisement data length is 31 bytes. 
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
 *  MERCHANTABILITY or FITNESS ARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 * 
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  Version:		0.1
 *  Design:		David Gascón
 *  Implementation:	Javier Siscart
 */

#include <WaspBLE.h>

// Auxiliary variable
uint16_t aux = 0;

// Variable to store advertisement data
char advData[32];

void setup() 
{  

  USB.println(F("BLE_17 Example"));  

  // 0. Turn BLE module ON
  BLE.ON(SOCKET0);

}

void loop() 
{

  /* NOTE 1: after turning BLE module ON, the default state 
   is non discoverable.
   */

  /* NOTE 2: If you are currently advertising, then any changes 
   on the advertisement data will not take effect until you 
   stop and re-start advertising again.
   */

  ////////////////////////////////////////////////////////////////////
  // 1. Send advertisements each 100 ms with "Hello Wasp BLE" message
  ////////////////////////////////////////////////////////////////////

  USB.println(F("1 Configuring advertisements each 100 ms with 'Hello Wasp BLE' message"));

  // 1.1 Make device no discoverable to stop advertisement.
  aux = BLE.setDiscoverableMode(BLE_GAP_NON_DISCOVERABLE);
  USB.println(F("\tA - Stop advertisements"));

  // 1.2 Set advertisement interval of 100 ms and three channels
  /* NOTE 3: intervals are specified in units of 625 uS
   Example: 100 ms / 0.625 = 160
   */
  aux = BLE.setAdvParameters(160, 160, 7);
  USB.println(F("\tB - Setting advertisement interval"));

  /* NOTE 4: Advertisement data must be formatter according to 
   core specification. this example just show the way to do it.
   Maximum length is 31 bytes.

   *  Advertisement data structure (31 bytes) according Bluetooth standard.
   * ------------------------------------------------------------------------------
   * |                            advertisement data                                |
   * ------------------------------------------------------------------------------
   * | advLength |          FIELD 1            |          FIELD 2            | (...)|
   * ---------------------------------------------------------------------------
   * |           | length1 |      data         | length2 |      data         | (...)|
   * ---------------------------------------------------------------------------
   * |           |         | AD_Type | AD_Data |         | AD_Type | AD_Data | (...)|
   * ------------------------------------------------------------------------------
   */

  // 1.3 Set a dummy string for demonstration, but clear the variable first.
  memset(advData, 0x00, sizeof(advData));
  sprintf(advData, "Hello Wasp BLE");

  aux = BLE.setAdvData(BLE_GAP_ADVERTISEMENT, advData);
  USB.println(F("\tC - Setting data"));


  // 1.4 Set discoverable mode to user data to start advertising 
  // with custom data
  aux = BLE.setDiscoverableMode(BLE_GAP_USER_DATA);
  USB.println(F("\tD - Start advertisements"));

  // 1.5 Go to sleep and but remain advertising to save power.
  BLE.sleep();

  // 1.6 Advertise during ten seconds
  USB.println(F("Advertising each 100 ms during 10 seconds."));

  // 1.7 Wait for 10 seconds
  for (uint8_t a = 1; a <= 10; a++)
  {
    USB.print(a);
    USB.print(" ");
    delay(1000);
  }
  USB.println();
  USB.println();

  // 1.8 Wake up again to allow receiving new commands.
  aux = BLE.wakeUp();


  ////////////////////////////////////////////////////////////////////
  // 2. Send advertisements each 100 ms with "Goodbye Waspmote" message
  ////////////////////////////////////////////////////////////////////

  USB.println(F("2 Configuring advertisements each second with 'Goodbye Waspmote' message"));

  // 2.1 Make device no discoverable to stop advertisement.
  aux = BLE.setDiscoverableMode(BLE_GAP_NON_DISCOVERABLE);
  USB.println(F("\tA - Stop advertisements"));


  // 2.2 Change advertisement interval to 1 second    
  aux = BLE.setAdvParameters(1600, 1600, 7);
  USB.println(F("\tB - Setting advertisement interval"));

  // 2.3 Set a dummy string for demonstration, but clear the variable first.
  memset(advData, 0x00, sizeof(advData));
  sprintf(advData, "Good bye Waspmote"); 

  aux = BLE.setAdvData(BLE_GAP_ADVERTISEMENT, advData);
  USB.println(F("\tC - Setting data"));

  // 2.4 Set discoverable mode to user data to start advertising 
  // with custom data
  aux = BLE.setDiscoverableMode(BLE_GAP_USER_DATA);
  USB.println(F("\tD - Start advertisements"));

  // 2.5 Go to sleep and but remain advertising to save power.
  BLE.sleep();

  // 2.6 Advertise during ten seconds
  USB.println(F("Advertising each second during 10 seconds."));

  // 2.7 Wait for 10 seconds
  for (uint8_t a = 1; a <= 10; a++)
  {
    USB.print(a);
    USB.print(" ");
    delay(1000);
  }
  USB.println();
  USB.println();

  // 2.8 Wake up again to allow receiving new commands.
  aux = BLE.wakeUp();

}



