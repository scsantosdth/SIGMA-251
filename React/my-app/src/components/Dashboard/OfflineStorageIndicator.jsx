// src/components/Dashboard/OfflineStorageIndicator.jsx
import { useOfflineStorageStatus } from '../../hooks/useOfflineStorageStatus';
import '../../styles/index.css';

function OfflineStorageIndicator({ compact = false }) {
  const { count, max, percentage, isCritical } = useOfflineStorageStatus();
  const roundedPercentage = Math.round(percentage);

  if (compact) {
    return (
      <div
        className="offline-storage-compact"
        title={`${count} de ${max} mediciones pendientes por sincronizar`}
      >
        <span className={`storage-percent ${isCritical ? 'critical' : ''}`}>
          {roundedPercentage}%
        </span>
        <span className="storage-icon" aria-hidden="true">💾</span>
      </div>
    );
  }

  return (
    <div className="offline-storage-card">
      <h3>Pendientes offline</h3>
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
          <span className="storage-percentage">{roundedPercentage}%</span>
        </div>
        {isCritical && (
          <div className="storage-warning">
            Hay muchos datos pendientes. Sincroniza cuando tengas conexion.
          </div>
        )}
      </div>
    </div>
  );
}

export default OfflineStorageIndicator;
