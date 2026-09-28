/*  
 *  ------ Sigfox Code Example -------- 
 *  
 *  Explanation: This example shows how to send a Keep-Alive packet
 *  to the Sigfox network
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
 *  Version:           0.1
 *  Design:            David Gascon 
 *  Implementation:    Yuri Carmona
 */
#include <WaspSigfox.h>

//////////////////////////////////////////////
uint8_t socket = SOCKET0;
//////////////////////////////////////////////

uint8_t error;


void setup() 
{
  USB.ON();  
  
  
  //////////////////////////////////////////////
  // switch on
  //////////////////////////////////////////////
  error = Sigfox.ON(socket);
  
  // Check sending status
  if( error == 0 ) 
  {
    USB.println(F("Switch ON OK"));     
  }
  else 
  {
    USB.println(F("Switch ON ERROR")); 
  }    
  
  
  //////////////////////////////////////////////
  // Send Keep-Alive packet
  //////////////////////////////////////////////
  Sigfox.sendKeepAlive();
   
  // Check sending status
  if( error == 0 ) 
  {
    USB.println(F("Send Keep-Alive: OK"));
  }
  else 
  {
    USB.println(F("Send Keep-Alive: ERROR"));
  }       
  
  USB.println(F("----------------------------------------------"));

}


void loop() 
{

  delay(10000);
}
