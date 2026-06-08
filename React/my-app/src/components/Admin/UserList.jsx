// src/components/Admin/UserList.jsx
import { api } from '../../services/api.jsx';

function UserList({ users, onEdit, onDelete, loading }) {
  const currentUser = api.getUser();

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  const getRoleBadgeClass = (role) => {
    return role === 'admin' ? 'badge-admin' : 'badge-operador';
  };

  const getStatusBadgeClass = (activo) => {
    return activo ? 'badge-active' : 'badge-inactive';
  };

  if (loading && users.length === 0) {
    return (
      <div className="loading-container">
        <div className="loading">Cargando usuarios...</div>
      </div>
    );
  }

  if (users.length === 0) {
    return (
      <div className="empty-state">
        <p>No hay usuarios registrados.</p>
        <p>Crea el primer usuario usando el botón "Nuevo Usuario".</p>
      </div>
    );
  }

  return (
    <div className="user-list-container">
      <div className="table-responsive">
        <table className="users-table">
          <thead>
            <tr>
              <th>Usuario</th>
              <th>Email</th>
              <th>Rol</th>
              <th>Estado</th>
              <th>Fecha Creación</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            {users.map((user) => (
              <tr key={user.id}>
                <td>
                  <div className="user-cell">
                    <div className="user-avatar-small">
                      {user.username.charAt(0).toUpperCase()}
                    </div>
                    <div className="user-info-small">
                      <div className="username">{user.username}</div>
                      <div className="user-id">ID: {user.id}</div>
                    </div>
                  </div>
                </td>
                <td>{user.email}</td>
                <td>
                  <span className={`badge ${getRoleBadgeClass(user.rol)}`}>
                    {user.rol === 'admin' ? 'Administrador' : 'Operador'}
                  </span>
                </td>
                <td>
                  <span className={`badge ${getStatusBadgeClass(user.activo)}`}>
                    {user.activo ? 'Activo' : 'Inactivo'}
                  </span>
                </td>
                <td>{formatDate(user.fecha_creacion)}</td>
                <td>
                  <div className="action-buttons">
                    <button
                      className="btn-action btn-edit"
                      onClick={() => onEdit(user)}
                      title="Editar usuario"
                      disabled={user.id === currentUser?.id}
                    >
                      ✏️
                    </button>
                    <button
                      className="btn-action btn-delete"
                      onClick={() => onDelete(user)}
                      title={user.activo ? 'Desactivar usuario' : 'Activar usuario'}
                      disabled={user.id === currentUser?.id}
                    >
                      {user.activo ? '🚫' : '✅'}
                    </button>
                  </div>
                  {user.id === currentUser?.id && (
                    <div className="current-user-note">(Tú)</div>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      
      <div className="table-footer">
        <div className="summary">
          Total: {users.length} usuario{users.length !== 1 ? 's' : ''}
        </div>
        <div className="stats">
          <span className="stat-item">
            <span className="stat-dot admin"></span>
            Admin: {users.filter(u => u.rol === 'admin').length}
          </span>
          <span className="stat-item">
            <span className="stat-dot operador"></span>
            Operadores: {users.filter(u => u.rol === 'operador').length}
          </span>
          <span className="stat-item">
            <span className="stat-dot active"></span>
            Activos: {users.filter(u => u.activo).length}
          </span>
        </div>
      </div>
    </div>
  );
}

export default UserList;