/*  
 *  --[Ag_12b] - Reading the Wind Vane filtered by mean-- 
 *  
 *  Explanation: Turn on the Agriculture v20 board and read the 
 *  Wind Vane Sensor calling the special 'getVaneFiltered' function 
 *  in order to calculate the mean value of sucesive measurement of 
 *  the wind vane direction sensor. The Wind Vane value will be stored 
 *  in the inner attribute: 'SensorAgrv20.vaneDirection'
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
 *  Version:           0.1 
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */

#include <WaspSensorAgr_v20.h>



void setup()
{
  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("start"));
  delay(100);

  // Turn on the sensor board
  SensorAgrv20.ON();
  
  // Turn on the RTC
  RTC.ON();
  
}
 
void loop()
{
  // Part 1: Sensor reading
  // Turn on the sensor and wait for stabilization and response time
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_VANE);
  delay(10);
  
  // Read the Wind Vane sensor calling the special 'getVaneFiltered' 
  // function in order to calculate the mean value of sucesive 
  // measurement of the wind vane direction sensor. The Wind Vane 
  // value will be stored in the inner attribute: 'SensorAgrv20.vaneDirection'
  SensorAgrv20.getVaneFiltered();


  // Turn off the sensor
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_VANE);
  
  // Part 2: USB printing 
  switch(SensorAgrv20.vaneDirection)
  {
    case  SENS_AGR_VANE_N   :  USB.println("N");
                               break;
    case  SENS_AGR_VANE_NNE :  USB.println("NNE");
                               break;
    case  SENS_AGR_VANE_NE  :  USB.println("NE");
                               break;
    case  SENS_AGR_VANE_ENE :  USB.println("ENE");
                               break;
    case  SENS_AGR_VANE_E   :  USB.println("E");
                               break;
    case  SENS_AGR_VANE_ESE :  USB.println("ESE");
                               break;
    case  SENS_AGR_VANE_SE  :  USB.println("SE");
                               break;
    case  SENS_AGR_VANE_SSE :  USB.println("SSE");
                               break;
    case  SENS_AGR_VANE_S   :  USB.println("S");
                               break;
    case  SENS_AGR_VANE_SSW :  USB.println("SSW");
                               break;
    case  SENS_AGR_VANE_SW  :  USB.println("SW");
                               break;
    case  SENS_AGR_VANE_WSW :  USB.println("WSW");
                               break;
    case  SENS_AGR_VANE_W   :  USB.println("W");
                               break;
    case  SENS_AGR_VANE_WNW :  USB.println("WNW");
                               break;
    case  SENS_AGR_VANE_NW  :  USB.println("WN");
                               break;
    case  SENS_AGR_VANE_NNW :  USB.println("NNW");
                               break;
  }

  
  delay(1000);
}
