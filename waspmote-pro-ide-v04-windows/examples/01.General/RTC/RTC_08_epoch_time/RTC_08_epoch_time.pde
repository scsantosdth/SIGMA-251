/*  
 *  ------ [RTC_08] Unix/Epoch time example -------- 
 *  
 *  Explanation: This example shows how to use the functions related to
 *  the management of Time and Date as Unix/Epoch time.
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

// Define variable to store Epoch time
unsigned long	epoch;

// Define variable for UTC timestamps
timestamp_t   time;


void setup()
{
  // Open the USB connection
  USB.ON();
  USB.println(F("RTC_08 example"));

  // Powers RTC up, init I2C bus and read initial values
  USB.println(F("Init RTC"));
  RTC.ON();
  
  // Setting time as Saturday, 2014-12-20 at 14:38:47
  RTC.setTime("14:12:20:07:14:38:47");
  USB.println(F("Setting time to: Saturday, 2014-12-20 at 14:38:47"));
  USB.println();
  delay(1000);
  USB.println(F("-----------------------------------"));  
  
}

void loop()
{   
  
  ///////////////////////////////////////////////////////
  //  1. Get Epoch time from input values
  ///////////////////////////////////////////////////////
  
  // Get Epoch time from input values (i.e: 2014-12-20 at 14:38:47)
  epoch = RTC.getEpochTime( 14, 12, 20, 14, 38, 47 );
                            
  USB.print(F("Epoch Time from input values (14/12/20, 14:38:47): "));
  USB.println( epoch ); 
  delay(1000); 
  
  
  ///////////////////////////////////////////////////////
  //  2. Get Epoch time from RTC value
  ///////////////////////////////////////////////////////
      
  // Get Epoch time from RTC values
  epoch = RTC.getEpochTime();  
  
  USB.print(F("Epoch Time from RTC: "));
  USB.println( epoch );
  delay(1000); 
  
  
  ///////////////////////////////////////////////////////
  //  3. Break Epoch time into UTC Time
  ///////////////////////////////////////////////////////
  
  // Break Epoch time into UTC time
  RTC.breakTimeAbsolute( epoch, &time ); 
  
  USB.print(F("Break Time from epoch time:"));
  USB.print( time.year, DEC );    USB.print(F("/"));
  USB.print( time.month, DEC );   USB.print(F("/"));
  USB.print( time.date, DEC );    USB.print(F(","));
  USB.print( time.hour, DEC );    USB.print(F(":"));
  USB.print( time.minute, DEC );  USB.print(F(":")); 
  USB.print( time.second, DEC );  
  USB.println();
  delay(1000); 
  
  
  
  ///////////////////////////////////////////////////////
  //  4. Break seconds time into days/hours/minutes/seconds
  ///////////////////////////////////////////////////////
  
  // Break Time from epoch subtraction
  RTC.breakTimeOffset( (epoch-1419086327), &time ); 
  
  USB.print(F("Break Time from epoch subtraction into: ")); 
  USB.print( time.date, DEC );   USB.print(F(" days, "));
  USB.print( time.hour, DEC );   USB.print(F(" hours, "));
  USB.print( time.minute, DEC ); USB.print(F(" minutes, ")); 
  USB.print( time.second, DEC ); USB.println(F(" seconds"));
  
  USB.println(F("-----------------------------------"));  
  delay(10000); 
  
  
  
}
