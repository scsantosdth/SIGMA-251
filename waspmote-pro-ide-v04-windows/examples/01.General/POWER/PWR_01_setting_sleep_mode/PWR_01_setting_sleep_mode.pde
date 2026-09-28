/*
 *  ------ [PWR_1] - Setting Sleep Mode -------- 
 *
 *  Explanation: This example shows how to set Waspmote in a low-power
 *  consumption mode
 *
 *  Copyright (C) 2013 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Implementation:    Marcos Yarza
 */
 
 
void setup()
{
  USB.ON();
  USB.println(F("PWR_1 example"));
}

void loop()
{
  USB.println(F("enter sleep"));
    
  // Go to sleep disconnecting all the switches and modules
  // After 8 seconds, Waspmote wakes up thanks to internal watchdog
  /* Other possible values are: 
  *   WTD_16MS:  16ms
  *   WTD_32MS:  32ms
  *   WTD_64MS:  64ms
  *   WTD_128MS: 128ms
  *   WTD_250MS: 250ms
  *   WTD_500MS: 500ms
  *   WTD_1S:    1s
  *   WTD_2S:    2s 
  *   WTD_4S:    4s
  *   WTD_8S:    8s
  */  
  PWR.sleep(WTD_8S, ALL_OFF);
  
  USB.ON();
  USB.println(F("\nwake up"));
  
  // After wake up I check intFlag and blink LEDs
  if( intFlag & WTD_INT )
  {
    USB.println(F("---------------------"));
    USB.println(F("WTD INT captured"));
    USB.println(F("---------------------"));
    Utils.blinkLEDs(300);
    Utils.blinkLEDs(300);
    Utils.blinkLEDs(300);
    intFlag &= ~(WTD_INT);
  }

}

