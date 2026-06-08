// src/components/Layout/Header.jsx
import '../../styles/index.css';
import OfflineStorageIndicator from '../Dashboard/OfflineStorageIndicator.jsx';

function Header({ onLogout, onToggleSidebar, onManualMeasure }) {
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