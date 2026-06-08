// src/components/Auth/Register.jsx
import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { api } from '../../services/api.jsx';
import '../../styles/Auth.css';

function Register() {
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: '',
    confirmPassword: ''
  });
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const validateForm = () => {
    const newErrors = {};

    if (!formData.username.trim()) {
      newErrors.username = 'El nombre de usuario es requerido';
    } else if (formData.username.length < 3) {
      newErrors.username = 'Mínimo 3 caracteres';
    } else if (!/^[a-zA-Z0-9]+$/.test(formData.username)) {
      newErrors.username = 'Solo letras y números';
    }

    if (formData.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = 'Email inválido';
    }

    if (!formData.password) {
      newErrors.password = 'La contraseña es requerida';
    } else if (formData.password.length < 6) {
      newErrors.password = 'Mínimo 6 caracteres';
    }

    if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = 'Las contraseñas no coinciden';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
    if (error) setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }

    setLoading(true);
    setError('');

    try {
      // Preparar datos para registro
      const userData = {
        username: formData.username,
        password: formData.password,
        email: formData.email || `${formData.username}@sigma.com`
      };

      // Llamar a la función register del api (usa API_BASE)
      await api.register(userData.username, userData.password, userData.email, formData.confirmPassword);

      setSuccess(true);
      setFormData({
        username: '',
        email: '',
        password: '',
        confirmPassword: ''
      });

      setTimeout(() => {
        navigate('/login');
      }, 3000);

    } catch (err) {
      setError(err.message || 'Error en el registro');
    } finally {
      setLoading(false);
    }
  };

  if (success) {
    return (
      <div className="login-container">
        <div className="login-card">
          <div className="login-header">
            <h1>¡Registro Exitoso!</h1>
            <p>Cuenta creada correctamente</p>
          </div>

          <div className="success-message">
            <div className="success-icon">✅</div>
            <h3>Bienvenido a SIGMA</h3>
            <p>Tu cuenta ha sido creada como <strong>Operador</strong>.</p>
            <p>Serás redirigido a la página de inicio de sesión en 3 segundos...</p>
            
            <div className="success-actions">
              <Link to="/login" className="btn btn-primary">
                Ir a Iniciar Sesión
              </Link>
            </div>
          </div>

          <div className="login-footer">
            <p>Sistema AgroIoT - Universidad Industrial de Santander</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="login-container">
      <div className="login-card">
        <div className="login-header">
          <h1>Crear Cuenta</h1>
          <p>Registro en SIGMA - Sistema de Monitoreo Ambiental</p>
        </div>

        <form onSubmit={handleSubmit} className="login-form">
          <div className="form-group">
            <label htmlFor="username">
              Nombre de Usuario *
              {errors.username && (
                <span className="error-text"> - {errors.username}</span>
              )}
            </label>
            <input
              type="text"
              id="username"
              name="username"
              value={formData.username}
              onChange={handleChange}
              className={errors.username ? 'input-error' : ''}
              placeholder="ej: juan.perez"
              disabled={loading}
              autoFocus
            />
            <small className="help-text">Solo letras y números, mínimo 3 caracteres</small>
          </div>

          <div className="form-group">
            <label htmlFor="email">
              Email 
              {errors.email && (
                <span className="error-text"> - {errors.email}</span>
              )}
            </label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              className={errors.email ? 'input-error' : ''}
              placeholder="ej: usuario@uis.edu.co (opcional)"
              disabled={loading}
            />
            <small className="help-text">Opcional. Si no proporcionas email, se generará uno automático.</small>
          </div>

          <div className="form-group">
            <label htmlFor="password">
              Contraseña *
              {errors.password && (
                <span className="error-text"> - {errors.password}</span>
              )}
            </label>
            <input
              type="password"
              id="password"
              name="password"
              value={formData.password}
              onChange={handleChange}
              className={errors.password ? 'input-error' : ''}
              placeholder="Mínimo 6 caracteres"
              disabled={loading}
            />
          </div>

          <div className="form-group">
            <label htmlFor="confirmPassword">
              Confirmar Contraseña *
              {errors.confirmPassword && (
                <span className="error-text"> - {errors.confirmPassword}</span>
              )}
            </label>
            <input
              type="password"
              id="confirmPassword"
              name="confirmPassword"
              value={formData.confirmPassword}
              onChange={handleChange}
              className={errors.confirmPassword ? 'input-error' : ''}
              placeholder="Repite la contraseña"
              disabled={loading}
            />
          </div>

          {error && <div className="error-message">{error}</div>}

          <button 
            type="submit" 
            className="login-button"
            disabled={loading}
          >
            {loading ? 'Creando cuenta...' : 'Crear Cuenta'}
          </button>

          <div className="register-section">
            <p className="register-text">
              ¿Ya tienes cuenta?{' '}
              <Link to="/login" className="register-link">
                Inicia sesión aquí
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

export default Register;