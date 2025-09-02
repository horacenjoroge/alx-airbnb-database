-- AirBnB Database Advanced Scripts - Index Creation for Optimization
-- File: database_index.sql

USE airbnb_db;

-- ================================================================
-- ANALYSIS OF HIGH-USAGE COLUMNS
-- ================================================================

-- Before creating indexes, let's analyze current table structures
-- and identify columns frequently used in WHERE, JOIN, and ORDER BY clauses

-- Current indexes (these are already created in the schema)
SHOW INDEX FROM User;
SHOW INDEX FROM Property;
SHOW INDEX FROM Booking;
SHOW INDEX FROM Payment;
SHOW INDEX FROM Review;
SHOW INDEX FROM Message;

-- ================================================================
-- ADDITIONAL STRATEGIC INDEXES FOR OPTIMIZATION
-- ================================================================

-- 1. USER TABLE INDEXES
-- Email is already unique indexed, but let's add composite indexes

-- Index for user role queries (frequently filtered by role)
CREATE INDEX idx_user_role_created ON User(role, created_at);

-- Index for user search by name (for admin/search functionality)
CREATE INDEX idx_user_name_search ON User(last_name, first_name);

-- Composite index for phone number lookups
CREATE INDEX idx_user_phone ON User(phone_number) 
WHERE phone_number IS NOT NULL;

-- ================================================================
-- 2. PROPERTY TABLE INDEXES
-- ================================================================

-- Composite index for property search queries (location + price filtering)
CREATE INDEX idx_property_location_price ON Property(location, price_per_night);

-- Index for property search with date availability (frequently used)
CREATE INDEX idx_property_host_status ON Property(host_id, created_at);

-- Full-text search index for property name and description
CREATE FULLTEXT INDEX idx_property_search ON Property(name, description);

-- Index for price range queries
CREATE INDEX idx_property_price_range ON Property(price_per_night, created_at);

-- ================================================================
-- 3. BOOKING TABLE INDEXES (MOST CRITICAL FOR PERFORMANCE)
-- ================================================================

-- Composite index for date range availability queries (most common query)
CREATE INDEX idx_booking_property_dates_status ON Booking(property_id, start_date, end_date, status);

-- Index for user booking history queries
CREATE INDEX idx_booking_user_status_created ON Booking(user_id, status, created_at);

-- Index for booking status and date filtering
CREATE INDEX idx_booking_status_dates ON Booking(status, start_date, end_date);

-- Index for revenue calculations and reporting
CREATE INDEX idx_booking_created_status_price ON Booking(created_at, status, total_price);

-- Index for property occupancy analysis
CREATE INDEX idx_booking_property_status_dates ON Booking(property_id, status, start_date, end_date);

-- Index for monthly/yearly booking reports
CREATE INDEX idx_booking_date_status ON Booking(DATE(created_at), status);

-- ================================================================
-- 4. PAYMENT TABLE INDEXES
-- ================================================================

-- Index for payment method analysis
CREATE INDEX idx_payment_method_date ON Payment(payment_method, payment_date);

-- Index for payment amount queries and reporting
CREATE INDEX idx_payment_amount_date ON Payment(amount, payment_date);

-- Index for booking payment lookup (booking_id already indexed)
CREATE INDEX idx_payment_date_method ON Payment(payment_date, payment_method);

-- ================================================================
-- 5. REVIEW TABLE INDEXES
-- ================================================================

-- Composite index for property review queries (property reviews with ratings)
CREATE INDEX idx_review_property_rating_date ON Review(property_id, rating, created_at);

-- Index for user review history
CREATE INDEX idx_review_user_created ON Review(user_id, created_at);

-- Index for rating analysis and filtering
CREATE INDEX idx_review_rating_date ON Review(rating, created_at);

-- Index for recent reviews queries
CREATE INDEX idx_review_created_rating ON Review(created_at, rating);

-- ================================================================
-- 6. MESSAGE TABLE INDEXES
-- ================================================================

-- Composite index for conversation threads
CREATE INDEX idx_message_conversation ON Message(sender_id, recipient_id, sent_at);

-- Index for inbox queries (messages received by a user)
CREATE INDEX idx_message_recipient_sent ON Message(recipient_id, sent_at);

-- Index for sent messages queries
CREATE INDEX idx_message_sender_sent ON Message(sender_id, sent_at);

-- Index for message search by date range
CREATE INDEX idx_message_sent_date ON Message(DATE(sent_at));

-- ================================================================
-- COVERING INDEXES FOR SPECIFIC QUERY PATTERNS
-- ================================================================

-- Covering index for property listing queries (includes all needed columns)
CREATE INDEX idx_property_listing_cover ON Property(location, price_per_night, created_at)
INCLUDE (property_id, name, description);

-- Covering index for booking confirmation queries
CREATE INDEX idx_booking_confirmation_cover ON Booking(user_id, status, created_at)
INCLUDE (booking_id, property_id, start_date, end_date, total_price);

-- Covering index for property review summaries
CREATE INDEX idx_review_summary_cover ON Review(property_id)
INCLUDE (rating, created_at, comment);

