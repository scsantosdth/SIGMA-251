/*  
 *  ------ [BS_04] Getting the value of temperature, humidity and light sensor -------- 
 *  
 *  Explanation: This example shows how to get the vale of humidity sensors
 *  Temperature sensor MCP9700A connected to ANALOG6 pin
 *  Light sensor (LDR) connected to ANALOG5 pin
 *  Humidity sensor (808H5V6) connected to ANALOG7 pin
 *  
 *  Copyright (C) 2012 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Design:            Marcos Yarza
 *  Implementation:    Marcos Yarza
 */

// variables
float temp = 0.0;
int light = 0;
int hum = 0;

void setup()
{
  // Open the USB connection
  USB.ON();
  USB.println(F("USB port started..."));

}

void loop()
{
  // read sensors
  temp = Utils.readTemperature();
  hum = Utils.readHumidity();
  light = Utils.readLight();
  
  // Printing the value of the sensors
  USB.print(F("Temperature: "));
  USB.print(temp);
  USB.print(F(" Celsius degrees"));
  
  USB.print(F(" | Light: "));
  USB.print(light);
  USB.print(F(" % of light"));
  
  USB.print(F(" | Humidity: "));
  USB.print(hum);
  USB.println(F(" % of humidity"));
  
  delay(1000); 
}
