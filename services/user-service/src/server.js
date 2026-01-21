const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// Vault configuration
const VAULT_ADDR = process.env.VAULT_ADDR || 'http://vault.vault:8200';
const VAULT_ROLE = process.env.VAULT_ROLE || 'ecommerce';

// Function to get Vault token
async function getVaultToken() {
  try {
    const jwt = require('fs').readFileSync('/var/run/secrets/kubernetes.io/serviceaccount/token', 'utf8');
    const response = await axios.post(`${VAULT_ADDR}/v1/auth/kubernetes/login`, {
      role: VAULT_ROLE,
      jwt: jwt
    });
    return response.data.auth.client_token;
  } catch (error) {
    console.error('Error getting Vault token:', error.message);
    return null;
  }
}

// Function to get secret from Vault
async function getVaultSecret(path) {
  try {
    const token = await getVaultToken();
    if (!token) {
      console.log('No Vault token, using environment variables');
      return null;
    }

    const response = await axios.get(`${VAULT_ADDR}/v1/secret/data/${path}`, {
      headers: { 'X-Vault-Token': token }
    });
    return response.data.data.data;
  } catch (error) {
    console.error(`Error getting secret ${path}:`, error.message);
    return null;
  }
}

// Initialize secrets
let JWT_SECRET;
let DB_CREDENTIALS;

async function initializeSecrets() {
  try {
    // Get MongoDB credentials from Vault
    const mongoSecret = await getVaultSecret('ecommerce/mongodb');
    if (mongoSecret) {
      DB_CREDENTIALS = mongoSecret;
      console.log('✅ Loaded MongoDB credentials from Vault');
    }

    // Get JWT secret from Vault
    const jwtSecret = await getVaultSecret('ecommerce/jwt');
    if (jwtSecret) {
      JWT_SECRET = jwtSecret.secret;
      console.log('✅ Loaded JWT secret from Vault');
    }

    // Fallback to environment variables
    if (!JWT_SECRET) {
      JWT_SECRET = process.env.JWT_SECRET || 'default-secret-change-in-production';
      console.log('⚠️  Using JWT secret from environment variables');
    }
  } catch (error) {
    console.error('Error initializing secrets:', error);
    JWT_SECRET = process.env.JWT_SECRET || 'default-secret-change-in-production';
  }
}

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
});
app.use(limiter);

// MongoDB connection
async function connectToMongoDB() {
  await initializeSecrets();

  let connectionString;
  if (DB_CREDENTIALS) {
    connectionString = `mongodb://${DB_CREDENTIALS.username}:${DB_CREDENTIALS.password}@mongodb:27017/users?authSource=admin`;
  } else {
    connectionString = process.env.DB_CONNECTION_STRING || 'mongodb://admin:password123@mongodb:27017/users?authSource=admin';
  }

  try {
    await mongoose.connect(connectionString, {
      useNewUrlParser: true,
      useUnifiedTopology: true
    });
    console.log('✅ Connected to MongoDB');
  } catch (err) {
    console.error('❌ MongoDB connection error:', err);
  }
}

connectToMongoDB();

// ... (rest of your user service code remains the same)
// Health check, User Schema, routes, etc.

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    service: 'user-service',
    timestamp: new Date().toISOString(),
    database: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected',
    vault: VAULT_ADDR
  });
});

// (Include all previous routes: register, login, profile, etc.)

app.listen(PORT, () => {
  console.log(`✅ User Service running on port ${PORT}`);
  console.log(`🔐 Vault integration: ${VAULT_ADDR}`);
});

module.exports = app;