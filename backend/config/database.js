const mysql = require('mysql2/promise');
require('dotenv').config();

// Database configuration
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'ikiraha_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  acquireTimeout: 60000,
  timeout: 60000,
  reconnect: true,
  charset: 'utf8mb4'
};

// Create connection pool
const pool = mysql.createPool(dbConfig);

// Test database connection
const testConnection = async () => {
  try {
    const connection = await pool.getConnection();
    console.log('✅ Database connected successfully');
    connection.release();
    return true;
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
    return false;
  }
};

// Initialize database and tables
const initializeDatabase = async () => {
  try {
    // Create database if it doesn't exist
    const tempConnection = await mysql.createConnection({
      host: dbConfig.host,
      port: dbConfig.port,
      user: dbConfig.user,
      password: dbConfig.password,
      charset: 'utf8mb4'
    });

    await tempConnection.execute(`CREATE DATABASE IF NOT EXISTS \`${dbConfig.database}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`);
    await tempConnection.end();

    // Test connection to the database
    await testConnection();

    // Create tables
    await createTables();
    
    console.log('✅ Database initialization completed');
  } catch (error) {
    console.error('❌ Database initialization failed:', error.message);
    throw error;
  }
};

// Create database tables
const createTables = async () => {
  try {
    // Users table
    await pool.execute(`
      CREATE TABLE IF NOT EXISTS users (
        id INT PRIMARY KEY AUTO_INCREMENT,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        first_name VARCHAR(100) NOT NULL,
        last_name VARCHAR(100) NOT NULL,
        phone_number VARCHAR(20),
        profile_image_url TEXT,
        is_email_verified BOOLEAN DEFAULT FALSE,
        email_verification_token VARCHAR(255),
        password_reset_token VARCHAR(255),
        password_reset_expires DATETIME,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        last_login_at TIMESTAMP NULL,
        INDEX idx_email (email),
        INDEX idx_verification_token (email_verification_token),
        INDEX idx_reset_token (password_reset_token)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // Refresh tokens table
    await pool.execute(`
      CREATE TABLE IF NOT EXISTS refresh_tokens (
        id INT PRIMARY KEY AUTO_INCREMENT,
        user_id INT NOT NULL,
        token VARCHAR(255) NOT NULL,
        expires_at DATETIME NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_token (token),
        INDEX idx_user_id (user_id),
        INDEX idx_expires_at (expires_at)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // Restaurants table
    await pool.execute(`
      CREATE TABLE IF NOT EXISTS restaurants (
        id INT PRIMARY KEY AUTO_INCREMENT,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        image_url TEXT,
        logo_url TEXT,
        address TEXT NOT NULL,
        latitude DECIMAL(10, 8),
        longitude DECIMAL(11, 8),
        phone_number VARCHAR(20),
        email VARCHAR(255),
        rating DECIMAL(3, 2) DEFAULT 0.00,
        review_count INT DEFAULT 0,
        delivery_time INT DEFAULT 30,
        delivery_fee DECIMAL(8, 2) DEFAULT 0.00,
        minimum_order DECIMAL(8, 2) DEFAULT 0.00,
        is_open BOOLEAN DEFAULT TRUE,
        opening_hours TIME DEFAULT '09:00:00',
        closing_hours TIME DEFAULT '22:00:00',
        is_popular BOOLEAN DEFAULT FALSE,
        is_featured BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_location (latitude, longitude),
        INDEX idx_rating (rating),
        INDEX idx_popular (is_popular),
        INDEX idx_featured (is_featured)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // Restaurant categories table
    await pool.execute(`
      CREATE TABLE IF NOT EXISTS restaurant_categories (
        id INT PRIMARY KEY AUTO_INCREMENT,
        restaurant_id INT NOT NULL,
        category VARCHAR(100) NOT NULL,
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
        INDEX idx_restaurant_category (restaurant_id, category)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // Food items table
    await pool.execute(`
      CREATE TABLE IF NOT EXISTS food_items (
        id INT PRIMARY KEY AUTO_INCREMENT,
        restaurant_id INT NOT NULL,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        price DECIMAL(8, 2) NOT NULL,
        discount_price DECIMAL(8, 2),
        image_url TEXT,
        category VARCHAR(100) NOT NULL,
        rating DECIMAL(3, 2) DEFAULT 0.00,
        review_count INT DEFAULT 0,
        is_vegetarian BOOLEAN DEFAULT FALSE,
        is_vegan BOOLEAN DEFAULT FALSE,
        is_spicy BOOLEAN DEFAULT FALSE,
        preparation_time INT DEFAULT 30,
        is_available BOOLEAN DEFAULT TRUE,
        allergens TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
        INDEX idx_restaurant_category (restaurant_id, category),
        INDEX idx_price (price),
        INDEX idx_rating (rating),
        INDEX idx_available (is_available)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // Food item ingredients table
    await pool.execute(`
      CREATE TABLE IF NOT EXISTS food_item_ingredients (
        id INT PRIMARY KEY AUTO_INCREMENT,
        food_item_id INT NOT NULL,
        ingredient VARCHAR(100) NOT NULL,
        FOREIGN KEY (food_item_id) REFERENCES food_items(id) ON DELETE CASCADE,
        INDEX idx_food_item (food_item_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    console.log('✅ Database tables created successfully');
  } catch (error) {
    console.error('❌ Error creating tables:', error.message);
    throw error;
  }
};

// Execute query with error handling
const executeQuery = async (query, params = []) => {
  try {
    const [results] = await pool.execute(query, params);
    return results;
  } catch (error) {
    console.error('Database query error:', error.message);
    throw error;
  }
};

// Get a single connection from pool
const getConnection = async () => {
  try {
    return await pool.getConnection();
  } catch (error) {
    console.error('Error getting database connection:', error.message);
    throw error;
  }
};

module.exports = {
  pool,
  testConnection,
  initializeDatabase,
  executeQuery,
  getConnection
};
