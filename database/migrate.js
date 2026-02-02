const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const config = require('../src/config');
const fs = require('fs');
const path = require('path');

const pool = new Pool(config.db);

async function runMigration() {
  const client = await pool.connect();
  
  try {
    console.log('Starting database migration...');
    
    // Read and execute schema
    const schemaSQL = fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf8');
    await client.query(schemaSQL);
    console.log('Schema created successfully');
    
    // Check if admin exists
    const adminCheck = await client.query('SELECT * FROM admins WHERE email = $1', [config.admin.email]);
    
    if (adminCheck.rows.length === 0) {
      // Create default admin
      const hashedPassword = await bcrypt.hash(config.admin.password, 10);
      await client.query(
        'INSERT INTO admins (email, password) VALUES ($1, $2)',
        [config.admin.email, hashedPassword]
      );
      console.log(`Admin user created: ${config.admin.email}`);
    } else {
      console.log('Admin user already exists');
    }
    
    console.log('Migration completed successfully!');
  } catch (error) {
    console.error('Migration failed:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

runMigration();
