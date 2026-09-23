import { useCallback, useMemo, useRef, useState } from 'react';
import { useSensorDataContext } from '../../hooks/useSensorData.jsx';
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

const formatLocalDate = (timestamp) => {
  if (!timestamp) return '';
  const date = new Date(timestamp);
  if (Number.isNaN(date.getTime())) return '';
  return date.toLocaleDateString('en-CA', { timeZone: 'America/Bogota' });
};

// Fix 3A: por defecto la lectura de la SD se corta un dia antes del actual para
// que la rafaga no se vuelva infinita mientras el nodo sigue guardando medidas.
const getTodayBogota = () => {
  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone: 'America/Bogota',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).formatToParts(new Date());
  const byType = Object.fromEntries(parts.filter((p) => p.type !== 'literal').map((p) => [p.type, p.value]));
  return `${byType.year}-${byType.month}-${byType.day}`;
};

const getYesterdayBogota = () => {
  const today = new Date(`${getTodayBogota()}T12:00:00`);
  today.setDate(today.getDate() - 1);
  return today.toISOString().slice(0, 10);
};

// Convierte las filas por sensor de la API en fotos (snapshots) por segundo,
// conservando las 4 variables en una sola fila para compararlas con la SD.
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
  const {
    serial,
    isMeasuring,
    observationActive,
    observationError,
    sdObservationRecords,
    startSdObservation,
    stopSdObservation,
    clearSdObservation,
  } = useSensorDataContext();

  const [cloudDate, setCloudDate] = useState('');
  const [cloudRecords, setCloudRecords] = useState([]);
  const [cloudTotal, setCloudTotal] = useState(0);
  const [cloudLoading, setCloudLoading] = useState(false);
  const [cloudError, setCloudError] = useState(null);
  const [rangeInfo, setRangeInfo] = useState(null);
  const [sdFilterDate, setSdFilterDate] = useState('');
  const [sdReadDate, setSdReadDate] = useState(getYesterdayBogota());
  const [sdPage, setSdPage] = useState(0);
  const [cloudPage, setCloudPage] = useState(0);
  const fetchingRef = useRef(false);

  const readOnlySd = () => {
    if (!serial.connected) return;
    if (isMeasuring) return;
    setCloudError(null);
    startSdObservation(sdReadDate || undefined);
  };

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
      setCloudTotal(total);
    } catch (requestError) {
      setCloudError(requestError?.message || 'No se pudo consultar la nube');
      setCloudRecords([]);
      setCloudTotal(0);
    } finally {
      setCloudLoading(false);
      fetchingRef.current = false;
    }
  }, [cloudDate]);

  const handleClear = async () => {
    await clearSdObservation();
    setCloudRecords([]);
    setCloudTotal(0);
    setCloudError(null);
    setRangeInfo(null);
    setSdFilterDate('');
    setCloudDate('');
    setSdPage(0);
    setCloudPage(0);
  };

  const comparison = useMemo(() => {
    const cloudSnapshots = pivotCloudRecords(cloudRecords);
    const cloudKeys = new Set(cloudSnapshots.map((record) => record.epochSecond));

    const filteredSd = sdObservationRecords.filter((record) => {
      if (!sdFilterDate) return true;
      return formatLocalDate(record.timestamp) === sdFilterDate;
    });
    const filteredSdKeys = new Set(filteredSd.map((record) => parseToEpochSecond(record.timestamp)));

    let coincidentes = 0;
    let soloSd = 0;
    filteredSd.forEach((record) => {
      const key = parseToEpochSecond(record.timestamp);
      if (key !== null && cloudKeys.has(key)) coincidentes += 1;
      else soloSd += 1;
    });
    const soloNube = cloudSnapshots.filter((record) => !filteredSdKeys.has(record.epochSecond)).length;

    return {
      cloudSnapshots,
      coincidentes,
      soloSd,
      soloNube,
      sdVisible: filteredSd.length,
      totalSd: sdObservationRecords.length,
    };
  }, [cloudRecords, sdObservationRecords, sdFilterDate]);

  const paginatedSd = useMemo(() => {
    const filtered = sdObservationRecords.filter((record) => {
      if (!sdFilterDate) return true;
      return formatLocalDate(record.timestamp) === sdFilterDate;
    });
    const start = sdPage * PAGE_SIZE;
    return filtered.slice(start, start + PAGE_SIZE);
  }, [sdObservationRecords, sdFilterDate, sdPage]);

  const paginatedCloud = useMemo(() => {
    const start = cloudPage * PAGE_SIZE;
    return comparison.cloudSnapshots.slice(start, start + PAGE_SIZE);
  }, [comparison.cloudSnapshots, cloudPage]);

  const cloudKeysSet = useMemo(
    () => new Set(comparison.cloudSnapshots.map((record) => record.epochSecond)),
    [comparison.cloudSnapshots]
  );

  const renderNumber = (value) => {
    if (value === null || value === undefined) return '—';
    const num = Number(value);
    return Number.isNaN(num) ? '—' : num.toLocaleString('es-CO', { maximumFractionDigits: 2 });
  };

  return (
    <div className="observation-section">
      <div className="observation-header">
        <h2>Observación de Mediciones</h2>
        <span className="observation-badge">Solo lectura</span>
      </div>

      <div className="observation-notice">
        <strong>Modo solo lectura:</strong> lee los registros de la SD y los datos de la nube sin
        modificar, sobreescribir ni eliminar nada en la base de datos ni en la tarjeta SD.
      </div>

      <div className="observation-controls">
        <label className="sync-date-control">
          <span>Leer SD hasta</span>
          <input
            type="date"
            value={sdReadDate}
            onChange={(event) => setSdReadDate(event.target.value)}
            title="El nodo deja de transmitir al llegar al primer registro posterior a esta fecha (el dia actual se excluye por defecto)"
          />
        </label>
        <button
          className="manual-measure-button"
          onClick={readOnlySd}
          disabled={!serial.connected || isMeasuring || observationActive}
          title={
            !serial.connected
              ? 'Conecta el XBee primero'
              : isMeasuring
                ? 'Detén las medidas antes de leer la SD'
                : `Leer la SD hasta ${sdReadDate} (fecha actual excluida) sin guardar nada en la nube`
          }
        >
          {observationActive ? 'Leyendo SD…' : 'Leer SD (solo lectura)'}
        </button>
        {observationActive && (
          <button className="manual-measure-button" onClick={stopSdObservation}>
            Detener lectura
          </button>
        )}

        <span className="observation-separator" />

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

      {observationActive && (
        <div className="observation-status">
          Recibiendo registros de la SD… {sdObservationRecords.length} registros leídos hasta ahora.
        </div>
      )}

      {observationError && <div className="dashboard-notice warning">{observationError}</div>}

      {cloudError && <div className="dashboard-notice warning">{cloudError}</div>}

      {rangeInfo && (
        <div className="observation-range">
          Nube: <strong>{rangeInfo.total ?? '—'}</strong> mediciones en total
          {rangeInfo.desde && <> · desde {formatDateTime(rangeInfo.desde)}</>}
          {rangeInfo.hasta && <> · hasta {formatDateTime(rangeInfo.hasta)}</>}
        </div>
      )}

      <div className="observation-summary">
        <div className="summary-card">
          <span>SD (leídas)</span>
          <strong>{comparison.totalSd}</strong>
        </div>
        <div className="summary-card">
          <span>Nube (BD)</span>
          <strong>{cloudTotal || comparison.cloudSnapshots.length}</strong>
        </div>
        <div className="summary-card warning-card">
          <span>Solo en SD (faltan en nube)</span>
          <strong>{comparison.soloSd}</strong>
        </div>
        <div className="summary-card ok-card">
          <span>Coincidentes</span>
          <strong>{comparison.coincidentes}</strong>
        </div>
        <div className="summary-card info-card">
          <span>Solo en nube</span>
          <strong>{comparison.soloNube}</strong>
        </div>
      </div>

      <div className="observation-tables">
        <div className="observation-table-block">
          <div className="observation-table-header">
            <h3>Mediciones en la SD ({comparison.sdVisible})</h3>
            <label className="sync-date-control">
              <span>Filtrar fecha</span>
              <input
                type="date"
                value={sdFilterDate}
                onChange={(event) => {
                  setSdFilterDate(event.target.value);
                  setSdPage(0);
                }}
              />
            </label>
          </div>
          {paginatedSd.length === 0 ? (
            <p className="no-data">
              Conecta el XBee y presiona “Leer SD (solo lectura)” para cargar los registros.
            </p>
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
                      <th>Batería (%)</th>
                      <th>¿En nube?</th>
                    </tr>
                  </thead>
                  <tbody>
                    {paginatedSd.map((record) => {
                      const key = parseToEpochSecond(record.timestamp);
                      const inCloud = key !== null && cloudKeysSet.has(key);
                      return (
                        <tr key={record.key || record.timestamp} className={inCloud ? '' : 'row-missing'}>
                          <td>{formatDateTime(record.timestamp)}</td>
                          <td>{renderNumber(record.temperatura)}</td>
                          <td>{renderNumber(record.humedad)}</td>
                          <td>{renderNumber(record.radiacion_solar)}</td>
                          <td>{renderNumber(record.humedad_suelo)}</td>
                          <td>{renderNumber(record.bateria)}</td>
                          <td>
                            <span className={inCloud ? 'badge-cloud' : 'badge-no-cloud'}>
                              {inCloud ? 'Sí' : 'No'}
                            </span>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
              {comparison.sdVisible > PAGE_SIZE && (
                <div className="observation-pagination">
                  <button
                    className="manual-measure-button"
                    disabled={sdPage === 0}
                    onClick={() => setSdPage((page) => page - 1)}
                  >
                    ←
                  </button>
                  <span>
                    Página {sdPage + 1} de {Math.ceil(comparison.sdVisible / PAGE_SIZE)}
                  </span>
                  <button
                    className="manual-measure-button"
                    disabled={(sdPage + 1) * PAGE_SIZE >= comparison.sdVisible}
                    onClick={() => setSdPage((page) => page + 1)}
                  >
                    →
                  </button>
                </div>
              )}
            </>
          )}
        </div>

        <div className="observation-table-block">
          <div className="observation-table-header">
            <h3>Mediciones en la nube ({comparison.cloudSnapshots.length})</h3>
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
                      <tr key={record.epochSecond} className={cloudKeysSet.has(record.epochSecond) ? '' : 'row-missing'}>
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
              {comparison.cloudSnapshots.length > PAGE_SIZE && (
                <div className="observation-pagination">
                  <button
                    className="manual-measure-button"
                    disabled={cloudPage === 0}
                    onClick={() => setCloudPage((page) => page - 1)}
                  >
                    ←
                  </button>
                  <span>
                    Página {cloudPage + 1} de {Math.ceil(comparison.cloudSnapshots.length / PAGE_SIZE)}
                  </span>
                  <button
                    className="manual-measure-button"
                    disabled={(cloudPage + 1) * PAGE_SIZE >= comparison.cloudSnapshots.length}
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