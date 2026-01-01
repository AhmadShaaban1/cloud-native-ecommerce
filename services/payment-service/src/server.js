const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3004;

app.use(helmet());
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy',
    service: 'payment-service',
    timestamp: new Date().toISOString()
  });
});

app.get('/api/payments', (req, res) => {
  res.json({ 
    message: 'payment service is running',
    payments: []
  });
});

app.listen(PORT, () => {
  console.log(`✅ payment Service running on port ${PORT}`);
});

module.exports = app;