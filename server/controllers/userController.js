// ===============================
// User Controller
// Handles Store profile retrieval only.
// Registration and Login now live in authController.js
// ===============================

const Store = require('../models/Store');
const User = require('../models/User');
/**
 * Get My Profile — بيانات المستخدم الحالي (من التوكن، مش من الـ URL)
 */
const getMyProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-passwordHash');

    if (!user) {
      return res.status(404).json({
        code: 'USER_NOT_FOUND',
        message: 'User not found'
      });
    }

    return res.status(200).json(user);

  } catch (error) {
    return res.status(500).json({
      code: 'INTERNAL_ERROR',
      message: error.message
    });
  }
};

/**
 * Update My Profile — تعديل fullName و phone فقط (البيانات الحساسة زي email/role غير قابلة للتعديل هنا)
 */
const updateMyProfile = async (req, res) => {
  try {
    const { fullName, phone } = req.body;

    const updates = {};
    if (fullName !== undefined) updates.fullName = fullName;
    if (phone !== undefined) updates.phone = phone;

    const user = await User.findByIdAndUpdate(
      req.user.id,
      updates,
      { new: true, runValidators: true }
    ).select('-passwordHash');

    if (!user) {
      return res.status(404).json({
        code: 'USER_NOT_FOUND',
        message: 'User not found'
      });
    }

    return res.status(200).json({
      message: 'Profile updated successfully',
      data: user
    });

  } catch (error) {
    return res.status(500).json({
      code: 'INTERNAL_ERROR',
      message: error.message
    });
  }
};

/**
 * Get Store By ID
 */
const getStoreById = async (req, res) => {
  try {
    const store = await Store.findById(req.params.id)
      .populate('ownerId', 'fullName email phone');

    if (!store) {
      return res.status(404).json({
        message: 'Store not found'
      });
    }

    return res.status(200).json(store);

  } catch (error) {
    return res.status(500).json({
      message: error.message
    });
  }
};

module.exports = {
  getStoreById,
  getMyProfile,
  updateMyProfile
};