const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const { login, getProfile } = require('../controllers/adminController');

// Public routes
router.post('/login', login);

// Protected routes
router.get('/profile', authMiddleware, getProfile);

module.exports = router;
