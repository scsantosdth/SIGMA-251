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

  useEffect(() => {
    sensorDataRef.current = sensorData;
    batteryDataRef.current = batteryData;
  }, [sensorData, batteryData]);

  const unwrapApiData = (payload) => {
    if (!payload) return null;
    if (Object.prototype.hasOwnProperty.call(payload, 'data')) return payload.data;
    return payload;
  };

  const applyOfflineData = useCallback((records) => {
    if (!Array.isArray(records) || records.length === 0) return false;

    const latest = records[records.length - 1];
    setSensorData({
      temperatura: { valor: latest.temperatura, timestamp: latest.timestamp, calidad: 'offline' },
      humedad: { valor: latest.humedad, timestamp: latest.timestamp, calidad: 'offline' },
      humedad_suelo: { valor: latest.humedad_suelo, timestamp: latest.timestamp, calidad: 'offline' },
      luminosidad: { valor: latest.luminosidad, timestamp: latest.timestamp, calidad: 'offline' }
    });
    setHistoricalData(records);

    if (latest.bateria !== undefined && latest.bateria !== null) {
      setBatteryData({ bateria: latest.bateria, timestamp: latest.timestamp, offline: true });
    }

    setError(null);
    return true;
  }, []);

  const loadIndexedDBFallback = useCallback(async () => {
    try {
      const indexedData = await getMedicionesOffline();
      return applyOfflineData(indexedData);
    } catch {
      return false;
    }
  }, [applyOfflineData]);

  const loadLocalJSON = useCallback(async () => {
    try {
      const response = await fetch(`/datos_sensor.json?_=${Date.now()}`);
      if (!response.ok) throw new Error('No JSON');

      const jsonData = await response.json();
      const loadedFromJson = applyOfflineData(jsonData);
      if (!loadedFromJson) {
        await loadIndexedDBFallback();
      }
    } catch {
      await loadIndexedDBFallback();
    } finally {
      setLoading(false);
    }
  }, [applyOfflineData, loadIndexedDBFallback]);

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
        await loadLocalJSON();
      } else if (offline) {
        setOffline(false);
      }

      if (measurementsResult.status === 'fulfilled') {
        const data = unwrapApiData(measurementsResult.value) || {};
        setSensorData(data);
      }

      if (batteryResult.status === 'fulfilled') {
        const battery = unwrapApiData(batteryResult.value) || {};
        setBatteryData(battery);
      }

      if (historicalResult.status === 'fulfilled') {
        const historical = unwrapApiData(historicalResult.value) || [];
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
  }, [timeRange, loadLocalJSON, offline]);

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
      loadLocalJSON();
    } else {
      loadOnlineData();
    }
  }, [offline, loadLocalJSON, loadOnlineData]);

  useEffect(() => {
    if (!offline) {
      const interval = setInterval(() => {
        loadOnlineData();
      }, 10000);
      return () => clearInterval(interval);
    }
  }, [offline, loadOnlineData]);

  useEffect(() => {
    if (offline) {
      const interval = setInterval(() => {
        loadLocalJSON();
      }, 5000);
      return () => clearInterval(interval);
    }
  }, [offline, loadLocalJSON]);

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
    refetch: offline ? loadLocalJSON : () => loadOnlineData(timeRange),
    changeTimeRange
  };
}

export default useSensorData;
