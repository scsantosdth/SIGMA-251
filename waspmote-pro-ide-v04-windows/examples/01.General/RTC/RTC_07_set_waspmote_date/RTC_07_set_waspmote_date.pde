/*  
 *  ------ [RTC_7] Setting and reading time example -------- 
 *  
 *  Explanation: This example permits to set Time and Date in Waspmote's 
 *  RTC very easily via USB port. There is an interface which asks the user
 *  to introduce the Date and Time as specified without any need to change 
 *  this code.
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

int year;
int month;
int day;
int hour;
int minute;
int second;

// buffer to set the date and time
char buffer[100];
char input[100];


void setup()
{
  // Open the USB connection
  USB.ON();
  USB.println(F("RTC_7 example"));

  // Powers RTC up, init I2C bus and read initial values
  RTC.ON();


  USB.println(F("-------------------------------------"));
  USB.println(F("Set RTC Date and Time via USB port"));
  USB.println(F("-------------------------------------"));

  /////////////////////////////////
  //  YEAR
  /////////////////////////////////
  do
  {
    USB.print("Insert year [yy]:");    
  }
  while( getData(2) != true );
  
  year=atoi(input);
  USB.println(year);
  

  /////////////////////////////////
  //  MONTH
  /////////////////////////////////
  do
  {
    USB.print("Insert month [mm]:");    
  }
  while( getData(2) != true );
  
  month=atoi(input);
  USB.println(month);
  

  /////////////////////////////////
  //  DAY
  /////////////////////////////////
  do
  {
    USB.print("Insert day [dd]:");    
  }
  while( getData(2) != true );
  
  day=atoi(input);
  USB.println(day);
  

  /////////////////////////////////
  //  HOUR
  /////////////////////////////////
  do
  {
    USB.print("Insert Hour [HH]:");    
  }
  while( getData(2) != true );
  
  hour=atoi(input);
  USB.println(hour);

  /////////////////////////////////
  //  MINUTE
  /////////////////////////////////
  do
  {
    USB.print("Insert minute [MM]:");    
  }
  while( getData(2) != true );
  
  minute=atoi(input);
  USB.println(minute);

  /////////////////////////////////
  //  SECOND
  /////////////////////////////////
  do
  {
    USB.print("Insert second [SS]:");    
  }
  while( getData(2) != true );
  
  second=atoi(input);
  USB.println(second);
  
  
  /////////////////////////////////
  //  create buffer
  /////////////////////////////////
  sprintf(buffer, "%02u:%02u:%02u:%02u:%02u:%02u:%02u",
                                                        year, 
                                                        month, 
                                                        day, 
                                                        RTC.dow(year, month,day), 
                                                        hour, 
                                                        minute, 
                                                        second );
  USB.println(buffer);

  // Setting time [yy:mm:dd:dow:hh:mm:ss]
  RTC.setTime(buffer);
}

void loop()
{
  // Reading time
  USB.print(F("Time [Day of week, YY/MM/DD, hh:mm:ss]: "));
  USB.println(RTC.getTime());

  delay(1000); 
}



/*********************************
*
* get numBytes from USB port 
*
**********************************/
boolean getData(int numBytes)
{ 
  memset(input, 0x00, sizeof(input) );
  int i=0;
  USB.flush();
  int nRead=0;
  
  while(!USB.available());
  
  while(USB.available()>0)
  {
    input[i]=USB.read();
    
    if( (input[i]=='\r') && (input[i]=='\n') )
    {
      input[i]='\0';
    }
    else
    {
      i++;
    }
  }
  
  nRead=i;
  
  if(nRead != numBytes)
  {
    USB.print(F("must write "));
    USB.print(numBytes, DEC);
    USB.print(F(" characters. Read "));     
    USB.print(nRead, DEC);
    USB.println(F(" bytes")); 
    return false;
  }
  else
  {
    input[i]='\0';
    return true;
  }
  
}



