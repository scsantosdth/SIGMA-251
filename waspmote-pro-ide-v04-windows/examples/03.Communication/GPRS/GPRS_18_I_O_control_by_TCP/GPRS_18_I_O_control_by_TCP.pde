/*  
 *  ------------  GPRS_18 - I/O control by TCP  ------------ 
 *  
 *  Explanation: This example shows how to manage I/O pins of Waspmote using 
 *  a TCP/IP connection for sending commands.
 *  This commands are:
 *  - READ/n_analog_input for read an analog pin
 *  - WRITE_1/n_digital_output for put '1' in a digital pin
 *  - WRITE_0/n_digital_output for put '0' in a digital pin
 *  - SLEEP/ for sned the Waspmote to sleep 1 hour
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
 *  Version:           0.3
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego
 */

#include "WaspGPRS_Pro.h"

char apn[] = "apn";
char login[] = "login";
char password[] = "password";

const char readpin[]="READ";
const char write_high[]="WRITE_1";
const char write_low[]="WRITE_0";
const char sleep[]="SLEEP";

int ok, x, answer;
char buffer[50], arg1[10], arg2[10];
unsigned long previous;

void setup()
{   
    USB.println(F("**************************"));
    // 1. sets operator parameters
    GPRS_Pro.set_APN(apn, login, password);
    // And shows them
    GPRS_Pro.show_APN();
    USB.println(F("**************************"));
}

