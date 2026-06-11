import MainLayout from '../Layout/MainLayout.jsx';
import MetricCard from './MetricCard.jsx';
import StatusSidebar from '../Layout/StatusSidebar.jsx';
import RealTimeChart from './RealTimeChart.jsx';
import useSensorData from '../../hooks/useSensorData.jsx';
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
    changeTimeRange
  } = useSensorData();

  const handleLogout = () => {
    api.logout();
    window.location.href = '/';
  };

  if (loading) {
    return (
      <MainLayout onLogout={handleLogout}>
        <div className="loading-container">
          <div className="loading">Cargando datos de sensores...</div>
        </div>
      </MainLayout>
    );
  }

  if (error && !sensorData) {
    return (
      <MainLayout onLogout={handleLogout}>
        <div className="error-container">
          <div className="error">{error}</div>
        </div>
      </MainLayout>
    );
  }

  const temp = sensorData?.temperatura?.valor ?? 0;
  const hum = sensorData?.humedad?.valor ?? 0;
  const lum = sensorData?.luminosidad?.valor ?? 0;
  const soil = sensorData?.humedad_suelo?.valor ?? 0;
  const batteryValue = batteryData;

  return (
    <MainLayout onLogout={handleLogout}>
      <div className="dashboard-container">
        <div className="dashboard-main">
          <div className="dashboard-header">
            <h2>Panel de Monitoreo en Tiempo Real</h2>
          </div>

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
              title="Luminosidad"
              value={lum}
              unit="LUX"
              maxValue={1000}
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
            <div className="chart-header">
              <h3>Historial de Mediciones</h3>
              <div className="chart-legend">
                <div className="legend-item">
                  <span className="legend-color temp"></span>
                  <span>Temperatura (C)</span>
                </div>
                <div className="legend-item">
                  <span className="legend-color humidity"></span>
                  <span>Humedad (%)</span>
                </div>
              </div>
            </div>
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
