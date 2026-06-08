// src/components/Auth/Login.jsx
import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { api } from '../../services/api.jsx';
import '../../styles/Auth.css';

function Login() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const response = await api.login(username, password);
      
      // Guardar token y datos de usuario
      localStorage.setItem('token', response.access_token);
      localStorage.setItem('user', JSON.stringify(response.user));
      
      // Redirigir al dashboard
      navigate('/');
    } catch (err) {
      console.log('Login error:', err);
      setError(err.message || 'Error de conexión');
    } finally {
      setLoading(false);
    }
  };

  return (

    <div className="login-container">
      <div className="login-card">
        
        <div className="login-header">
          <div className="logo-login">
            <img
            src="/logo.png"
            alt="SIGMA Logo"
            className="logo-image-login"
            />
            <div className="logo-text-login">
              <h1>SIGMA</h1>
              <p>Sistema de Gestión de Monitoreo Ambiental</p>
            </div>
          </div>
        </div>
        

        <form onSubmit={handleSubmit} className="login-form">
          <div className="form-group">
            <label htmlFor="username">Usuario</label>
            <input
              type="text"
              id="username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
              disabled={loading}
              placeholder="Ingresa tu usuario"
            />
          </div>

          <div className="form-group">
            <label htmlFor="password">Contraseña</label>
            <input
              type="password"
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              disabled={loading}
              placeholder="Ingresa tu contraseña"
            />
          </div>

          {error && <div className="error-message">{error}</div>}

          <button 
            type="submit" 
            className="login-button"
            disabled={loading}
          >
            {loading ? 'Cargando...' : 'Iniciar Sesión'}
          </button>

          <div className="register-section">
            <p className="register-text">
              ¿No tienes cuenta?{' '}
              <Link to="/register" className="register-link">
                Regístrate aquí
              </Link>
            </p>
          </div>
        </form>

        <div className="login-footer">
          <p>Sistema AgroIoT - Universidad Industrial de Santander</p>
        </div>
      </div>
    </div>
  );
}

export default Login;