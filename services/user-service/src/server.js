const express = require('express');
const mongoose = require('mongoose');
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const axios = require('axios');
require('dotenv').config();

const authRoutes = require('./routes/auth'); // ✅ ADD THIS

const app = express();
const PORT = process.env.PORT || 3001;

// Vault configuration
const VAULT_ADDR = process.env.VAULT_ADDR || 'http://vault.vault:8200';
const VAULT_ROLE = process.env.VAULT_ROLE || 'ecommerce';

// Trust proxy for rate limiting behind Ingress/ALB
app.set('trust proxy', 1);

// =====================
// Vault helpers
// =====================
async function getVaultToken() {
  try {
    const jwt = require('fs').readFileSync(
      '/var/run/secrets/kubernetes.io/serviceaccount/token',
      'utf8'
    );

    const response = await axios.post(
      `${VAULT_ADDR}/v1/auth/kubernetes/login`,
      { role: VAULT_ROLE, jwt }
    );

    return response.data.auth.client_token;
  } catch (error) {
    console.error('Error getting Vault token:', error.message);
    return null;
  }
}

async function getVaultSecret(path) {
  try {
    const token = await getVaultToken();
    if (!token) return null;

    const response = await axios.get(
      `${VAULT_ADDR}/v1/secret/data/${path}`,
      { headers: { 'X-Vault-Token': token } }
    );

    return response.data.data.data;
  } catch (error) {
    console.error(`Error getting secret ${path}:`, error.message);
    return null;
  }
}

// =====================
// Init secrets
// =====================
let JWT_SECRET;
let DB_CREDENTIALS;

async function initializeSecrets() {
  const mongoSecret = await getVaultSecret('ecommerce/mongodb');
  if (mongoSecret) DB_CREDENTIALS = mongoSecret;

  const jwtSecret = await getVaultSecret('ecommerce/jwt');
  JWT_SECRET = jwtSecret?.secret || process.env.JWT_SECRET || 'dev-secret';
}

initializeSecrets();

// =====================
// Middleware
// =====================
app.use(helmet());
app.use(cors());
app.use(express.json());

// Rate limiting (skip health checks)
app.use('/api/',
  rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 1000 // Increased limit
  })
);

// =====================
// Routes
// =====================

// Health check (for ALB & K8s)
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    service: 'user-service'
  });
});

// ✅ THIS WAS MISSING
app.use('/api/auth', authRoutes);

// =====================
// Database
// =====================
async function connectToMongoDB() {
  const uri =
    DB_CREDENTIALS
      ? `mongodb://${DB_CREDENTIALS.username}:${DB_CREDENTIALS.password}@mongodb:27017/users?authSource=admin`
      : process.env.DB_CONNECTION_STRING;

  try {
    await mongoose.connect(uri);
    console.log('✅ Connected to MongoDB');
  } catch (err) {
    console.error('❌ MongoDB connection error:', err);
  }
}

connectToMongoDB();

// =====================
// Start server
// =====================
app.listen(PORT, () => {
  console.log(`✅ User Service running on port ${PORT}`);
  console.log(`🔐 Vault integration: ${VAULT_ADDR}`);
});

module.exports = app;
