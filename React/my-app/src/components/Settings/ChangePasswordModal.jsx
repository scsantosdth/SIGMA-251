// src/components/Settings/ChangePasswordModal.jsx
import { useState } from 'react';
import { api } from '../../services/api.jsx';

function ChangePasswordModal({ onClose, onSuccess }) {
  const [formData, setFormData] = useState({
    currentPassword: '',
    newPassword: '',
    confirmPassword: ''
  });
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const validateForm = () => {
    const newErrors = {};

    if (!formData.currentPassword.trim()) {
      newErrors.currentPassword = 'La contraseña actual es requerida';
    }

    if (!formData.newPassword) {
      newErrors.newPassword = 'La nueva contraseña es requerida';
    } else if (formData.newPassword.length < 6) {
      newErrors.newPassword = 'Mínimo 6 caracteres';
    }

    if (formData.newPassword !== formData.confirmPassword) {
      newErrors.confirmPassword = 'Las contraseñas no coinciden';
    }

    // Verificar que nueva contraseña sea diferente a la actual
    if (formData.currentPassword && formData.newPassword && 
        formData.currentPassword === formData.newPassword) {
      newErrors.newPassword = 'La nueva contraseña debe ser diferente a la actual';
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
      await api.changePassword(formData.currentPassword, formData.newPassword);
      
      // Éxito
      if (onSuccess) onSuccess('Contraseña cambiada exitosamente');
      onClose();
      
    } catch (err) {
      setError(err.message || 'Error al cambiar la contraseña');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="modal-overlay">
      <div className="modal-content password-modal">
        <div className="modal-header">
          <h3>Cambiar Contraseña</h3>
          <button className="close-modal" onClick={onClose}>×</button>
        </div>

        <form onSubmit={handleSubmit}>
          <div className="form-grid">
            <div className="form-group">
              <label htmlFor="currentPassword">
                Contraseña Actual *
                {errors.currentPassword && (
                  <span className="error-text"> - {errors.currentPassword}</span>
                )}
              </label>
              <input
                type="password"
                id="currentPassword"
                name="currentPassword"
                value={formData.currentPassword}
                onChange={handleChange}
                className={errors.currentPassword ? 'input-error' : ''}
                placeholder="Ingresa tu contraseña actual"
                disabled={loading}
                autoFocus
              />
            </div>

            <div className="form-group">
              <label htmlFor="newPassword">
                Nueva Contraseña *
                {errors.newPassword && (
                  <span className="error-text"> - {errors.newPassword}</span>
                )}
              </label>
              <input
                type="password"
                id="newPassword"
                name="newPassword"
                value={formData.newPassword}
                onChange={handleChange}
                className={errors.newPassword ? 'input-error' : ''}
                placeholder="Mínimo 6 caracteres"
                disabled={loading}
              />
              <div className="help-text">
                La contraseña debe tener al menos 6 caracteres
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="confirmPassword">
                Confirmar Nueva Contraseña *
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
                placeholder="Repite la nueva contraseña"
                disabled={loading}
              />
            </div>
          </div>

          {error && (
            <div className="error-message">
              {error}
            </div>
          )}

          <div className="password-tips">
            <h4>Recomendaciones de seguridad:</h4>
            <ul>
              <li>Usa al menos 8 caracteres</li>
              <li>Combina letras, números y símbolos</li>
            </ul>
          </div>

          <div className="form-actions">
            <button
              type="button"
              className="btn btn-secondary"
              onClick={onClose}
              disabled={loading}
            >
              Cancelar
            </button>
            <button
              type="submit"
              className="btn btn-primary"
              disabled={loading}
            >
              {loading ? 'Cambiando...' : 'Cambiar Contraseña'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default ChangePasswordModal;