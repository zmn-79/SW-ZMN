const express = require('express');
const router = express.Router();

const orderController = require('../controllers/orderController');
const authMiddleware = require('../middleware/authMiddleware');

// كل مسارات الطلبات محمية — لازم Token صالح
router.use(authMiddleware);

router.post('/checkout', orderController.checkout);
router.get('/my-orders', orderController.getMyOrders);
router.get('/store-orders', orderController.getStoreOrders);
router.put('/:id/status', orderController.updateStatus);

module.exports = router;