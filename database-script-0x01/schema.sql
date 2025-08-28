-- AirBnB Database Schema DDL
-- Create database and use it
CREATE DATABASE IF NOT EXISTS airbnb_db;
USE airbnb_db;

-- Create User table
CREATE TABLE User (
    user_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NULL,
    role ENUM('guest', 'host', 'admin') NOT NULL DEFAULT 'guest',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX idx_user_email (email),
    INDEX idx_user_role (role)
);

-- Create Property table
CREATE TABLE Property (
    property_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    host_id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(255) NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL CHECK (price_per_night > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    FOREIGN KEY (host_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Indexes
    INDEX idx_property_host_id (host_id),
    INDEX idx_property_location (location),
    INDEX idx_property_price (price_per_night)
);

-- Create Booking table
CREATE TABLE Booking (
    booking_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price > 0),
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Check constraint to ensure end_date is after start_date
    CONSTRAINT chk_booking_dates CHECK (end_date > start_date),
    
    -- Foreign key constraints
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Indexes
    INDEX idx_booking_property_id (property_id),
    INDEX idx_booking_user_id (user_id),
    INDEX idx_booking_dates (start_date, end_date),
    INDEX idx_booking_status (status)
);

-- Create Payment table
CREATE TABLE Payment (
    payment_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    booking_id CHAR(36) UNIQUE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('credit_card', 'paypal', 'stripe') NOT NULL,
    
    -- Foreign key constraint
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Indexes
    INDEX idx_payment_booking_id (booking_id),
    INDEX idx_payment_method (payment_method),
    INDEX idx_payment_date (payment_date)
);

-- Create Review table
CREATE TABLE Review (
    review_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Unique constraint to prevent multiple reviews from same user for same property
    UNIQUE KEY unique_user_property_review (user_id, property_id),
    
    -- Indexes
    INDEX idx_review_property_id (property_id),
    INDEX idx_review_user_id (user_id),
    INDEX idx_review_rating (rating),
    INDEX idx_review_created_at (created_at)
);

-- Create Message table
CREATE TABLE Message (
    message_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    sender_id CHAR(36) NOT NULL,
    recipient_id CHAR(36) NOT NULL,
    message_body TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Check constraint to prevent self-messaging
    CONSTRAINT chk_message_different_users CHECK (sender_id != recipient_id),
    
    -- Foreign key constraints
    FOREIGN KEY (sender_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (recipient_id) REFERENCES User(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Indexes
    INDEX idx_message_sender_id (sender_id),
    INDEX idx_message_recipient_id (recipient_id),
    INDEX idx_message_sent_at (sent_at),
    INDEX idx_message_conversation (sender_id, recipient_id, sent_at)
);

-- Create additional indexes for performance optimization
-- Composite indexes for common query patterns

-- For finding available properties in date range
ALTER TABLE Booking ADD INDEX idx_booking_property_dates (property_id, start_date, end_date, status);

-- For user's booking history
ALTER TABLE Booking ADD INDEX idx_booking_user_status_date (user_id, status, created_at);

-- For property reviews with ratings
ALTER TABLE Review ADD INDEX idx_review_property_rating_date (property_id, rating, created_at);

-- For host's properties
ALTER TABLE Property ADD INDEX idx_property_host_created (host_id, created_at);

-- For payment tracking
ALTER TABLE Payment ADD INDEX idx_payment_date_method (payment_date, payment_method);

-- Create views for common queries
-- View for property details with host information
CREATE VIEW PropertyWithHost AS
SELECT 
    p.property_id,
    p.name,
    p.description,
    p.location,
    p.price_per_night,
    p.created_at,
    p.updated_at,
    u.user_id as host_id,
    u.first_name as host_first_name,
    u.last_name as host_last_name,
    u.email as host_email
FROM Property p
JOIN User u ON p.host_id = u.user_id
WHERE u.role = 'host';

-- View for booking details with user and property information
CREATE VIEW BookingDetails AS
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at,
    u.first_name as guest_first_name,
    u.last_name as guest_last_name,
    u.email as guest_email,
    p.name as property_name,
    p.location as property_location,
    h.first_name as host_first_name,
    h.last_name as host_last_name
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
JOIN User h ON p.host_id = h.user_id;

-- View for property reviews with reviewer information
CREATE VIEW PropertyReviews AS
SELECT 
    r.review_id,
    r.property_id,
    r.rating,
    r.comment,
    r.created_at,
    u.first_name as reviewer_first_name,
    u.last_name as reviewer_last_name,
    p.name as property_name
FROM Review r
JOIN User u ON r.user_id = u.user_id
JOIN Property p ON r.property_id = p.property_id;

-- Trigger to update property updated_at timestamp when booking is made
DELIMITER //
CREATE TRIGGER update_property_timestamp
AFTER INSERT ON Booking
FOR EACH ROW
BEGIN
    UPDATE Property 
    SET updated_at = CURRENT_TIMESTAMP 
    WHERE property_id = NEW.property_id;
END//
DELIMITER ;

-- Trigger to validate booking dates against existing bookings
DELIMITER //
CREATE TRIGGER validate_booking_overlap
BEFORE INSERT ON Booking
FOR EACH ROW
BEGIN
    DECLARE overlap_count INT;
    
    SELECT COUNT(*) INTO overlap_count
    FROM Booking
    WHERE property_id = NEW.property_id
    AND status IN ('confirmed', 'pending')
    AND (
        (NEW.start_date BETWEEN start_date AND end_date)
        OR (NEW.end_date BETWEEN start_date AND end_date)
        OR (start_date BETWEEN NEW.start_date AND NEW.end_date)
    );
    
    IF overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Booking dates overlap with existing booking';
    END IF;
END//
DELIMITER ;