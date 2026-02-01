import { userApi } from './api';

class AuthService {
  async register(userData) {
    try {
      const response = await userApi.post('/register', userData);
      if (response.data.token) {
        this.setAuth(response.data);
      }
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async login(credentials) {
    try {
      const response = await userApi.post('/login', credentials);
      if (response.data.token) {
        this.setAuth(response.data);
      }
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    window.location.href = '/login';
  }

  setAuth(data) {
    localStorage.setItem('token', data.token);
    localStorage.setItem('user', JSON.stringify(data.user));
  }

  getToken() {
    return localStorage.getItem('token');
  }

  getUser() {
    const user = localStorage.getItem('user');
    return user ? JSON.parse(user) : null;
  }

  isAuthenticated() {
    return !!this.getToken();
  }

  isAdmin() {
    const user = this.getUser();
    return user?.role === 'admin';
  }

  async getCurrentUser() {
    try {
      const response = await userApi.get('/me');
      return response.data;
    } catch (error) {
      this.logout();
      throw error;
    }
  }

  async updateProfile(userData) {
    try {
      const response = await userApi.put('/me', userData);
      if (response.data.user) {
        localStorage.setItem('user', JSON.stringify(response.data.user));
      }
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async changePassword(passwordData) {
    try {
      const response = await userApi.put('/me/password', passwordData);
      return response.data;
    } catch (error) {
      throw error;
    }
  }
}

const authService = new AuthService();
export default authService;
