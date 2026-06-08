const API_BASE = import.meta.env.VITE_API_BASE || `http://${window.location.hostname}:8000`;
console.log('API_BASE:', API_BASE);

const fetchWithAuth = async (url, options = {}) => {
  const token = localStorage.getItem('token');

  const headers = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  const response = await fetch(url, {
    ...options,
    headers,
  });

  if (response.status === 401) {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    window.location.href = '/login';
    throw new Error('Sesion expirada');
  }

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    let message = errorData.detail || `Error ${response.status}`;
    if (Array.isArray(errorData.detail)) {
      message = errorData.detail.map((d) => d.msg || d.message || 'Error').join(', ');
    }
    throw new Error(message);
  }

  return response.json();
};

export const api = {
  getApiBase: () => API_BASE,

  // Auth
  login: async (username, password) => {
    const response = await fetch(`${API_BASE}/api/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ username, password }),
    });

    const data = await response.json();

    if (!response.ok) {
      const error = new Error(data.detail || 'Error de conexion');
      error.response = { data };
      throw error;
    }

    return data;
  },

  register: async (username, password, email) => {
    const response = await fetch(`${API_BASE}/api/auth/register`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ username, password, email }),
    });

    const data = await response.json();

    if (!response.ok) {
      const error = new Error(data.detail || 'Error en el registro');
      error.response = { data };
      throw error;
    }

    return data;
  },

  getCurrentUser: async () => fetchWithAuth(`${API_BASE}/api/auth/me`),

  updateCurrentUser: async (userData) =>
    fetchWithAuth(`${API_BASE}/api/auth/me`, {
      method: 'PUT',
      body: JSON.stringify(userData),
    }),

  changePassword: async (currentPassword, newPassword) =>
    fetchWithAuth(`${API_BASE}/api/auth/change-password`, {
      method: 'POST',
      body: JSON.stringify({ current_password: currentPassword, new_password: newPassword }),
    }),

  logout: () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  },

  // Sensor data
  getLatestMeasurements: async () => fetchWithAuth(`${API_BASE}/api/mediciones/waspmote/latest`),

  getBatteryStatus: async () => fetchWithAuth(`${API_BASE}/api/estado-sistema/waspmote/latest`),

  getHistoricalData: async (hours = 24) =>
    fetchWithAuth(`${API_BASE}/api/mediciones/waspmote/historical?horas=${hours}`),

  postWaspmoteMeasurement: async (measurementData) =>
    fetchWithAuth(`${API_BASE}/api/mediciones/waspmote`, {
      method: 'POST',
      body: JSON.stringify(measurementData),
    }),

  postManualMeasurement: async () =>
    fetchWithAuth(`${API_BASE}/api/mediciones/manual`, { method: 'POST' }),

  // Configuración
  getAutoInterval: async () => fetchWithAuth(`${API_BASE}/api/config/auto-interval`),

  setAutoInterval: async (intervalo) =>
    fetchWithAuth(`${API_BASE}/api/config/auto-interval?intervalo=${intervalo}`, { method: 'PUT' }),

  // Health checks
  checkApiHealth: async () => {
    const response = await fetch(`${API_BASE}/health`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`API no disponible (${response.status})`);
    }

    return response.json();
  },

  checkDatabaseHealth: async () => fetchWithAuth(`${API_BASE}/api/mediciones/waspmote/latest`),

  // Session helpers
  isAuthenticated: () => !!localStorage.getItem('token'),
  getToken: () => localStorage.getItem('token'),
  getUser: () => {
    const userStr = localStorage.getItem('user');
    return userStr ? JSON.parse(userStr) : null;
  },

  // User management
  getUsers: async () => fetchWithAuth(`${API_BASE}/api/auth/users`),

  createUser: async (userData) =>
    fetchWithAuth(`${API_BASE}/api/auth/users`, {
      method: 'POST',
      body: JSON.stringify(userData),
    }),

  updateUser: async (userId, userData) =>
    fetchWithAuth(`${API_BASE}/api/auth/users/${userId}`, {
      method: 'PUT',
      body: JSON.stringify(userData),
    }),

  deleteUser: async (userId) =>
    fetchWithAuth(`${API_BASE}/api/auth/users/${userId}`, {
      method: 'DELETE',
    }),
};