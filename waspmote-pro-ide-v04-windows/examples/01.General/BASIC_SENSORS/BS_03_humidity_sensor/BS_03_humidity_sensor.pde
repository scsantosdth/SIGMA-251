/*  
 *  ------ [BS_03] Getting the value of humidity sensor -------- 
 *  
 *  Explanation: This example shows how to get the vale of humidity
 *  sensor. Sensor humidity (808H5V6) connected to ANALOG7 pin
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

int humidity = 0;

void setup()
{
  // Open the USB connection
  USB.ON();
  USB.println(F("USB port started..."));

}

void loop()
{
  // read Humidity sensor connected to ANALOG7
  humidity = Utils.readHumidity();
  
  USB.print(F("Value of humidity: "));
  USB.print(humidity,DEC);
  USB.println(F(" % of relative humidity"));
  
  USB.println(F("------------------------------------------------------"));
  delay(1000); 
}
