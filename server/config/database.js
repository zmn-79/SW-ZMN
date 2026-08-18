// ===============================
// MongoDB Connection
// ===============================

const mongoose = require('mongoose');

const connectDatabase = async () => {
  try {
    const uri = process.env.MONGODB_URI;

    if (!uri) {
      throw new Error('MONGODB_URI missing in .env');
    }

    await mongoose.connect(uri);

    console.log('✅ Database Connected');

  } catch (err) {
    console.error('❌ DB Connection Error:', err.message);
    process.exit(1);
  }
};

module.exports = connectDatabase;