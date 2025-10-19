-- Database initialization script
-- This script will be executed when the PostgreSQL container starts for the first time

-- Create database if it doesn't exist (this is handled by POSTGRES_DB environment variable)
-- But we can add additional setup here if needed

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- The tables will be created by the application on startup
-- This file is here for any additional database setup that might be needed
