const SENSOR_PATTERN_WITH_BATTERY = /T:\s*([\d.-]+),\s*H:\s*([\d.-]+),\s*R:\s*([\d.-]+),\s*W:\s*([\d.-]+),\s*B:\s*([\d.-]+)/i;
const SENSOR_PATTERN = /T:\s*([\d.-]+),\s*H:\s*([\d.-]+),\s*R:\s*([\d.-]+),\s*W:\s*([\d.-]+)/i;
const SENSOR_PATTERN_WITHOUT_WATERMARK = /T:\s*([\d.-]+),\s*H:\s*([\d.-]+),\s*R:\s*([\d.-]+),\s*B:\s*([\d.-]+)/i;
const SD_RECORD_PATTERN = /^SD_RECORD:\s*(.*)$/i;

export const WEB_SERIAL_BAUD_RATE = 115200;

export const isWebSerialSupported = () =>
  typeof navigator !== 'undefined' && 'serial' in navigator;

export const convertWatermarkHzToCbar = (watermarkHz) => {
  const frequency = Number(watermarkHz);
  if (!Number.isFinite(frequency) || frequency <= 0) return null;

  const clamped = Math.max(300, Math.min(7600, frequency));
  const denominator = (2.8875 * clamped) - 137.5;
  if (denominator === 0) return null;

  const tensionCbar = (150940 - (19.74 * clamped)) / denominator;
  return Math.max(0, Math.min(200, tensionCbar));
};

const round = (value, decimals) => {
  const factor = 10 ** decimals;
  return Math.round(Number(value) * factor) / factor;
};

const isValidSensorRange = ({ temperatura, humedad, radiacion_solar, watermark, bateria }) => {
  const batteryOk = bateria === null || (bateria >= 0 && bateria <= 100);
  const watermarkOk = watermark === null || (watermark >= 0 && watermark <= 20000);

  return (
    temperatura >= -40 &&
    temperatura <= 80 &&
    humedad >= 0 &&
    humedad <= 100 &&
    radiacion_solar >= 0 &&
    radiacion_solar <= 1600 &&
    watermarkOk &&
    batteryOk
  );
};

export const parseXBeeLine = (rawLine) => {
  if (!rawLine || typeof rawLine !== 'string') return null;

  const line = rawLine.trim();
  const match = line.match(SENSOR_PATTERN_WITH_BATTERY)
    || line.match(SENSOR_PATTERN)
    || line.match(SENSOR_PATTERN_WITHOUT_WATERMARK);
  if (!match) return null;

  const temperatura = Number(match[1]);
  const humedad = Number(match[2]);
  const radiacion_solar = Number(match[3]);
  const hasWatermark = line.match(SENSOR_PATTERN_WITH_BATTERY) || line.match(SENSOR_PATTERN);
  const watermark = hasWatermark ? Number(match[4]) : null;
  const bateria = hasWatermark
    ? (match[5] === undefined ? null : Number(match[5]))
    : Number(match[4]);

  if ([temperatura, humedad, radiacion_solar].some(Number.isNaN)) return null;
  if (watermark !== null && Number.isNaN(watermark)) return null;
  if (bateria !== null && Number.isNaN(bateria)) return null;

  const sensorValues = { temperatura, humedad, radiacion_solar, watermark, bateria };
  if (!isValidSensorRange(sensorValues)) return null;

  const tensionCbar = watermark === null ? null : convertWatermarkHzToCbar(watermark);

  return {
    temperatura: round(temperatura, 2),
    humedad: round(humedad, 2),
    radiacion_solar: round(radiacion_solar, 2),
    // Se conserva la clave historica de la API; el valor ahora esta en cbar.
    humedad_suelo: tensionCbar === null ? null : round(tensionCbar, 1),
    bateria: bateria === null ? null : round(bateria, 1),
  };
};

const rtcTimestampToIso = (value) => {
  if (!/^\d{12}$/.test(value)) return null;

  const year = 2000 + Number(value.slice(0, 2));
  const month = Number(value.slice(2, 4));
  const day = Number(value.slice(4, 6));
  const hour = Number(value.slice(6, 8));
  const minute = Number(value.slice(8, 10));
  const second = Number(value.slice(10, 12));

  if (month < 1 || month > 12 || day < 1 || day > 31 || hour > 23 || minute > 59 || second > 59) {
    return null;
  }

  // El RTC del Waspmote se mantiene en hora de Colombia (UTC-05:00).
  return `${String(year).padStart(4, '0')}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}T${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}:${String(second).padStart(2, '0')}-05:00`;
};

export const parseSdRecordLine = (rawLine) => {
  if (!rawLine || typeof rawLine !== 'string') return null;

  const wrapper = rawLine.trim().match(SD_RECORD_PATTERN);
  if (!wrapper) return null;

  const record = wrapper[1].trim();
  const measurement = parseXBeeLine(record);
  const timestampMatch = record.match(/(?:^|,)TS:\s*(\d{12})(?:,|$)/i);
  const timestamp = timestampMatch ? rtcTimestampToIso(timestampMatch[1]) : null;

  if (!measurement || !timestamp) return null;

  return {
    ...measurement,
    timestamp,
    raw: record,
    source: 'sd',
  };
};
