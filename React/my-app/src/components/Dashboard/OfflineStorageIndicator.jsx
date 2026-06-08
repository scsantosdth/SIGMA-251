// src/components/Dashboard/OfflineStorageIndicator.jsx
import { useOfflineStorageStatus } from '../../hooks/useOfflineStorageStatus';
import '../../styles/index.css';


function OfflineStorageIndicator({ compact = false }) {
  const { count, max, percentage, isCritical } = useOfflineStorageStatus();

  if (compact) {
    return (
      <div className="offline-storage-compact" title={`${count} de ${max} mediciones almacenadas`}>
        <span className="storage-icon">💾</span>
        <span className={`storage-percent ${isCritical ? 'critical' : ''}`}>
          {Math.round(percentage)}%
        </span>
      </div>
    );
  }

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
          ></div>
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