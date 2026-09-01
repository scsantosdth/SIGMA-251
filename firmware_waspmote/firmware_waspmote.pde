#include <WaspSensorAgr_v20.h>
#include <WaspXBee802.h>
#include <WaspSD.h>
#include <WaspRTC.h>

char DEST_ADDR[] = "0001";
char payload[120];
bool sdReady = false;
bool syncActive = false;
char syncAck[] = "SYNC_ACK\n";
char syncBegin[] = "SYNC_BEGIN\n";
char syncEnd[] = "SYNC_END\n";
char syncError[] = "SYNC_ERROR\n";
const unsigned long MEASUREMENT_INTERVAL_MS = 30000UL;

void handleSyncRequest();

void sendAllSdRecords() {
  uint32_t lineNumber = 0;
  uint32_t recordsSent = 0;

  while (true) {
    SD.buffer[0] = '\0';
    char* lineRead = SD.catln("LOG.TXT", lineNumber, 1);
    if (lineRead == NULL || lineRead[0] == '\0') break;
    lineNumber++;

    char record[180];
    snprintf(record, sizeof(record), "SD_RECORD:%s\n", SD.buffer);
    uint8_t sendError = 1;
    for (uint8_t attempt = 0; attempt < 3; attempt++) {
      sendError = xbee802.send(DEST_ADDR, record);
      if (sendError == 0) break;
      delay(100);
    }

    if (sendError != 0) {
      USB.print(F("Error enviando registro SD: "));
      USB.println(sendError);
      syncActive = false;
      xbee802.send(DEST_ADDR, syncError);
      return;
    }

    recordsSent++;
    delay(250);
  }

  USB.print(F("Sincronizacion SD terminada. Registros enviados: "));
  USB.println((unsigned long)recordsSent);
  syncActive = false;
  delay(200);
  xbee802.send(DEST_ADDR, syncEnd);
}

bool isValidAirReading(float temperature, float humidity) {
  return temperature >= -40.0 && temperature <= 80.0 &&
         humidity >= 0.0 && humidity <= 100.0;
}

void waitForNextMeasurement() {
  unsigned long elapsed = 0;
  while (elapsed < MEASUREMENT_INTERVAL_MS) {
    handleSyncRequest();
    delay(100);
    elapsed += 100;
  }
}

void handleSyncRequest() {
  if (xbee802.available() <= 0) return;

  xbee802.treatData();
  if (xbee802.error_RX) return;

  while (xbee802.pos > 0) {
    char* received = (char*)xbee802.packet_finished[xbee802.pos - 1]->data;
    bool isSyncStart = (strncmp(received, "SYNC_SD", 7) == 0) ||
                       (strncmp(received, "YNC_SD", 6) == 0);
    USB.print(F("Comando XBee recibido: "));
    USB.println(received);

    if (isSyncStart && !syncActive && sdReady) {
      syncActive = true;
      xbee802.send(DEST_ADDR, syncAck);
      delay(100);
      xbee802.send(DEST_ADDR, syncBegin);
      delay(100);
      sendAllSdRecords();
    }

    free(xbee802.packet_finished[xbee802.pos - 1]);
    xbee802.packet_finished[xbee802.pos - 1] = NULL;
    xbee802.pos--;
  }
}

void buildTimestamp(char* timestamp) {
  RTC.getTime();
  snprintf(timestamp, 13, "%02u%02u%02u%02u%02u%02u",
           RTC.year, RTC.month, RTC.date, RTC.hour, RTC.minute, RTC.second);
}

void setup() {
  USB.ON();
  USB.println(F("Inicio - SHT75 + SR11-TR + Watermark1"));
  
  SensorAgrv20.ON();
  
  // Apagar el LDR para que no interfiera en ANALOG7
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_LDR);
  pinMode(DIGITAL5, OUTPUT);
  digitalWrite(DIGITAL5, LOW);

  RTC.ON();

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
  delay(200);
}

