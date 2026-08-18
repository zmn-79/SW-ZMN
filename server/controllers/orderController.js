const Order = require('../models/Order');
const Cart = require('../models/Cart');
const Product = require('../models/Product');
const Store = require('../models/Store');

/*
 * Checkout — تحويل السلة الحالية إلى طلب واحد أو أكثر (طلب منفصل لكل متجر)
 */
exports.checkout = async (req, res) => {
  try {
    const cart = await Cart.findOne({ customerId: req.user.id });

    if (!cart || cart.items.length === 0) {
      return res.status(400).json({
        code: 'EMPTY_CART',
        message: 'Cart is empty'
      });
    }

    // ===== 1. Hard check: التأكد من توفر كل المنتجات بأحدث بيانات فعلية =====
    const stockIssues = [];

    for (const item of cart.items) {
      const product = await Product.findById(item.productId);

      if (!product || product.quantity < item.quantity) {
        stockIssues.push({
          productId: item.productId,
          requested: item.quantity,
          available: product ? product.quantity : 0
        });
      }
    }

    if (stockIssues.length > 0) {
      return res.status(409).json({
        code: 'INSUFFICIENT_STOCK',
        message: 'Some items are no longer available in the requested quantity',
        issues: stockIssues
      });
    }

    // ===== 2. تقسيم عناصر السلة حسب المتجر (طلب منفصل لكل متجر) =====
    const itemsByStore = {};

    for (const item of cart.items) {
      const storeKey = item.storeId.toString();
      if (!itemsByStore[storeKey]) {
        itemsByStore[storeKey] = [];
      }
      itemsByStore[storeKey].push(item);
    }

    // ===== 3. إنشاء طلب لكل متجر =====
    const createdOrders = [];

    for (const storeId of Object.keys(itemsByStore)) {
      const storeItems = itemsByStore[storeId];

      const orderItems = [];
      let totalAmount = 0;

      for (const item of storeItems) {
        const product = await Product.findById(item.productId);
        orderItems.push({
          productId: item.productId,
          name: product.name,
          quantity: item.quantity,
          priceAtOrder: item.priceAtAdd
        });
        totalAmount += item.priceAtAdd * item.quantity;
      }

      const order = await Order.create({
        customerId: req.user.id,
        storeId,
        items: orderItems,
        totalAmount,
        status: 'pending'
      });

      createdOrders.push(order);
    }

    // ===== 4. تفريغ السلة بعد نجاح إنشاء الطلبات =====
    cart.items = [];
    await cart.save();

    return res.status(201).json({
      message: 'Order(s) created successfully',
      data: createdOrders
    });

  } catch (error) {
    return res.status(500).json({
      code: 'INTERNAL_ERROR',
      message: error.message
    });
  }
};

/*
 * Get My Orders (Customer)
 */
exports.getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ customerId: req.user.id })
      .populate('storeId', 'storeName')
      .sort({ createdAt: -1 });

    return res.status(200).json(orders);

  } catch (error) {
    return res.status(500).json({
      code: 'INTERNAL_ERROR',
      message: error.message
    });
  }
};

/*
 * Get Store Orders (Store Owner) — بس الطلبات الخاصة بمتجره
 */
exports.getStoreOrders = async (req, res) => {
  try {
    const store = await Store.findOne({ ownerId: req.user.id });

    if (!store) {
      return res.status(404).json({
        code: 'STORE_NOT_FOUND',
        message: 'No store found for this account'
      });
    }

    const orders = await Order.find({ storeId: store._id })
      .populate('customerId', 'fullName phone')
      .sort({ createdAt: -1 });

    return res.status(200).json(orders);

  } catch (error) {
    return res.status(500).json({
      code: 'INTERNAL_ERROR',
      message: error.message
    });
  }
};

/*
 * Update Order Status — بس لصاحب المتجر المرتبط بالطلب فعليًا
 */
exports.updateStatus = async (req, res) => {
  try {
    const { status } = req.body;

    if (!Order.ORDER_STATUSES.includes(status)) {
      return res.status(400).json({
        code: 'INVALID_STATUS',
        message: `status must be one of: ${Order.ORDER_STATUSES.join(', ')}`
      });
    }

    const order = await Order.findById(req.params.id);

    if (!order) {
      return res.status(404).json({
        code: 'ORDER_NOT_FOUND',
        message: 'Order not found'
      });
    }

    // ===== تحقق الملكية: هل صاحب المتجر ده فعلاً هو صاحب الطلب؟ =====
    const store = await Store.findOne({ ownerId: req.user.id });

    if (!store || order.storeId.toString() !== store._id.toString()) {
      return res.status(403).json({
        code: 'FORBIDDEN',
        message: 'You are not authorized to update this order'
      });
    }

    const previousStatus = order.status;

    // ===== إنقاص المخزون عند أول انتقال لحالة "confirmed" فقط =====
    if (status === 'confirmed' && previousStatus === 'pending') {
      for (const item of order.items) {
        await Product.findByIdAndUpdate(item.productId, {
          $inc: { quantity: -item.quantity }
        });
      }
    }

    order.status = status;
    await order.save();

    return res.status(200).json({
      message: 'Order status updated',
      data: order
    });

  } catch (error) {
    return res.status(500).json({
      code: 'INTERNAL_ERROR',
      message: error.message
    });
  }
};