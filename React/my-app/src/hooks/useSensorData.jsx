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
  const cloudSyncIntervalRef = useRef(5 * 60 * 1000);
  const lastCloudSyncScheduledRef = useRef(0);

  useEffect(() => {
    sensorDataRef.current = sensorData;
    batteryDataRef.current = batteryData;
    historicalDataRef.current = historicalData;
  }, [sensorData, batteryData, historicalData]);

  useEffect(() => {
    const setCloudInterval = (minutes) => {
      const parsed = Number(minutes);
      if (Number.isFinite(parsed) && parsed > 0) {
        cloudSyncIntervalRef.current = parsed * 60 * 1000;
        lastCloudSyncScheduledRef.current = 0;
      }
    };

    api.getAutoInterval().then((data) => setCloudInterval(data?.valor)).catch(() => {});
    const handleIntervalChange = (event) => setCloudInterval(event.detail);
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
      record.luminosidad ?? '',
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
      luminosidad: { valor: latest.luminosidad, timestamp: latest.timestamp, calidad: latest.source || 'offline' }
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
        luminosidad: record.luminosidad,
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
    if (shouldSyncToCloud) lastCloudSyncScheduledRef.current = now;

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
        luminosidad: { valor: record.luminosidad, timestamp, calidad: record.source },
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

  const serial = useXBeeSerial(handleSerialMeasurement);

  useEffect(() => {
    serialConnectedRef.current = serial.connected;
  }, [serial.connected]);

  const cacheOnlineMeasurement = useCallback((measurements, battery) => {
    if (!measurements || serialConnectedRef.current) return;

    const record = {
      temperatura: measurements.temperatura?.valor ?? measurements.temperatura ?? null,
      humedad: measurements.humedad?.valor ?? measurements.humedad ?? null,
      luminosidad: measurements.luminosidad?.valor ?? measurements.luminosidad ?? null,
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
        .filter((record) => record.cloudSync !== false);
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
        historicalDataRef.current = historical;
        setHistoricalData(historical);
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
