const User = require('../models/User');
const Store = require('../models/Store');
const {
  hashPassword,
  comparePassword,
  generateToken
} = require('../services/authService');

const VALID_ROLES = ['customer', 'store_owner'];

const register = async (req, res) => {
  try {
    const data = req.body;
    const role = data.role;

    // ===== 1. Validation (منفصلة عن منطق الإنشاء) =====
    if (!data.email || !data.password || !data.fullName) {
      return res.status(400).json({
        code: 'MISSING_REQUIRED_FIELDS',
        message: 'fullName, email and password are required'
      });
    }

    if (!role || !VALID_ROLES.includes(role)) {
      return res.status(400).json({
        code: 'INVALID_ROLE',
        message: `role must be one of: ${VALID_ROLES.join(', ')}`
      });
    }

    if (role === 'store_owner' && (!data.storeName || !data.storeType)) {
      return res.status(400).json({
        code: 'MISSING_STORE_FIELDS',
        message: 'storeName and storeType are required for store_owner registration'
      });
    }

    // ===== 2. إنشاء المستخدم (مشترك لكل الأدوار) =====
    const hashedPassword = await hashPassword(data.password);

    const user = await User.create({
      fullName: data.fullName,
      email: data.email,
      phone: data.phone,
      passwordHash: hashedPassword,
      role
    });

    // ===== 3. إنشاء الكيانات الإضافية الخاصة بكل دور =====
    let storeId = null;

    if (role === 'store_owner') {
      const store = await Store.create({
        ownerId: user._id,
        storeName: data.storeName,
        storeType: data.storeType,
        storeAddress: data.storeAddress,
        paymentMethods: data.paymentMethods,
        description: data.description,
        taxNumber: data.taxNumber,
        commercialNumber: data.commercialNumber
      });
      storeId = store._id;
    }

    return res.status(201).json({
      message: 'Registration successful',
      userId: user._id,
      storeId
    });

  } catch (err) {
    if (err.code === 11000) {
      return res.status(409).json({
        code: 'EMAIL_ALREADY_EXISTS',
        message: 'An account with this email already exists'
      });
    }

    console.error('[authController.register] Unexpected error:', err);

    return res.status(500).json({
      code: 'INTERNAL_ERROR',
      message: err.message
    });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        message: 'email and password are required'
      });
    }

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(401).json({
        message: 'Invalid email or password'
      });
    }

    const isMatch = await comparePassword(password, user.passwordHash);

    if (!isMatch) {
      return res.status(401).json({
        message: 'Invalid email or password'
      });
    }

    const token = generateToken({ id: user._id, role: user.role });

    let storeId = null;

    if (user.role === 'store_owner') {
      const store = await Store.findOne({ ownerId: user._id });
      storeId = store ? store._id : null;
    }

    return res.status(200).json({
      message: 'Login successful',
      token,
      userId: user._id,
      role: user.role,
      storeId
    });

  } catch (error) {
    return res.status(500).json({
      message: error.message
    });
  }
};

module.exports = {
  register,
  login
};