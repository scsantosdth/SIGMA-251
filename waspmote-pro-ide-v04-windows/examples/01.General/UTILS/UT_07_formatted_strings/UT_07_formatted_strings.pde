/*
 *  ------   [UT_07] - Formatted messages   -------- 
 *
 *  Explanation: This example shows how to use the snprintf function
 *  in order to create formatted strings from variable values. The 
 *  variables types can be integer types, characters, strings, etc.
 *  Conversions are introduced with the character '%'. Possible 
 *  options can follow the '%':
 *    %c 	character
 *    %d 	signed integers
 *    %i 	signed integers
 *    %o 	octal
 *    %s 	a string of characters
 *    %u 	unsigned integer
 *    %x 	unsigned hexadecimal, with lowercase letters
 *    %X 	unsigned hexadecimal, with uppercase letters 
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

// define buffer to store the message
char message[100];

// define several variable types to be 
// included within a formatted message
char character = 'A';
int  integer = -123;
char string[]="This_is_a_string";
unsigned long ulong = 10000000;
float float_val = 123.456789;


void setup() 
{ 
  USB.ON();
  USB.println("UT_07 example - Formatted strings\n");  
  
  
  /////////////////////////////////////////////////
  // 1. Include Character  
  /////////////////////////////////////////////////
  snprintf( message, sizeof(message), "1.character: %c", character );
  USB.println( message );
  
  
  /////////////////////////////////////////////////
  // 2. Include Integer
  /////////////////////////////////////////////////
  snprintf( message, sizeof(message), "2.signed integers: %d", integer);
  USB.println( message );
  
  
  /////////////////////////////////////////////////
  // 3. Include String 
  ///////////////////////////////////////////////// 
  snprintf( message, sizeof(message), "3.string: %s", string);
  USB.println( message );
  
  
  /////////////////////////////////////////////////
  // 4. Include unsigned long 
  /////////////////////////////////////////////////
  snprintf( message, sizeof(message), "4.unsigned long: %lu", ulong );
  USB.println( message );
    
    
  /////////////////////////////////////////////////
  // 5. Include hexadecimal conversion
  /////////////////////////////////////////////////
  snprintf( message, sizeof(message), "5.hexadecimal: %x", character);
  USB.println( message);
  
  
  /////////////////////////////////////////////////
  // 6. Include float
  ///////////////////////////////////////////////// 
  // define local buffer for float to string conversion
  char float_str[10];
  
  // use dtostrf() to convert from float to string: 
  // '1' refers to minimum width
  // '3' refers to number of decimals
  dtostrf( float_val, 1, 3, float_str);
  
  // use snprintf() to include the float representation
  snprintf( message, sizeof(message), "6.floating point: %s", float_str );
  USB.println( message );


  /////////////////////////////////////////////////
  // 7. All together
  /////////////////////////////////////////////////
  USB.println(F("\n----------------------------------------"));  
  USB.println(F("Complete message with several fields:"));
  USB.println(F("----------------------------------------"));
  
  snprintf( message, sizeof(message), "A:%c#B:%d#C:%s#D:%lu#E:%x#F:%s#", character, integer, string, ulong, character, float_str );
  USB.println( message );
  USB.println();
  USB.println();
  
  
}



void loop() 
{
  // do nothing
  delay(5000);
}






