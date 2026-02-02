const { Client } = require('pg');

const config = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT ? parseInt(process.env.DB_PORT, 10) : 5432,
  database: process.env.DB_NAME || 'voith_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
};

const maxRetries = 30;
const retryInterval = 2000; // ms

async function waitForDb() {
  let attempt = 0;
  while (attempt < maxRetries) {
    try {
      const client = new Client(config);
      await client.connect();
      await client.end();
      console.log('Database is available');
      return;
    } catch (err) {
      attempt++;
      console.log(`Waiting for database... (${attempt}/${maxRetries})`);
      await new Promise((r) => setTimeout(r, retryInterval));
    }
  }
  console.error('Timed out waiting for the database');
  process.exit(1);
}

waitForDb();
