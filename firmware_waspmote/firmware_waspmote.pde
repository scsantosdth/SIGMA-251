#include <WaspSensorAgr_v20.h>
#include <WaspXBee802.h>

char DEST_ADDR[] = "0001";
char payload[100];

void setup() {
  USB.ON();
  USB.println(F("Inicio - SHT75 + SR11-TR + Watermark1"));
  
  SensorAgrv20.ON();
  
  // Apagar el LDR para que no interfiera en ANALOG7
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_LDR);
  pinMode(DIGITAL5, OUTPUT);
  digitalWrite(DIGITAL5, LOW);
  
  xbee802.ON();
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
  USB.print(F("Bateria (%): ")); USB.println(battery_level);
  USB.println(F("----------------"));

  // --- Construir payload: el dashboard recibe este formato por Web Serial ---
  char tempStr[16], humStr[16], radStr[16], wmStr[16], batteryStr[4];
  dtostrf(temperature, 6, 2, tempStr);
  dtostrf(humidity, 6, 2, humStr);
  dtostrf(irradiance, 6, 2, radStr);
  dtostrf(watermark_freq, 6, 2, wmStr);
  itoa(battery_level, batteryStr, 10);
  // El salto de linea es el delimitador de trama para el XBee receptor. Sin
  // este separador, dos transmisiones consecutivas pueden quedar pegadas en
  // el buffer serie del navegador y una de ellas se pierde.
  sprintf(payload, "T:%s,H:%s,R:%s,W:%s,B:%s\n", tempStr, humStr, radStr, wmStr, batteryStr);

  // --- Enviar por XBee ---
  int error = xbee802.send(DEST_ADDR, payload);
  if (error == 0) {
    USB.print(F("Datos enviados: ")); USB.println(payload);
  } else {
    USB.print(F("Error enviar: ")); USB.println(error);
  }

  delay(5000);
}
