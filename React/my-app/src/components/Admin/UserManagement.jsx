// src/components/Admin/UserManagement.jsx
import { useState, useEffect } from 'react';
import MainLayout from '../Layout/MainLayout.jsx';
import { api } from '../../services/api.jsx';
import UserList from './UserList.jsx';
import UserForm from './UserForm.jsx';
import UserDeleteModal from './UserDeleteModal.jsx';
import '../../styles/Admin.css';

function UserManagement() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);

  // Función de logout (igual que en Dashboard)
  const handleLogout = () => {
    api.logout();
    window.location.href = '/login';
  };

  // Cargar usuarios
  const loadUsers = async () => {
    try {
      setLoading(true);
      const data = await api.getUsers();
      setUsers(data);
      setError(null);
    } catch (err) {
      setError(err.message || 'Error al cargar usuarios');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadUsers();
  }, []);

  // Manejar editar usuario
  const handleEditUser = (user) => {
    setSelectedUser(user);
    setShowForm(true);
  };

  // Manejar eliminar/activar usuario
  const handleToggleUserStatus = (user) => {
    setSelectedUser(user);
    setShowDeleteModal(true);
  };

  // Confirmar cambio de estado
  const confirmToggleStatus = async () => {
    try {
      // Cambiar estado activo/inactivo
      const updatedUser = {
        activo: !selectedUser.activo
      };
      
      await api.updateUser(selectedUser.id, updatedUser);
      await loadUsers(); // Recargar lista
      setShowDeleteModal(false);
      setSelectedUser(null);
    } catch (err) {
      setError(err.message || 'Error al cambiar estado del usuario');
    }
  };

  // Cerrar formulario
  const handleCloseForm = () => {
    setShowForm(false);
    setSelectedUser(null);
  };

  // Guardar usuario (solo edición)
  const handleSaveUser = async (userData) => {
    try {
      await api.updateUser(selectedUser.id, userData);
      await loadUsers(); // Recargar lista
      handleCloseForm();
    } catch (err) {
      throw err; // El formulario manejará el error
    }
  };

  if (loading && users.length === 0) {
    return (
      <MainLayout onLogout={handleLogout}>
        <div className="admin-container">
          <div className="loading">Cargando usuarios...</div>
        </div>
      </MainLayout>
    );
  }

  return (
    <MainLayout onLogout={handleLogout}>
      <div className="admin-container">
        <div className="admin-header">
          <h2>Gestión de Usuarios</h2>
          <div className="admin-subtitle">
            Gestiona los usuarios registrados en el sistema SIGMA
          </div>
        </div>

        {error && (
          <div className="error-message">
            {error}
          </div>
        )}

        <UserList 
          users={users}
          onEdit={handleEditUser}
          onDelete={handleToggleUserStatus}
          loading={loading}
        />

        {/* Modal de formulario (solo edición) */}
        {showForm && (
          <UserForm
            user={selectedUser}
            onSave={handleSaveUser}
            onClose={handleCloseForm}
          />
        )}

        {/* Modal de confirmación de cambio de estado */}
        {showDeleteModal && (
          <UserDeleteModal
            user={selectedUser}
            onConfirm={confirmToggleStatus}
            onCancel={() => setShowDeleteModal(false)}
          />
        )}
      </div>
    </MainLayout>
  );
}

export default UserManagement;