-- ================================================================
-- PARTIAL INDEXES FOR SPECIFIC CONDITIONS
-- ================================================================

-- Index only for confirmed bookings (most queried status)
CREATE INDEX idx_booking_confirmed_dates ON Booking(property_id, start_date, end_date)
WHERE status = 'confirmed';

-- Index only for active properties (properties with bookings)
CREATE INDEX idx_property_active ON Property(location, price_per_night, created_at)
WHERE property_id IN (SELECT DISTINCT property_id FROM Booking);

-- Index for high-rated properties
CREATE INDEX idx_property_high_rated ON Property(location, price_per_night)
WHERE property_id IN (
    SELECT property_id 
    FROM Review 
    GROUP BY property_id 
    HAVING AVG(rating) >= 4.0
);

-- ================================================================
-- FUNCTION-BASED INDEXES FOR COMMON CALCULATIONS
-- ================================================================

-- Index for year-based queries on booking dates
CREATE INDEX idx_booking_year ON Booking(YEAR(created_at), MONTH(created_at), status);

-- Index for day of week analysis
CREATE INDEX idx_booking_dayofweek ON Booking(DAYOFWEEK(start_date), status);

-- Index for price per night ranges
CREATE INDEX idx_property_price_ranges ON Property(
    CASE 
        WHEN price_per_night < 100 THEN 'Budget'
        WHEN price_per_night BETWEEN 100 AND 200 THEN 'Mid-range'
        WHEN price_per_night > 200 THEN 'Luxury'
    END,
    location
);

-- ================================================================
-- MAINTENANCE QUERIES FOR INDEX MONITORING
-- ================================================================

-- Query to check index usage statistics
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    INDEX_NAME,
    INDEX_TYPE,
    IS_VISIBLE,
    COLUMN_NAME,
    SEQ_IN_INDEX,
    CARDINALITY
FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = 'airbnb_db'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- Query to analyze table sizes and row counts
SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    DATA_LENGTH,
    INDEX_LENGTH,
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) as 'Total Size (MB)',
    ROUND((INDEX_LENGTH / DATA_LENGTH) * 100, 2) as 'Index Ratio %'
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'airbnb_db'
ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC;

-- ================================================================
-- INDEX MAINTENANCE COMMANDS
-- ================================================================

-- Analyze tables to update index statistics
ANALYZE TABLE User, Property, Booking, Payment, Review, Message;

-- Check table optimization status
CHECK TABLE User, Property, Booking, Payment, Review, Message;

-- Optimize tables (rebuilds indexes)
-- Note: Use with caution in production, should be run during maintenance windows
-- OPTIMIZE TABLE User, Property, Booking, Payment, Review, Message;

-- ================================================================
-- PERFORMANCE TESTING QUERIES (Before/After Index Creation)
-- ================================================================

-- Test Query 1: Property search by location and price range
EXPLAIN FORMAT=JSON
SELECT p.property_id, p.name, p.location, p.price_per_night
FROM Property p
WHERE p.location = 'New York, NY, USA' 
AND p.price_per_night BETWEEN 100 AND 300;

-- Test Query 2: Available properties for date range
EXPLAIN FORMAT=JSON
SELECT p.property_id, p.name, p.location, p.price_per_night
FROM Property p
WHERE NOT EXISTS (
    SELECT 1 FROM Booking b 
    WHERE b.property_id = p.property_id 
    AND b.status IN ('confirmed', 'pending')
    AND (
        ('2024-07-01' BETWEEN b.start_date AND b.end_date) OR
        ('2024-07-07' BETWEEN b.start_date AND b.end_date) OR
        (b.start_date BETWEEN '2024-07-01' AND '2024-07-07')
    )
);

-- Test Query 3: User booking history
EXPLAIN FORMAT=JSON
SELECT u.first_name, u.last_name, b.booking_id, b.start_date, b.end_date, b.status
FROM User u
JOIN Booking b ON u.user_id = b.user_id
WHERE u.user_id = '550e8400-e29b-41d4-a716-446655440005'
ORDER BY b.created_at DESC;

-- Test Query 4: Property reviews with ratings
EXPLAIN FORMAT=JSON
SELECT p.name, r.rating, r.comment, r.created_at,
       CONCAT(u.first_name, ' ', u.last_name) as reviewer_name
FROM Property p
JOIN Review r ON p.property_id = r.property_id
JOIN User u ON r.user_id = u.user_id
WHERE p.property_id = '650e8400-e29b-41d4-a716-446655440001'
ORDER BY r.created_at DESC;

-- Test Query 5: Monthly booking revenue report
EXPLAIN FORMAT=JSON
SELECT 
    YEAR(b.created_at) as year,
    MONTH(b.created_at) as month,
    COUNT(*) as total_bookings,
    SUM(b.total_price) as total_revenue
FROM Booking b
WHERE b.status = 'confirmed' 
AND b.created_at >= '2024-01-01'
GROUP BY YEAR(b.created_at), MONTH(b.created_at)
ORDER BY year, month;