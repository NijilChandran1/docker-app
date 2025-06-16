-- Initialize the database with sample schema and data
-- This script will be executed when the PostgreSQL container starts for the first time

-- Create the database if it doesn't exist (handled by POSTGRES_DB environment variable)

-- Connect to the application database
\c appdb;

-- Create the data_items table if it doesn't exist
CREATE TABLE IF NOT EXISTS data_items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_data_items_name ON data_items(name);
CREATE INDEX IF NOT EXISTS idx_data_items_created_at ON data_items(created_at);

-- Insert sample data if the table is empty
INSERT INTO data_items (name, description) 
SELECT * FROM (VALUES 
    ('Database Item 1', 'This item was created directly in PostgreSQL initialization'),
    ('Database Item 2', 'This demonstrates database initialization scripts'),
    ('PostgreSQL Demo', 'This shows PostgreSQL working with Docker Compose'),
    ('Initial Data', 'This data is loaded when the database container starts'),
    ('Docker Integration', 'This demonstrates the complete Docker setup')
) AS sample_data(name, description)
WHERE NOT EXISTS (SELECT 1 FROM data_items);

-- Grant necessary permissions (if using a different user)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;

-- Display confirmation
SELECT 'Database initialization completed successfully' AS status;

