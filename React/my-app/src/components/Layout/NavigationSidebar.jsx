// src/components/Layout/NavigationSidebar.jsx
import { NavLink } from 'react-router-dom';
import { api } from '../../services/api.jsx';
import '../../styles/index.css';

function NavigationSidebar({ isOpen, onClose, onLogout }) {
  const user = api.getUser();
  const isAdmin = user?.rol === 'admin';

  const navItems = [
    {
      path: '/',
      label: 'Dashboard',
      icon: (
        <img
          src="/dashboard1.png"
          alt="Dashboard"
          className="nav-icon-img"
        />
      ),
      exact: true
    },
    ...(isAdmin ? [{
      path: '/admin/users',
      label: 'Gestión de Usuarios',
      icon: (
        <img
          src="/users1.png"
          alt="Usuarios"
          className="nav-icon-img nav-icon-img--lg"
        />
      ),
      exact: false
    }] : []),
    
    {
      path: '/settings',
      label: 'Configuración',
      icon: (
        <img
          src="/config.png"
          alt="Configuración"
          className="nav-icon-img"
        />
      ),
      exact: false
    }
  ];

  return (
    <>
      {/* Overlay para móviles */}
      {isOpen && <div className="sidebar-overlay" onClick={onClose}></div>}
      
      <aside className={`navigation-sidebar ${isOpen ? 'open' : ''}`}>
        <div className="sidebar-header">
          <div className="sidebar-user">
            <div className="user-avatar">
              {user?.username?.charAt(0).toUpperCase() || 'U'}
            </div>
            <div className="user-info">
              <div className="username">{user?.username || 'Usuario'}</div>
              <div className="user-role">
                {user?.rol === 'admin' ? 'Administrador' : 'Operador'}
              </div>
            </div>
          </div>
          
          <button className="close-sidebar" onClick={onClose}>
            ✕
          </button>
        </div>

        <nav className="sidebar-nav">
          <ul>
            {navItems.map((item) => (
              <li key={item.path}>
                <NavLink
                  to={item.path}
                  className={({ isActive }) => 
                    `nav-link ${isActive ? 'active' : ''}`
                  }
                  end={item.exact}
                  onClick={onClose}
                >
                  <span className="nav-icon">{item.icon}</span>
                  <span className="nav-label">{item.label}</span>
                </NavLink>
              </li>
            ))}
          </ul>
        </nav>

        <div className="sidebar-footer">
          <div className="system-info">
            <button
              ClassName="logout-footer-btn"
              onClick={() => {
                onClose();
                onLogout();
              }}
            >
              <span className="logout-icon">🚪</span>
              <span>Cerrar sesión</span>
            </button>
            <div className="info-item">
              <span className="info-label">Versión:</span>
              <span className="info-value">1.0.0</span>
            </div>
            <div className="info-item">
              <span className="info-label">Sesión:</span>
              <span className="info-value active">Activa</span>
            </div>
          </div>
        </div>
      </aside>
    </>
  );
}

export default NavigationSidebar;
