const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const SALT_ROUNDS = 10;

/**
 * تشفير كلمة السر قبل حفظها في قاعدة البيانات
 * @param {string} plainPassword
 * @returns {Promise<string>} كلمة السر المشفرة
 */
const hashPassword = async (plainPassword) => {
  return bcrypt.hash(plainPassword, SALT_ROUNDS);
};

/**
 * مقارنة كلمة السر المدخلة وقت تسجيل الدخول بالنسخة المشفرة المخزنة
 * @param {string} plainPassword
 * @param {string} hashedPassword
 * @returns {Promise<boolean>}
 */
const comparePassword = async (plainPassword, hashedPassword) => {
  return bcrypt.compare(plainPassword, hashedPassword);
};

/**
 * توليد JWT Token بعد نجاح تسجيل الدخول
 * @param {{ id: string, role: string }} payload
 * @returns {string} token
 */
const generateToken = (payload) => {
  const secret = process.env.JWT_SECRET;

  if (!secret) {
    throw new Error('JWT_SECRET is missing in .env');
  }

  return jwt.sign(payload, secret, { expiresIn: '7d' });
};

module.exports = {
  hashPassword,
  comparePassword,
  generateToken
};