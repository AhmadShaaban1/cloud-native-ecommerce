const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// Security middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
});
app.use(limiter);

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy',
    service: 'user-service',
    timestamp: new Date().toISOString()
  });
});

// Ready check
app.get('/ready', (req, res) => {
  res.status(200).json({ status: 'ready' });
});

// API routes
app.get('/api/users', (req, res) => {
  res.json({ 
    message: 'User service is running',
    users: []
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

app.listen(PORT, () => {
  console.log(`✅ User Service running on port ${PORT}`);
});

module.exports = app;// CI/CD test
