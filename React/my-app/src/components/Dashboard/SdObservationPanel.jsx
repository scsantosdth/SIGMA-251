import { useCallback, useMemo, useRef, useState } from 'react';
import { api } from '../../services/api.jsx';
import '../../styles/index.css';

const PAGE_SIZE = 100;
const MAX_FETCH_PAGES = 100;
const MAX_FETCH_ROWS = 500000;

const parseToEpochSecond = (timestamp) => {
  if (!timestamp) return null;
  const hasTimezone = /(?:Z|[+-]\d{2}:?\d{2})$/i.test(String(timestamp));
  const date = new Date(hasTimezone ? timestamp : `${timestamp}Z`);
  if (Number.isNaN(date.getTime())) return null;
  return Math.floor(date.getTime() / 1000);
};

const formatDateTime = (timestamp) => {
  if (!timestamp) return '—';
  const date = new Date(timestamp);
  if (Number.isNaN(date.getTime())) return String(timestamp);
  return date.toLocaleString('es-CO', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    timeZone: 'America/Bogota',
  });
};

// Convierte las filas por sensor de la API en fotos (snapshots) por segundo,
// conservando las 4 variables en una sola fila para mostrarlas juntas.
const pivotCloudRecords = (records) => {
  const snapshots = new Map();
  (records || []).forEach((record) => {
    if (!record || record.sensor === undefined) return;
    const key = parseToEpochSecond(record.timestamp);
    if (key === null) return;

    if (!snapshots.has(key)) {
      snapshots.set(key, {
        epochSecond: key,
        timestamp: record.timestamp,
        source: 'cloud',
        temperatura: null,
        humedad: null,
        radiacion_solar: null,
        humedad_suelo: null,
      });
    }
    snapshots.get(key)[record.sensor] = record.valor;
  });
  return Array.from(snapshots.values()).sort((a, b) => a.epochSecond - b.epochSecond);
};

