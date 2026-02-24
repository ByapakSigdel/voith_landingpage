const db = require('../config/database');

// Get all images (public)
const getImages = async (req, res) => {
  try {
    const result = await db.query(
      'SELECT id, filename, original_name, mime_type, size, url, created_at FROM images ORDER BY created_at DESC'
    );

    res.json({
      success: true,
      data: result.rows
    });
  } catch (error) {
    console.error('Get images error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to fetch images' 
    });
  }
};

// Get single image by ID (public)
const getImageById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      'SELECT id, filename, original_name, mime_type, size, url, created_at FROM images WHERE id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        success: false, 
        message: 'Image not found' 
      });
    }

    res.json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Get image error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to fetch image' 
    });
  }
};

// Get image file (public) — redirects to ImageKit URL
const getImageFile = async (req, res) => {
  try {
    const { filename } = req.params;

    const result = await db.query('SELECT * FROM images WHERE filename = $1', [filename]);

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        success: false, 
        message: 'Image not found' 
      });
    }

    const image = result.rows[0];
    // Redirect to the ImageKit CDN URL
    res.redirect(image.url);
  } catch (error) {
    console.error('Get image file error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to fetch image file' 
    });
  }
};

module.exports = {
  getImages,
  getImageById,
  getImageFile
};
