import { useCallback, useEffect, useMemo, useState } from 'react'
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'
import { api } from '../../services/api.jsx'

const SENSOR_DEFS = [
  { key: 'temperatura', label: 'Temperatura (°C)', color: '#ff6b6b', axis: 'left' },
  { key: 'humedad', label: 'Humedad (%)', color: '#4ecdc4', axis: 'left' },
  { key: 'radiacion_solar', label: 'Radiación solar (W/m²)', color: '#ffd93d', axis: 'right' },
  { key: 'humedad_suelo', label: 'Tensión agua suelo (cbar)', color: '#6c5ce7', axis: 'left' },
]

const ALL_SENSOR_KEYS = SENSOR_DEFS.map((def) => def.key)

const HOURS = Array.from({ length: 24 }, (_, hour) => hour)

const parseMeasurementTimestamp = (timestamp) => {
  if (typeof timestamp !== 'string') return new Date(timestamp)

  // Las filas antiguas de Supabase se guardaron como TIMESTAMP sin zona. En
  // produccion esas marcas representan UTC, por lo que se agrega Z antes de
  // convertirlas para no interpretarlas equivocadamente como hora local.
  const hasTimezone = /(?:Z|[+-]\d{2}:?\d{2})$/i.test(timestamp)
  return new Date(hasTimezone ? timestamp : `${timestamp}Z`)
}

const unwrapApiData = (payload) => {
  if (!payload) return []
  if (Object.prototype.hasOwnProperty.call(payload, 'data')) return payload.data
  return payload
}

const getTodayLocalDate = () => {
  const now = new Date()
  const local = new Date(now.getTime() - now.getTimezoneOffset() * 60000)
  return local.toISOString().slice(0, 10)
}

// Procesar datos para Recharts - version SEGURA
const processChartData = (records) => {
  if (!Array.isArray(records)) return []

  const dataByTime = {}

  records.forEach((item) => {
    if (!item) return // Saltar items null

    const rawDate = parseMeasurementTimestamp(item.timestamp)
    if (Number.isNaN(rawDate.getTime())) return

    // Agrupar por segundo para no perder lecturas distintas que comparten el mismo minuto
    const timeKey = rawDate.toISOString().slice(0, 19)
    const time = rawDate.toLocaleString('es-CO', {
      day: '2-digit',
      month: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      timeZone: 'America/Bogota'
    })

    if (!dataByTime[timeKey]) {
      dataByTime[timeKey] = { time, timeKey }
    }

    if (item.sensor && Object.prototype.hasOwnProperty.call(item, 'valor')) {
      dataByTime[timeKey][item.sensor] = item.valor ?? 0
    } else {
      // Usar valores directamente (sin .sensor ni .valor)
      dataByTime[timeKey].temperatura = item.temperatura ?? null
      dataByTime[timeKey].humedad = item.humedad ?? null
      dataByTime[timeKey].radiacion_solar = item.radiacion_solar ?? null
      dataByTime[timeKey].humedad_suelo = item.humedad_suelo ?? null
    }
  })

  return Object.values(dataByTime).sort((a, b) => a.timeKey.localeCompare(b.timeKey))
}

