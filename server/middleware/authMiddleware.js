const jwt = require('jsonwebtoken');

/**
 * Verifies the JWT token from the Authorization header
 * and attaches the decoded payload to req.user
 * Expected header format: "Authorization: Bearer <token>"
 */
const authMiddleware = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        code: 'NO_TOKEN',
        message: 'Authorization token is required'
      });
    }

    const token = authHeader.split(' ')[1];

    const secret = process.env.JWT_SECRET;

    if (!secret) {
      console.error('[authMiddleware] JWT_SECRET is missing in .env');
      return res.status(500).json({
        code: 'SERVER_MISCONFIGURED',
        message: 'Server authentication is misconfigured'
      });
    }

    const decoded = jwt.verify(token, secret);

    // decoded = { id, role, iat, exp } (من generateToken في authService.js)
    req.user = {
      id: decoded.id,
      role: decoded.role
    };

    next();

  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        code: 'TOKEN_EXPIRED',
        message: 'Session expired, please login again'
      });
    }

    return res.status(401).json({
      code: 'INVALID_TOKEN',
      message: 'Invalid authentication token'
    });
  }
};

module.exports = authMiddleware;