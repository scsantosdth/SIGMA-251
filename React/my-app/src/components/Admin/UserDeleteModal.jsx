// src/components/Admin/UserDeleteModal.jsx
function UserDeleteModal({ user, onConfirm, onCancel }) {
  if (!user) return null;

  const actionText = user.activo ? 'desactivar' : 'activar';
  const actionType = user.activo ? 'Desactivar' : 'Activar';

  return (
    <div className="modal-overlay">
      <div className="modal-content delete-modal">
        <div className="modal-header">
          <h3>{actionType} Usuario</h3>
          <button className="close-modal" onClick={onCancel}>×</button>
        </div>

        <div className="modal-body">
          <div className="warning-icon">⚠️</div>
          
          <p className="warning-text">
            {user.activo ? (
              <>
                ¿Estás seguro de que quieres <strong>desactivar</strong> al usuario?
              </>
            ) : (
              <>
                ¿Estás seguro de que quieres <strong>activar</strong> al usuario?
              </>
            )}
          </p>

          <div className="user-details-preview">
            <div className="detail-row">
              <span className="detail-label">Usuario:</span>
              <span className="detail-value">{user.username}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Email:</span>
              <span className="detail-value">{user.email}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Rol:</span>
              <span className={`badge ${user.rol === 'admin' ? 'badge-admin' : 'badge-operador'}`}>
                {user.rol === 'admin' ? 'Administrador' : 'Operador'}
              </span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Estado actual:</span>
              <span className={`badge ${user.activo ? 'badge-active' : 'badge-inactive'}`}>
                {user.activo ? 'Activo' : 'Inactivo'}
              </span>
            </div>
          </div>

          <div className="consequences">
            <h4>Consecuencias:</h4>
            <ul>
              {user.activo ? (
                <>
                  <li>El usuario <strong>NO podrá iniciar sesión</strong></li>
                  <li>Sus datos se mantendrán en el sistema</li>
                  <li>Puedes reactivarlo en cualquier momento</li>
                </>
              ) : (
                <>
                  <li>El usuario <strong>podrá iniciar sesión nuevamente</strong></li>
                  <li>Recuperará todos sus permisos anteriores</li>
                </>
              )}
            </ul>
          </div>
        </div>

        <div className="modal-actions">
          <button
            className="btn btn-secondary"
            onClick={onCancel}
          >
            Cancelar
          </button>
          <button
            className={`btn ${user.activo ? 'btn-warning' : 'btn-success'}`}
            onClick={onConfirm}
          >
            {user.activo ? 'Sí, Desactivar' : 'Sí, Activar'}
          </button>
        </div>
      </div>
    </div>
  );
}

export default UserDeleteModal;