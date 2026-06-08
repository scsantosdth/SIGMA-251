function StorageLevel({ batteryData }) {
  const batteryLevel =
    typeof batteryData === 'number' ? batteryData : (batteryData?.bateria ?? 0)
  
  const getBatteryColor = () => {
    if (batteryLevel > 70) return '#4caf50'
    if (batteryLevel > 30) return '#ff9800'
    return '#f44336'
  }

  const getBatteryStatus = () => {
    if (batteryLevel > 70) return 'Óptimo'
    if (batteryLevel > 30) return 'Moderado'
    return 'Bajo'
  }

  return (
    <div className="battery-card">
      <h3>Estado de Batería</h3>
      <div className="battery-content">
        <div className="battery-level">
          <div 
            className="battery-fill"
            style={{ 
              width: `${batteryLevel}%`,
              backgroundColor: getBatteryColor()
            }}
          ></div>
        </div>
        <div className="battery-info">
          <span className="battery-value">{batteryLevel}%</span>
          <span className="battery-status">{getBatteryStatus()}</span>
        </div>
      </div>
    </div>
  )
}

export default StorageLevel
