/*  
 *  ------ [USB_1] Using USB.printf() function -------- 
 *  
 *  Explanation: This example shows how to use USB.printf() funciton to print 
 *  several char/strings/int... in a single line
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
 *  Design:            Yuri Carmona
 *  Implementation:    Yuri Carmona, Marcos Yarza
 */
 
// variables
int var1=0xABCD;
int var2=3.1416;
int var3=32767;//max signed int
int var4=32768;//overflows signed int range
long var5=2147483647;//max signed long int
long var6=2147483648;//overflows signed long range
unsigned long var7=4294967295;//max unsigned long

void setup()
{
  // Opening UART to show messages using 'Serial Monitor'
  USB.ON();
  RTC.ON();
  ACC.ON();
}

void loop()
{
  USB.printf("%s\n", "Hello world"); // with line break
  USB.printf("time: %s\n", RTC.getTime());
  USB.printf("millis: %lu\n",millis());  
  USB.printf("hexadecimal: %x\n", var1);
  USB.printf("decimal: %d\n", var1);
  USB.printf("unsigned int: %u\n", var1);  
  USB.printf("It is not possible to print floats: %f\n", var2);
  USB.printf("int: %d\n", var3);
  USB.printf("'32768' overflows signed int range: %d\n", var4);
  USB.printf("signed long: %ld\n", var5);
  USB.printf("'2147483648' overflows signed long range: %ld\n", var6);
  USB.printf("unsigned long: %lu\n", var7);
  USB.printf("ACC x:%d,y:%d,z:%d - temp:%d - bat: %d%c%c%c",
                                                            ACC.getX(),
                                                            ACC.getY(),ACC.getZ(),
                                                            (int)RTC.getTemperature(),
                                                            PWR.getBatteryLevel(),
                                                            '%',
                                                            '\r',
                                                            '\n');
  
  USB.println(F("\n----------------------------\n"));

  // A little delay
  delay(5000);
}


