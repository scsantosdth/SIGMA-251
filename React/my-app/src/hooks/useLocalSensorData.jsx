// src/hooks/useLocalSensorData.jsx
import { useState, useEffect } from 'react';

export function useLocalSensorData() {
  const [data, setData] = useState([]);
  const [latest, setLatest] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchLocalData = async () => {
    try {
      // Intentar fetch del archivo JSON local
      const response = await fetch('/datos_sensor.json');
      
      if (!response.ok) {
        throw new Error('No se pudo leer archivo local');
      }
      
      const jsonData = await response.json();
      
      if (jsonData && jsonData.length > 0) {
        setData(jsonData);
        setLatest(jsonData[jsonData.length - 1]);
        setError(null);
      } else {
        setError('No hay datos locales');
      }
    } catch (err) {
      console.error('Error leyendo datos locales:', err);
      setError('Error leyendo archivo local');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchLocalData();
    
    // Polling cada 5 segundos para leer nuevo JSON
    const interval = setInterval(fetchLocalData, 5000);
    
    return () => clearInterval(interval);
  }, []);

  return { data, latest, loading, error, refetch: fetchLocalData };
}