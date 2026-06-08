// src/hooks/useOfflineStorageStatus.js
import { useState, useEffect } from 'react';
import localForage from 'localforage';

const MAX_MEDICIONES = 100;

export function useOfflineStorageStatus() {
  const [status, setStatus] = useState({
    count: 0,
    max: MAX_MEDICIONES,
    percentage: 0,
    isCritical: false
  });

  useEffect(() => {
    const checkStorage = async () => {
      try {
        const mediciones = await localForage.getItem('mediciones') || [];
        const count = mediciones.length;
        const percentage = (count / MAX_MEDICIONES) * 100;
        setStatus({
          count,
          max: MAX_MEDICIONES,
          percentage,
          isCritical: percentage >= 80
        });
      } catch (error) {
        console.error('Error obteniendo almacenamiento offline:', error);
      }
    };

    checkStorage();
    // Actualizar cada 30 segundos
    const interval = setInterval(checkStorage, 30000);
    return () => clearInterval(interval);
  }, []);

  return status;
}