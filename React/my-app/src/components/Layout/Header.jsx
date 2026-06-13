// src/components/Layout/Header.jsx
import { useEffect, useState } from 'react';
import '../../styles/index.css';
import OfflineStorageIndicator from '../Dashboard/OfflineStorageIndicator.jsx';

function Header({ onLogout, onToggleSidebar, onManualMeasure }) {
  const [isOnline, setIsOnline] = useState(true);

  useEffect(() => {
    const checkConnection = async () => {
      if (typeof navigator === 'undefined' || !navigator.onLine) {
        setIsOnline(false);
        return;
      }

      const controller = new AbortController();
      const timeoutId = window.setTimeout(() => controller.abort(), 2500);

      try {
        await fetch('https://www.gstatic.com/generate_204', {
          method: 'GET',
          mode: 'no-cors',
          cache: 'no-store',
          signal: controller.signal,
        });
        setIsOnline(true);
      } catch {
        setIsOnline(false);
      } finally {
        window.clearTimeout(timeoutId);
      }
    };

    const updateStatus = () => {
      setIsOnline(typeof navigator !== 'undefined' ? navigator.onLine : true);
      checkConnection();
    };

    updateStatus();

    window.addEventListener('online', updateStatus);
    window.addEventListener('offline', updateStatus);

    const intervalId = window.setInterval(updateStatus, 3000);

    return () => {
      window.removeEventListener('online', updateStatus);
      window.removeEventListener('offline', updateStatus);
      window.clearInterval(intervalId);
    };
  }, []);

  return (
    <header className="header">
      <div className="header-left">
        <button className="hamburger-menu" onClick={onToggleSidebar}>
          <span></span>
          <span></span>
          <span></span>
        </button>

        <div className="logo">
          <div className="logo-horizontal">
            <img
              src="/logo.png"
              alt="SIGMA - Sistema de Monitoreo Ambiental"
              className="logo-icon"
            />
            <div className="logo-text">
              <h1>SIGMA</h1>
              <span>Sistema de Monitoreo Ambiental</span>
            </div>
          </div>
        </div>

        <div className={`system-status ${isOnline ? 'online' : 'offline'}`} aria-live="polite" title="Estado de conexión">
          <span className={`status-indicator ${isOnline ? 'online' : 'offline'}`}></span>
          <span>{isOnline ? 'Online' : 'Offline'}</span>
        </div>
      </div>

      <div className="header-right">
        <div className="header-actions">
          <OfflineStorageIndicator compact={true} />
          <button className="manual-measure-button" onClick={onManualMeasure}>
            📊 Medir ahora
          </button>
          {onLogout && (
            <button className="logout-button" onClick={onLogout}>
              <span className="logout-icon">{'>'}</span>
              Salir
            </button>
          )}
        </div>
      </div>
    </header>
  );
}

export default Header;