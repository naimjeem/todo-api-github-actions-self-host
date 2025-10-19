const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'todoapp',
  user: process.env.DB_USER || 'todo_user',
  password: process.env.DB_PASSWORD || 'todo_password',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Test database connection
const connect = async () => {
  try {
    const client = await pool.connect();
    console.log('Connected to PostgreSQL database');
    client.release();
    
    // Initialize database tables
    await initializeTables();
  } catch (error) {
    console.error('Database connection error:', error);
    throw error;
  }
};

// Initialize database tables
const initializeTables = async () => {
  try {
    // Create users table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create todos table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS todos (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        completed BOOLEAN DEFAULT FALSE,
        priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
        due_date TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create indexes for better performance
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_todos_user_id ON todos(user_id);
      CREATE INDEX IF NOT EXISTS idx_todos_completed ON todos(completed);
      CREATE INDEX IF NOT EXISTS idx_todos_priority ON todos(priority);
    `);

    console.log('Database tables initialized successfully');
  } catch (error) {
    console.error('Error initializing database tables:', error);
    throw error;
  }
};

// Disconnect from database
const disconnect = async () => {
  try {
    await pool.end();
    console.log('Database connection closed');
  } catch (error) {
    console.error('Error closing database connection:', error);
    throw error;
  }
};

module.exports = {
  pool,
  connect,
  disconnect,
  query: (text, params) => pool.query(text, params)
};
