import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'

function RealTimeChart({ historicalData, timeRange, onTimeRangeChange }) {
  // Opciones de tiempo
  const timeOptions = [
    { value: 1, label: '1 Hora' },
    { value: 6, label: '6 Horas' },
    { value: 24, label: '24 Horas' }
  ]

  // Si no hay datos históricos o no es array, mostrar mensaje
  if (!historicalData || !Array.isArray(historicalData) || historicalData.length === 0) {
    return (
      <div className="chart-container">
        <div className="chart-header">
          <h2>Métricas en Tiempo Real</h2>
        </div>
        <div className="no-data">
          <p>No hay datos disponibles</p>
        </div>
      </div>
    )
  }

  // Procesar datos para Recharts - versión SEGURA
  const processChartData = () => {
    const dataByTime = {}
    const sensorKeyMap = {
      temperatura: 'temperatura',
      humedad: 'humedad',
      luminosidad: 'luminosidad',
      humedad_suelo: 'humedad_suelo'
    }
    
    // Usar forEach solo si es array
    historicalData.forEach(item => {
      if (!item) return; // Saltar items null

      const rawDate = new Date(item.timestamp)
      if (Number.isNaN(rawDate.getTime())) return

      // Agrupar por segundo para no perder lecturas distintas que comparten el mismo minuto
      const timeKey = rawDate.toISOString().slice(0, 19)
      const time = rawDate.toLocaleString('es-ES', {
        day: '2-digit',
        month: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })

      if (!dataByTime[timeKey]) {
        dataByTime[timeKey] = { time, timeKey }
      }

      if (item.sensor && Object.prototype.hasOwnProperty.call(item, 'valor')) {
        const key = sensorKeyMap[item.sensor] || item.sensor
        dataByTime[timeKey][key] = item.valor ?? 0
      } else {
        // Usar valores directamente (sin .sensor ni .valor)
        dataByTime[timeKey].temperatura = item.temperatura ?? 0
        dataByTime[timeKey].humedad = item.humedad ?? 0
        dataByTime[timeKey].luminosidad = item.luminosidad ?? 0
        dataByTime[timeKey].humedad_suelo = item.humedad_suelo ?? 0
      }
    })
    
    return Object.values(dataByTime).sort((a, b) => a.timeKey.localeCompare(b.timeKey))
  }

  const chartData = processChartData()

  // Si después de procesar no hay datos
  if (chartData.length === 0) {
    return (
      <div className="chart-container">
        <div className="chart-header">
          <h2>Métricas en Tiempo Real</h2>
        </div>
        <div className="no-data">
          <p>No hay datos para mostrar</p>
        </div>
      </div>
    )
  }

  return (
    <div className="chart-container">
      <div className="chart-header">
        <h2>Métricas en Tiempo Real</h2>
        <div className="time-filters">
          {timeOptions.map(option => (
            <button
              key={option.value}
              className={`time-filter ${timeRange === option.value ? 'active' : ''}`}
              onClick={() => onTimeRangeChange(option.value)}
            >
              {option.label}
            </button>
          ))}
        </div>
      </div>

      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={chartData}>
          <CartesianGrid strokeDasharray="3 3" stroke="#333" />
          <XAxis 
            dataKey="time" 
            stroke="#9e9e9e"
            fontSize={12}
          />
          <YAxis 
            stroke="#9e9e9e"
            fontSize={12}
          />
          <Tooltip 
            contentStyle={{ 
              backgroundColor: '#1e1e1e', 
              border: '1px solid #333',
              borderRadius: '8px'
            }}
          />
          <Legend />
          <Line 
            type="monotone" 
            dataKey="temperatura" 
            stroke="#ff6b6b" 
            name="Temperatura (°C)" 
            strokeWidth={2}
            dot={false}
          />
          <Line 
            type="monotone" 
            dataKey="humedad" 
            stroke="#4ecdc4" 
            name="Humedad (%)" 
            strokeWidth={2}
            dot={false}
          />
          <Line 
            type="monotone" 
            dataKey="luminosidad" 
            stroke="#ffd93d" 
            name="Luminosidad (LUX)" 
            strokeWidth={2}
            dot={false}
          />
          <Line 
            type="monotone" 
            dataKey="humedad_suelo" 
            stroke="#6c5ce7" 
            name="Humedad Suelo (%)" 
            strokeWidth={2}
            dot={false}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  )
}

export default RealTimeChart
