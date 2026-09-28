import { getBatteryLevel } from '../../utils/batteryLevel.jsx';

function StorageLevel({ batteryData }) {
  const { value, level, color, label } = getBatteryLevel(batteryData);
  const isAlerting = level === 'critical' || level === 'warning';

  return (
    <div className={`offline-storage-card battery-card-${level}`}>
      <h3>Estado de Bateria</h3>
      <div className="storage-content">
        <div className="storage-level">
          <div
            className={`storage-fill${isAlerting ? ' battery-fill-alert' : ''}`}
            style={{ width: `${value}%`, backgroundColor: color }}
          ></div>
        </div>
        <div className="storage-info">
          <span className="battery-value">{Math.round(value)}%</span>
          <span className="battery-status">{label}</span>
        </div>
        {level === 'critical' && (
          <div className="battery-alert" role="alert">
            Bateria critica: {Math.round(value)}%. Conecte la bateria antes de que el nodo se apague.
          </div>
        )}
        {level === 'warning' && (
          <div className="battery-alert warning" role="status">
            Bateria baja: {Math.round(value)}%. Programe el cambio pronto.
          </div>
        )}
      </div>
    </div>
  )
}

export default StorageLevel