void loop() 
{ 

    // setup for Serial port over USB: 
    USB.ON(); 
    USB.println(F("USB port started...")); 
    USB.println(F("**************************")); 
    USB.println(F("Setting pins...")); 
    pinMode(ANALOG1,INPUT); 
    pinMode(ANALOG2,INPUT); 
    pinMode(ANALOG3,INPUT); 
    pinMode(ANALOG4,INPUT); 
    pinMode(ANALOG5,INPUT); 
    pinMode(ANALOG6,INPUT);    
    USB.println(F("Analog pins ready...")); 
    pinMode(DIGITAL1,OUTPUT); 
    pinMode(DIGITAL2,OUTPUT); 
    pinMode(DIGITAL3,OUTPUT); 
    pinMode(DIGITAL4,OUTPUT); 
    pinMode(DIGITAL5,OUTPUT); 
    pinMode(DIGITAL7,OUTPUT); 
    pinMode(DIGITAL8,OUTPUT); 
    USB.println(F("Digital pins ready...")); 

    // 2. activates the GPRS_Pro module:
    answer = GPRS_Pro.ON(); 
    if ((answer == 1) || (answer == -3))
    {
        USB.println(F("GPRS_Pro module ready...")); 

        // 3. sets pin code: 
        USB.println(F("Setting PIN code...")); 
        // **** must be substituted by the SIM code 
        if (GPRS_Pro.setPIN("****") == 1) 
        { 
            USB.println(F("PIN code accepted")); 
        } 
        else 
        { 
            USB.println(F("PIN code incorrect")); 
        } 

        // 4. waits for connection to the network:
        answer = GPRS_Pro.check(180);    
        if (answer == 1)
        {
            USB.println(F("GPRS_Pro module connected to the network...")); 

            // 5. configures IP connection
            USB.print(F("Setting connection...")); 
            answer = GPRS_Pro.configureGPRS_TCP_UDP(SINGLE_CONNECTION, NON_TRANSPARENT); 
            if (answer == 1) 
            { 
                USB.println(F("Done")); 

                // if configuration is success shows the IP address 
                USB.print(F("Configuration success. IP address: ")); 
                USB.println(GPRS_Pro.IP_dir); 
                USB.print(F("Opening TCP socket..."));  

                // 6. create a TCP socket
                // “IP” and “port” must be substituted by the IP address and the port 
                answer = GPRS_Pro.createSocket(TCP_CLIENT, "IP", "port"); 
                if (answer == 1) 
                { 
                    USB.println(F("Conected")); 
                    PWR.setSensorPower(SENS_3V3, SENS_ON); 
                    USB.print(F("Sending start string...")); 
                    // 7. sending 'start string' 
                    if (GPRS_Pro.sendData("Waspmote ready!\n") == 1) 
                    { 
                        USB.println(F("Done")); 
                    } 
                    else 
                    { 
                        USB.println(F("Fail")); 
                    } 

                    ok = 0; 
                    while (ok == 0) 
                    { 
                        // waits for TCP client data: 
                        USB.println(F("Waiting for order..."));

                        // 8. waits five minutes for data
                        answer = 0;
                        previous = millis();
                        while ((answer != 3) && ((millis() - previous) < 300000)) 
                        {
                            answer = GPRS_Pro.manageIncomingData();
                            // Condition to avoid an overflow (DO NOT REMOVE)
                            if (millis() < previous)
                            {
                                previous = millis();	
                            }
                        }

                        if (answer == 3)
                        {
                            // cleans the buffer 
                            for( x = 0; x < 50; x++) 
                            { 
                                buffer[x]='\0'; 
                            } 

                            strncpy(buffer, GPRS_Pro.buffer_GPRS, strchr(GPRS_Pro.buffer_GPRS, '/') - GPRS_Pro.buffer_GPRS);                
                            USB.print(F("Order: ")); 
                            USB.println(buffer); 

                            // 9. checks the received string and search the order:        

                            // order: READ. Reads desired analog pin   
                            if (strcmp(buffer, readpin) == 0) 
                            { 
                                strcpy(buffer, strrchr(GPRS_Pro.buffer_GPRS, '/') + 1); 
                                USB.print(F("Pin: ")); 
                                USB.println(buffer); 
                                switch(buffer[0]) 
                                { 
                                case '1': 
                                    x=analogRead(ANALOG1); 
                                    break; 
                                case '2': 
                                    x=analogRead(ANALOG2); 
                                    break; 
                                case '3': 
                                    x=analogRead(ANALOG3); 
                                    break; 
                                case '4': 
                                    x=analogRead(ANALOG4); 
                                    break; 
                                case '5': 
                                    x=analogRead(ANALOG5); 
                                    break; 
                                case '6': 
                                    x=analogRead(ANALOG6); 
                                    break; 
                                } 
                                sprintf(buffer, "=>Value: %d\n\r", x); 
                                GPRS_Pro.sendData(buffer);                    
                            } 

                            // order: WRITE_1. Puts high desired digital pin 
                            if (strcmp(buffer, write_high) == 0) 
                            { 
                                strcpy(buffer, strrchr(GPRS_Pro.buffer_GPRS, '/') + 1); 
                                USB.print(F("Pin: ")); 
                                USB.println(buffer); 
                                switch(buffer[0]) 
                                { 
                                case '1': 
                                    digitalWrite(DIGITAL1, HIGH); 
                                    break; 
                                case '2': 
                                    digitalWrite(DIGITAL2, HIGH); 
                                    break; 
                                case '3': 
                                    digitalWrite(DIGITAL3, HIGH); 
                                    break; 
                                case '4': 
                                    digitalWrite(DIGITAL4, HIGH); 
                                    break; 
                                case '5': 
                                    digitalWrite(DIGITAL5, HIGH); 
                                    break; 
                                case '7': 
                                    digitalWrite(DIGITAL7, HIGH); 
                                    break; 
                                case '8': 
                                    digitalWrite(DIGITAL8, HIGH); 
                                    break; 
                                } 
                                GPRS_Pro.sendData("=>Done\n\r"); 
                            } 

                            // order: WRITE_0. Puts low desired digital pin 
                            if (strcmp(buffer, write_low) == 0) 
                            { 
                                strcpy(buffer, strrchr(GPRS_Pro.buffer_GPRS, '/') + 1); 
                                USB.print(F("Pin: ")); 
                                USB.println(buffer); 
                                switch(buffer[0]) 
                                { 
                                case '1': 
                                    digitalWrite(DIGITAL1, LOW); 
                                    break; 
                                case '2': 
                                    digitalWrite(DIGITAL2, LOW); 
                                    break; 
                                case '3': 
                                    digitalWrite(DIGITAL3, LOW); 
                                    break; 
                                case '4': 
                                    digitalWrite(DIGITAL4, LOW); 
                                    break; 
                                case '5': 
                                    digitalWrite(DIGITAL5, LOW); 
                                    break; 
                                case '7': 
                                    digitalWrite(DIGITAL7, LOW); 
                                    break; 
                                case '8': 
                                    digitalWrite(DIGITAL8, LOW); 
                                    break; 
                                } 
                                GPRS_Pro.sendData("=>Done\n\r"); 
                            } 

                            // order: SLEEP. Goes to sleep 
                            if (strcmp(buffer, sleep) == 0) 
                            { 
                                GPRS_Pro.sendData("=>Bye developer\n\r"); 
                                ok=1; 
                            } 
                        }
                        else if ((answer != 3) && ((millis() - previous) > 300000))
                        {
                            ok = 1;    
                        }
                    } 

                    USB.print(F("Closing TCP socket..."));  

                    // 10. closes socket: 
                    if (GPRS_Pro.closeSocket() == 1) 
                    { 
                        USB.println(F("Done")); 
                    } 
                    else 
                    { 
                        USB.println(F("Fail")); 
                    } 
                } 
                else if (answer < -14) 
                { 
                    USB.print("Connection failed. Error code: "); 
                    USB.println(answer, DEC); 
                    USB.print("CME error code: "); 
                    USB.println(GPRS_Pro.CME_CMS_code, DEC); 
                } 
                else 
                { 
                    USB.print("Connection failed. Error code: "); 
                    USB.println(answer, DEC); 
                }           
            } 
            else if (answer < -14) 
            { 
                USB.print(F("Configuration failed. Error code: ")); 
                USB.println(answer, DEC); 
                USB.print(F("CME error code: ")); 
                USB.println(GPRS_Pro.CME_CMS_code, DEC); 
            } 
            else 
            { 
                USB.print(F("Configuration failed. Error code: ")); 
                USB.println(answer, DEC); 
            } 
        }
        else
        {
            USB.println(F("GPRS_Pro module cannot connect to the network"));     
        }
    }
    else
    {
        USB.println(F("GPRS_Pro module not ready"));    
    }

    // 11. powers off the GPRS_Pro module: 
    GPRS_Pro.OFF(); 

    USB.println(F("Sleeping...")); 

    // 12. sleeps one hour: 
    PWR.deepSleep("00:01:00:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF); 

} 


