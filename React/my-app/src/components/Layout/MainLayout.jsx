import { useEffect, useState } from 'react';
import Header from './Header.jsx';
import NavigationSidebar from './NavigationSidebar.jsx';
import { applyTheme, getTheme } from '../../utils/theme.jsx';
import '../../styles/index.css';
import { api } from '../../services/api.jsx';

function MainLayout({ children, onLogout, batteryData }) {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  useEffect(() => {
    applyTheme(getTheme());
  }, []);

  const toggleSidebar = () => {
    setSidebarOpen(!sidebarOpen);
  };

  const closeSidebar = () => {
    setSidebarOpen(false);
  };

  const handleManualMeasure = async () => {
    try {
      const response = await api.postManualMeasurement();
      alert(response.message || 'Medicion manual guardada');
    } catch (error) {
      console.error('Error en medicion manual:', error);
      alert('Error al guardar medicion manual. Revisa la consola.');
    }
  };

  return (
    <div className="main-layout">
      <NavigationSidebar
        isOpen={sidebarOpen}
        onClose={closeSidebar}
        onLogout={onLogout}
      />

      <div className="layout-content">
        <Header
          onToggleSidebar={toggleSidebar}
          onManualMeasure={handleManualMeasure}
          batteryData={batteryData}
        />

        <main className="main-content">
          {children}
        </main>

        <footer className="layout-footer">
          <div className="footer-content">
            <span>(c) 2025 SIGMA - Sistema de Monitoreo Ambiental</span>
            <span>Universidad Industrial de Santander</span>
          </div>
        </footer>
      </div>
    </div>
  );
}

export default MainLayout;
