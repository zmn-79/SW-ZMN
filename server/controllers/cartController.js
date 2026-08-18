const Cart = require('../models/Cart');
const Product = require('../models/Product');

/*
 * Get My Cart
 */
exports.getCart = async (req, res) => {
  try {
    const cart = await Cart.findOne({ customerId: req.user.id })
     .populate('items.productId', 'name priceSell quantity imageUrl')
      .populate('items.storeId', 'storeName');

    if (!cart) {
      return res.status(200).json({ customerId: req.user.id, items: [] });
    }

    return res.status(200).json(cart);

  } catch (error) {
    return res.status(500).json({
      code: 'INTERNAL_ERROR',
      message: error.message
    });
  }
};

/*
 * Add Item to Cart (or increase quantity if it already exists)
 */
exports.addItem = async (req, res) => {
  try {
    const { productId, quantity } = req.body;

    if (!productId || !quantity || quantity < 1) {
      return res.status(400).json({
        code: 'INVALID_ITEM',
        message: 'productId and a quantity of at least 1 are required'
      });
    }

    const product = await Product.findById(productId);

    if (!product) {
      return res.status(404).json({
        code: 'PRODUCT_NOT_FOUND',
        message: 'Product not found'
      });
    }

    let cart = await Cart.findOne({ customerId: req.user.id });

    if (!cart) {
      cart = new Cart({ customerId: req.user.id, items: [] });
    }

    const existingItem = cart.items.find(
      (item) => item.productId.toString() === productId
    );

    if (existingItem) {
      existingItem.quantity += quantity;
    } else {
      cart.items.push({
        productId: product._id,
        storeId: product.storeId,
        quantity,
        priceAtAdd: product.priceSell
      });
    }

 await cart.save();

    await cart.populate('items.productId', 'name priceSell quantity imageUrl');
    await cart.populate('items.storeId', 'storeName');

    // تحذير غير حاجز (Soft check) لو الكمية المطلوبة أكبر من المتاح حاليًا
    const availableQuantity = product.quantity;
    const requestedQuantity = existingItem ? existingItem.quantity : quantity;
    const stockWarning = requestedQuantity > availableQuantity;

    return res.status(200).json({
      message: 'Item added to cart',
      data: cart,
      stockWarning,
      availableQuantity
    });

  } catch (error) {
    return res.status(500).json({
      code: 'INTERNAL_ERROR',
      message: error.message
    });
  }
};

/*
 * Update Item Quantity
 */
exports.updateItemQuantity = async (req, res) => {
  try {
    const { quantity } = req.body;
    const { productId } = req.params;

    if (!quantity || quantity < 1) {
      return res.status(400).json({
        code: 'INVALID_QUANTITY',
        message: 'quantity must be at least 1'
      });
    }

    const cart = await Cart.findOne({ customerId: req.user.id });

    if (!cart) {
      return res.status(404).json({
        code: 'CART_NOT_FOUND',
        message: 'Cart not found'
      });
    }

    const item = cart.items.find(
      (item) => item.productId.toString() === productId
    );

    if (!item) {
      return res.status(404).json({
        code: 'ITEM_NOT_FOUND',
        message: 'Item not found in cart'
      });
    }

 item.quantity = quantity;
    await cart.save();

    await cart.populate('items.productId', 'name priceSell quantity imageUrl');
    await cart.populate('items.storeId', 'storeName');

    return res.status(200).json({
      message: 'Quantity updated',
      data: cart
    });

  } catch (error) {
    return res.status(500).json({
      code: 'INTERNAL_ERROR',
      message: error.message
    });
  }
};

/*
 * Remove Item from Cart
 */
exports.removeItem = async (req, res) => {
  try {
    const { productId } = req.params;

    const cart = await Cart.findOne({ customerId: req.user.id });

    if (!cart) {
      return res.status(404).json({
        code: 'CART_NOT_FOUND',
        message: 'Cart not found'
      });
    }

  cart.items = cart.items.filter(
      (item) => item.productId.toString() !== productId
    );

    await cart.save();

    await cart.populate('items.productId', 'name priceSell quantity imageUrl');
    await cart.populate('items.storeId', 'storeName');

    return res.status(200).json({
      message: 'Item removed',
      data: cart
    });

  } catch (error) {
    return res.status(500).json({
      code: 'INTERNAL_ERROR',
      message: error.message
    });
  }
};

/*
 * Clear Cart
 */
exports.clearCart = async (req, res) => {
  try {
    await Cart.findOneAndUpdate(
      { customerId: req.user.id },
      { items: [] }
    );

    return res.status(200).json({ message: 'Cart cleared' });

  } catch (error) {
    return res.status(500).json({
      code: 'INTERNAL_ERROR',
      message: error.message
    });
  }
};