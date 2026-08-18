const mongoose = require('mongoose');

const storeSchema = new mongoose.Schema(
  {
    ownerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },

    storeName: {
      type: String,
      required: true
    },

    storeType: {
      type: String,
      required: true
    },

    storeAddress: String,
    paymentMethods: String,
    description: String,

    taxNumber: String,
    commercialNumber: String,

    isActive: {
      type: Boolean,
      default: true
    }
  },
  { timestamps: true }
);

module.exports = mongoose.model('Store', storeSchema);