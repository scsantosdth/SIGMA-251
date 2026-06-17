import { useState, useEffect } from 'react';
import { api } from '../services/api.jsx';

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
        const health = await api.getLocalHealth();
        const count = Number(health?.pending_count ?? 0);
        const percentage = (count / MAX_MEDICIONES) * 100;
        setStatus({
          count,
          max: MAX_MEDICIONES,
          percentage,
          isCritical: percentage >= 80
        });
      } catch (error) {
        console.error('Error obteniendo almacenamiento offline:', error);
        setStatus({
          count: 0,
          max: MAX_MEDICIONES,
          percentage: 0,
          isCritical: false
        });
      }
    };

    checkStorage();
    // Actualizar cada 30 segundos
    const interval = setInterval(checkStorage, 30000);
    return () => clearInterval(interval);
  }, []);

  return status;
}
