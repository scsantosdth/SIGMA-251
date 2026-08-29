import localForage from 'localforage';

export const MAX_OFFLINE_MEDICIONES = 1000;
const STORAGE_EVENT = 'sigma-offline-storage-updated';

localForage.config({
  name: 'SigmaOfflineDB',
  storeName: 'mediciones',
  description: 'Almacenamiento offline de mediciones',
});

const emitStorageUpdate = () => {
  if (typeof window !== 'undefined') {
    window.dispatchEvent(new CustomEvent(STORAGE_EVENT));
  }
};

export const onOfflineStorageChange = (callback) => {
  if (typeof window === 'undefined') return () => {};
  window.addEventListener(STORAGE_EVENT, callback);
  return () => window.removeEventListener(STORAGE_EVENT, callback);
};

export const saveMedicionOffline = async (medicion, options = {}) => {
  try {
    const mediciones = await localForage.getItem('mediciones') || [];
    const record = {
      ...medicion,
      timestamp: medicion.timestamp || new Date().toISOString(),
      id: medicion.id || Date.now(),
      synced: Boolean(options.synced ?? medicion.synced),
      source: medicion.source || 'web-serial',
    };

    const existingIndex = mediciones.findIndex((item) => item.id === record.id);
    if (existingIndex >= 0) {
      mediciones[existingIndex] = { ...mediciones[existingIndex], ...record };
    } else {
      mediciones.push(record);
    }

    if (mediciones.length > MAX_OFFLINE_MEDICIONES) {
      mediciones.splice(0, mediciones.length - MAX_OFFLINE_MEDICIONES);
    }

    await localForage.setItem('mediciones', mediciones);
    emitStorageUpdate();
    return record;
  } catch (error) {
    console.error('Error guardando offline:', error);
    return null;
  }
};

export const getMedicionesOffline = async (options = {}) => {
  try {
    const mediciones = await localForage.getItem('mediciones') || [];
    if (options.pendingOnly) {
      return mediciones.filter((medicion) => !medicion.synced && medicion.cloudSync !== false);
    }
    return mediciones;
  } catch (error) {
    console.error('Error leyendo offline:', error);
    return [];
  }
};

export const markMedicionSynced = async (id) => {
  try {
    const mediciones = await localForage.getItem('mediciones') || [];
    const updated = mediciones.map((medicion) =>
      medicion.id === id ? { ...medicion, synced: true } : medicion
    );
    await localForage.setItem('mediciones', updated);
    emitStorageUpdate();
    return true;
  } catch (error) {
    console.error('Error marcando medicion sincronizada:', error);
    return false;
  }
};

export const getOfflineStorageSummary = async () => {
  const mediciones = await getMedicionesOffline();
  const pending = mediciones.filter((medicion) => !medicion.synced).length;

  return {
    total: mediciones.length,
    pending,
    max: MAX_OFFLINE_MEDICIONES,
    percentage: (pending / MAX_OFFLINE_MEDICIONES) * 100,
  };
};

export const syncOfflineMediciones = async (api) => {
  try {
    const mediciones = await getMedicionesOffline({ pendingOnly: true });
    if (mediciones.length === 0) return { synced: 0, failed: 0 };

    let synced = 0;
    let failed = 0;

    for (const medicion of mediciones) {
      try {
        await api.postWaspmoteMeasurement({
          temperatura: medicion.temperatura,
          humedad: medicion.humedad,
          radiacion_solar: medicion.radiacion_solar,
          humedad_suelo: medicion.humedad_suelo,
          timestamp: medicion.timestamp,
          offline_sync: true,
        });

        if (medicion.bateria !== undefined && medicion.bateria !== null) {
          await api.postWaspmoteBattery({
            dispositivo_id: 1,
            bateria: medicion.bateria,
            timestamp: medicion.timestamp,
          }).catch((error) => {
            console.warn('No se pudo sincronizar bateria offline:', error);
          });
        }

        await markMedicionSynced(medicion.id);
        synced++;
      } catch {
        failed++;
      }
    }

    return { synced, failed };
  } catch (error) {
    console.error('Error en sincronizacion:', error);
    return { synced: 0, failed: 0 };
  }
};

export const isOnline = () => {
  return typeof navigator !== 'undefined' ? navigator.onLine : true;
};

export const onConnectivityChange = (callback) => {
  const handleOnline = () => callback(true);
  const handleOffline = () => callback(false);

  window.addEventListener('online', handleOnline);
  window.addEventListener('offline', handleOffline);

  return () => {
    window.removeEventListener('online', handleOnline);
    window.removeEventListener('offline', handleOffline);
  };
};
