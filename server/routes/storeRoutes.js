const express = require('express');
const router = express.Router();

const storeController = require('../controllers/storeController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/me', storeController.getMyStore);
router.put('/me', storeController.updateMyStore);

module.exports = router;