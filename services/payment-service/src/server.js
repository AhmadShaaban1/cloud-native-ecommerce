const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3004;

app.use(helmet());
app.use(cors());
app.use(express.json());

// In-memory payment store (for demo - use database in production)
const payments = new Map();

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    service: 'payment-service',
    timestamp: new Date().toISOString()
  });
});

// Process payment
app.post('/api/payments/process', async (req, res) => {
  try {
    const { orderId, amount, currency, userId } = req.body;

    // Validate
    if (!orderId || !amount || !currency) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Simulate payment processing (80% success rate)
    const success = Math.random() > 0.2;

    const paymentId = uuidv4();
    const payment = {
      paymentId,
      orderId,
      amount,
      currency,
      userId,
      status: success ? 'success' : 'failed',
      timestamp: new Date().toISOString(),
      method: 'credit_card',
      last4: '4242'
    };

    payments.set(paymentId, payment);

    // Simulate processing delay
    await new Promise(resolve => setTimeout(resolve, 500));

    if (success) {
      res.status(200).json({
        message: 'Payment processed successfully',
        paymentId,
        status: 'success',
        transactionId: paymentId
      });
    } else {
      res.status(400).json({
        message: 'Payment failed',
        status: 'failed',
        error: 'Card declined'
      });
    }
  } catch (error) {
    console.error('Payment processing error:', error);
    res.status(500).json({ error: 'Payment processing failed' });
  }
});

// Get payment status
app.get('/api/payments/:paymentId', (req, res) => {
  try {
    const payment = payments.get(req.params.paymentId);
    
    if (!payment) {
      return res.status(404).json({ error: 'Payment not found' });
    }

    res.status(200).json({ payment });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch payment' });
  }
});

// Refund payment
app.post('/api/payments/:paymentId/refund', async (req, res) => {
  try {
    const payment = payments.get(req.params.paymentId);
    
    if (!payment) {
      return res.status(404).json({ error: 'Payment not found' });
    }

    if (payment.status !== 'success') {
      return res.status(400).json({ error: 'Can only refund successful payments' });
    }

    // Simulate refund processing
    await new Promise(resolve => setTimeout(resolve, 500));

    payment.status = 'refunded';
    payment.refundedAt = new Date().toISOString();
    payments.set(req.params.paymentId, payment);

    res.status(200).json({
      message: 'Refund processed successfully',
      payment
    });
  } catch (error) {
    res.status(500).json({ error: 'Refund failed' });
  }
});

// List all payments (for testing)
app.get('/api/payments', (req, res) => {
  try {
    const allPayments = Array.from(payments.values())
      .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
      .slice(0, 50);

    res.status(200).json({
      count: allPayments.length,
      payments: allPayments
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch payments' });
  }
});

// Get payment methods
app.get('/api/payments/methods', (req, res) => {
  res.status(200).json({
    methods: [
      { id: '1', type: 'credit_card', last4: '4242', default: true },
      { id: '2', type: 'paypal', email: 'user@example.com', default: false }
    ]
  });
});

// Add payment method
app.post('/api/payments/methods', (req, res) => {
  const { type, details } = req.body;
  res.status(201).json({
    message: 'Payment method added',
    method: { id: uuidv4(), type, ...details }
  });
});

// Delete payment method
app.delete('/api/payments/methods/:id', (req, res) => {
  res.status(200).json({
    message: 'Payment method deleted'
  });
});

// Get payment history
app.get('/api/payments/history', (req, res) => {
  const allPayments = Array.from(payments.values())
    .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

  res.status(200).json({
    count: allPayments.length,
    payments: allPayments
  });
});

// Verify payment
app.get('/api/payments/:paymentId/verify', (req, res) => {
  const payment = payments.get(req.params.paymentId);
  
  if (!payment) {
    return res.status(404).json({ error: 'Payment not found' });
  }

  res.status(200).json({
    verified: payment.status === 'success',
    payment
  });
});

app.listen(PORT, () => {
  console.log(`✅ Payment Service running on port ${PORT}`);
});

module.exports = app;