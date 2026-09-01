import { createContext, useContext, useState, useEffect, useCallback, useRef } from 'react';
import { api } from '../services/api.jsx';
import {
  saveMedicionOffline,
  getMedicionesOffline,
  markMedicionSynced,
  syncOfflineMediciones,
  isOnline,
  onConnectivityChange
} from '../services/offlineService';
import { useXBeeSerial } from './useXBeeSerial.jsx';

const SensorDataContext = createContext(null);
const LAST_CLOUD_SAMPLE_KEY = 'sigma_last_cloud_sample_at';
const CLOUD_INTERVAL_KEY = 'sigma_cloud_interval_minutes';

const getLastCloudSampleAt = () => {
  try {
    return Number(window.localStorage.getItem(LAST_CLOUD_SAMPLE_KEY)) || 0;
  } catch {
    return 0;
  }
};

const setLastCloudSampleAt = (timestamp) => {
  try {
    window.localStorage.setItem(LAST_CLOUD_SAMPLE_KEY, String(timestamp));
  } catch {
    // Si el almacenamiento no esta disponible, el flujo sigue funcionando en memoria.
  }
};

const getCloudIntervalMinutes = () => {
  try {
    return Number(window.localStorage.getItem(CLOUD_INTERVAL_KEY)) || 5;
  } catch {
    return 5;
  }
};

