import { createContext, useContext, useState, useEffect, useCallback, useRef } from 'react';
import { api } from '../services/api.jsx';
import {
  saveMedicionOffline,
  getMedicionesOffline,
  markMedicionSynced,
  syncOfflineMediciones,
  isOnline,
  onConnectivityChange,
  saveSdObservation,
  getSdObservationRecords,
  clearSdObservationRecords
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
  const [isMeasuring, setIsMeasuring] = useState(false);
  const [syncedHistoryDate, setSyncedHistoryDate] = useState(null);
  const [observationActive, setObservationActive] = useState(false);
  const [sdObservationRecords, setSdObservationRecords] = useState([]);

  const sensorDataRef = useRef(sensorData);
  const batteryDataRef = useRef(batteryData);
  const historicalDataRef = useRef(historicalData);
  const serialConnectedRef = useRef(false);
  const serialRef = useRef(null);
  const syncedHistoryDateRef = useRef(null);
  const isMeasuringRef = useRef(false);
  const sdSyncPromisesRef = useRef([]);
  const cloudSyncIntervalRef = useRef(getCloudIntervalMinutes() * 60 * 1000);
  const lastCloudSyncScheduledRef = useRef(getLastCloudSampleAt());
  const observationModeRef = useRef(false);
  const sdObservationRecordsRef = useRef([]);
  const observationDedupKeysRef = useRef(new Set());

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
      const result = await api.postWaspmoteMeasurement({
        temperatura: record.temperatura,
        humedad: record.humedad,
        radiacion_solar: record.radiacion_solar,
        humedad_suelo: record.humedad_suelo,
        timestamp: record.timestamp,
      });

      // Si el servidor responde "skipped" la muestra NO se guardo en la nube.
      // No se marca como sincronizada: queda pendiente y se reintenta en la
      // siguiente conexion con offline_sync=true (que si inserta lo faltante).
      if (result?.status !== 'success') {
        console.warn('Servidor no guardo la muestra (skipped); queda pendiente:', result);
        return false;
      }

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
    // El firmware transmite periodicamente mientras el XBee esta conectado.
    // La toma de medidas en la interfaz determina cuando esas tramas se
    // procesan, se muestran y se guardan.
    if (!isMeasuringRef.current) return;

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

  const appendObservationRecord = useCallback(async (record) => {
    const key = record?.timestamp || '';
    if (!key || observationDedupKeysRef.current.has(key)) return;

    observationDedupKeysRef.current.add(key);
    const fullRecord = {
      ...record,
      id: record.id || `sd-${key}`,
      key,
      source: 'sd',
      synced: true,
      cloudSync: false,
    };

    sdObservationRecordsRef.current = [...sdObservationRecordsRef.current, fullRecord];
    setSdObservationRecords(sdObservationRecordsRef.current);
    // Se guarda en el navegador (IndexedDB) para poder revisarla despues SIN
    // enviarla nunca a la nube: cloudSync:false la excluye de la cola de sync.
    await saveSdObservation(fullRecord);
  }, []);

  const loadPersistedObservation = useCallback(async () => {
    try {
      const persisted = await getSdObservationRecords();
      if (Array.isArray(persisted) && persisted.length > 0) {
        persisted.forEach((record) => {
          observationDedupKeysRef.current.add(record.key || record.timestamp || '');
        });
        sdObservationRecordsRef.current = persisted;
        setSdObservationRecords(persisted);
      }
    } catch (error) {
      console.error('Error cargando observacion SD persistida:', error);
    }
  }, []);

  const startSdObservation = useCallback(() => {
    if (!serialConnectedRef.current) {
      setError('Conecta el XBee antes de leer la SD');
      return false;
    }

    observationModeRef.current = true;
    setObservationActive(true);
    setError(null);

    // Solo lectura: se pide toda la SD y los registros se recopilan
    // localmente sin escribir en la base de datos de la nube.
    serialRef.current?.sendCommand('SYNC_SD').catch((commandError) => {
      console.error('Error enviando SYNC_SD para observacion:', commandError);
      observationModeRef.current = false;
      setObservationActive(false);
    });
    return true;
  }, []);

  const stopSdObservation = useCallback(() => {
    observationModeRef.current = false;
    setObservationActive(false);
  }, []);

  const clearSdObservation = useCallback(async () => {
    observationModeRef.current = false;
    setObservationActive(false);
    observationDedupKeysRef.current.clear();
    sdObservationRecordsRef.current = [];
    setSdObservationRecords([]);
    await clearSdObservationRecords();
  }, []);

  const prepareSdHistoryDate = useCallback((date) => {
    syncedHistoryDateRef.current = date;
    setSyncedHistoryDate(null);
  }, []);

  const handleSerialControlMessage = useCallback((message) => {
    if (message?.type === 'sd-record') {
      // MODALIDAD OBSERVACION (solo lectura): los registros de la SD se
      // recopilan localmente y NUNCA se envian a la base de datos.
      if (observationModeRef.current) {
        appendObservationRecord(message.record);
        return;
      }

      console.info('Registro SD recibido; pendiente de sincronizacion:', message.record);

      const requestNextSdRecord = () => {
        serialRef.current?.sendCommand('SYNC_NEXT').catch((commandError) => {
          console.error('No se pudo solicitar el siguiente registro SD:', commandError);
        });
      };

      // El registro SD lleva un id estable por su timestamp para no duplicarse
      // en la cola offline si esta conexion falla y se reintenta.
      const pendingRecord = {
        ...message.record,
        id: message.record.id || `sd-${message.record.timestamp || Date.now()}`,
        cloudSync: true,
      };

      if (isOnline() && api.isAuthenticated()) {
        const syncPromise = api.postSdMeasurement({
          temperatura: pendingRecord.temperatura,
          humedad: pendingRecord.humedad,
          radiacion_solar: pendingRecord.radiacion_solar,
          humedad_suelo: pendingRecord.humedad_suelo,
          timestamp: pendingRecord.timestamp,
        }).then((result) => {
          console.info('Resultado sincronizacion SD:', result);
          return result;
        }).catch(async (syncError) => {
          console.error('No se pudo enviar el registro SD; queda pendiente:', syncError);
          // Fix P2: si el envio falla, se conserva para sincronizarlo despues.
          await saveMedicionOffline(pendingRecord, { synced: false });
          throw syncError;
        });

        sdSyncPromisesRef.current.push(syncPromise);
        syncPromise.then(() => {
          sdSyncPromisesRef.current = sdSyncPromisesRef.current.filter(
            (pending) => pending !== syncPromise
          );
        }, () => {
          sdSyncPromisesRef.current = sdSyncPromisesRef.current.filter(
            (pending) => pending !== syncPromise
          );
        });
        // La confirmacion se envia incluso si Supabase marco el registro como
        // duplicado: ya no es necesario retransmitirlo desde la SD.
        syncPromise.then(requestNextSdRecord, requestNextSdRecord);
      } else {
        // Fix P2: sin conexion o sin sesion el registro NO se descarta; se
        // guarda en IndexedDB y se sincroniza cuando vuelva la conexion.
        saveMedicionOffline(pendingRecord, { synced: false }).finally(() => {
          requestNextSdRecord();
        });
      }

      return;
    }

    if (message?.type === 'sync-end') {
      if (observationModeRef.current) {
        // Lectura de observacion finalizada: detener el modo sin escribir nada.
        observationModeRef.current = false;
        setObservationActive(false);
        console.info(
          `Observacion SD terminada. Registros recopilados: ${sdObservationRecordsRef.current.length}`
        );
        return;
      }

      const pending = [...sdSyncPromisesRef.current];
      Promise.allSettled(pending).then(async () => {
        if (!isOnline() || !api.isAuthenticated()) return;

        const selectedDate = syncedHistoryDateRef.current;
        if (!selectedDate) return;

        try {
          const payload = await api.getHistoricalDataByDate(selectedDate);
          const historical = unwrapApiData(payload) || [];
          historicalDataRef.current = historical;
          setHistoricalData(historical);
          setSyncedHistoryDate(selectedDate);
          console.info(`Grafica actualizada con los datos SD de ${selectedDate}`);
        } catch (refreshError) {
          console.error('No se pudo actualizar la grafica tras SYNC_SD:', refreshError);
        }
      });
      return;
    }
  }, [appendObservationRecord]);

  const serial = useXBeeSerial(handleSerialMeasurement, handleSerialControlMessage);
  serialRef.current = serial;

  useEffect(() => {
    serialConnectedRef.current = serial.connected;
    if (!serial.connected) {
      isMeasuringRef.current = false;
      setIsMeasuring(false);
    }
  }, [serial.connected]);

  const startMeasurements = useCallback(() => {
    if (!serialConnectedRef.current) {
      setError('Conecta el XBee antes de iniciar las medidas');
      return;
    }

    isMeasuringRef.current = true;
    setIsMeasuring(true);
    setError(null);
  }, []);

  const stopMeasurements = useCallback(() => {
    isMeasuringRef.current = false;
    setIsMeasuring(false);
  }, []);

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

  // Cargar la ultima observacion SD persistida en el navegador para poder
  // revisarla sin volver a conectar el nodo. Solo lectura.
  useEffect(() => {
    loadPersistedObservation();
  }, [loadPersistedObservation]);

  const changeTimeRange = (hours) => {
    setTimeRange(hours);
    syncedHistoryDateRef.current = null;
    setSyncedHistoryDate(null);
    if (!offline) {
      loadOnlineData(hours);
    }
  };

  return {
    sensorData,
    batteryData,
    historicalData,
    syncedHistoryDate,
    timeRange,
    loading,
    error,
    offline,
    serial,
    isMeasuring,
    startMeasurements,
    stopMeasurements,
    prepareSdHistoryDate,
    observationActive,
    sdObservationRecords,
    startSdObservation,
    stopSdObservation,
    clearSdObservation,
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
