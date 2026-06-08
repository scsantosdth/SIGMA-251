#include <WaspSensorAgr_v20.h>
#include <WaspXBee802.h>

char DEST_ADDR[] = "0001";
char payload[100]; // Buffer más grande para 4 campos

void setup() {
  USB.ON();
  USB.println(F("Inicio - SHT75 + LDR + Watermark1"));
  
  SensorAgrv20.ON();
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

  // --- Luminosidad (LDR) - Valor amplificado ---
  float luminosity_raw = SensorAgrv20.readValue(SENS_AGR_LDR);
  float luminosity_amp = luminosity_raw * 100.0;

  // --- Humedad Suelo (Watermark 1) ---
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_WATERMARK_1);
  delay(100);
  
  // Configurar multiplexor para Watermarks (DIGITAL3 = LOW)
  pinMode(DIGITAL3, OUTPUT);
  digitalWrite(DIGITAL3, LOW);
  delay(50);
  
  float watermark_freq = SensorAgrv20.readValue(SENS_AGR_WATERMARK_1);
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_WATERMARK_1);

  // Mostrar por USB
  USB.print(F("Temperatura (C): ")); USB.println(temperature);
  USB.print(F("Humedad (%RH): ")); USB.println(humidity);
  USB.print(F("Luminosidad (AMP): ")); USB.println(luminosity_amp);
  USB.print(F("Watermark1 (Hz): ")); USB.println(watermark_freq);

  // Construir payload con 4 campos
  char tempStr[16], humStr[16], lumStr[16], wmStr[16];
  dtostrf(temperature, 6, 2, tempStr);
  dtostrf(humidity, 6, 2, humStr);
  dtostrf(luminosity_amp, 6, 2, lumStr);
  dtostrf(watermark_freq, 6, 2, wmStr);
  sprintf(payload, "T:%s,H:%s,L:%s,W:%s", tempStr, humStr, lumStr, wmStr);

  // Enviar
  int error = xbee802.send(DEST_ADDR, payload);
  if (error == 0) {
    USB.print(F("Datos enviados: ")); USB.println(payload);
  } else {
    USB.print(F("Error enviar: ")); USB.println(error);
  }

  delay(5000);
}