function useSensorData() {
  const [sensorData, setSensorData] = useState(null);
  const [batteryData, setBatteryData] = useState(null);
  const [historicalData, setHistoricalData] = useState(null);
  const [timeRange, setTimeRange] = useState(6);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [offline, setOffline] = useState(!isOnline());

  const sensorDataRef = useRef(sensorData);
  const batteryDataRef = useRef(batteryData);
  const historicalDataRef = useRef(historicalData);
  const serialConnectedRef = useRef(false);
  const cloudSyncIntervalRef = useRef(getCloudIntervalMinutes() * 60 * 1000);
  const lastCloudSyncScheduledRef = useRef(getLastCloudSampleAt());

  useEffect(() => {
    sensorDataRef.current = sensorData;
    batteryDataRef.current = batteryData;
    historicalDataRef.current = historicalData;
  }, [sensorData, batteryData, historicalData]);

  useEffect(() => {
    const setCloudInterval = (minutes, resetSchedule = false) => {
      const parsed = Number(minutes);
      if (Number.isFinite(parsed) && parsed > 0) {
        cloudSyncIntervalRef.current = parsed * 60 * 1000;
        try { window.localStorage.setItem(CLOUD_INTERVAL_KEY, String(parsed)); } catch {}
        if (resetSchedule) {
          lastCloudSyncScheduledRef.current = 0;
          setLastCloudSampleAt(0);
        }
      }
    };

    api.getAutoInterval().then((data) => setCloudInterval(data?.valor)).catch(() => {});
    const handleIntervalChange = (event) => setCloudInterval(event.detail, true);
    window.addEventListener('sigma-auto-interval-updated', handleIntervalChange);
    return () => window.removeEventListener('sigma-auto-interval-updated', handleIntervalChange);
  }, []);

  const unwrapApiData = (payload) => {
    if (!payload) return null;
    if (Object.prototype.hasOwnProperty.call(payload, 'data')) return payload.data;
    return payload;
  };

  const getHistoricalRecordKey = useCallback((record) => {
    if (!record) return null;

    if (record.sensor) {
      return [
        'sensor',
        record.sensor,
        record.timestamp || '',
        record.valor ?? '',
        record.calidad ?? ''
      ].join('|');
    }

    return [
      'snapshot',
      record.timestamp || '',
      record.temperatura ?? '',
      record.humedad ?? '',
      record.radiacion_solar ?? '',
      record.humedad_suelo ?? '',
      record.bateria ?? ''
    ].join('|');
  }, []);

  const mergeHistoricalData = useCallback((baseRecords, extraRecords) => {
    const base = Array.isArray(baseRecords) ? baseRecords : [];
    const extra = Array.isArray(extraRecords) ? extraRecords : [];

    const merged = new Map();
    [...base, ...extra].filter(Boolean).forEach((record) => {
      const key = getHistoricalRecordKey(record);
      if (!key) return;
      merged.set(key, record);
    });

    return Array.from(merged.values())
      .sort((a, b) => new Date(a.timestamp || 0) - new Date(b.timestamp || 0));
  }, [getHistoricalRecordKey]);

  const applyOfflineData = useCallback((records, baseHistory = historicalDataRef.current) => {
    if (!Array.isArray(records) || records.length === 0) return false;

    const latest = records[records.length - 1];
    const mergedHistory = mergeHistoricalData(baseHistory, records);
    setSensorData({
      temperatura: { valor: latest.temperatura, timestamp: latest.timestamp, calidad: latest.source || 'offline' },
      humedad: { valor: latest.humedad, timestamp: latest.timestamp, calidad: latest.source || 'offline' },
      humedad_suelo: { valor: latest.humedad_suelo, timestamp: latest.timestamp, calidad: latest.source || 'offline' },
      radiacion_solar: { valor: latest.radiacion_solar, timestamp: latest.timestamp, calidad: latest.source || 'offline' }
    });
    historicalDataRef.current = mergedHistory;
    setHistoricalData(mergedHistory);

    if (latest.bateria !== undefined && latest.bateria !== null) {
      setBatteryData({ bateria: latest.bateria, timestamp: latest.timestamp, offline: !latest.synced });
    }

    setError(null);
    setLoading(false);
    return true;
  }, [mergeHistoricalData]);

  const syncSingleSerialMeasurement = useCallback(async (record) => {
    if (!isOnline() || !api.isAuthenticated()) return false;

    try {
      await api.postWaspmoteMeasurement({
        temperatura: record.temperatura,
        humedad: record.humedad,
        radiacion_solar: record.radiacion_solar,
        humedad_suelo: record.humedad_suelo,
        timestamp: record.timestamp,
      });

      if (record.bateria !== undefined && record.bateria !== null) {
        await api.postWaspmoteBattery({
          dispositivo_id: 1,
          bateria: record.bateria,
          timestamp: record.timestamp,
        }).catch((syncError) => {
          console.warn('No se pudo sincronizar bateria:', syncError);
        });
      }

      await markMedicionSynced(record.id);
      return true;
    } catch (syncError) {
      console.warn('Medicion guardada localmente; se sincronizara luego:', syncError);
      return false;
    }
  }, []);

  const handleSerialMeasurement = useCallback(async (measurement) => {
    const timestamp = new Date().toISOString();
    const now = Date.now();
    const shouldSyncToCloud = now - lastCloudSyncScheduledRef.current >= cloudSyncIntervalRef.current;
    if (shouldSyncToCloud) {
      lastCloudSyncScheduledRef.current = now;
      setLastCloudSampleAt(now);
    }

    const record = {
      ...measurement,
      timestamp,
      id: Date.now(),
      source: 'web-serial',
      // Todas las lecturas quedan en IndexedDB; solo las del intervalo elegido
      // entran en la cola de Supabase.
      synced: !shouldSyncToCloud,
      cloudSync: shouldSyncToCloud,
    };

    if (shouldSyncToCloud) {
      // La grafica conserva solo las muestras del intervalo configurado.
      applyOfflineData([record], historicalDataRef.current);
    } else {
      // Las tarjetas siguen siendo tiempo real aunque la muestra no vaya a la grafica.
      setSensorData({
        temperatura: { valor: record.temperatura, timestamp, calidad: record.source },
        humedad: { valor: record.humedad, timestamp, calidad: record.source },
        humedad_suelo: { valor: record.humedad_suelo, timestamp, calidad: record.source },
        radiacion_solar: { valor: record.radiacion_solar, timestamp, calidad: record.source },
      });
      if (record.bateria !== undefined && record.bateria !== null) {
        setBatteryData({ bateria: record.bateria, timestamp, offline: false });
      }
      setError(null);
      setLoading(false);
    }

    const savedRecord = await saveMedicionOffline(record, { synced: !shouldSyncToCloud });
    if (!savedRecord || !shouldSyncToCloud) return;
    await syncSingleSerialMeasurement(savedRecord);
  }, [applyOfflineData, syncSingleSerialMeasurement]);

  const handleSerialControlMessage = useCallback((message) => {
    if (message?.type === 'sd-record') {
      console.info('Registro SD recibido; pendiente de sincronizacion:', message.record);

      if (isOnline() && api.isAuthenticated()) {
        api.postSdMeasurement({
          temperatura: message.record.temperatura,
          humedad: message.record.humedad,
          radiacion_solar: message.record.radiacion_solar,
          humedad_suelo: message.record.humedad_suelo,
          timestamp: message.record.timestamp,
        }).then((result) => {
          console.info('Resultado sincronizacion SD:', result);
        }).catch((syncError) => {
          console.error('No se pudo enviar el registro SD:', syncError);
        });
      }
    }
  }, []);

  const serial = useXBeeSerial(handleSerialMeasurement, handleSerialControlMessage);

  useEffect(() => {
    serialConnectedRef.current = serial.connected;
  }, [serial.connected]);

  const cacheOnlineMeasurement = useCallback((measurements, battery) => {
    if (!measurements || serialConnectedRef.current) return;

    const record = {
      temperatura: measurements.temperatura?.valor ?? measurements.temperatura ?? null,
      humedad: measurements.humedad?.valor ?? measurements.humedad ?? null,
      radiacion_solar: measurements.radiacion_solar?.valor ?? measurements.radiacion_solar ?? null,
      humedad_suelo: measurements.humedad_suelo?.valor ?? measurements.humedad_suelo ?? null,
      bateria: battery?.bateria ?? battery?.valor ?? battery?.level ?? null
    };

    saveMedicionOffline(record, { synced: true }).catch((storageError) => {
      console.error('Error guardando medicion en cache offline:', storageError);
    });
  }, []);

  const loadIndexedDBFallback = useCallback(async () => {
    try {
      const indexedData = (await getMedicionesOffline())
        .filter((record) => record.cloudSync === true);
      return applyOfflineData(indexedData, historicalDataRef.current);
    } catch {
      return false;
    }
  }, [applyOfflineData]);

  const loadLocalData = useCallback(async (hours = timeRange) => {
    if (serialConnectedRef.current) {
      setLoading(false);
      return;
    }

    try {
      const indexedLoaded = await loadIndexedDBFallback();
      if (!indexedLoaded) {
        setError('Conecta el XBee para recibir datos locales');
      }
    } finally {
      setLoading(false);
    }
  }, [applyOfflineData, loadIndexedDBFallback, timeRange]);

  const loadOnlineData = useCallback(async (hours = timeRange) => {
    if (serialConnectedRef.current) {
      setLoading(false);
      return;
    }

    if (!api.isAuthenticated()) {
      setError('No autenticado');
      setLoading(false);
      return;
    }

    if (!sensorDataRef.current && !batteryDataRef.current) {
      setLoading(true);
    }

    try {
      const results = await Promise.allSettled([
        api.getLatestMeasurements(),
        api.getBatteryStatus(),
        api.getHistoricalData(hours)
      ]);

      const [
        measurementsResult,
        batteryResult,
        historicalResult
      ] = results;
      const onlineResults = [measurementsResult, batteryResult, historicalResult];
      const failedOnlineResults = onlineResults.filter((result) => result.status === 'rejected');
      const allOnlineFailed = failedOnlineResults.length === onlineResults.length;
      if (allOnlineFailed) {
        setOffline(true);
        await loadLocalData(hours);
        return;
      } else if (offline) {
        setOffline(false);
      }

      if (measurementsResult.status === 'fulfilled') {
        const data = unwrapApiData(measurementsResult.value) || {};
        setSensorData(data);

        if (batteryResult.status === 'fulfilled') {
          cacheOnlineMeasurement(data, unwrapApiData(batteryResult.value) || {});
        } else {
          cacheOnlineMeasurement(data, null);
        }
      }

      if (batteryResult.status === 'fulfilled') {
        const battery = unwrapApiData(batteryResult.value) || {};
        setBatteryData(battery);
      }

      if (historicalResult.status === 'fulfilled') {
        const historical = unwrapApiData(historicalResult.value) || [];
        // Se recuperan solo las muestras programadas tomadas sin internet.
        // Las intermedias nunca entran aqui, por lo que la grafica conserva
        // exactamente el intervalo configurado.
        const cutoff = Date.now() - hours * 60 * 60 * 1000;
        const localScheduled = (await getMedicionesOffline()).filter((record) => {
          const timestamp = new Date(record.timestamp || 0).getTime();
          return record.cloudSync === true && Number.isFinite(timestamp) && timestamp >= cutoff;
        });
        // La misma muestra puede existir ya en Supabase y en IndexedDB tras una
        // reconexion. El backend la expone por sensor y el cache como snapshot,
        // por eso se elimina el snapshot local si ambos pertenecen al minuto.
        const remoteMinutes = new Set(historical.map((record) => {
          const time = new Date(record.timestamp || 0).getTime();
          return Number.isFinite(time) ? Math.floor(time / 60000) : null;
        }));
        const localOnly = localScheduled.filter((record) => {
          const time = new Date(record.timestamp || 0).getTime();
          return !Number.isFinite(time) || !remoteMinutes.has(Math.floor(time / 60000));
        });
        const mergedHistorical = mergeHistoricalData(historical, localOnly);
        historicalDataRef.current = mergedHistorical;
        setHistoricalData(mergedHistorical);
      }

      if (failedOnlineResults.length === 0) {
        setError(null);
      } else if (!sensorDataRef.current) {
        const firstError = failedOnlineResults[0].reason;
        const message = firstError?.message || 'Error cargando datos';
        setError(message);
      }
    } catch (err) {
      console.error('Error:', err.message);
      if (!sensorDataRef.current) {
        setError('Error cargando datos');
      }
    } finally {
      setLoading(false);
    }
  }, [timeRange, loadLocalData, offline, cacheOnlineMeasurement, applyOfflineData, mergeHistoricalData]);

  useEffect(() => {
    const unsubscribe = onConnectivityChange((online) => {
      setOffline(!online);
      if (online) {
        syncOfflineMediciones(api).catch((err) => {
          console.error('Error sincronizando offline:', err);
        });
        loadOnlineData();
      }
    });
    return unsubscribe;
  }, [loadOnlineData]);

  useEffect(() => {
    if (serial.connected) {
      setError(null);
      setLoading(false);
      return;
    }

    if (offline) {
      loadLocalData();
    } else {
      loadOnlineData();
    }
  }, [offline, loadLocalData, loadOnlineData, serial.connected]);

  useEffect(() => {
    if (!offline && !serial.connected) {
      const interval = setInterval(() => {
        loadOnlineData();
      }, 10000);
      return () => clearInterval(interval);
    }
  }, [offline, loadOnlineData, serial.connected]);

  useEffect(() => {
    if (offline && !serial.connected) {
      const interval = setInterval(() => {
        loadLocalData();
      }, 30000);
      return () => clearInterval(interval);
    }
  }, [offline, loadLocalData, serial.connected]);

  const changeTimeRange = (hours) => {
    setTimeRange(hours);
    if (!serialConnectedRef.current && !offline) {
      loadOnlineData(hours);
    }
  };

  return {
    sensorData,
    batteryData,
    historicalData,
    timeRange,
    loading,
    error,
    offline,
    serial,
    refetch: offline ? loadLocalData : () => loadOnlineData(timeRange),
    changeTimeRange
  };
}

export default useSensorData;

export function SensorDataProvider({ children }) {
  const sensorData = useSensorData();
  return <SensorDataContext.Provider value={sensorData}>{children}</SensorDataContext.Provider>;
}

export function useSensorDataContext() {
  const sensorData = useContext(SensorDataContext);
  if (!sensorData) throw new Error('useSensorDataContext debe usarse dentro de SensorDataProvider');
  return sensorData;
}
