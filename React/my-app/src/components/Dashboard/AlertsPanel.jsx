import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../../services/api.jsx';
import { useSensorDataContext } from '../../hooks/useSensorData.jsx';
import {
  getUmbrales,
  evaluarAlertas,
  computarResumenDiario,
  formatHoraBogota,
} from '../../utils/umbrales.jsx';
import '../../styles/index.css';

const getTodayLocalDate = () => {
  const now = new Date();
  const local = new Date(now.getTime() - now.getTimezoneOffset() * 60000);
  return local.toISOString().slice(0, 10);
};

const unwrapApiData = (payload) => {
  if (!payload) return [];
  if (Object.prototype.hasOwnProperty.call(payload, 'data')) return payload.data;
  return payload;
};

const estadoLabel = (estado) => {
  const labels = {
    ok: 'OK',
    bajo: 'Bajo',
    alto: 'Alto',
    'sin-datos': 'Sin datos',
  };
  return labels[estado] || estado;
};

const formatNumero = (value) => {
  const numero = Number(value);
  return Number.isFinite(numero)
    ? numero.toLocaleString('es-CO', { maximumFractionDigits: 1 })
    : '—';
};

const formatMinutos = (minutos) => {
  if (minutos === null || minutos === undefined || !Number.isFinite(minutos)) return '—';
  if (minutos < 60) return `${Math.round(minutos)} min`;
  const horas = Math.floor(minutos / 60);
  const resto = Math.round(minutos % 60);
  return `${horas}h ${resto}min`;
};

function AlertsPanel() {
  const { sensorData } = useSensorDataContext();
  const [umbrales, setUmbrales] = useState(getUmbrales);
  const [dayDate, setDayDate] = useState(getTodayLocalDate);
  const [dayLoading, setDayLoading] = useState(false);
  const [dayError, setDayError] = useState(null);
  const [dayResumen, setDayResumen] = useState(null);

  useEffect(() => {
    const syncUmbrales = () => setUmbrales(getUmbrales());
    window.addEventListener('sigma-umbrales-updated', syncUmbrales);
    return () => window.removeEventListener('sigma-umbrales-updated', syncUmbrales);
  }, []);

  const alertas = useMemo(() => evaluarAlertas(sensorData, umbrales), [sensorData, umbrales]);
  const alertasActivas = alertas.filter((alerta) => alerta.estado === 'bajo' || alerta.estado === 'alto');

  const fetchResumen = useCallback(async () => {
    if (!dayDate) return;

    setDayLoading(true);
    setDayError(null);
    try {
      const payload = await api.getHistoricalDataByFilters({ fecha: dayDate });
      const registros = unwrapApiData(payload);
      setDayResumen(computarResumenDiario(registros, umbrales));
    } catch (requestError) {
      setDayError(requestError?.message || 'No se pudo consultar el resumen del día');
      setDayResumen(null);
    } finally {
      setDayLoading(false);
    }
  }, [dayDate, umbrales]);

  const allWithoutData = alertas.every((alerta) => alerta.estado === 'sin-datos');

  return (
    <div className="alerts-section">
      <div className="alerts-header">
        <h2>Alertas del cultivo</h2>
        <span className={`alerts-count ${alertasActivas.length > 0 ? 'has-alerts' : ''}`}>
          {alertasActivas.length} {alertasActivas.length === 1 ? 'alerta' : 'alertas'}
        </span>
      </div>

      <div className="alerts-grid">
        {alertas.map((alerta) => (
          <div key={alerta.key} className={`alert-card status-${alerta.estado}`}>
            <div className="alert-card-top">
              <span className="alert-dot" style={{ background: alerta.color }} />
              <h3>{alerta.label}</h3>
              <span className={`alert-status status-${alerta.estado}`}>{estadoLabel(alerta.estado)}</span>
            </div>
            <div className="alert-value">
              {alerta.valor !== null ? `${formatNumero(alerta.valor)} ${alerta.unidad}` : '—'}
            </div>
            <div className="alert-range">
              {alerta.umbral
                ? `Rango: ${formatNumero(alerta.umbral.min)} – ${formatNumero(alerta.umbral.max)} ${alerta.unidad}`
                : 'Umbral sin configurar'}
            </div>
          </div>
        ))}
      </div>

      <p className={`alerts-ok ${alertasActivas.length === 0 ? '' : 'hidden'}`}>
        {allWithoutData
          ? 'Conecta el XBee o espera lecturas para evaluar los umbrales.'
          : 'Ninguna lectura fuera de rango. El cultivo está dentro de los umbrales configurados.'}
      </p>

      <div className="alerts-divider" />

      <div className="alerts-resumen-header">
        <h3>Resumen diario (mínimo, máximo y tiempo fuera de rango)</h3>
        <div className="alerts-resumen-controls">
          <label className="sync-date-control">
            <span>Fecha</span>
            <input
              type="date"
              value={dayDate}
              max={getTodayLocalDate()}
              onChange={(event) => setDayDate(event.target.value)}
            />
          </label>
          <button
            className="manual-measure-button"
            onClick={fetchResumen}
            disabled={dayLoading || !dayDate}
          >
            {dayLoading ? 'Consultando…' : 'Consultar día'}
          </button>
        </div>
      </div>

      {dayError && <div className="dashboard-notice warning">{dayError}</div>}

      {dayResumen ? (
        <div className="alerts-table-scroll">
          <table className="alerts-table">
            <thead>
              <tr>
                <th>Variable</th>
                <th>Mínimo (hora)</th>
                <th>Máximo (hora)</th>
                <th>Muestras</th>
                <th>Fuera de rango bajo</th>
                <th>Fuera de rango alto</th>
              </tr>
            </thead>
            <tbody>
              {dayResumen.map((fila) => (
                <tr key={fila.sensor}>
                  <td>
                    <span className="alert-dot" style={{ background: fila.color }} />
                    <span>{fila.label} ({fila.unidad})</span>
                  </td>
                  <td>
                    {fila.min !== null
                      ? `${formatNumero(fila.min)} (${formatHoraBogota(fila.min_timestamp)})`
                      : '—'}
                  </td>
                  <td>
                    {fila.max !== null
                      ? `${formatNumero(fila.max)} (${formatHoraBogota(fila.max_timestamp)})`
                      : '—'}
                  </td>
                  <td>{fila.muestras}</td>
                  <td>{formatMinutos(fila.minutos_bajo)}</td>
                  <td>{formatMinutos(fila.minutos_alto)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <p className="no-data">
          Selecciona una fecha y presiona "Consultar día" para ver el mínimo, el máximo y cuántos
          minutos cada variable estuvo fuera de su rango.
        </p>
      )}
    </div>
  );
}

export default AlertsPanel;