// src/components/Settings/Settings.jsx
import { useCallback, useEffect, useState } from 'react';
import MainLayout from '../Layout/MainLayout.jsx';
import { api } from '../../services/api.jsx';
import ChangePasswordModal from './ChangePasswordModal.jsx';
import ChangeEmailModal from './ChangeEmailModal.jsx';
import { applyTheme, getTheme, setTheme } from '../../utils/theme.jsx';
import '../../styles/Settings.css';

function Settings() {
  const currentUser = api.getUser();
  const [activeTab, setActiveTab] = useState('profile');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState({ type: '', text: '' });
  const [showChangePassword, setShowChangePassword] = useState(false);
  const [showChangeEmail, setShowChangeEmail] = useState(false);
  const [theme, setThemeState] = useState(getTheme());
  const [localApiBase, setLocalApiBaseState] = useState(api.getLocalApiBase());
  const [systemStatus, setSystemStatus] = useState({
    api: 'checking',
    db: 'checking',
    apiText: 'Verificando...',
    dbText: 'Verificando...'
  });
  const [lastSystemCheck, setLastSystemCheck] = useState(null);

  // Nuevos estados para el intervalo automático
  const [autoInterval, setAutoInterval] = useState(5);
  const [intervalLoading, setIntervalLoading] = useState(false);
  const [localApiSaving, setLocalApiSaving] = useState(false);

  // Logout
  const handleLogout = () => {
    api.logout();
    window.location.href = '/';
  };

  const showMessage = (type, text) => {
    setMessage({ type, text });
    setTimeout(() => setMessage({ type: '', text: '' }), 5000);
  };

  // Guardar intervalo automático
  const handleSaveInterval = async () => {
    setIntervalLoading(true);
    try {
      await api.setAutoInterval(autoInterval);
      showMessage('success', `Intervalo automático actualizado a ${autoInterval} minutos`);
    } catch (err) {
      showMessage('error', 'Error al guardar el intervalo');
      console.error(err);
    } finally {
      setIntervalLoading(false);
    }
  };

  const handleSaveLocalApiBase = async () => {
    setLocalApiSaving(true);
    try {
      const normalized = api.setLocalApiBase(localApiBase);
      setLocalApiBaseState(normalized);
      showMessage('success', `API local configurada: ${normalized}`);
    } catch (err) {
      showMessage('error', 'Error guardando la API local');
      console.error(err);
    } finally {
      setLocalApiSaving(false);
    }
  };

  const handleClearLocalApiBase = () => {
    const restored = api.clearLocalApiBase();
    setLocalApiBaseState(restored);
    showMessage('success', 'API local restaurada al valor por defecto');
  };

  const handlePasswordChangeSuccess = (successMessage) => {
    showMessage('success', successMessage);
    setShowChangePassword(false);
  };

  const handleEmailChangeSuccess = (successMessage) => {
    showMessage('success', successMessage);
    setShowChangeEmail(false);
  };

  // Tema oscuro
  useEffect(() => {
    applyTheme(theme);
  }, [theme]);

  // Cargar intervalo actual desde el backend
  useEffect(() => {
    const loadInterval = async () => {
      try {
        const data = await api.getAutoInterval();
        setAutoInterval(data.valor);
      } catch (err) {
        console.error('Error cargando intervalo:', err);
      }
    };
    loadInterval();
  }, []);

  // Estado del sistema
  const refreshSystemStatus = useCallback(async () => {
    setSystemStatus((prev) => ({
      ...prev,
      api: 'checking',
      db: 'checking',
      apiText: 'Verificando...',
      dbText: 'Verificando...'
    }));

    const [apiResult, dbResult] = await Promise.allSettled([
      api.checkApiHealth(),
      api.checkDatabaseHealth()
    ]);

    setSystemStatus({
      api: apiResult.status === 'fulfilled' ? 'online' : 'offline',
      db: dbResult.status === 'fulfilled' ? 'online' : 'offline',
      apiText: apiResult.status === 'fulfilled' ? 'En linea' : 'Sin conexion',
      dbText: dbResult.status === 'fulfilled' ? 'Conectada' : 'No disponible'
    });
    setLastSystemCheck(new Date());
  }, []);

  useEffect(() => {
    if (activeTab !== 'system') return undefined;

    refreshSystemStatus();
    const interval = setInterval(refreshSystemStatus, 30000);
    return () => clearInterval(interval);
  }, [activeTab, refreshSystemStatus]);

  return (
    <MainLayout onLogout={handleLogout}>
      <div className="settings-container">
        <div className="settings-header">
          <h1>Configuración</h1>
          <p className="settings-subtitle">
            Gestiona tu perfil y preferencias del sistema
          </p>
        </div>

        {message.text && (
          <div className={`message ${message.type}`}>
            {message.text}
          </div>
        )}

        <div className="settings-content">
          {/* Sidebar de navegación */}
          <div className="settings-sidebar">
            <nav className="settings-nav">
              <button
                className={`nav-item ${activeTab === 'profile' ? 'active' : ''}`}
                onClick={() => setActiveTab('profile')}
              >
                <span className="nav-icon"><img src="/perfil.png" alt="Perfil" className="nav-icon-img" /></span>
                <span className="nav-label">Perfil</span>
              </button>
              
              <button
                className={`nav-item ${activeTab === 'security' ? 'active' : ''}`}
                onClick={() => setActiveTab('security')}
              >
                <span className="nav-icon"><img src="/seguridad.png" alt="Seguridad" className="nav-icon-img" /></span>
                <span className="nav-label">Seguridad</span>
              </button>
              
              <button
                className={`nav-item ${activeTab === 'preferences' ? 'active' : ''}`}
                onClick={() => setActiveTab('preferences')}
              >
                <span className="nav-icon"><img src="/config.png" alt="Preferencias" className="nav-icon-img" /></span>
                <span className="nav-label">Preferencias</span>
              </button>
              
              <button
                className={`nav-item ${activeTab === 'system' ? 'active' : ''}`}
                onClick={() => setActiveTab('system')}
              >
                <span className="nav-icon">🖥️</span>
                <span className="nav-label">Sistema</span>
              </button>
            </nav>

            <div className="user-summary">
              <div className="user-avatar-large">
                {currentUser?.username?.charAt(0).toUpperCase() || 'U'}
              </div>
              <div className="user-info-summary">
                <div className="username-summary">{currentUser?.username || 'Usuario'}</div>
                <div className="user-role-summary">
                  {currentUser?.rol === 'admin' ? 'Administrador' : 'Operador'}
                </div>
                <div className="user-status">
                  <span className="status-dot active"></span>
                  Sesión activa
                </div>
              </div>
            </div>
          </div>

          {/* Contenido principal */}
          <div className="settings-main">
            {activeTab === 'profile' && (
              <div className="settings-section">
                <h2>Información del Perfil</h2>
                <p className="section-description">
                  Gestiona tu información personal y de contacto.
                </p>
                
                <div className="profile-info">
                  <div className="info-item">
                    <label>Nombre de Usuario</label>
                    <div className="info-value">{currentUser?.username || 'N/A'}</div>
                    <div className="info-help">
                      El nombre de usuario no se puede cambiar
                    </div>
                  </div>
                  
                  <div className="info-item">
                    <label>Email</label>
                    <div className="info-value">{currentUser?.email || 'No especificado'}</div>
                    <div className="info-help">
                      {currentUser?.email ? 
                        'Puedes cambiar tu email en la sección de Seguridad' : 
                        'Añade un email para recuperación de cuenta'}
                    </div>
                  </div>
                  
                  <div className="info-item">
                    <label>Rol</label>
                    <div className="info-value">
                      <span className={`badge ${currentUser?.rol === 'admin' ? 'badge-admin' : 'badge-operador'}`}>
                        {currentUser?.rol === 'admin' ? 'Administrador' : 'Operador'}
                      </span>
                    </div>
                    <div className="info-help">
                      Contacta al administrador para cambios de rol
                    </div>
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'security' && (
              <div className="settings-section">
                <h2>Seguridad y Privacidad</h2>
                <p className="section-description">
                  Protege tu cuenta y gestiona el acceso.
                </p>
                
                <div className="security-actions">
                  <div className="action-card">
                    <div className="action-icon">✉️</div>
                    <div className="action-content">
                      <h3>Cambiar Email</h3>
                      <p>Actualiza tu dirección de email para notificaciones y recuperación.</p>
                      <button 
                        className="btn btn-primary" 
                        disabled={loading}
                        onClick={() => setShowChangeEmail(true)}
                      >
                        Cambiar Email
                      </button>
                    </div>
                  </div>
                  
                  <div className="action-card">
                    <div className="action-icon">🔑</div>
                    <div className="action-content">
                      <h3>Cambiar Contraseña</h3>
                      <p>Actualiza tu contraseña regularmente para mayor seguridad.</p>
                      <button 
                        className="btn btn-primary" 
                        disabled={loading}
                        onClick={() => setShowChangePassword(true)}
                      >
                        Cambiar Contraseña
                      </button>
                    </div>
                  </div>
                  
                  <div className="action-card warning">
                    <div className="action-icon">🚫</div>
                    <div className="action-content">
                      <h3>Cerrar Sesiones</h3>
                      <p>Cierra todas las sesiones activas en otros dispositivos.</p>
                      <button 
                        className="btn btn-warning" 
                        disabled={loading}
                        onClick={() => showMessage('warning', 'Funcionalidad en desarrollo')}
                      >
                        Cerrar Otras Sesiones
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'preferences' && (
              <div className="settings-section">
                <h2>Preferencias</h2>
                <p className="section-description">
                  Personaliza tu experiencia en SIGMA.
                </p>
                
                <div className="preferences-grid">
                  <div className="preference-item">
                    <label className="preference-label">
                      <input
                        type="checkbox"
                        checked={theme === 'dark'}
                        onChange={(e) => {
                          const nextTheme = e.target.checked ? 'dark' : 'light';
                          setThemeState(nextTheme);
                          setTheme(nextTheme);
                        }}
                      />
                      <span>Tema oscuro</span>
                    </label>
                    <div className="preference-help">
                      Interfaz con colores oscuros (recomendado)
                    </div>
                  </div>

                  {/* NUEVO BLOQUE: Intervalo automático */}
                  <div className="preference-item">
                    <label className="preference-label">
                      <span>Intervalo automático (minutos)</span>
                      <input
                        type="number"
                        min="1"
                        max="1440"
                        value={autoInterval}
                        onChange={(e) => setAutoInterval(parseInt(e.target.value) || 1)}
                        style={{ width: '100px', marginLeft: '10px' }}
                      />
                    </label>
                    <div className="preference-help">
                      Cada cuántos minutos se guardan automáticamente las mediciones.
                    </div>
                    <button 
                      className="btn btn-primary" 
                      onClick={handleSaveInterval}
                      disabled={intervalLoading}
                      style={{ marginTop: '10px' }}
                    >
                      {intervalLoading ? 'Guardando...' : 'Guardar intervalo'}
                    </button>
                  </div>
                  
                  <div className="preference-item">
                    <label className="preference-label">
                      <span>Unidades de temperatura</span>
                      <select defaultValue="celsius">
                        <option value="celsius">°C (Celsius)</option>
                        <option value="fahrenheit">°F (Fahrenheit)</option>
                      </select>
                    </label>
                  </div>
                  
                  <div className="preference-item">
                    <label className="preference-label">
                      <span>URL API local del receiver</span>
                      <input
                        type="text"
                        value={localApiBase}
                        onChange={(e) => setLocalApiBaseState(e.target.value)}
                        placeholder="http://127.0.0.1:5050 o http://192.168.x.x:5050"
                        style={{ width: '320px', marginLeft: '10px' }}
                      />
                    </label>
                    <div className="preference-help">
                      PC: usa <strong>http://127.0.0.1:5050</strong>. Celular: usa la IP local del PC, por ejemplo <strong>http://192.168.1.50:5050</strong>.
                    </div>
                    <div style={{ display: 'flex', gap: '10px', marginTop: '10px', flexWrap: 'wrap' }}>
                      <button
                        className="btn btn-primary"
                        onClick={handleSaveLocalApiBase}
                        disabled={localApiSaving}
                      >
                        {localApiSaving ? 'Guardando...' : 'Guardar API local'}
                      </button>
                      <button
                        className="btn btn-secondary"
                        onClick={handleClearLocalApiBase}
                        disabled={localApiSaving}
                      >
                        Restaurar por defecto
                      </button>
                    </div>
                  </div>

                  <div className="preference-item">
                    <label className="preference-label">
                      <span>Idioma</span>
                      <select defaultValue="es">
                        <option value="es">Español</option>
                        <option value="en">English</option>
                      </select>
                    </label>
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'system' && (
              <div className="settings-section">
                <h2>Información del Sistema</h2>
                <p className="section-description">
                  Detalles técnicos y estado del sistema.
                </p>
                
                <div className="system-info">
                  <div className="system-item">
                    <label>Versión SIGMA</label>
                    <div className="system-value">1.0.0</div>
                  </div>
                  
                  <div className="system-item">
                    <label>API Backend</label>
                    <div className="system-value">{api.getApiBase()}</div>
                  </div>
                  
                  <div className="system-item">
                    <label>Estado API</label>
                    <div className="system-value status">
                      <span className={`status-dot ${systemStatus.api}`}></span>
                      {systemStatus.apiText}
                    </div>
                  </div>
                  
                  <div className="system-item">
                    <label>Base de datos</label>
                    <div className="system-value status">
                      <span className={`status-dot ${systemStatus.db}`}></span>
                      {systemStatus.dbText}
                    </div>
                  </div>
                  
                  <div className="system-item">
                    <label>Última actualización</label>
                    <div className="system-value">
                      {lastSystemCheck ? lastSystemCheck.toLocaleString('es-ES') : 'Sin verificar'}
                    </div>
                  </div>
                </div>
                
                <div className="system-actions">
                  <button 
                    className="btn btn-secondary" 
                    disabled={loading}
                    onClick={refreshSystemStatus}
                  >
                    Verificar estado
                  </button>
                  <button 
                    className="btn btn-secondary" 
                    disabled={loading}
                    onClick={() => showMessage('info', 'Funcionalidad en desarrollo')}
                  >
                    Exportar Configuración
                  </button>
                  <button 
                    className="btn btn-warning" 
                    disabled={loading}
                    onClick={() => showMessage('warning', 'Esta acción reiniciará todas tus preferencias')}
                  >
                    Reiniciar Preferencias
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {showChangePassword && (
        <ChangePasswordModal
          onClose={() => setShowChangePassword(false)}
          onSuccess={handlePasswordChangeSuccess}
        />
      )}

      {showChangeEmail && (
        <ChangeEmailModal
          onClose={() => setShowChangeEmail(false)}
          onSuccess={handleEmailChangeSuccess}
        />
      )}
    </MainLayout>
  );
}

export default Settings;

