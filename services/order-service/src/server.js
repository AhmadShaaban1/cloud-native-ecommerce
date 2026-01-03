const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3003;

app.use(helmet());
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy',
    service: 'order-service',
    timestamp: new Date().toISOString()
  });
});

app.get('/api/orders', (req, res) => {
  res.json({ 
    message: 'order service is running',
    orders: []
  });
});

app.listen(PORT, () => {
  console.log(`✅ order Service running on port ${PORT}`);
});

module.exports = app;
// AWS Credentials