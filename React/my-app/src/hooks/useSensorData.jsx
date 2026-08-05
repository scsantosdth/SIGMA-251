import { useState, useEffect, useCallback, useRef } from 'react';
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

  useEffect(() => {
    sensorDataRef.current = sensorData;
    batteryDataRef.current = batteryData;
    historicalDataRef.current = historicalData;
  }, [sensorData, batteryData, historicalData]);

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
    const record = {
      ...measurement,
      timestamp,
      id: Date.now(),
      source: 'web-serial',
      synced: false,
    };

    applyOfflineData([record], historicalDataRef.current);

    const savedRecord = await saveMedicionOffline(record, { synced: false });
    if (!savedRecord) return;

    const synced = await syncSingleSerialMeasurement(savedRecord);
    if (synced) {
      syncOfflineMediciones(api).catch((syncError) => {
        console.warn('Error sincronizando pendientes:', syncError);
      });
    }
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
      const indexedData = await getMedicionesOffline();
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
      const [latestResult, historyResult] = await Promise.allSettled([
        api.getLocalLatestMeasurements(),
        api.getLocalHistoricalData(hours)
      ]);

      if (historyResult.status === 'fulfilled') {
        const history = unwrapApiData(historyResult.value) || [];
        if (applyOfflineData(history, historicalDataRef.current)) {
          return;
        }
      }

      if (latestResult.status === 'fulfilled') {
        const latest = unwrapApiData(latestResult.value) || {};
        if (Object.keys(latest).length > 0) {
          applyOfflineData([latest], historicalDataRef.current);
          return;
        }
      }

      const indexedLoaded = await loadIndexedDBFallback();
      if (!indexedLoaded) {
        setError('Conecta el XBee para recibir datos locales');
      }
    } catch {
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
        api.getHistoricalData(hours),
        api.getLocalLatestMeasurements(),
        api.getLocalHistoricalData(hours)
      ]);

      const [
        measurementsResult,
        batteryResult,
        historicalResult,
        localLatestResult,
        localHistoricalResult
      ] = results;
      const onlineResults = [measurementsResult, batteryResult, historicalResult];
      const failedOnlineResults = onlineResults.filter((result) => result.status === 'rejected');
      const allOnlineFailed = failedOnlineResults.length === onlineResults.length;
      const localHistorical = localHistoricalResult.status === 'fulfilled'
        ? unwrapApiData(localHistoricalResult.value) || []
        : [];
      const localLatest = localLatestResult.status === 'fulfilled'
        ? unwrapApiData(localLatestResult.value) || {}
        : {};
      const hasLocalHistorical = Array.isArray(localHistorical) && localHistorical.length > 0;
      const hasLocalLatest = localLatest && Object.keys(localLatest).length > 0;
      let loadedLocalData = false;

      if (allOnlineFailed) {
        setOffline(true);
        if (!hasLocalHistorical && !hasLocalLatest) {
          await loadLocalData(hours);
          return;
        }
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
      } else if (hasLocalHistorical) {
        loadedLocalData = applyOfflineData(localHistorical, historicalDataRef.current);
      } else if (hasLocalLatest) {
        loadedLocalData = applyOfflineData([localLatest], historicalDataRef.current);
      }

      if (batteryResult.status === 'fulfilled') {
        const battery = unwrapApiData(batteryResult.value) || {};
        setBatteryData(battery);
      }

      if (historicalResult.status === 'fulfilled') {
        const historical = unwrapApiData(historicalResult.value) || [];
        const mergedHistorical = mergeHistoricalData(historical, localHistorical);
        historicalDataRef.current = mergedHistorical;
        setHistoricalData(mergedHistorical);
      } else if (hasLocalHistorical) {
        historicalDataRef.current = mergeHistoricalData(historicalDataRef.current, localHistorical);
        setHistoricalData(historicalDataRef.current);
      }

      if (failedOnlineResults.length === 0 || loadedLocalData) {
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
