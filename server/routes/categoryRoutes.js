const express =
  require('express');

const router =
  express.Router();

const categoryController =
  require('../controllers/categoryController');

/*
 * Create Category
 */
router.post(
  '/create',
  categoryController.createCategory
);

router.get(
  '/store/:storeId',
  categoryController.getCategoriesByStore
);

module.exports = router;