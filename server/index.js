// Load environment variables
require('dotenv').config();

// Import Express
const express = require('express');
const app = express();

// Connect to MongoDB
const mongoose = require('mongoose');

// --------------------
// Middleware
// --------------------

// JSON parser (بديل bodyParser)
app.use(express.json());

// --------------------
// Routes
// --------------------
// Auth Routes
const authRoutes = require('./routes/authRoutes');
app.use('/auth', authRoutes);

// Users Routes
const userRoutes = require('./routes/userRoutes');
app.use('/users', userRoutes);
// Cart Routes
const cartRoutes = require('./routes/cartRoutes');
app.use('/cart', cartRoutes);
// Order Routes
const orderRoutes = require('./routes/orderRoutes');
app.use('/orders', orderRoutes);
// Store Routes
const storeRoutes = require('./routes/storeRoutes');
app.use('/stores', storeRoutes);
// Categories Routes
const categoryRoutes = require('./routes/categoryRoutes');
app.use('/categories', categoryRoutes);

// Products Routes
const productRoutes =
  require('./routes/productRoutes');

app.use(
  '/products',
  productRoutes
);

// --------------------
// Database Connection
// --------------------

mongoose.connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('✅ Connected to MongoDB');
  })
  .catch((err) => {
    console.error('❌ MongoDB connection error:', err);
    process.exit(1);
  });

// --------------------
// Health Check
// --------------------

app.get('/', (req, res) => {
  res.json({
    status: 'OK',
    message: 'API is running',
    time: new Date().toISOString()
  });
});

// --------------------
// Start Server
// --------------------

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});