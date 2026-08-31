#include <WaspSensorAgr_v20.h>
#include <WaspXBee802.h>
#include <WaspRTC.h>
#include <WaspSD.h>

char DEST_ADDR[] = "0001";
char payload[120];
bool sdReady = false;

void buildTimestamp(char* timestamp) {
  RTC.getTime();
  snprintf(timestamp, 13, "%02u%02u%02u%02u%02u%02u",
           RTC.year, RTC.month, RTC.date, RTC.hour, RTC.minute, RTC.second);
}

void setup() {
  USB.ON();
  USB.println(F("Inicio - SHT75 + SR11-TR (sin Watermark)"));
  
  SensorAgrv20.ON();
  
  // Apagar el LDR para que no interfiera en ANALOG7
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_LDR);
  pinMode(DIGITAL5, OUTPUT);
  digitalWrite(DIGITAL5, LOW);
  
  SD.ON();
  if (SD.flag == 0) {
    sdReady = true;
    USB.println(F("SD lista"));
    if (SD.getFileSize("LOG.TXT") < 0) {
      SD.create("LOG.TXT");
    }
  } else {
    USB.print(F("Error SD. Flag: ")); USB.println(SD.flag);
  }

  xbee802.ON();
  RTC.ON();
  delay(200);
}

void loop() {
  // --- Humedad y temperatura (SHT75 Sensirion) ---
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_SENSIRION);
  delay(100);
  float temperature = SensorAgrv20.readValue(SENS_AGR_SENSIRION, SENSIRION_TEMP);
  float humidity    = SensorAgrv20.readValue(SENS_AGR_SENSIRION, SENSIRION_HUM);
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_SENSIRION);

  // --- Radiación Solar SR11-TR (ANALOG7) ---
  int raw = analogRead(ANALOG7);
  float v_rad = (raw * 3.3) / 1023.0;
  float offset = 0.030;
  float irradiance = (v_rad - offset) * 10000.0;
  if (irradiance < 0) irradiance = 0;

  // Watermark esta desconectado. No se envia un valor fijo: 0 Hz se
  // convertiria en 100% de humedad de suelo y almacenaria un dato falso.

  // Batería
  uint8_t battery_level = PWR.getBatteryLevel();

  USB.println(F("---- Datos ----"));
  USB.print(F("RAW: ")); USB.println(raw);
  USB.print(F("V_rad (V): ")); USB.println(v_rad);
  USB.print(F("Temperatura (C): ")); USB.println(temperature);
  USB.print(F("Humedad (%RH): ")); USB.println(humidity);
  USB.print(F("Radiacion (W/m2): ")); USB.println(irradiance);
  USB.println(F("Watermark: no conectado"));
  USB.print(F("Bateria (%): ")); USB.println((int) battery_level);
  USB.println(F("----------------"));

  // --- Payload ---
  char tempStr[16], humStr[16], radStr[16], batteryStr[4], timestamp[13];
  dtostrf(temperature, 6, 2, tempStr);
  dtostrf(humidity, 6, 2, humStr);
  dtostrf(irradiance, 6, 2, radStr);
  itoa(battery_level, batteryStr, 10);
  buildTimestamp(timestamp);
  
  snprintf(payload, sizeof(payload), "T:%s,H:%s,R:%s,B:%s,TS:%s,O:0",
           tempStr, humStr, radStr, batteryStr, timestamp);

  // Registro historico permanente. Nunca se elimina automaticamente,
  // aunque el envio por XBee sea exitoso.
  if (sdReady) {
    if (SD.appendln("LOG.TXT", payload) == 1) {
      USB.println(F("Medicion guardada en SD"));
    } else {
      USB.print(F("Error guardando en SD. Flag: ")); USB.println(SD.flag);
    }
  }

  // El salto de linea solo se agrega a la trama transmitida.
  strcat(payload, "\n");

  // --- Enviar por XBee ---
  int error = xbee802.send(DEST_ADDR, payload);
  if (error == 0) {
    USB.print(F("Datos enviados: ")); USB.println(payload);
  } else {
    USB.print(F("Error enviar: ")); USB.println(error);
  }

  delay(5000);
}

