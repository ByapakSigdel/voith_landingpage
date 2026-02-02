const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const upload = require('../middleware/upload');
const { uploadImage, getAllImages, deleteImage } = require('../controllers/imageController');

// Protected admin routes
router.post('/upload', authMiddleware, upload.single('image'), uploadImage);
router.get('/all', authMiddleware, getAllImages);
router.delete('/:id', authMiddleware, deleteImage);

module.exports = router;
