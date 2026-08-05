import StorageLevel from '../Dashboard/StorageLevel.jsx';
import OfflineStorageIndicator from '../Dashboard/OfflineStorageIndicator.jsx';
import '../../styles/index.css';

function StatusSidebar({ batteryData, serial }) {
  return (
    <div className="status-sidebar">
      <StorageLevel batteryData={batteryData} />
      <div className="status-card">
        <h3>Enlace XBee</h3>
        <div className="status-list">
          <div className="status-item">
            <span className={`status-dot ${serial?.connected ? 'online' : 'offline'}`}></span>
            <span>{serial?.connected ? 'Puerto serial conectado' : 'Puerto serial pendiente'}</span>
          </div>
          <div className="status-item">
            <span className="status-dot"></span>
            <span>{serial?.lastTimestamp ? new Date(serial.lastTimestamp).toLocaleTimeString('es-CO') : 'Sin lecturas seriales'}</span>
          </div>
        </div>
      </div>
      <OfflineStorageIndicator compact={false} />
    </div>
  );
}

export default StatusSidebar;
