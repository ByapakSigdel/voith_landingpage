const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const config = require('../src/config');

const pool = new Pool(config.db);

async function seed() {
  const client = await pool.connect();

  try {
    console.log('Starting database seeding...');

    // ------- Seed admins -------
    const admins = [
      { email: config.admin.email, password: config.admin.password },
      { email: 'editor@voith.com', password: 'Editor@123' },
    ];

    for (const admin of admins) {
      const exists = await client.query('SELECT id FROM admins WHERE email = $1', [admin.email]);
      if (exists.rows.length === 0) {
        const hashed = await bcrypt.hash(admin.password, 10);
        await client.query(
          'INSERT INTO admins (email, password) VALUES ($1, $2)',
          [admin.email, hashed]
        );
        console.log(`  Admin created: ${admin.email}`);
      } else {
        console.log(`  Admin already exists: ${admin.email}`);
      }
    }

    // ------- Seed images -------
    // Fetch the primary admin id to use as uploaded_by
    const adminRow = await client.query('SELECT id FROM admins WHERE email = $1', [config.admin.email]);
    const adminId = adminRow.rows[0].id;

    const images = [
      {
        filename: 'hero-banner.jpg',
        original_name: 'hero-banner.jpg',
        mime_type: 'image/jpeg',
        size: 204800,
        path: '/uploads/hero-banner.jpg',
        url: '/uploads/hero-banner.jpg',
      },
      {
        filename: 'about-voith.png',
        original_name: 'about-voith.png',
        mime_type: 'image/png',
        size: 153600,
        path: '/uploads/about-voith.png',
        url: '/uploads/about-voith.png',
      },
      {
        filename: 'services-overview.jpg',
        original_name: 'services-overview.jpg',
        mime_type: 'image/jpeg',
        size: 184320,
        path: '/uploads/services-overview.jpg',
        url: '/uploads/services-overview.jpg',
      },
      {
        filename: 'team-photo.jpg',
        original_name: 'team-photo.jpg',
        mime_type: 'image/jpeg',
        size: 256000,
        path: '/uploads/team-photo.jpg',
        url: '/uploads/team-photo.jpg',
      },
      {
        filename: 'contact-map.png',
        original_name: 'contact-map.png',
        mime_type: 'image/png',
        size: 102400,
        path: '/uploads/contact-map.png',
        url: '/uploads/contact-map.png',
      },
    ];

    for (const img of images) {
      const exists = await client.query('SELECT id FROM images WHERE filename = $1', [img.filename]);
      if (exists.rows.length === 0) {
        await client.query(
          `INSERT INTO images (filename, original_name, mime_type, size, path, url, uploaded_by)
           VALUES ($1, $2, $3, $4, $5, $6, $7)`,
          [img.filename, img.original_name, img.mime_type, img.size, img.path, img.url, adminId]
        );
        console.log(`  Image seeded: ${img.filename}`);
      } else {
        console.log(`  Image already exists: ${img.filename}`);
      }
    }

    console.log('Seeding completed successfully!');
  } catch (error) {
    console.error('Seeding failed:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

seed();
