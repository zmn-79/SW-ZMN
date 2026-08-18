const express = require('express');

const router = express.Router();

const productController =
  require('../controllers/productController');
  const authMiddleware = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');

router.post(
  '/create',
  productController.createProduct
);
console.log("🔥 productRoutes loaded");

router.get(
  '/',
  productController.getAllProducts
);

router.get(
  '/store/:id',
  productController.getProductsByStore
);
router.get(
  '/:id',
  productController.getProductById
);
router.put(
  '/:id',
  productController.updateProduct
);
router.delete(
  '/:id',
  productController.deleteProduct
);
router.post(
  '/:id/image',
  authMiddleware,
  upload.single('image'),
  productController.uploadProductImage
);
module.exports = router;