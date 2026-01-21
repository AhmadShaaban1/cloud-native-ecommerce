import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Link, useNavigate } from 'react-router-dom';
import axios from 'axios';
import './App.css';

// Get Istio Gateway URL or fallback to localhost
const API_BASE = process.env.REACT_APP_API_URL || window.location.origin;

// Auth context
const AuthContext = React.createContext();

function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(localStorage.getItem('token'));

  useEffect(() => {
    const savedUser = localStorage.getItem('user');
    if (savedUser) {
      setUser(JSON.parse(savedUser));
    }
  }, []);

  const login = (userData, userToken) => {
    setUser(userData);
    setToken(userToken);
    localStorage.setItem('user', JSON.stringify(userData));
    localStorage.setItem('token', userToken);
  };

  const logout = () => {
    setUser(null);
    setToken(null);
    localStorage.removeItem('user');
    localStorage.removeItem('token');
  };

  return (
    <AuthContext.Provider value={{ user, token, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

// Home Component
function Home() {
  const [stats, setStats] = useState({
    users: 0,
    products: 0,
    orders: 0
  });

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const [usersRes, productsRes, ordersRes] = await Promise.all([
        axios.get(`${API_BASE}/api/users`).catch(() => ({ data: { count: 0 } })),
        axios.get(`${API_BASE}/api/products`).catch(() => ({ data: { count: 0 } })),
        axios.get(`${API_BASE}/api/orders`).catch(() => ({ data: { count: 0 } }))
      ]);

      setStats({
        users: usersRes.data.count || 0,
        products: productsRes.data.count || 0,
        orders: ordersRes.data.count || 0
      });
    } catch (error) {
      console.error('Error fetching stats:', error);
    }
  };

  return (
    <div className="hero">
      <div className="hero-content">
        <h1>☁️ Cloud-Native E-Commerce</h1>
        <p className="subtitle">Production-grade microservices on AWS EKS</p>
        
        <div className="stats">
          <div className="stat-card">
            <div className="stat-number">{stats.users}</div>
            <div className="stat-label">Users</div>
          </div>
          <div className="stat-card">
            <div className="stat-number">{stats.products}</div>
            <div className="stat-label">Products</div>
          </div>
          <div className="stat-card">
            <div className="stat-number">{stats.orders}</div>
            <div className="stat-label">Orders</div>
          </div>
        </div>

        <div className="features">
          <div className="feature-card">
            <h3>🚀 4 t3.medium Nodes</h3>
            <p>High-performance Kubernetes cluster</p>
          </div>
          <div className="feature-card">
            <h3>📊 Full Observability</h3>
            <p>Prometheus, Grafana, Loki, Kiali</p>
          </div>
          <div className="feature-card">
            <h3>🔐 Enterprise Security</h3>
            <p>Vault, Istio mTLS, Network Policies</p>
          </div>
          <div className="feature-card">
            <h3>🔄 GitOps Ready</h3>
            <p>ArgoCD automated deployments</p>
          </div>
        </div>

        <div className="cta-buttons">
          <Link to="/products" className="btn btn-primary">Browse Products</Link>
          <Link to="/register" className="btn btn-secondary">Get Started</Link>
        </div>
      </div>
    </div>
  );
}

// Products Component
function Products() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [cart, setCart] = useState([]);
  const [category, setCategory] = useState('');
  const [search, setSearch] = useState('');

  useEffect(() => {
    fetchProducts();
  }, [category, search]);

  const fetchProducts = async () => {
    try {
      setLoading(true);
      let url = `${API_BASE}/api/products`;
      const params = new URLSearchParams();
      if (category) params.append('category', category);
      if (search) params.append('search', search);
      if (params.toString()) url += `?${params.toString()}`;

      const response = await axios.get(url);
      setProducts(response.data.products || []);
    } catch (error) {
      console.error('Error fetching products:', error);
      setProducts([]);
    } finally {
      setLoading(false);
    }
  };

  const addToCart = (product) => {
    setCart([...cart, product]);
    alert(`✅ ${product.name} added to cart!`);
  };

  if (loading) {
    return (
      <div className="loading">
        <div className="spinner"></div>
        <p>Loading products...</p>
      </div>
    );
  }

  return (
    <div className="products-container">
      <div className="products-header">
        <h2>Our Products</h2>
        <div className="filters">
          <input
            type="text"
            placeholder="Search products..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="search-input"
          />
          <select value={category} onChange={(e) => setCategory(e.target.value)} className="category-select">
            <option value="">All Categories</option>
            <option value="Electronics">Electronics</option>
            <option value="Furniture">Furniture</option>
          </select>
        </div>
      </div>

      {products.length === 0 ? (
        <div className="no-products">
          <h3>No products found</h3>
          <p>Try adjusting your filters or search terms</p>
        </div>
      ) : (
        <div className="products-grid">
          {products.map(product => (
            <div key={product._id} className="product-card">
              <div className="product-image">
                <img src={product.imageUrl || 'https://via.placeholder.com/300x200'} alt={product.name} />
                {product.stock < 10 && <span className="low-stock">Low Stock!</span>}
              </div>
              <div className="product-info">
                <h3>{product.name}</h3>
                <p className="product-description">{product.description}</p>
                <div className="product-meta">
                  <span className="category">{product.category}</span>
                  <span className={`stock ${product.stock > 0 ? 'in-stock' : 'out-of-stock'}`}>
                    {product.stock > 0 ? `${product.stock} in stock` : 'Out of stock'}
                  </span>
                </div>
                <div className="product-footer">
                  <span className="price">${product.price.toFixed(2)}</span>
                  <button 
                    onClick={() => addToCart(product)}
                    disabled={product.stock === 0}
                    className="btn btn-primary"
                  >
                    {product.stock > 0 ? 'Add to Cart' : 'Out of Stock'}
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// Register Component
function Register() {
  const navigate = useNavigate();
  const { login } = React.useContext(AuthContext);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: ''
  });
  const [message, setMessage] = useState({ type: '', text: '' });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setMessage({ type: '', text: '' });

    try {
      const response = await axios.post(`${API_BASE}/api/users/register`, formData);
      setMessage({ type: 'success', text: 'Registration successful! Redirecting...' });
      login(response.data.user, response.data.token);
      setTimeout(() => navigate('/products'), 2000);
    } catch (error) {
      setMessage({ 
        type: 'error', 
        text: error.response?.data?.error || 'Registration failed. Please try again.' 
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="form-container">
      <div className="form-card">
        <h2>Create Account</h2>
        <p className="form-subtitle">Join our cloud-native platform</p>
        
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Full Name</label>
            <input
              type="text"
              placeholder="John Doe"
              value={formData.name}
              onChange={(e) => setFormData({...formData, name: e.target.value})}
              required
            />
          </div>

          <div className="form-group">
            <label>Email Address</label>
            <input
              type="email"
              placeholder="john@example.com"
              value={formData.email}
              onChange={(e) => setFormData({...formData, email: e.target.value})}
              required
            />
          </div>

          <div className="form-group">
            <label>Password</label>
            <input
              type="password"
              placeholder="••••••••"
              value={formData.password}
              onChange={(e) => setFormData({...formData, password: e.target.value})}
              required
              minLength={6}
            />
          </div>

          <button type="submit" className="btn btn-primary btn-block" disabled={loading}>
            {loading ? 'Creating Account...' : 'Register'}
          </button>
        </form>

        {message.text && (
          <div className={`message ${message.type}`}>
            {message.text}
          </div>
        )}

        <p className="form-footer">
          Already have an account? <Link to="/login">Login here</Link>
        </p>
      </div>
    </div>
  );
}

// Login Component
function Login() {
  const navigate = useNavigate();
  const { login } = React.useContext(AuthContext);
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  });
  const [message, setMessage] = useState({ type: '', text: '' });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setMessage({ type: '', text: '' });

    try {
      const response = await axios.post(`${API_BASE}/api/users/login`, formData);
      setMessage({ type: 'success', text: 'Login successful! Redirecting...' });
      login(response.data.user, response.data.token);
      setTimeout(() => navigate('/products'), 2000);
    } catch (error) {
      setMessage({ 
        type: 'error', 
        text: error.response?.data?.error || 'Login failed. Please check your credentials.' 
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="form-container">
      <div className="form-card">
        <h2>Welcome Back</h2>
        <p className="form-subtitle">Login to your account</p>
        
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Email Address</label>
            <input
              type="email"
              placeholder="john@example.com"
              value={formData.email}
              onChange={(e) => setFormData({...formData, email: e.target.value})}
              required
            />
          </div>

          <div className="form-group">
            <label>Password</label>
            <input
              type="password"
              placeholder="••••••••"
              value={formData.password}
              onChange={(e) => setFormData({...formData, password: e.target.value})}
              required
            />
          </div>

          <button type="submit" className="btn btn-primary btn-block" disabled={loading}>
            {loading ? 'Logging in...' : 'Login'}
          </button>
        </form>

        {message.text && (
          <div className={`message ${message.type}`}>
            {message.text}
          </div>
        )}

        <p className="form-footer">
          Don't have an account? <Link to="/register">Register here</Link>
        </p>
      </div>
    </div>
  );
}

// Navigation Bar
function Navbar() {
  const { user, logout } = React.useContext(AuthContext);

  return (
    <nav className="navbar">
      <div className="nav-brand">
        <Link to="/">☁️ Cloud E-Commerce</Link>
      </div>
      <div className="nav-links">
        <Link to="/">Home</Link>
        <Link to="/products">Products</Link>
        {user ? (
          <>
            <span className="user-name">Hello, {user.name}</span>
            <button onClick={logout} className="btn btn-small">Logout</button>
          </>
        ) : (
          <>
            <Link to="/register">Register</Link>
            <Link to="/login">Login</Link>
          </>
        )}
      </div>
    </nav>
  );
}

// Footer
function Footer() {
  return (
    <footer className="footer">
      <div className="footer-content">
        <div className="footer-section">
          <h4>Platform Stats</h4>
          <p>✅ Kubernetes 1.33</p>
          <p>✅ 4 t3.medium Nodes</p>
          <p>✅ 100% Infrastructure as Code</p>
        </div>
        <div className="footer-section">
          <h4>Tech Stack</h4>
          <p>⚙️ AWS EKS + Istio</p>
          <p>🔐 HashiCorp Vault</p>
          <p>📊 Prometheus + Grafana</p>
        </div>
        <div className="footer-section">
          <h4>By Ahmed Shaaban</h4>
          <p>🚀 Production-Ready DevOps</p>
          <p>📧 DevOps Engineer</p>
          <a href="https://github.com/AhmadShaaban1/cloud-native-ecommerce" target="_blank" rel="noopener noreferrer">
            GitHub Repository
          </a>
        </div>
      </div>
      <div className="footer-bottom">
        <p>&copy; 2026 Cloud-Native E-Commerce | Built with ❤️ on AWS</p>
      </div>
    </footer>
  );
}

// Main App
function App() {
  return (
    <AuthProvider>
      <Router>
        <div className="App">
          <Navbar />
          
          <main className="main-content">
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/products" element={<Products />} />
              <Route path="/register" element={<Register />} />
              <Route path="/login" element={<Login />} />
            </Routes>
          </main>

          <Footer />
        </div>
      </Router>
    </AuthProvider>
  );
}

export default App;