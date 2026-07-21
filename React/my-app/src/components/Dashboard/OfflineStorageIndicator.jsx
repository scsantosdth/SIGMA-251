// src/components/Dashboard/OfflineStorageIndicator.jsx
import { useState, useEffect } from 'react';
import { useOfflineStorageStatus } from '../../hooks/useOfflineStorageStatus';
import '../../styles/Layout.css';

function OfflineStorageIndicator({ compact = false }) {
  const { count, max, percentage, isCritical } = useOfflineStorageStatus();

  // Estado reactivo para la conexión
  const [isOnline, setIsOnline] = useState(
    typeof navigator !== 'undefined' ? navigator.onLine : true
  );

  // Escuchar eventos de conectividad
  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  // Determinar color según porcentaje (para la carpeta)
  const getFolderColor = () => {
    if (percentage < 70) return '#4CAF50';   // verde
    if (percentage < 80) return '#FF9800';   // naranja
    return '#F44336';                        // rojo
  };

  // Colores dinámicos
  const cloudColor = isOnline ? '#4A90E2' : '#B0B0B0';
  const folderColor = getFolderColor();

  // Depuración (puedes eliminar esta línea después de probar)
  console.log('porcentaje:', percentage, 'online:', isOnline);

  // Versión compacta para el header
  if (compact) {
    return (
      <div className="offline-storage-compact" title={`${count} de ${max} mediciones almacenadas`}>
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          {/* Nube (con transform para subirla) */}
          <g transform="translate(0, -5)">
            <path
              d="M6.5 18C4.01472 18 2 15.9853 2 13.5C2 11.0147 4.01472 9 6.5 9C6.83261 9 7.15559 9.03972 7.46545 9.11376C8.16358 6.76888 10.3837 5 13 5C15.6163 5 17.8364 6.76888 18.5345 9.11376C18.8444 9.03972 19.1674 9 19.5 9C21.9853 9 24 11.0147 24 13.5C24 15.9853 21.9853 18 19.5 18H6.5Z"
              fill={cloudColor}
              stroke={cloudColor}
              strokeWidth="1.5"
            />
          </g>
          {/* Carpeta (superpuesta) */}
          <path
            d="M8 14V10C8 8.89543 8.89543 8 10 8H14.5858C14.851 8 15.1054 8.10536 15.2929 8.29289L16.7071 9.70711C16.8946 9.89464 17.149 10 17.4142 10H20C21.1046 10 22 10.8954 22 12V14H8Z"
            fill={folderColor}
            stroke="white"
            strokeWidth="1.5"
            style={{ transition: 'fill 0.3s ease' }}
          />
          <path
            d="M8 14V17C8 18.1046 8.89543 19 10 19H20C21.1046 19 22 18.1046 22 17V14H8Z"
            fill={folderColor}
            stroke="white"
            strokeWidth="1.5"
            style={{ transition: 'fill 0.3s ease' }}
          />
        </svg>
        <span className={`storage-percent ${isCritical ? 'critical' : ''}`}>
          {Math.round(percentage)}%
        </span>
      </div>
    );
  }

  // Versión completa para el sidebar
  return (
    <div className="offline-storage-card">
      <h3>Almacenamiento offline</h3>
      <div className="storage-content">
        <div className="storage-level">
          <div 
            className="storage-fill"
            style={{ 
              width: `${percentage}%`,
              backgroundColor: isCritical ? '#e74c3c' : '#2ecc71'
            }}
          />
        </div>
        <div className="storage-info">
          <span className="storage-value">{count} / {max}</span>
          <span className="storage-percentage">{Math.round(percentage)}%</span>
        </div>
        {isCritical && (
          <div className="storage-warning">
            ⚠️ Almacenamiento casi lleno (80%). Sincroniza datos.
          </div>
        )}
      </div>
    </div>
  );
}

export default OfflineStorageIndicator;