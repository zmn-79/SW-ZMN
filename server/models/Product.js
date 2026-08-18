const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({

  // Owner Store
  storeId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Store',
    required: true
  },

  // Product Category
  categoryId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
    required: true
  },

  // Product Name
  name: {
    type: String,
    required: true
  },

  // Purchase Price
  priceCapital: {
    type: Number,
    default: 0
  },

  // Sell Price
  priceSell: {
    type: Number,
    default: 0
  },

  // Barcode
  parcode: {
    type: Number
  },
  // Product Image
  imageUrl: {
    type: String,
    default: null
  },
  // Quantity
  quantity: {
    type: Number,
    default: 0
  },

  // Manufacture Year
  yearManufacture: {
    type: Number
  },

  // Product Age
  age: {
    type: Number
  },

  // Size
  size: {
    type: String
  },

  // Expiry Date
  expiryDate: {
    type: Date
  }

},
{
  timestamps: true
});

module.exports =
  mongoose.model('Product', productSchema);