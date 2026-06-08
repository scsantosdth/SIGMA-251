import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './components/Auth/Login.jsx';
import Register from './components/Auth/Register.jsx'; // NUEVO
import Dashboard from './components/Dashboard/Dashboard.jsx';
import UserManagement from './components/Admin/UserManagement.jsx';
import Settings from './components/Settings/Settings.jsx';
import { api } from './services/api.jsx';
import './styles/index.css';

// Componente para rutas protegidas
const PrivateRoute = ({ children }) => {
  return api.isAuthenticated() ? children : <Navigate to="/login" />;
};

// Componente para rutas solo admin
const AdminRoute = ({ children }) => {
  const user = api.getUser();
  const isAdmin = user?.rol === 'admin';
  
  return api.isAuthenticated() && isAdmin ? children : <Navigate to="/" />;
};

// Componente para rutas públicas (solo si NO está autenticado)
const PublicRoute = ({ children }) => {
  return !api.isAuthenticated() ? children : <Navigate to="/" />;
};

function App() {
  return (
    <Router>
      <Routes>
        {/* Ruta pública: Login */}
        <Route 
          path="/login" 
          element={
            <PublicRoute>
              <Login />
            </PublicRoute>
          } 
        />
        
        {/* Ruta pública: Registro */}
        <Route 
          path="/register" 
          element={
            <PublicRoute>
              <Register />
            </PublicRoute>
          } 
        />
        
        {/* Ruta protegida: Dashboard */}
        <Route 
          path="/" 
          element={
            <PrivateRoute>
              <Dashboard />
            </PrivateRoute>
          } 
        />
        
        {/* Ruta protegida solo para admin: Administración de Usuarios */}
        <Route 
          path="/admin/users" 
          element={
            <AdminRoute>
              <UserManagement />
            </AdminRoute>
          } 
        />

        // Y añade esta ruta dentro del Router:
        <Route 
          path="/settings" 
          element={
            <PrivateRoute>
              <Settings />
            </PrivateRoute>
          } 
        />
        
        {/* Redirección por defecto */}
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </Router>
  );
}

export default App;