function RealTimeChart({ historicalData, syncedHistoryDate, timeRange, onTimeRangeChange }) {
  const [mode, setMode] = useState('live')
  const [dayDate, setDayDate] = useState(getTodayLocalDate)
  const [dayHour, setDayHour] = useState('')
  const [selectedSensors, setSelectedSensors] = useState(ALL_SENSOR_KEYS)
  const [dayData, setDayData] = useState(null)
  const [dayLoading, setDayLoading] = useState(false)
  const [dayError, setDayError] = useState(null)

  // Opciones de tiempo (vista en vivo)
  const timeOptions = [
    { value: 1, label: '1 Hora' },
    { value: 6, label: '6 Horas' },
    { value: 24, label: '24 Horas' }
  ]

  const fetchDayHistory = useCallback(async () => {
    if (!dayDate) return

    setDayLoading(true)
    setDayError(null)

    try {
      const payload = await api.getHistoricalDataByFilters({
        fecha: dayDate,
        hora: dayHour === '' ? undefined : dayHour,
      })
      setDayData(unwrapApiData(payload))
    } catch (requestError) {
      setDayError(requestError?.message || 'No se pudo consultar el histórico')
      setDayData(null)
    } finally {
      setDayLoading(false)
    }
  }, [dayDate, dayHour])

  // Al entrar en la vista por dia se consulta automaticamente.
  useEffect(() => {
    if (mode === 'day') {
      fetchDayHistory()
    }
  }, [mode]) // eslint-disable-line react-hooks/exhaustive-deps

  const toggleSensor = (key) => {
    setSelectedSensors((prev) =>
      prev.includes(key) ? prev.filter((item) => item !== key) : [...prev, key]
    )
  }

  const visibleSensors = SENSOR_DEFS.filter((def) => selectedSensors.includes(def.key))
  const leftAxisSensors = visibleSensors.filter((def) => def.axis === 'left')
  const rightAxisSensors = visibleSensors.filter((def) => def.axis === 'right')

  const sourceRecords = mode === 'day' ? dayData : historicalData
  const chartData = useMemo(() => processChartData(sourceRecords), [sourceRecords])

  const renderModeButtons = () => (
    <div className="time-filters">
      <button
        className={`time-filter ${mode === 'live' ? 'active' : ''}`}
        onClick={() => setMode('live')}
      >
        En vivo
      </button>
      <button
        className={`time-filter ${mode === 'day' ? 'active' : ''}`}
        onClick={() => setMode('day')}
      >
        Por día
      </button>
    </div>
  )

  const renderDayFilters = () => (
    <div className="history-filters">
      <label className="history-filter-field">
        <span>Fecha</span>
        <input
          type="date"
          value={dayDate}
          max={getTodayLocalDate()}
          onChange={(event) => setDayDate(event.target.value)}
        />
      </label>

      <label className="history-filter-field">
        <span>Hora</span>
        <select value={dayHour} onChange={(event) => setDayHour(event.target.value)}>
          <option value="">Todo el día</option>
          {HOURS.map((hour) => (
            <option key={hour} value={hour}>
              {String(hour).padStart(2, '0')}:00
            </option>
          ))}
        </select>
      </label>

      <div className="history-sensor-toggles">
        <span className="history-filter-label">Variables</span>
        {SENSOR_DEFS.map((def) => (
          <label key={def.key} className="history-sensor-check">
            <input
              type="checkbox"
              checked={selectedSensors.includes(def.key)}
              onChange={() => toggleSensor(def.key)}
            />
            <span style={{ color: def.color }}>{def.label}</span>
          </label>
        ))}
      </div>

      <button
        className="time-filter"
        onClick={fetchDayHistory}
        disabled={dayLoading || !dayDate}
      >
        {dayLoading ? 'Consultando...' : 'Consultar'}
      </button>
    </div>
  )

  const renderNotice = () => {
    if (mode !== 'day') return null

    if (dayLoading) {
      return <div className="chart-note">Cargando mediciones del día seleccionado...</div>
    }

    if (dayError) {
      return <div className="chart-note warning">{dayError}</div>
    }

    if (visibleSensors.length === 0) {
      return <div className="chart-note warning">Selecciona al menos una variable para graficar.</div>
    }

    return null
  }

  if (chartData.length === 0) {
    return (
      <div className="chart-container">
        <div className="chart-header">
          <h2>Registro Histórico</h2>
          {renderModeButtons()}
        </div>

        {mode === 'day' && renderDayFilters()}
        {renderNotice()}

        <div className="no-data">
          <p>
            {mode === 'day'
              ? 'No hay datos para la fecha y hora seleccionadas'
              : 'No hay datos disponibles'}
          </p>
        </div>
      </div>
    )
  }

  return (
    <div className="chart-container">
      <div className="chart-header">
        <h2>Registro Histórico</h2>
        {syncedHistoryDate && mode === 'live' && (
          <span className="sync-history-label">
            Datos sincronizados: {syncedHistoryDate}
          </span>
        )}
        {renderModeButtons()}
        {mode === 'live' && (
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
        )}
      </div>

      {mode === 'day' && renderDayFilters()}
      {renderNotice()}

      <div className="chart-with-axis-labels">
        <div className="chart-axis-labels chart-axis-labels-left" aria-label="Variables del eje izquierdo">
          {leftAxisSensors.length > 1 && (
            <div className="chart-axis-labels-left-group">
              {leftAxisSensors.slice(0, -1).map((def) => (
                <span key={def.key} className="chart-axis-label" style={{ color: def.color }}>
                  {def.label}
                </span>
              ))}
            </div>
          )}
          {leftAxisSensors.slice(-1).map((def) => (
            <span key={def.key} className="chart-axis-label" style={{ color: def.color }}>
              {def.label}
            </span>
          ))}
        </div>

        <ResponsiveContainer width="100%" height={320}>
        <LineChart data={chartData} margin={{ top: 10, right: 0, left: 0, bottom: 25 }}>
          <CartesianGrid yAxisId="left" strokeDasharray="3 3" stroke="#333" />
          <XAxis 
            dataKey="time" 
            stroke="#9e9e9e"
            fontSize={12}
            height={40}
            label={{
              value: 'Fecha y hora',
              position: 'bottom',
              offset: 0,
              fill: '#9e9e9e',
              fontSize: 12
            }}
          />
          <YAxis
            yAxisId="left"
            stroke="#cbd5e1"
            tick={{ fill: '#cbd5e1', fontSize: 12 }}
            width={44}
          />
          <YAxis
            yAxisId="right"
            orientation="right"
            stroke="#ffd93d"
            tick={{ fill: '#ffd93d', fontSize: 12 }}
            width={36}
          />
          <Tooltip 
            contentStyle={{ 
              backgroundColor: '#1e1e1e', 
              border: '1px solid #333',
              borderRadius: '8px'
            }}
          />
          {visibleSensors.map((def) => (
            <Line
              key={def.key}
              type="monotone"
              dataKey={def.key}
              yAxisId={def.axis}
              stroke={def.color}
              name={def.label}
              strokeWidth={2}
              dot={false}
              connectNulls
            />
          ))}
        </LineChart>
        </ResponsiveContainer>

        <div className="chart-axis-labels chart-axis-labels-right" aria-label="Variable del eje derecho">
          {rightAxisSensors.map((def) => (
            <span key={def.key} className="chart-axis-label" style={{ color: def.color }}>
              {def.label}
            </span>
          ))}
        </div>
      </div>
    </div>
  )
}

export default RealTimeChart
