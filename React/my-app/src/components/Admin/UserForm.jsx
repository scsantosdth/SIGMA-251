// src/components/Admin/UserForm.jsx
import { useState, useEffect } from 'react';

function UserForm({ user, onSave, onClose }) {
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    rol: 'operador',
    activo: true
  });

  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);
  const [formError, setFormError] = useState('');

  // Inicializar formulario con datos del usuario
  useEffect(() => {
    if (user) {
      setFormData({
        username: user.username || '',
        email: user.email || '',
        rol: user.rol || 'operador',
        activo: user.activo !== undefined ? user.activo : true
      });
    }
    setErrors({});
    setFormError('');
  }, [user]);

  const validateForm = () => {
    const newErrors = {};

    // Validar email (opcional pero si se provee debe ser válido)
    if (formData.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = 'Email inválido';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
    
    // Limpiar error del campo cuando el usuario empieza a escribir
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }

    setLoading(true);
    setFormError('');

    try {
      // Preparar datos para enviar
      const userData = {
        email: formData.email,
        rol: formData.rol,
        activo: formData.activo
      };

      // Nota: No incluimos username porque no se puede cambiar
      await onSave(userData);
    } catch (err) {
      setFormError(err.message || 'Error al guardar los cambios');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="modal-overlay">
      <div className="modal-content user-form-modal">
        <div className="modal-header">
          <h3>Editar Usuario</h3>
          <button className="close-modal" onClick={onClose}>×</button>
        </div>

        <form onSubmit={handleSubmit}>
          <div className="form-grid">
            <div className="form-group">
              <label htmlFor="username">
                Nombre de Usuario
              </label>
              <input
                type="text"
                id="username"
                name="username"
                value={formData.username}
                readOnly
                className="input-readonly"
                placeholder="Nombre de usuario"
              />
              <div className="help-text">
                El nombre de usuario no se puede modificar
              </div>
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
                placeholder="ej: usuario@uis.edu.co"
                disabled={loading}
              />
              <div className="help-text">
                El usuario puede actualizar su email desde su perfil
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="rol">Rol</label>
              <select
                id="rol"
                name="rol"
                value={formData.rol}
                onChange={handleChange}
                disabled={loading}
              >
                <option value="operador">Operador</option>
                <option value="admin">Administrador</option>
              </select>
              <div className="help-text">
                Administrador: acceso completo. Operador: solo lectura.
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="activo">
                <input
                  type="checkbox"
                  id="activo"
                  name="activo"
                  checked={formData.activo}
                  onChange={handleChange}
                  disabled={loading}
                />
                <span className="checkbox-label">Usuario activo</span>
              </label>
              <div className="help-text">
                Usuarios inactivos no pueden iniciar sesión
              </div>
            </div>
          </div>

          {formError && (
            <div className="form-error-message">
              {formError}
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
              {loading ? 'Guardando...' : 'Guardar Cambios'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default UserForm;