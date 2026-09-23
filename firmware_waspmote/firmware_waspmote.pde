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
// Limite opcional para la lectura de la SD: fecha YYMMDD hasta la cual se
// transmite (0 = sin limite, se lee toda la tarjeta).
uint32_t syncDateLimit = 0;
// Cooldown tras finalizar una sincronizacion: un SYNC_SD que quedo en cola en
// el modulo XBee durante la rafaga (o un doble envio del navegador) se procesa
// justo despues de SYNC_END y re-dispararia la lectura entera. Con este margen
// se ignora hasta que pase el tiempo indicado.
const unsigned long SYNC_COOLDOWN_MS = 3000UL;
unsigned long lastSyncEndMillis = 0;

void handleSyncRequest();

// Convierte los primeros 6 digitos tras "TS:" de una linea del LOG a YYMMDD.
uint32_t extractLineDate(const char* line) {
  const char* ts = strstr(line, "TS:");
  if (ts == NULL) return 0;
  ts += 3;
  uint32_t value = 0;
  for (uint8_t i = 0; i < 6; i++) {
    char c = ts[i];
    if (c < '0' || c > '9') return 0;
    value = value * 10 + (uint32_t)(c - '0');
  }
  return value;
}

// Parsea el sufijo opcional ":YYMMDD" del comando SYNC_SD:YYMMDD.
uint32_t parseRequestedSyncDate(const char* command) {
  const char* sep = strchr(command, ':');
  if (sep == NULL) return 0;
  sep++;
  uint32_t value = 0;
  for (uint8_t i = 0; i < 6; i++) {
    char c = sep[i];
    if (c < '0' || c > '9') return 0;
    value = value * 10 + (uint32_t)(c - '0');
  }
  return value;
}

void sendAllSdRecords() {
  uint32_t lineNumber = 0;
  uint32_t recordsSent = 0;
  uint32_t recordsFailed = 0;

  // Pequena pausa para que el modulo asiente la red tras recibir el comando
  // y evitar fallos en los primeros envios de la rafaga.
  delay(200);

  while (true) {
    SD.buffer[0] = '\0';
    char* lineRead = SD.catln("LOG.TXT", lineNumber, 1);
    if (lineRead == NULL || lineRead[0] == '\0') break;
    lineNumber++;

    // LOG.TXT es cronologico: si la fecha pedida se indica, se detiene la
    // transmision al encontrar el primer registro posterior a dicha fecha.
    if (syncDateLimit > 0) {
      uint32_t lineDate = extractLineDate(SD.buffer);
      if (lineDate > 0 && lineDate > syncDateLimit) break;
    }

    char record[180];
    snprintf(record, sizeof(record), "SD_RECORD:%s\n", SD.buffer);
    uint8_t sendError = 1;
    for (uint8_t attempt = 0; attempt < 5; attempt++) {
      sendError = xbee802.send(DEST_ADDR, record);
      if (sendError == 0) break;
      delay(150);
    }

    if (sendError != 0) {
      // Un fallo de envio NO aborta toda la sincronizacion: se cuenta, se
      // omite el registro y se continua con el siguiente para entregar todo
      // lo posible al receptor.
      recordsFailed++;
      USB.print(F("Registro SD omitido (fallo de envio "));
      USB.print((int)sendError);
      USB.println(F(")"));
      delay(150);
      continue;
    }

    recordsSent++;
    delay(300);
  }

  USB.print(F("Sincronizacion SD finalizada. Enviados: "));
  USB.print((unsigned long)recordsSent);
  USB.print(F("; omitidos: "));
  USB.println((unsigned long)recordsFailed);
  syncActive = false;
  lastSyncEndMillis = millis();
  delay(200);
  if (recordsSent == 0 && recordsFailed > 0) {
    xbee802.send(DEST_ADDR, syncError);
  } else {
    xbee802.send(DEST_ADDR, syncEnd);
  }
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

    if (isSyncStart && !syncActive && sdReady &&
        (millis() - lastSyncEndMillis >= SYNC_COOLDOWN_MS)) {
      syncActive = true;
      syncDateLimit = parseRequestedSyncDate(received);
      xbee802.send(DEST_ADDR, syncAck);
      delay(150);
      // Reintentar SYNC_BEGIN: si el primer envio se pierde el receptor
      // (navegador) quedaria esperando sin saber que comenzo la sincronizacion.
      for (uint8_t attempt = 0; attempt < 3; attempt++) {
        if (xbee802.send(DEST_ADDR, syncBegin) == 0) break;
        delay(150);
      }
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
  lastSyncEndMillis = millis();
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

  // --- Tension de Agua del Suelo (Watermark 1) ---
  // readValue() entrega la frecuencia del sensor en Hz. Se conserva cruda
  // en W y la conversion a TA (cbar), usando la Ecuacion 4, se realiza en
  // los receptores para que el firmware siga siendo independiente de la UI.
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
  USB.print(F("Watermark1 frecuencia (Hz): ")); USB.println(watermark_freq);
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
