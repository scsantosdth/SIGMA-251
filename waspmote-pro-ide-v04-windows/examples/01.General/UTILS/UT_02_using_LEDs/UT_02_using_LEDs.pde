/*
 *  ------ [Ut_02] Waspmote Using LEDs Example --------
 *
 *  Explanation: This example shows how to use the LEDs of Waspmote
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
 *  Implementation:    Marcos Yarza
 */
 
 
void setup()
{
 
}

void loop()
{
  ////////////////////////////////////////////////////////
  // 1. Setting LEDs ON
  ////////////////////////////////////////////////////////  
  Utils.setLED(LED0, LED_ON);
  Utils.setLED(LED1, LED_ON);  
  delay(2000);

  ////////////////////////////////////////////////////////    
  // 2. Setting LEDs OFF
  ////////////////////////////////////////////////////////  
  Utils.setLED(LED0, LED_OFF);
  delay(1000);
  Utils.setLED(LED1, LED_OFF);
  delay(1000);
  
  ////////////////////////////////////////////////////////  
  // 3. Blink both LEDs once (during 1 second)
  ////////////////////////////////////////////////////////  
  Utils.blinkLEDs(1000);
  
  //////////////////////////////////////////////////////// 
  // 4. Blink LEDs separately for 5 times, during 200ms each time
  ////////////////////////////////////////////////////////  
  Utils.blinkGreenLED(200, 5);
  Utils.blinkRedLED(200, 5);

}

