import React, { useEffect, useState } from 'react';
import './App.css';

function App() {
  const [services, setServices] = useState({
    user: 'checking...',
    product: 'checking...',
    order: 'checking...',
    payment: 'checking...'
  });

  useEffect(() => {
    // Check backend services health
    const checkServices = async () => {
      const endpoints = [
        { name: 'user', url: 'http://localhost:3001/health' },
        { name: 'product', url: 'http://localhost:3002/health' },
        { name: 'order', url: 'http://localhost:3003/health' },
        { name: 'payment', url: 'http://localhost:3004/health' }
      ];

      for (const endpoint of endpoints) {
        try {
          const response = await fetch(endpoint.url);
          const data = await response.json();
          setServices(prev => ({
            ...prev,
            [endpoint.name]: data.status
          }));
        } catch (error) {
          setServices(prev => ({
            ...prev,
            [endpoint.name]: 'offline'
          }));
        }
      }
    };

    checkServices();
    const interval = setInterval(checkServices, 10000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <h1>☁️ Cloud Native E-Commerce</h1>
        <p>Microservices Architecture on AWS EKS</p>
        
        <div className="services-status">
          <h2>Backend Services Status</h2>
          <div className="status-grid">
            <ServiceStatus name="User Service" status={services.user} />
            <ServiceStatus name="Product Service" status={services.product} />
            <ServiceStatus name="Order Service" status={services.order} />
            <ServiceStatus name="Payment Service" status={services.payment} />
          </div>
        </div>
      </header>
    </div>
  );
}

function ServiceStatus({ name, status }) {
  const getStatusColor = () => {
    if (status === 'healthy') return '#4caf50';
    if (status === 'offline') return '#f44336';
    return '#ff9800';
  };

  return (
    <div className="service-card">
      <h3>{name}</h3>
      <div 
        className="status-indicator"
        style={{ backgroundColor: getStatusColor() }}
      >
        {status}
      </div>
    </div>
  );
}

export default App;