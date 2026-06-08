// src/components/Settings/ChangeEmailModal.jsx
import { useState } from 'react';
import { api } from '../../services/api.jsx';

function ChangeEmailModal({ onClose, onSuccess }) {
  const currentUser = api.getUser();
  const [formData, setFormData] = useState({
    email: currentUser?.email || '',
    confirmEmail: currentUser?.email || '',
    password: '',
  });
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const validateForm = () => {
    const newErrors = {};

    if (!formData.email.trim()) {
      newErrors.email = 'El email es requerido';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = 'Email inválido';
    }

    if (formData.email !== formData.confirmEmail) {
      newErrors.confirmEmail = 'Los emails no coinciden';
    }

    if (!formData.password) {
      newErrors.password = 'La contraseña actual es requerida';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
    if (errors[name]) {
      setErrors((prev) => ({ ...prev, [name]: '' }));
    }
    if (error) setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validateForm()) return;

    setLoading(true);
    setError('');

    try {
      const updated = await api.updateCurrentUser({
        email: formData.email.trim(),
        current_password: formData.password,
      });
      localStorage.setItem('user', JSON.stringify(updated));

      if (onSuccess) onSuccess('Email actualizado correctamente');
      onClose();
    } catch (err) {
      setError(err.message || 'Error al actualizar email');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="modal-overlay">
      <div className="modal-content email-modal">
        <div className="modal-header">
          <h3>Cambiar Email</h3>
          <button className="close-modal" onClick={onClose}>×</button>
        </div>

        <form onSubmit={handleSubmit}>
          <div className="form-grid">
            <div className="form-group">
              <label htmlFor="email">
                Nuevo Email *
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
                placeholder="tu@email.com"
                disabled={loading}
                autoFocus
              />
            </div>

            <div className="form-group">
              <label htmlFor="confirmEmail">
                Confirmar Email *
                {errors.confirmEmail && (
                  <span className="error-text"> - {errors.confirmEmail}</span>
                )}
              </label>
              <input
                type="email"
                id="confirmEmail"
                name="confirmEmail"
                value={formData.confirmEmail}
                onChange={handleChange}
                className={errors.confirmEmail ? 'input-error' : ''}
                placeholder="Repite tu email"
                disabled={loading}
              />
            </div>

            <div className="form-group">
              <label htmlFor="password">
                Contraseña Actual *
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
                placeholder="Ingresa tu contraseña actual"
                disabled={loading}
              />
              <div className="help-text">
                Por seguridad, confirma tu contraseña
              </div>
            </div>
          </div>

          {error && (
            <div className="error-message">
              {error}
            </div>
          )}

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
              {loading ? 'Guardando...' : 'Guardar Email'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default ChangeEmailModal;