function SdObservationPanel() {
  const [cloudDate, setCloudDate] = useState('');
  const [cloudRecords, setCloudRecords] = useState([]);
  const [cloudLoading, setCloudLoading] = useState(false);
  const [cloudError, setCloudError] = useState(null);
  const [rangeInfo, setRangeInfo] = useState(null);
  const [cloudPage, setCloudPage] = useState(0);
  const fetchingRef = useRef(false);

  const fetchRange = useCallback(async () => {
    setCloudLoading(true);
    setCloudError(null);
    try {
      const payload = await api.getObservacionRango();
      setRangeInfo({ ...(payload?.data || payload), status: payload?.status });
    } catch (requestError) {
      setCloudError(requestError?.message || 'No se pudo consultar el rango en la nube');
      setRangeInfo(null);
    } finally {
      setCloudLoading(false);
    }
  }, []);

  const fetchCloud = useCallback(async () => {
    if (fetchingRef.current) return;
    fetchingRef.current = true;
    setCloudLoading(true);
    setCloudError(null);
    setCloudPage(0);

    try {
      const params = { limite: 5000, offset: 0 };
      if (cloudDate) params.fecha = cloudDate;
      const first = await api.getObservacionMediciones(params);
      const firstData = first?.data || [];
      const total = first?.total ?? firstData.length;

      // Recorrer todo el historico (o el dia completo) con paginacion.
      // Solo lectura: no se modifica nada en la base de datos.
      let all = [...firstData];
      let offset = firstData.length;
      let pages = 1;
      while (offset < total && pages < MAX_FETCH_PAGES && all.length < MAX_FETCH_ROWS) {
        const next = await api.getObservacionMediciones({ ...params, offset });
        const batch = next?.data || [];
        if (batch.length === 0) break;
        all = [...all, ...batch];
        offset += batch.length;
        pages += 1;
      }
      setCloudRecords(all);
    } catch (requestError) {
      setCloudError(requestError?.message || 'No se pudo consultar la nube');
      setCloudRecords([]);
    } finally {
      setCloudLoading(false);
      fetchingRef.current = false;
    }
  }, [cloudDate]);

  const handleClear = () => {
    setCloudRecords([]);
    setCloudError(null);
    setRangeInfo(null);
    setCloudDate('');
    setCloudPage(0);
  };

  const cloudSnapshotsTotal = useMemo(
    () => pivotCloudRecords(cloudRecords).length,
    [cloudRecords]
  );

  const paginatedCloud = useMemo(() => {
    const start = cloudPage * PAGE_SIZE;
    return pivotCloudRecords(cloudRecords).slice(start, start + PAGE_SIZE);
  }, [cloudRecords, cloudPage]);

  const renderNumber = (value) => {
    if (value === null || value === undefined) return '—';
    const num = Number(value);
    return Number.isNaN(num) ? '—' : num.toLocaleString('es-CO', { maximumFractionDigits: 2 });
  };

  return (
    <div className="observation-section">
      <div className="observation-header">
        <h2>Mediciones en la Nube</h2>
        <span className="observation-badge">Solo lectura</span>
      </div>

      <div className="observation-notice">
        <strong>Modo solo lectura:</strong> consulta los registros subidos a la base de datos sin
        modificar ni eliminar nada. Para subir los registros de la tarjeta SD usa el botón
        “Sincronizar SD” del panel superior.
      </div>

      <div className="observation-controls">
        <label className="sync-date-control">
          <span>Fecha nube</span>
          <input
            type="date"
            value={cloudDate}
            onChange={(event) => {
              setCloudDate(event.target.value);
              setCloudPage(0);
            }}
          />
        </label>
        <button
          className="manual-measure-button"
          onClick={fetchCloud}
          disabled={cloudLoading}
          title="Consultar mediciones en la base de datos (sin fecha = todo el historico)"
        >
          {cloudLoading ? 'Consultando…' : cloudDate ? 'Consultar nube (fecha)' : 'Consultar nube (todo)'}
        </button>
        <button
          className="manual-measure-button"
          onClick={fetchRange}
          disabled={cloudLoading}
          title="Periodo de fechas cubierto por la base de datos"
        >
          Rango nube
        </button>
        <button className="manual-measure-button" onClick={handleClear}>
          Limpiar
        </button>
      </div>

      {cloudError && <div className="dashboard-notice warning">{cloudError}</div>}

      {rangeInfo && (
        <div className="observation-range">
          Nube: <strong>{rangeInfo.total ?? '—'}</strong> mediciones en total
          {rangeInfo.desde && <> · desde {formatDateTime(rangeInfo.desde)}</>}
          {rangeInfo.hasta && <> · hasta {formatDateTime(rangeInfo.hasta)}</>}
        </div>
      )}

      <div className="observation-tables">
        <div className="observation-table-block">
          <div className="observation-table-header">
            <h3>Mediciones en la nube ({cloudSnapshotsTotal})</h3>
          </div>
          {paginatedCloud.length === 0 ? (
            <p className="no-data">Presiona “Consultar nube” para cargar los datos de la base de datos.</p>
          ) : (
            <>
              <div className="observation-table-scroll">
                <table className="observation-table">
                  <thead>
                    <tr>
                      <th>Fecha y hora</th>
                      <th>Temp (°C)</th>
                      <th>Hum (%)</th>
                      <th>Rad (W/m²)</th>
                      <th>Suelo (cbar)</th>
                    </tr>
                  </thead>
                  <tbody>
                    {paginatedCloud.map((record) => (
                      <tr key={record.epochSecond}>
                        <td>{formatDateTime(record.timestamp)}</td>
                        <td>{renderNumber(record.temperatura)}</td>
                        <td>{renderNumber(record.humedad)}</td>
                        <td>{renderNumber(record.radiacion_solar)}</td>
                        <td>{renderNumber(record.humedad_suelo)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              {cloudSnapshotsTotal > PAGE_SIZE && (
                <div className="observation-pagination">
                  <button
                    className="manual-measure-button"
                    disabled={cloudPage === 0}
                    onClick={() => setCloudPage((page) => page - 1)}
                  >
                    ←
                  </button>
                  <span>
                    Página {cloudPage + 1} de {Math.ceil(cloudSnapshotsTotal / PAGE_SIZE)}
                  </span>
                  <button
                    className="manual-measure-button"
                    disabled={(cloudPage + 1) * PAGE_SIZE >= cloudSnapshotsTotal}
                    onClick={() => setCloudPage((page) => page + 1)}
                  >
                    →
                  </button>
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  );
}

export default SdObservationPanel;