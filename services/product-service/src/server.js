const express = require('express');
const mongoose = require('mongoose');
const helmet = require('helmet');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3002;

app.use(helmet());
app.use(cors());
app.use(express.json());

// MongoDB connection
mongoose.connect(process.env.DB_CONNECTION_STRING || 'mongodb://admin:password123@mongodb:27017/products?authSource=admin', {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log('✅ Connected to MongoDB');
}).catch(err => {
  console.error('❌ MongoDB connection error:', err);
});

// Product Schema
const productSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String, required: true },
  price: { type: Number, required: true },
  category: { type: String, required: true },
  stock: { type: Number, default: 0 },
  imageUrl: { type: String },
  createdAt: { type: Date, default: Date.now }
});

const Product = mongoose.model('Product', productSchema);

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    service: 'product-service',
    timestamp: new Date().toISOString()
  });
});

// Get all products
app.get('/api/products', async (req, res) => {
  try {
    const { category, search } = req.query;
    let query = {};

    if (category) {
      query.category = category;
    }

    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } }
      ];
    }

    const products = await Product.find(query).sort({ createdAt: -1 });
    res.status(200).json({
      count: products.length,
      products
    });
  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({ error: 'Failed to fetch products' });
  }
});

// Get single product
app.get('/api/products/:id', async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    
    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }

    res.status(200).json({ product });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch product' });
  }
});

// Create product
app.post('/api/products', async (req, res) => {
  try {
    const { name, description, price, category, stock, imageUrl } = req.body;

    const product = new Product({
      name,
      description,
      price,
      category,
      stock,
      imageUrl
    });

    await product.save();

    res.status(201).json({
      message: 'Product created successfully',
      product
    });
  } catch (error) {
    console.error('Error creating product:', error);
    res.status(500).json({ error: 'Failed to create product' });
  }
});

// Seed sample products (for testing)
app.post('/api/products/seed', async (req, res) => {
  try {
    const sampleProducts = [
      {
        name: 'Laptop Pro 15',
        description: 'High-performance laptop for professionals',
        price: 1299.99,
        category: 'Electronics',
        stock: 25,
        imageUrl: 'https://via.placeholder.com/300x200'
      },
      {
        name: 'Wireless Mouse',
        description: 'Ergonomic wireless mouse',
        price: 29.99,
        category: 'Electronics',
        stock: 100,
        imageUrl: 'https://via.placeholder.com/300x200'
      },
      {
        name: 'Office Chair',
        description: 'Comfortable ergonomic office chair',
        price: 249.99,
        category: 'Furniture',
        stock: 15,
        imageUrl: 'https://via.placeholder.com/300x200'
      },
      {
        name: 'Standing Desk',
        description: 'Adjustable height standing desk',
        price: 399.99,
        category: 'Furniture',
        stock: 10,
        imageUrl: 'https://via.placeholder.com/300x200'
      },
      {
        name: 'Mechanical Keyboard',
        description: 'RGB mechanical gaming keyboard',
        price: 89.99,
        category: 'Electronics',
        stock: 50,
        imageUrl: 'https://via.placeholder.com/300x200'
      }
    ];

    await Product.deleteMany({});
    await Product.insertMany(sampleProducts);

    res.status(201).json({
      message: 'Sample products created',
      count: sampleProducts.length
    });
  } catch (error) {
    console.error('Seed error:', error);
    res.status(500).json({ error: 'Failed to seed products' });
  }
});

app.listen(PORT, () => {
  console.log(`✅ Product Service running on port ${PORT}`);
});

module.exports = app;