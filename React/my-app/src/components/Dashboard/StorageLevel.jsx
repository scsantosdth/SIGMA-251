function StorageLevel({ batteryData }) {
  const batteryLevel =
    typeof batteryData === 'number' ? batteryData : (batteryData?.bateria ?? 0)

  const getBatteryColor = () => {
    if (batteryLevel > 70) return '#4caf50'
    if (batteryLevel > 30) return '#ff9800'
    return '#f44336'
  }

  const getBatteryStatus = () => {
    if (batteryLevel > 70) return 'Optimo'
    if (batteryLevel > 30) return 'Moderado'
    return 'Bajo'
  }

  return (
    <div className="offline-storage-card">
      <h3>Estado de Bateria</h3>
      <div className="storage-content">
        <div className="storage-level">
          <div
            className="storage-fill"
            style={{
              width: `${batteryLevel}%`,
              backgroundColor: getBatteryColor()
            }}
          ></div>
        </div>
        <div className="storage-info">
          <span className="battery-value">{batteryLevel}%</span>
          <span className="battery-status">{getBatteryStatus()}</span>
        </div>
      </div>
    </div>
  )
}

export default StorageLevel
