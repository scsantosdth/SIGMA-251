// src/utils/umbrales.jsx
// Umbrales de alerta configurados por el usuario. Se guardan SOLO en el
// navegador (localStorage); nunca se escriben en la base de datos.

const UMBRALES_KEY = 'sigma_umbrales';
const UMBRALES_EVENT = 'sigma-umbrales-updated';

export const SENSORES_UMBRALES = {
  temperatura: {
    label: 'Temperatura',
    unidad: '°C',
    color: '#ff6b6b',
    ayuda: 'Rango óptimo de temperatura del ambiente.',
  },
  humedad: {
    label: 'Humedad ambiental',
    unidad: '%',
    color: '#4ecdc4',
    ayuda: 'Rango óptimo de humedad relativa del ambiente.',
  },
  radiacion_solar: {
    label: 'Radiación solar',
    unidad: 'W/m²',
    color: '#ffd93d',
    ayuda: 'Rango óptimo de radiación solar.',
  },
  humedad_suelo: {
    label: 'Tensión agua suelo',
    unidad: 'cbar',
    color: '#6c5ce7',
    ayuda: 'Tensión de agua del suelo (cbar). Mayor = suelo más seco.',
  },
};

export const UMBRALES_DEFAULT = {
  temperatura: { min: 10, max: 35 },
  humedad: { min: 40, max: 80 },
  radiacion_solar: { min: 0, max: 1200 },
  humedad_suelo: { min: 10, max: 80 },
};

const isFiniteNumber = (value) => Number.isFinite(Number(value));

const parseUmbral = (value) => {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
};

const mergeUmbrales = (stored) => {
  const merged = {};
  Object.keys(UMBRALES_DEFAULT).forEach((key) => {
    const def = UMBRALES_DEFAULT[key];
    const storedItem = stored?.[key] || {};
    const min = parseUmbral(storedItem.min);
    const max = parseUmbral(storedItem.max);
    merged[key] = {
      min: min !== null ? min : def.min,
      max: max !== null ? max : def.max,
    };
  });
  return merged;
};

export const getUmbrales = () => {
  try {
    const raw = window.localStorage.getItem(UMBRALES_KEY);
    const stored = raw ? JSON.parse(raw) : null;
    return mergeUmbrales(stored);
  } catch {
    return mergeUmbrales(null);
  }
};

export const setUmbrales = (umbrales) => {
  try {
    window.localStorage.setItem(UMBRALES_KEY, JSON.stringify(umbrales || {}));
  } catch {
    return false;
  }
  if (typeof window !== 'undefined') {
    window.dispatchEvent(new CustomEvent(UMBRALES_EVENT));
  }
  return true;
};

export const validarUmbrales = (umbrales) => {
  const errores = {};
  Object.keys(SENSORES_UMBRALES).forEach((key) => {
    const item = umbrales?.[key];
    if (!item) {
      errores[key] = 'Faltan los valores';
      return;
    }
    const min = parseUmbral(item.min);
    const max = parseUmbral(item.max);
    if (min === null || !isFiniteNumber(item.min)) {
      errores[key] = 'El mínimo debe ser un número';
      return;
    }
    if (max === null || !isFiniteNumber(item.max)) {
      errores[key] = 'El máximo debe ser un número';
      return;
    }
    if (min >= max) {
      errores[key] = 'El mínimo debe ser menor que el máximo';
    }
  });
  return errores;
};

export const evaluarAlertas = (sensorData, umbrales) => {
  const resultados = [];
  Object.keys(SENSORES_UMBRALES).forEach((key) => {
    const reading = sensorData?.[key];
    const valor = reading?.valor ?? reading ?? null;
    const umbral = umbrales?.[key];
    let estado = 'sin-datos';
    if (Number.isFinite(Number(valor)) && umbral) {
      const numero = Number(valor);
      estado = numero < umbral.min ? 'bajo' : numero > umbral.max ? 'alto' : 'ok';
    }
    resultados.push({
      key,
      ...SENSORES_UMBRALES[key],
      valor: Number.isFinite(Number(valor)) ? Number(valor) : null,
      timestamp: reading?.timestamp || null,
      estado,
      umbral: umbral || null,
    });
  });
  return resultados;
};

const parseTimestampMs = (timestamp) => {
  if (!timestamp) return null;
  const hasTimezone = /(?:Z|[+-]\d{2}:?\d{2})$/i.test(String(timestamp));
  const date = new Date(hasTimezone ? timestamp : `${timestamp}Z`);
  return Number.isNaN(date.getTime()) ? null : date.getTime();
};

export const formatHoraBogota = (timestamp) => {
  if (!timestamp) return '—';
  const date = new Date(timestamp);
  if (Number.isNaN(date.getTime())) return '—';
  return date.toLocaleTimeString('es-CO', {
    hour: '2-digit',
    minute: '2-digit',
    timeZone: 'America/Bogota',
  });
};

// Calcula el resumen diario (min/max + tiempo fuera de rango) a partir de las
// filas por sensor que devuelve la API (cada fila: {sensor, valor, timestamp}).
// Cada lectura se considera vigente desde su timestamp hasta la siguiente; la
// última lectura se asume vigente durante el último intervalo observado.
export const computarResumenDiario = (registros, umbrales) => {
  const porSensor = {};

  (registros || []).forEach((record) => {
    if (!record || !record.sensor) return;
    const ts = parseTimestampMs(record.timestamp);
    if (ts === null) return;
    if (!porSensor[record.sensor]) porSensor[record.sensor] = [];
    porSensor[record.sensor].push({ valor: Number(record.valor), ts });
  });

  return Object.keys(SENSORES_UMBRALES).map((key) => {
    const base = { sensor: key, ...SENSORES_UMBRALES[key] };
    const samples = (porSensor[key] || []).sort((a, b) => a.ts - b.ts);
    const umbral = umbrales?.[key];

    if (samples.length === 0) {
      return {
        ...base,
        muestras: 0,
        min: null,
        min_timestamp: null,
        max: null,
        max_timestamp: null,
        minutos_bajo: null,
        minutos_dentro: null,
        minutos_alto: null,
      };
    }

    let minSample = samples[0];
    let maxSample = samples[0];
    samples.forEach((sample) => {
      if (sample.valor < minSample.valor) minSample = sample;
      if (sample.valor > maxSample.valor) maxSample = sample;
    });

    let minutosBajo = 0;
    let minutosDentro = 0;
    let minutosAlto = 0;
    let lastGap = null;

    const aplicarUmbrales = (valor, duracion) => {
      if (valor < umbral.min) minutosBajo += duracion;
      else if (valor > umbral.max) minutosAlto += duracion;
      else minutosDentro += duracion;
    };

    const calculaDuraciones = () => {
      for (let i = 0; i < samples.length; i += 1) {
        const gapMs = i < samples.length - 1 ? samples[i + 1].ts - samples[i].ts : lastGap;
        if (i < samples.length - 1) lastGap = gapMs;
        const duracionMin = Number.isFinite(gapMs) ? gapMs / 60000 : 0;
        if (duracionMin > 0) aplicarUmbrales(samples[i].valor, duracionMin);
      }
    };

    if (umbral) {
      calculaDuraciones();
    } else {
      minutosBajo = null;
      minutosDentro = null;
      minutosAlto = null;
    }

    return {
      ...base,
      muestras: samples.length,
      min: minSample.valor,
      min_timestamp: minSample.ts,
      max: maxSample.valor,
      max_timestamp: maxSample.ts,
      minutos_bajo: minutosBajo,
      minutos_dentro: minutosDentro,
      minutos_alto: minutosAlto,
    };
  });
};