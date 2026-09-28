/*  
 *  ------------  [Ag_15] - Frame Class Utility  -------------- 
 *  
 *  Explanation: This is the basic code to create frame with every sensor
 * 	that uses Agriculture Board
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
 *  Version:		    0.1
 *  Design:             David Gascón
 *  Implementation:     Luis Miguel Marti
 */

#include <WaspSensorAgr_v20.h>
#include <WaspFrame.h>

char node_ID[] = "Node_01";

//variables to store sensors readings
float temperature;
float humidity;
float pressure;
float ldr;
uint8_t wetness;
float digitalTemperature;
float digitalHumidity;
float UVvalue;
float radiation;
float dendrometer;
float pt1000Temperature;
float watermark;
float anemometer;
float pluviometer1;
float pluviometer2;
float pluviometer3;
uint8_t vane;

// variable to store the number of pending pulses
int pendingPulses;

void setup() 
{
  USB.ON();
  USB.println(F("Frame Utility Example for Agriculture"));
  
  RTC.ON();
  
  // Turn on the sensor board
  SensorAgrv20.ON();
  
  // Set the Waspmote ID
  frame.setID(node_ID); 
}

void loop()
{
  /////////////////////////////////////////////
  // 1. Enter sleep mode
  /////////////////////////////////////////////
  SensorAgrv20.sleepAgr("00:00:00:00", RTC_ABSOLUTE, RTC_ALM1_MODE5, SOCKET0_OFF, SENS_AGR_PLUVIOMETER);


  /////////////////////////////////////////////
  // 2 Check interruptions
  /////////////////////////////////////////////
  //Check pluviometer interruption
  if( intFlag & PLV_INT)
  {
    USB.println(F("+++ PLV interruption +++"));

    pendingPulses = intArray[PLV_POS];

    USB.print(F("Number of pending pulses:"));
    USB.println( pendingPulses );

    for(int i=0 ; i<pendingPulses; i++)
    {
      // Enter pulse information inside class structure
      SensorAgrv20.storePulse();

      // decrease number of pulses
      intArray[PLV_POS]--;
    }

    // Clear flag
    intFlag &= ~(PLV_INT); 
  }
  
  //Check RTC interruption
  if(intFlag & RTC_INT)
  {
    USB.println(F("+++ RTC interruption +++"));
    
    // switch on sensor board
    SensorAgrv20.ON();
    
    RTC.ON();
    USB.print(F("Time:"));
    USB.println(RTC.getTime());        

    // measure sensors
    measureSensors();

    // Clear flag
    intFlag &= ~(RTC_INT); 
  }  
}

