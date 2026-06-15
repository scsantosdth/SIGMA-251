import { useState, useEffect, useCallback, useRef } from 'react';
import { api } from '../services/api.jsx';
import {
  saveMedicionOffline,
  getMedicionesOffline,
  syncOfflineMediciones,
  isOnline,
  onConnectivityChange
} from '../services/offlineService';

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

  const mergeHistoricalData = useCallback((baseRecords, extraRecords) => {
    const base = Array.isArray(baseRecords) ? baseRecords : [];
    const extra = Array.isArray(extraRecords) ? extraRecords : [];
    return [...base, ...extra]
      .filter(Boolean)
      .sort((a, b) => new Date(a.timestamp || 0) - new Date(b.timestamp || 0));
  }, []);

  const cacheOnlineMeasurement = useCallback((measurements, battery) => {
    if (!measurements) return;

    // Evitar guardar en IndexedDB cuando estamos offline o cuando la API base es la local (127.0.0.1:5050)
    const apiBase = api.getApiBase();
    if (offline || apiBase.includes('127.0.0.1:5050')) {
      return;
    }

    const record = {
      temperatura: measurements.temperatura?.valor ?? measurements.temperatura ?? null,
      humedad: measurements.humedad?.valor ?? measurements.humedad ?? null,
      luminosidad: measurements.luminosidad?.valor ?? measurements.luminosidad ?? null,
      humedad_suelo: measurements.humedad_suelo?.valor ?? measurements.humedad_suelo ?? null,
      bateria: battery?.bateria ?? battery?.valor ?? battery?.level ?? null
    };

    saveMedicionOffline(record).catch((error) => {
      console.error('Error guardando medicion offline:', error);
    });
  }, [offline]);

  const applyOfflineData = useCallback((records, baseHistory = historicalDataRef.current) => {
    if (!Array.isArray(records) || records.length === 0) return false;

    const latest = records[records.length - 1];
    const mergedHistory = mergeHistoricalData(baseHistory, records);
    setSensorData({
      temperatura: { valor: latest.temperatura, timestamp: latest.timestamp, calidad: 'offline' },
      humedad: { valor: latest.humedad, timestamp: latest.timestamp, calidad: 'offline' },
      humedad_suelo: { valor: latest.humedad_suelo, timestamp: latest.timestamp, calidad: 'offline' },
      luminosidad: { valor: latest.luminosidad, timestamp: latest.timestamp, calidad: 'offline' }
    });
    historicalDataRef.current = mergedHistory;
    setHistoricalData(mergedHistory);

    if (latest.bateria !== undefined && latest.bateria !== null) {
      setBatteryData({ bateria: latest.bateria, timestamp: latest.timestamp, offline: true });
    }

    setError(null);
    return true;
  }, [mergeHistoricalData]);

  const loadIndexedDBFallback = useCallback(async () => {
    try {
      const indexedData = await getMedicionesOffline();
      return applyOfflineData(indexedData, historicalDataRef.current);
    } catch {
      return false;
    }
  }, [applyOfflineData]);

  const loadLocalData = useCallback(async (hours = timeRange) => {
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
        setError('No se pudieron cargar datos locales');
      }
    } catch {
      await loadIndexedDBFallback();
    } finally {
      setLoading(false);
    }
  }, [applyOfflineData, loadIndexedDBFallback, timeRange]);

  const loadOnlineData = useCallback(async (hours = timeRange) => {
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

      const [measurementsResult, batteryResult, historicalResult] = results;
      const failedResults = results.filter((result) => result.status === 'rejected');
      const allFailed = failedResults.length === results.length;

      if (allFailed) {
        setOffline(true);
        await loadLocalData(hours);
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
      if (failedResults.length === 0) {
        setError(null);
      } else if (!sensorDataRef.current) {
        const firstError = failedResults[0].reason;
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
  }, [timeRange, loadLocalData, offline, cacheOnlineMeasurement]);

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
    if (offline) {
      loadLocalData();
    } else {
      loadOnlineData();
    }
  }, [offline, loadLocalData, loadOnlineData]);

  useEffect(() => {
    if (!offline) {
      const interval = setInterval(() => {
        loadOnlineData();
      }, 10000);
      return () => clearInterval(interval);
    }
  }, [offline, loadOnlineData]);

  // Intervalo para modo offline: se reduce la frecuencia a 30 segundos (antes 5)
  useEffect(() => {
    if (offline) {
      const interval = setInterval(() => {
        loadLocalData();
      }, 30000);
      return () => clearInterval(interval);
    }
  }, [offline, loadLocalData]);

  const changeTimeRange = (hours) => {
    setTimeRange(hours);
    if (!offline) {
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
    refetch: offline ? loadLocalData : () => loadOnlineData(timeRange),
    changeTimeRange
  };
}

export default useSensorData;
