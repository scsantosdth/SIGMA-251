import MainLayout from '../Layout/MainLayout.jsx';
import MetricCard from './MetricCard.jsx';
import StatusSidebar from '../Layout/StatusSidebar.jsx';
import RealTimeChart from './RealTimeChart.jsx';
import { useSensorDataContext } from '../../hooks/useSensorData.jsx';
import { api } from '../../services/api.jsx';
import '../../styles/index.css';

function Dashboard() {
  const {
    sensorData,
    batteryData,
    historicalData,
    timeRange,
    loading,
    error,
    offline,
    serial,
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

  const handleSerialClick = () => {
    if (serial.connected) {
      serial.disconnect();
      return;
    }

    serial.connect();
  };

  const handlePingClick = async () => {
    try {
      await serial.sendCommand('PING');
    } catch (commandError) {
      console.error('Error enviando PING:', commandError);
    }
  };

  const handleSyncTestClick = async () => {
    try {
      await serial.sendCommand('SYNC_SD');
    } catch (commandError) {
      console.error('Error enviando SYNC_SD:', commandError);
    }
  };

  return (
    <MainLayout onLogout={handleLogout} batteryData={batteryValue}>
      <div className="dashboard-container">
        <div className="dashboard-main">
          <div className="dashboard-header">
            <h2>Panel de Monitoreo en Tiempo Real</h2>
            <div className="dashboard-actions">
              <button
                className={`xbee-connect-button ${serial.connected ? 'connected' : ''}`}
                onClick={handleSerialClick}
                disabled={!serial.supported || serial.connecting}
                title={!serial.supported ? 'Disponible en Chrome o Edge con HTTPS/local' : 'Abrir selector de puerto serial'}
              >
                {serialLabel}
              </button>
              <button
                className="xbee-connect-button"
                onClick={handlePingClick}
                disabled={!serial.connected}
                title="Envía PING al Waspmote y espera PONG"
              >
                Probar petición
              </button>
              <button
                className="xbee-connect-button"
                onClick={handleSyncTestClick}
                disabled={!serial.connected}
                title="Prueba la petición de sincronización SD"
              >
                Sincronizar SD
              </button>
            </div>
            {serial.commandStatus && (
              <div className="serial-command-status">{serial.commandStatus}</div>
            )}
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
              title="Humedad Suelo"
              value={soil}
              unit="%"
              maxValue={100}
              trend="stable"
            />
          </div>

          <div className="chart-section">
            <RealTimeChart
              historicalData={historicalData}
              timeRange={timeRange}
              onTimeRangeChange={changeTimeRange}
            />
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
