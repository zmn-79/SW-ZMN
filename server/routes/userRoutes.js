const express = require('express');
const router = express.Router();

const productController = require('../controllers/productController');
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/', (req, res) => {
  res.json({ ok: true });
});

router.get('/me', authMiddleware, userController.getMyProfile);
router.put('/me', authMiddleware, userController.updateMyProfile);

router.get('/:id/products', productController.getProductsByStore);
router.get('/:id', userController.getStoreById);

module.exports = router;