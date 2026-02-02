const express = require('express');
const router = express.Router();
const { getImages, getImageById, getImageFile } = require('../controllers/publicController');

// Public routes - no authentication required
router.get('/images', getImages);
router.get('/images/:id', getImageById);
router.get('/images/file/:filename', getImageFile);

module.exports = router;
