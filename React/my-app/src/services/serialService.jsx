const SENSOR_PATTERN_WITH_BATTERY = /T:\s*([\d.-]+),\s*H:\s*([\d.-]+),\s*R:\s*([\d.-]+),\s*W:\s*([\d.-]+),\s*B:\s*([\d.-]+)/i;
const SENSOR_PATTERN = /T:\s*([\d.-]+),\s*H:\s*([\d.-]+),\s*R:\s*([\d.-]+),\s*W:\s*([\d.-]+)/i;

export const WEB_SERIAL_BAUD_RATE = 115200;

export const isWebSerialSupported = () =>
  typeof navigator !== 'undefined' && 'serial' in navigator;

export const convertWatermarkToPercentage = (watermarkHz) => {
  const clamped = Math.max(50, Math.min(10000, Number(watermarkHz)));
  const percentage = 100.0 - ((clamped - 50) / 99.5) * 100.0;
  return Math.max(0, Math.min(100, percentage));
};

const round = (value, decimals) => {
  const factor = 10 ** decimals;
  return Math.round(Number(value) * factor) / factor;
};

const isValidSensorRange = ({ temperatura, humedad, radiacion_solar, watermark, bateria }) => {
  const batteryOk = bateria === null || (bateria >= 0 && bateria <= 100);

  return (
    temperatura >= -40 &&
    temperatura <= 80 &&
    humedad >= 0 &&
    humedad <= 100 &&
    radiacion_solar >= 0 &&
    radiacion_solar <= 1600 &&
    watermark >= 0 &&
    watermark <= 20000 &&
    batteryOk
  );
};

export const parseXBeeLine = (rawLine) => {
  if (!rawLine || typeof rawLine !== 'string') return null;

  const line = rawLine.trim();
  const match = line.match(SENSOR_PATTERN_WITH_BATTERY) || line.match(SENSOR_PATTERN);
  if (!match) return null;

  const temperatura = Number(match[1]);
  const humedad = Number(match[2]);
  const radiacion_solar = Number(match[3]);
  const watermark = Number(match[4]);
  const bateria = match[5] === undefined ? null : Number(match[5]);

  if ([temperatura, humedad, radiacion_solar, watermark].some(Number.isNaN)) return null;
  if (bateria !== null && Number.isNaN(bateria)) return null;

  const sensorValues = { temperatura, humedad, radiacion_solar, watermark, bateria };
  if (!isValidSensorRange(sensorValues)) return null;

  return {
    temperatura: round(temperatura, 2),
    humedad: round(humedad, 2),
    radiacion_solar: round(radiacion_solar, 2),
    humedad_suelo: round(convertWatermarkToPercentage(watermark), 1),
    bateria: bateria === null ? null : round(bateria, 1),
  };
};
