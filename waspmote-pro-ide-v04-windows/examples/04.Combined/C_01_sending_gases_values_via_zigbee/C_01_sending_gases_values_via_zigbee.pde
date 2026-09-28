/*  
 *  ------ [C_01] - sending gases values via ZigBee -------- 
 *  
 *  Explanation: This example shows how to measure CO, CO2, temperature 
 *  and humidity using the Gases Sensor Board. The data is sent via 
 *  XBee-ZigBee. And Waspmote is put to deep sleep mode in order to save 
 *  energy.
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
 *  Version:           0.2
 *  Design:            David Gascón 
 *  Implementation:    Javier Siscart
 */


#include <WaspXBeeZB.h>
#include <WaspFrame.h>
#include <WaspSensorGas_v20.h>

float temperatureFloatValue[10]; 
float humidityFloatValue[10];  
float CO2FloatValue;    
float COFloatValue;
unsigned long previous;

// Sleep time [dd:hh:mm:ss]
char sleepTime[] = "00:00:00:10";           

// Destination MAC address
//////////////////////////////////////////
char MAC_ADDRESS[] = "0013A200400A3451";
//////////////////////////////////////////

// Define the Waspmote ID
char WASPMOTE_ID[] = "node_01";

// define variable
uint8_t error;

void setup()
{
    ////////////////////////////////////////////////
    // 0. Init USB port for debugging
    ////////////////////////////////////////////////
    USB.ON();
    USB.println(F("C_1 example"));


    ////////////////////////////////////////////////
    // 1. Initial message composition
    ////////////////////////////////////////////////

    // 1.1 Set mote Identifier (16-Byte max)
    frame.setID( WASPMOTE_ID );	

    // 1.2 Create new ASCII frame
    frame.createFrame(ASCII);  

    // 1.3 Set frame fields (String - char*)
    frame.addSensor(SENSOR_STR, (char*) "C.01 Example");

    // 1.4 Print frame
    frame.showFrame();


    ////////////////////////////////////////////////
    // 2. Send initial message
    ////////////////////////////////////////////////

    // 2.1 Powers XBee
    xbeeZB.ON();  
    delay(3000);

    // 2.2. check network parameters
    checkNetworkParams();

    // 2.3 Send XBee packet
    error = xbeeZB.send( MAC_ADDRESS, frame.buffer, frame.length );   

    // 2.4 Check TX flag
    if( error == 0 ) 
    {
        USB.println(F("ok"));
    }
    else 
    {
        USB.println(F("error"));
    }

    // 2.5 Communication module to OFF
    xbeeZB.OFF();
    delay(100);
}



