const Store = require('../models/Store');

/**
 * Get My Store — بيانات متجر صاحب الحساب الحالي (من التوكن)
 */
const getMyStore = async (req, res) => {
  try {
    const store = await Store.findOne({ ownerId: req.user.id });

    if (!store) {
      return res.status(404).json({
        code: 'STORE_NOT_FOUND',
        message: 'No store found for this account'
      });
    }

    return res.status(200).json(store);

  } catch (error) {
    return res.status(500).json({
      code: 'INTERNAL_ERROR',
      message: error.message
    });
  }
};

/**
 * Update My Store — تعديل بيانات المتجر الخاصة بصاحب الحساب الحالي فقط
 */
const updateMyStore = async (req, res) => {
  try {
    const allowedFields = [
      'storeName',
      'storeType',
      'storeAddress',
      'paymentMethods',
      'description',
      'taxNumber',
      'commercialNumber'
    ];

    const updates = {};
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    }

    const store = await Store.findOneAndUpdate(
      { ownerId: req.user.id },
      updates,
      { new: true, runValidators: true }
    );

    if (!store) {
      return res.status(404).json({
        code: 'STORE_NOT_FOUND',
        message: 'No store found for this account'
      });
    }

    return res.status(200).json({
      message: 'Store updated successfully',
      data: store
    });

  } catch (error) {
    return res.status(500).json({
      code: 'INTERNAL_ERROR',
      message: error.message
    });
  }
};

module.exports = {
  getMyStore,
  updateMyStore
};