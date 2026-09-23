import { useState } from 'react';
import MainLayout from '../Layout/MainLayout.jsx';
import MetricCard from './MetricCard.jsx';
import StatusSidebar from '../Layout/StatusSidebar.jsx';
import RealTimeChart from './RealTimeChart.jsx';
import SdObservationPanel from './SdObservationPanel.jsx';
import { useSensorDataContext } from '../../hooks/useSensorData.jsx';
import { api } from '../../services/api.jsx';
import '../../styles/index.css';

function Dashboard() {
  const [syncDate, setSyncDate] = useState('');
  const {
    sensorData,
    batteryData,
    historicalData,
    syncedHistoryDate,
    timeRange,
    loading,
    error,
    offline,
    serial,
    isMeasuring,
    startMeasurements,
    stopMeasurements,
    prepareSdHistoryDate,
    changeTimeRange
  } = useSensorDataContext();

  const handleLogout = () => {
    api.logout();
    window.location.href = '/';
  };

  const temp = sensorData?.temperatura?.valor ?? 0;
  const hum = sensorData?.humedad?.valor ?? 0;
  const radiacionSolar = sensorData?.radiacion_solar?.valor ?? 0;
  const soil = sensorData?.humedad_suelo?.valor ?? null;
  const batteryValue = batteryData;
  const serialLabel = serial.connected
    ? 'Desconectar XBee'
    : serial.connecting
      ? 'Conectando...'
      : 'Conectar XBee';
  const measurementsLabel = isMeasuring ? 'Detener medidas' : 'Iniciar medidas';

  const handleSerialClick = () => {
    if (isMeasuring) return;

    if (serial.connected) {
      serial.disconnect();
      return;
    }

    serial.connect();
  };

  const handleSyncClick = async () => {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(syncDate)) return;

    const waspmoteDate = syncDate.replaceAll('-', '').slice(2);

    try {
      prepareSdHistoryDate(syncDate);
      await serial.sendCommand(`SYNC_SD:${waspmoteDate}`);
      console.info(`Comando SYNC_SD enviado para la fecha ${waspmoteDate}`);
    } catch (commandError) {
      console.error('Error enviando SYNC_SD con fecha:', commandError);
    }
  };

  const handleMeasurementsClick = () => {
    if (isMeasuring) {
      stopMeasurements();
      return;
    }

    startMeasurements();
  };

  return (
    <MainLayout onLogout={handleLogout} batteryData={batteryValue}>
      <div className="dashboard-container">
        <div className="dashboard-main">
          <div className="dashboard-header">
            <h2>Panel de Monitoreo</h2>
            <div className="dashboard-actions">
              <button
                className={`xbee-connect-button ${serial.connected ? 'connected' : ''}`}
                onClick={handleSerialClick}
                disabled={!serial.supported || serial.connecting || isMeasuring}
                title={!serial.supported
                  ? 'Disponible en Chrome o Edge con HTTPS/local'
                  : isMeasuring
                    ? 'Detén las medidas antes de desconectar el XBee'
                    : 'Abrir selector de puerto serial'}
              >
                {serialLabel}
              </button>
              <button
                className={`manual-measure-button ${isMeasuring ? 'active' : ''}`}
                onClick={handleMeasurementsClick}
                disabled={!serial.connected}
                title={isMeasuring
                  ? 'Detener el procesamiento de mediciones en tiempo real'
                  : 'Mostrar y guardar las mediciones recibidas del XBee'}
              >
                {measurementsLabel}
              </button>
              <label className="sync-date-control">
                <span>Fecha SD</span>
                <input
                  type="date"
                  value={syncDate}
                  onChange={(event) => setSyncDate(event.target.value)}
                  disabled={isMeasuring}
                  aria-label="Fecha que se sincronizara desde la tarjeta SD"
                />
              </label>
              <button
                className="manual-measure-button sync-sd-button"
                onClick={handleSyncClick}
                disabled={!serial.connected || isMeasuring || !syncDate}
                title={isMeasuring
                  ? 'Detén las medidas antes de sincronizar la memoria SD'
                  : 'Sincronizar registros conservados en la memoria SD'}
              >
                Sincronizar SD
              </button>
            </div>
          </div>

          {(loading || error || serial.error || offline) && (
            <div className={`dashboard-notice ${error || serial.error ? 'warning' : 'info'}`}>
              {serial.error || error || (offline ? 'Modo offline activo. Las lecturas se guardaran localmente.' : 'Cargando datos de sensores...')}
            </div>
          )}

          <div className="metrics-grid">
            <MetricCard
              title="Temperatura"
              value={temp}
              unit="C"
              maxValue={50}
              trend="stable"
            />
            <MetricCard
              title="Humedad Ambiental"
              value={hum}
              unit="%"
              maxValue={100}
              trend="up"
            />
            <MetricCard
              title="Radiacion Solar"
              value={radiacionSolar}
              unit="W/m²"
              maxValue={1600}
              trend="down"
            />
            <MetricCard
              title="Tension Agua Suelo"
              value={soil}
              unit="cbar"
              maxValue={200}
              trend="stable"
            />
          </div>

          <div className="chart-section">
            <RealTimeChart
              historicalData={historicalData}
              syncedHistoryDate={syncedHistoryDate}
              timeRange={timeRange}
              onTimeRangeChange={changeTimeRange}
            />
          </div>

          <div className="chart-section">
            <SdObservationPanel />
          </div>
        </div>

        <div className="dashboard-sidebar">
          <StatusSidebar batteryData={batteryValue} />
        </div>
      </div>
    </MainLayout>
  );
}

export default Dashboard;
