import { useState, useEffect } from 'react';
import {
  MAX_OFFLINE_MEDICIONES,
  getOfflineStorageSummary,
  onOfflineStorageChange
} from '../services/offlineService';

export function useOfflineStorageStatus() {
  const [status, setStatus] = useState({
    count: 0,
    max: MAX_OFFLINE_MEDICIONES,
    percentage: 0,
    isCritical: false,
  });

  useEffect(() => {
    const checkStorage = async () => {
      try {
        const summary = await getOfflineStorageSummary();
        const count = Number(summary.pending ?? 0);
        const percentage = Number(summary.percentage ?? 0);

        setStatus({
          count,
          max: summary.max ?? MAX_OFFLINE_MEDICIONES,
          percentage,
          isCritical: percentage > 80,
        });
      } catch (error) {
        console.error('Error obteniendo almacenamiento offline:', error);
        setStatus({
          count: 0,
          max: MAX_OFFLINE_MEDICIONES,
          percentage: 0,
          isCritical: false,
        });
      }
    };

    checkStorage();
    const unsubscribe = onOfflineStorageChange(checkStorage);
    const interval = setInterval(checkStorage, 30000);

    return () => {
      unsubscribe();
      clearInterval(interval);
    };
  }, []);

  return status;
}
