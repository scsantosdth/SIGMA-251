// src/services/offlineService.js
import localForage from 'localforage';
import { api } from './api.jsx'; // Necesario para conocer la URL base

// Configurar localForage
localForage.config({
  name: 'SigmaOfflineDB',
  storeName: 'mediciones',
  description: 'Almacenamiento offline de mediciones'
});

// Guardar medición (solo si no estamos usando la API local)
export const saveMedicionOffline = async (medicion) => {
  const apiBase = api.getApiBase();
  // Si la API base es la local (receiver), no guardamos en IndexedDB
  if (apiBase.includes('127.0.0.1:5050') || apiBase.includes('localhost')) {
    return false;
  }

  try {
    // Obtener mediciones existentes
    const mediciones = await localForage.getItem('mediciones') || [];
    
    // Agregar nueva medición con timestamp
    mediciones.push({
      ...medicion,
      timestamp: new Date().toISOString(),
      id: Date.now() // ID único temporal
    });
    
    // Guardar solo últimas 100 mediciones
    if (mediciones.length > 100) {
      mediciones.shift(); // Eliminar la más antigua
    }
    
    await localForage.setItem('mediciones', mediciones);
    return true;
  } catch (error) {
    console.error('Error guardando offline:', error);
    return false;
  }
};

// Obtener todas las mediciones offline
export const getMedicionesOffline = async () => {
  try {
    return await localForage.getItem('mediciones') || [];
  } catch (error) {
    console.error('Error leyendo offline:', error);
    return [];
  }
};

// Sincronizar mediciones offline con el servidor
export const syncOfflineMediciones = async (api) => {
  try {
    const mediciones = await getMedicionesOffline();
    if (mediciones.length === 0) return { synced: 0, failed: 0 };
    
    let synced = 0;
    let failed = 0;
    
    for (const medicion of mediciones) {
      try {
        // Intentar enviar al servidor
        await api.postWaspmoteMeasurement({
          temperatura: medicion.temperatura,
          humedad: medicion.humedad,
          luminosidad: medicion.luminosidad,
          humedad_suelo: medicion.humedad_suelo
        });
        synced++;
      } catch (error) {
        failed++;
      }
    }
    
    // Limpiar solo las sincronizadas
    if (synced > 0) {
      const pending = mediciones.slice(-failed); // Mantener fallidas
      await localForage.setItem('mediciones', pending);
    }
    
    return { synced, failed };
  } catch (error) {
    console.error('Error en sincronización:', error);
    return { synced: 0, failed: 0 };
  }
};

// Detectar si hay conexión a internet
export const isOnline = () => {
  return navigator.onLine;
};

// Escuchar cambios de conectividad
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