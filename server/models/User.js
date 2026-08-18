const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    fullName: String,
    email: { type: String, unique: true },
    phone: String,
    passwordHash: String,

    role: {
      type: String,
      enum: ['customer', 'store_owner'],
      required: true
    }
  },
  { timestamps: true }
);

module.exports = mongoose.model('User', userSchema);