void loop()
{

    ////////////////////////////////////////////////
    // 3. Measure corresponding values
    ////////////////////////////////////////////////
    USB.println(F("Measuring sensors..."));

    // 3.1 Turn on the sensor board
    SensorGasv20.ON();

    // 3.2 Turn on the RTC
    RTC.ON();

    // 3.3 supply stabilization delay
    delay(100);

    // 3.4 Turn on the sensors
    USB.println(F("Warming sensors"));

    //Configure and turn on the CO sensor   
    SensorGasv20.configureSensor(SENS_SOCKET4CO, 1, 100);

    //Configure and turn on the CO2 sensor  
    SensorGasv20.configureSensor(SENS_CO2, 7);
    SensorGasv20.setSensorMode(SENS_ON, SENS_CO2);    

    previous = millis();
    while (millis() - previous < 30000)
    {
        USB.print(".");

        // dummy readings in order to warm the sensor
        SensorGasv20.readValue(SENS_SOCKET4CO); 
        // Condition to avoid an overflow (DO NOT REMOVE)
        if (millis() < previous)
        {
            previous = millis();	
        }   
    }
    USB.println();  

    // 3.5 Read the sensors

    //++++++++   Temperature    +++++++++

    // Get 10 measurements
    for (int i=0;i<10;i++)
    {
        temperatureFloatValue[i] = SensorGasv20.readValue(SENS_TEMPERATURE);
    }

    // Calculate average (stored in first member of array)
    for (int i=1; i<10; i++) 
    {
        // Add the next element to the total
        temperatureFloatValue[0] = temperatureFloatValue[0] + temperatureFloatValue[i];
    }
    temperatureFloatValue[0] = temperatureFloatValue[0] / 10 ;  


    //++++++++   Humidity    +++++++++

    // Get 10 measurements
    for (int i=0;i<10;i++)
    {
        humidityFloatValue[i] = SensorGasv20.readValue(SENS_HUMIDITY);  
    }

    // Calculate average (stored in first member of array)
    for (int i=1; i<10; i++) 
    {
        // Add the next element to the total
        humidityFloatValue[0] = humidityFloatValue[0] + humidityFloatValue[i];
    }
    humidityFloatValue[0] = humidityFloatValue[0] / 10 ;  


    //++++++++   CO2    +++++++++  
    // get CO2 value
    CO2FloatValue = SensorGasv20.readValue(SENS_CO2);    


    //++++++++   CO    +++++++++
    // get CO value
    COFloatValue = SensorGasv20.readValue(SENS_SOCKET4CO);    


    // 3.6 Turn off the sensor board
    SensorGasv20.OFF();

    // 3.7 get time from RTC  
    RTC.getTime(); 


    ////////////////////////////////////////////////
    // 4. Message composition
    ////////////////////////////////////////////////

    // 4.1 Create new ASCII frame
    frame.createFrame(ASCII);  

    // 4.2 Add frame fields
    frame.addSensor(SENSOR_TCA, temperatureFloatValue[0] ); 
    frame.addSensor(SENSOR_HUMA, humidityFloatValue[0]); 
    frame.addSensor(SENSOR_CO2, CO2FloatValue ); 
    frame.addSensor(SENSOR_CO, COFloatValue); 
    frame.addSensor(SENSOR_TIME, RTC.hour, RTC.minute, RTC.second );

    // 4.3 Print frame
    // Example: <=>#35689722#n1#1#TCA:23.83#HUMA:25.4#CO2:1.806#CO:0.361#TIME:13-10-21#
    frame.showFrame();


    ////////////////////////////////////////////////
    // 5. Send message
    ////////////////////////////////////////////////

    // 5.1 Powers XBee
    xbeeZB.ON();  
    delay(3000); 

    // 5.2 check network parameters
    checkNetworkParams();

    // 5.3 wait for association indication
    xbeeZB.getAssociationIndication();
    previous = millis();
    while( xbeeZB.associationIndication != 0 )
    { 
        delay(2000);
        xbeeZB.getAssociationIndication();

        // Condition to avoid an overflow (DO NOT REMOVE)
        if (millis() < previous)
        {
            previous = millis();	
        }   

        // exit when time is up
        if( previous-millis() > 30000 )
        {
            break;
        }
    }

    // 5.4 clean buffer
    xbeeZB.flush();

    // 5.5 Send XBee packet
      // send XBee packet
	error = xbeeZB.send( MAC_ADDRESS, frame.buffer, frame.length ); 

    // 5.6 Check TX flag
    if( error == 0 ) 
    {
        USB.println(F("ok"));
    }
    else 
    {
        USB.println(F("error"));
    }

    // 5.7 Communication module to OFF
    xbeeZB.OFF();
    delay(100);


    ////////////////////////////////////////////////
    // 6. Entering Deep Sleep mode
    ////////////////////////////////////////////////
    USB.println(F("Going to sleep..."));
    USB.println();
    PWR.deepSleep(sleepTime, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

    USB.ON();
    USB.println(F("wake"));
}


/*******************************************
 *
 *  checkNetworkParams - Check operating
 *  network parameters in the XBee module
 *
 *******************************************/
void checkNetworkParams()
{
    // 1. get operating 64-b PAN ID
    xbeeZB.getOperating64PAN();

    // 2. wait for association indication
    xbeeZB.getAssociationIndication();

    while( xbeeZB.associationIndication != 0 )
    { 
        delay(2000);

        // get operating 64-b PAN ID
        xbeeZB.getOperating64PAN();

        USB.print(F("operating 64-b PAN ID: "));
        USB.printHex(xbeeZB.operating64PAN[0]);
        USB.printHex(xbeeZB.operating64PAN[1]);
        USB.printHex(xbeeZB.operating64PAN[2]);
        USB.printHex(xbeeZB.operating64PAN[3]);
        USB.printHex(xbeeZB.operating64PAN[4]);
        USB.printHex(xbeeZB.operating64PAN[5]);
        USB.printHex(xbeeZB.operating64PAN[6]);
        USB.printHex(xbeeZB.operating64PAN[7]);
        USB.println();     

        xbeeZB.getAssociationIndication();
    }

    USB.println(F("\nJoined a network!"));

    // 3. get network parameters 
    xbeeZB.getOperating16PAN();
    xbeeZB.getOperating64PAN();
    xbeeZB.getChannel();

    USB.print(F("operating 16-b PAN ID: "));
    USB.printHex(xbeeZB.operating16PAN[0]);
    USB.printHex(xbeeZB.operating16PAN[1]);
    USB.println();

    USB.print(F("operating 64-b PAN ID: "));
    USB.printHex(xbeeZB.operating64PAN[0]);
    USB.printHex(xbeeZB.operating64PAN[1]);
    USB.printHex(xbeeZB.operating64PAN[2]);
    USB.printHex(xbeeZB.operating64PAN[3]);
    USB.printHex(xbeeZB.operating64PAN[4]);
    USB.printHex(xbeeZB.operating64PAN[5]);
    USB.printHex(xbeeZB.operating64PAN[6]);
    USB.printHex(xbeeZB.operating64PAN[7]);
    USB.println();

    USB.print(F("channel: "));
    USB.printHex(xbeeZB.channel);
    USB.println();

}