void measureSensors()
{  
  
  ///////////////////////////////////////////
  // 3. Turn on the sensors
  /////////////////////////////////////////// 

  // Power on the temperature sensor
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_TEMPERATURE);
  // Power on the humidity sensor
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_HUMIDITY);
  // Power on the pressure sensor
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_PRESSURE);
  // Power on the LDR sensor
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_LDR);
  // Power on the leaf wetness sensor
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_LEAF_WETNESS);
  // Power on Sensirion
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_SENSIRION);
  // Power on the ultraviolet sensor
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_RADIATION);
  // Power on the dendrometer sensor
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_DENDROMETER);
  // Power on the PT1000 sensor
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_PT1000);
  // Power on the watermark sensor
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_WATERMARK_1);
  // Power on the weather station sensor
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_ANEMOMETER);
  
  delay(100);


  ///////////////////////////////////////////
  // 4. Read sensors
  ///////////////////////////////////////////  
  
  //It takes several minutes to read all sensors

  // Read the temperature sensor 
  temperature = SensorAgrv20.readValue(SENS_AGR_TEMPERATURE);
  // Read the humidity sensor
  humidity = SensorAgrv20.readValue(SENS_AGR_HUMIDITY);
  // Read the pressure sensor
  pressure = SensorAgrv20.readValue(SENS_AGR_PRESSURE);
  // Read the LDR sensor 
  ldr = SensorAgrv20.readValue(SENS_AGR_LDR);
  // Read the leaf wetness sensor 
  wetness = SensorAgrv20.readValue(SENS_AGR_LEAF_WETNESS);
  // Read the digital temperature sensor 
  digitalTemperature = SensorAgrv20.readValue(SENS_AGR_SENSIRION, SENSIRION_TEMP);
  // Read the digital humidity sensor 
  digitalHumidity = SensorAgrv20.readValue(SENS_AGR_SENSIRION, SENSIRION_HUM);
  // Read the ultraviolet sensor 
  UVvalue = SensorAgrv20.readValue(SENS_AGR_RADIATION);
  // Conversion from voltage into umol·m-2·s-1
  radiation = UVvalue / 0.0002;
  // Read the dendrometer sensor 
  dendrometer = SensorAgrv20.readValue(SENS_AGR_DENDROMETER);
  // Read the PT1000 sensor 
  pt1000Temperature = SensorAgrv20.readValue(SENS_AGR_PT1000);
  // Read the watermark sensor 
  watermark = SensorAgrv20.readValue(SENS_AGR_WATERMARK_1);
  // Read the anemometer sensor 
  anemometer = SensorAgrv20.readValue(SENS_AGR_ANEMOMETER);
  // Read the pluviometer sensor 
  pluviometer1 = SensorAgrv20.readPluviometerCurrent();
  pluviometer2 = SensorAgrv20.readPluviometerHour();
  pluviometer3 = SensorAgrv20.readPluviometerDay();
  // Read the vane sensor 
  vane = SensorAgrv20.readValue(SENS_AGR_VANE);


  ///////////////////////////////////////////
  // 5. Turn off the sensors
  /////////////////////////////////////////// 

  // Power off the temperature sensor
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_TEMPERATURE);
  // Power off the humidity sensor
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_HUMIDITY);
  // Power off the pressure sensor
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_PRESSURE);
  // Power off the LDR sensor
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_LDR);
  // Power off the leaf wetness sensor
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_LEAF_WETNESS);
  // Power off Sensirion
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_SENSIRION);
  // Power off the ultraviolet sensor
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_RADIATION);
  // Power off the dendrometer sensor
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_DENDROMETER);
  // Power off the PT1000 sensor
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_PT1000);
  // Power off the watermark sensor
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_WATERMARK_1);
  // Power off the weather station sensor
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_ANEMOMETER);


  ///////////////////////////////////////////
  // 6. Create ASCII frame
  /////////////////////////////////////////// 

  // Create new frame (ASCII)
  frame.createFrame(ASCII);

  // Add temperature
  frame.addSensor(SENSOR_TCA, temperature);
  // Add humidity
  frame.addSensor(SENSOR_HUMA, humidity);
  // Add pressure
  frame.addSensor(SENSOR_PA, pressure);
  // Add luminosity
  frame.addSensor(SENSOR_LUM, ldr);
  // Add wetness
  frame.addSensor(SENSOR_LW, wetness);
  // Add digital temperature
  frame.addSensor(SENSOR_TCB, digitalTemperature);
  // Add digital humidity
  frame.addSensor(SENSOR_HUMB, digitalHumidity);
  // Add radiation
  frame.addSensor(SENSOR_UV, radiation);
  // Add dendrometer
  frame.addSensor(SENSOR_TD, dendrometer);
  // Add PT1000
  frame.addSensor(SENSOR_SOILT, pt1000Temperature);
  // Add watermark
  frame.addSensor(SENSOR_HUMB, watermark);
  // Add pluviometer value
  frame.addSensor( SENSOR_PLV1, pluviometer1 );
  // Add pluviometer value
  frame.addSensor( SENSOR_PLV2, pluviometer2 );
  // Add pluviometer value
  frame.addSensor( SENSOR_PLV3, pluviometer3 );
  // Add anemometer value
  frame.addSensor( SENSOR_ANE, anemometer );
  // Add pluviometer value
  frame.addSensor( SENSOR_WV, vane );
  
  // Show the frame
  frame.showFrame();

  //wait 2 seconds
  delay(2000);
}