void loop() {
  handleSyncRequest();

  // --- Humedad y temperatura (SHT75 Sensirion) ---
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_SENSIRION);
  delay(100);
  float temperature = SensorAgrv20.readValue(SENS_AGR_SENSIRION, SENSIRION_TEMP);
  float humidity    = SensorAgrv20.readValue(SENS_AGR_SENSIRION, SENSIRION_HUM);
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_SENSIRION);

  // Una lectura negativa de humedad indica un fallo/transitorio del sensor.
  // Reintentar evita guardar y transmitir datos imposibles.
  bool validAirReading = isValidAirReading(temperature, humidity);
  for (uint8_t attempt = 1; attempt < 3 && !validAirReading; attempt++) {
    delay(100);
    SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_SENSIRION);
    delay(100);
    temperature = SensorAgrv20.readValue(SENS_AGR_SENSIRION, SENSIRION_TEMP);
    humidity = SensorAgrv20.readValue(SENS_AGR_SENSIRION, SENSIRION_HUM);
    SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_SENSIRION);
    validAirReading = isValidAirReading(temperature, humidity);
  }

  if (!validAirReading) {
    USB.println(F("Lectura SHT75 invalida; no se guarda ni se envia"));
    waitForNextMeasurement();
    return;
  }

  // --- Radiación Solar SR11-TR (ANALOG7) ---
  int raw = analogRead(ANALOG7);
  float v_rad = (raw * 3.3) / 1023.0;
  
  // Offset calibrado a 0.030V (para que en reposo dé 0.00 W/m²)
  float offset = 0.030;
  float irradiance = (v_rad - offset) * 10000.0;
  if (irradiance < 0) irradiance = 0;

  // --- Humedad Suelo (Watermark 1) ---
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_WATERMARK_1);
  delay(100);
  pinMode(DIGITAL3, OUTPUT);
  digitalWrite(DIGITAL3, LOW);
  delay(50);
  float watermark_freq = SensorAgrv20.readValue(SENS_AGR_WATERMARK_1);
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_WATERMARK_1);

  // El API de Waspmote devuelve el nivel de bateria como porcentaje (0-100).
  uint8_t battery_level = PWR.getBatteryLevel();

  USB.println(F("---- Datos ----"));
  USB.print(F("RAW: ")); USB.println(raw);
  USB.print(F("V_rad (V): ")); USB.println(v_rad);
  USB.print(F("Temperatura (C): ")); USB.println(temperature);
  USB.print(F("Humedad (%RH): ")); USB.println(humidity);
  USB.print(F("Radiacion (W/m2): ")); USB.println(irradiance);
  USB.print(F("Watermark1 (Hz): ")); USB.println(watermark_freq);
  USB.print(F("Bateria (%): ")); USB.println((int) battery_level);
  USB.println(F("----------------"));

  // --- Construir payload: el dashboard recibe este formato por Web Serial ---
  char tempStr[16], humStr[16], radStr[16], wmStr[16], batteryStr[4];
  char timestamp[13];
  dtostrf(temperature, 6, 2, tempStr);
  dtostrf(humidity, 6, 2, humStr);
  dtostrf(irradiance, 6, 2, radStr);
  dtostrf(watermark_freq, 6, 2, wmStr);
  itoa(battery_level, batteryStr, 10);
  // El salto de linea es el delimitador de trama para el XBee receptor. Sin
  // este separador, dos transmisiones consecutivas pueden quedar pegadas en
  // el buffer serie del navegador y una de ellas se pierde.
  sprintf(payload, "T:%s,H:%s,R:%s,W:%s,B:%s", tempStr, humStr, radStr, wmStr, batteryStr);

  // Registro historico permanente. Nunca se elimina automaticamente,
  // aunque el envio por XBee sea exitoso.
  buildTimestamp(timestamp);
  if (sdReady) {
    char line[140];
    snprintf(line, sizeof(line), "TS:%s,%s", timestamp, payload);
    if (SD.appendln("LOG.TXT", line) == 1) {
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

  // Atender una peticion que haya llegado mientras se tomaban los sensores.
  handleSyncRequest();

  // Esperar 30 segundos entre mediciones sin dejar de escuchar el XBee.
  waitForNextMeasurement();
}
