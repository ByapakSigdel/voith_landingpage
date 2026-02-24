const db = require('../config/database');
const config = require('../config');
const ImageKit = require('@imagekit/nodejs').default;

// Initialize ImageKit
const imagekit = new ImageKit({
  privateKey: config.imagekit.privateKey,
});

// Upload image to ImageKit
const uploadImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ 
        success: false, 
        message: 'No file uploaded' 
      });
    }

    const { originalname, mimetype, size, buffer } = req.file;

    // Upload to ImageKit
    const ikResponse = await imagekit.files.upload({
      file: buffer.toString('base64'),
      fileName: originalname,
      folder: '/voith',
    });

    const filename = ikResponse.name || originalname;
    const url = ikResponse.url;
    const fileId = ikResponse.fileId;
    const filePath = ikResponse.filePath || '';

    const result = await db.query(
      `INSERT INTO images (filename, original_name, mime_type, size, path, url, uploaded_by) 
       VALUES ($1, $2, $3, $4, $5, $6, $7) 
       RETURNING *`,
      [filename, originalname, mimetype, size, filePath, url, req.admin.id]
    );

    res.status(201).json({
      success: true,
      message: 'Image uploaded successfully',
      data: { ...result.rows[0], imagekit_file_id: fileId }
    });
  } catch (error) {
    console.error('Upload image error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to upload image' 
    });
  }
};

// Get all images (admin)
const getAllImages = async (req, res) => {
  try {
    const result = await db.query(
      `SELECT i.*, a.email as uploaded_by_email 
       FROM images i 
       LEFT JOIN admins a ON i.uploaded_by = a.id 
       ORDER BY i.created_at DESC`
    );

    res.json({
      success: true,
      data: result.rows
    });
  } catch (error) {
    console.error('Get all images error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to fetch images' 
    });
  }
};

// Delete image (admin)
const deleteImage = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query('SELECT * FROM images WHERE id = $1', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ 
        success: false, 
        message: 'Image not found' 
      });
    }

    // Delete from database
    await db.query('DELETE FROM images WHERE id = $1', [id]);

    res.json({
      success: true,
      message: 'Image deleted successfully'
    });
  } catch (error) {
    console.error('Delete image error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to delete image' 
    });
  }
};

module.exports = {
  uploadImage,
  getAllImages,
  deleteImage
};
