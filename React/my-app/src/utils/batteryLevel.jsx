// src/utils/batteryLevel.jsx
// Fuente unica de verdad para el nivel de bateria (color, etiqueta y alertas).

export const BATTERY_CRITICAL_THRESHOLD = 20;
export const BATTERY_WARNING_THRESHOLD = 30;
export const BATTERY_OPTIMAL_THRESHOLD = 70;

// Acepta tanto un numero como el objeto { bateria } que entrega la API.
export const getBatteryValue = (data) => {
  if (typeof data === 'number') return Number.isFinite(data) ? data : 0;
  const value = data?.bateria;
  return typeof value === 'number' && Number.isFinite(value) ? value : 0;
};

export const getBatteryLevel = (data) => {
  const value = Math.min(100, Math.max(0, getBatteryValue(data)));

  if (value < BATTERY_CRITICAL_THRESHOLD) {
    return { value, level: 'critical', color: '#f44336', label: 'Critico' };
  }
  if (value < BATTERY_WARNING_THRESHOLD) {
    return { value, level: 'warning', color: '#ff9800', label: 'Bajo' };
  }
  if (value < BATTERY_OPTIMAL_THRESHOLD) {
    return { value, level: 'moderate', color: '#ff9800', label: 'Moderado' };
  }
  return { value, level: 'ok', color: '#4caf50', label: 'Optimo' };
};
