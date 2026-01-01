const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3002;

app.use(helmet());
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy',
    service: 'product-service',
    timestamp: new Date().toISOString()
  });
});

app.get('/api/products', (req, res) => {
  res.json({ 
    message: 'Product service is running',
    products: []
  });
});

app.listen(PORT, () => {
  console.log(`✅ Product Service running on port ${PORT}`);
});

module.exports = app;