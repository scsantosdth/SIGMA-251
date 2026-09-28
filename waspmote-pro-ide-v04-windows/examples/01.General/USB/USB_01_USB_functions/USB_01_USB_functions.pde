/*  
 *  ------ [USB_1]  -------- 
 *  
 *  Explanation: This example shows how to use the USB port: turn USB ON,
 *  turn USB OFF, print chars, strings...
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

unsigned long time = 0;
int val = 0;

void setup()
{

}

void loop()
{
    ///////////////////////////////////////////////////////////
    // 1. Opening UART to show messages using 'USB Monitor'
    ///////////////////////////////////////////////////////////
    USB.ON();

    ///////////////////////////////////////////////////////////
    // 2. print a char
    ///////////////////////////////////////////////////////////
    USB.print('N');
    USB.print('\r');
    USB.print('\n');

    // print an separator line
    USB.println(F("------------------------------------"));

    ///////////////////////////////////////////////////////////
    // 3. printing strings
    ///////////////////////////////////////////////////////////
    USB.print("Hello world");
    USB.print("Waspmote is here");

    // print an separator line
    USB.println(F("\n------------------------------------"));

    ///////////////////////////////////////////////////////////
    // 4. printing strings +  new line (CR+LF)
    ///////////////////////////////////////////////////////////
    USB.println("Hello world");
    USB.println("Waspmote is here");

    // print an separator line
    USB.println(F("------------------------------------"));

    ///////////////////////////////////////////////////////////
    // 5. printing numbers
    ///////////////////////////////////////////////////////////
    USB.println(78);
    USB.println(78, BIN);
    USB.println(78, OCT);
    USB.println(78, DEC);
    USB.println(78, HEX);
    USB.println(1.23456);

    // print an separator line
    USB.println(F("------------------------------------"));

    ///////////////////////////////////////////////////////////
    // 6. printing strings from Flash memmory => F()
    ///////////////////////////////////////////////////////////
    USB.println(F("Hello world"));
    USB.println(F("Waspmote is here"));

    // print an separator line
    USB.println(F("------------------------------------"));

    ///////////////////////////////////////////////////////////
    // 7. printing several chars/strings/ints... in a single line
    ///////////////////////////////////////////////////////////
    USB.printf("%s\n", "Hello world"); // with line break
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

    // print an separator line
    USB.println(F("------------------------------------"));

    ///////////////////////////////////////////////////////////
    // 8. Cleaning the serial port buffer
    ///////////////////////////////////////////////////////////
    USB.flush();

    ///////////////////////////////////////////////////////////
    // 9. wait for 10 seconds to receive char from PC
    // when a char is received, waspmote sends it to PC
    ///////////////////////////////////////////////////////////
    USB.println(F("Wait for 10 seconds to receive char from PC"));
    USB.println(F("when a char is received, waspmote sends it to PC"));
    USB.print(F("Received: "));
    time = millis();
    while(millis()-time < 10000)
    {
        if (USB.available() > 0)
        {
            val = USB.read();
            USB.print(val,BYTE);
        }

        // Condition to avoid an overflow (DO NOT REMOVE)
        if (millis() < time)
        {
            time = millis();	
        }
    }

    // print an separator line
    USB.println(F("\n------------------------------------"));

    USB.println(F("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"));

    // Closing UART 
    USB.OFF();
}



