-- AirBnB Database Advanced Scripts - Query Performance Optimization
-- File: performance.sql

USE airbnb_db;

-- ================================================================
-- INITIAL COMPLEX QUERY (BEFORE OPTIMIZATION)
-- ================================================================

-- Original Query: Retrieve all bookings with user details, property details, and payment details
-- This query demonstrates common performance issues with complex joins

-- BEFORE OPTIMIZATION: Basic query with all joins
SELECT 
    -- Booking details
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status as booking_status,
    b.created_at as booking_created,
    
    -- User (Guest) details
    guest.user_id as guest_id,
    guest.first_name as guest_first_name,
    guest.last_name as guest_last_name,
    guest.email as guest_email,
    guest.phone_number as guest_phone,
    guest.created_at as guest_created,
    
    -- Property details
    p.property_id,
    p.name as property_name,
    p.description as property_description,
    p.location as property_location,
    p.price_per_night,
    p.created_at as property_created,
    
    -- Host details
    host.user_id as host_id,
    host.first_name as host_first_name,
    host.last_name as host_last_name,
    host.email as host_email,
    host.phone_number as host_phone,
    
    -- Payment details
    pay.payment_id,
    pay.amount as payment_amount,
    pay.payment_date,
    pay.payment_method
    
FROM Booking b
    -- Join with User table for guest details
    JOIN User guest ON b.user_id = guest.user_id
    
    -- Join with Property table  
    JOIN Property p ON b.property_id = p.property_id
    
    -- Join with User table again for host details
    JOIN User host ON p.host_id = host.user_id
    
    -- Left join with Payment (not all bookings have payments)
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id

ORDER BY b.created_at DESC, b.booking_id;

-- ================================================================
-- PERFORMANCE ANALYSIS OF ORIGINAL QUERY
-- ================================================================

-- Analyze the execution plan of the original query
EXPLAIN FORMAT=JSON
SELECT 
    b.booking_id, b.start_date, b.end_date, b.total_price, b.status,
    guest.first_name as guest_first_name, guest.last_name as guest_last_name,
    p.name as property_name, p.location as property_location,
    host.first_name as host_first_name, host.last_name as host_last_name,
    pay.amount as payment_amount, pay.payment_method
FROM Booking b
    JOIN User guest ON b.user_id = guest.user_id
    JOIN Property p ON b.property_id = p.property_id
    JOIN User host ON p.host_id = host.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;

-- ================================================================
-- QUERY OPTIMIZATION TECHNIQUES
-- ================================================================

-- OPTIMIZATION 1: Reduce selected columns to only what's needed
-- Remove unnecessary columns to reduce data transfer and processing

SELECT 
    -- Essential booking details only
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    
    -- Minimal user details
    CONCAT(guest.first_name, ' ', guest.last_name) as guest_name,
    guest.email as guest_email,
    
    -- Essential property details
    p.name as property_name,
    p.location as property_location,
    p.price_per_night,
    
    -- Minimal host details
    CONCAT(host.first_name, ' ', host.last_name) as host_name,
    
    -- Payment status
    CASE WHEN pay.payment_id IS NOT NULL THEN 'Paid' ELSE 'Unpaid' END as payment_status,
    pay.payment_method

FROM Booking b
    JOIN User guest ON b.user_id = guest.user_id
    JOIN Property p ON b.property_id = p.property_id
    JOIN User host ON p.host_id = host.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;

-- OPTIMIZATION 2: Use indexes and limit results for pagination
-- Add LIMIT clause and use covering indexes

SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    CONCAT(guest.first_name, ' ', guest.last_name) as guest_name,
    p.name as property_name,
    p.location as property_location,
    CONCAT(host.first_name, ' ', host.last_name) as host_name,
    pay.payment_method

FROM Booking b
    USE INDEX (idx_booking_created_status_price)  -- Force use of optimal index
    JOIN User guest USE INDEX (PRIMARY) ON b.user_id = guest.user_id
    JOIN Property p USE INDEX (PRIMARY) ON b.property_id = p.property_id
    JOIN User host USE INDEX (PRIMARY) ON p.host_id = host.user_id
    LEFT JOIN Payment pay USE INDEX (idx_payment_booking_id) ON b.booking_id = pay.booking_id

ORDER BY b.created_at DESC
LIMIT 20 OFFSET 0;  -- Pagination: first 20 results

-- OPTIMIZATION 3: Use Common Table Expression (CTE) for better readability and performance
-- Break down complex query into logical components

WITH booking_summary AS (
    SELECT 
        b.booking_id,
        b.property_id,
        b.user_id,
        b.start_date,
        b.end_date,
        b.total_price,
        b.status,
        b.created_at
    FROM Booking b
    WHERE b.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)  -- Only recent bookings
),
property_host AS (
    SELECT 
        p.property_id,
        p.name as property_name,
        p.location,
        p.price_per_night,
        p.host_id,
        CONCAT(h.first_name, ' ', h.last_name) as host_name
    FROM Property p
    JOIN User h ON p.host_id = h.user_id
    WHERE h.role = 'host'
)
SELECT 
    bs.booking_id,
    bs.start_date,
    bs.end_date,
    bs.total_price,
    bs.status,
    CONCAT(g.first_name, ' ', g.last_name) as guest_name,
    g.email as guest_email,
    ph.property_name,
    ph.location,
    ph.host_name,
    p.payment_method,
    p.amount as payment_amount
    
FROM booking_summary bs
    JOIN User g ON bs.user_id = g.user_id AND g.role = 'guest'
    JOIN property_host ph ON bs.property_id = ph.property_id
    LEFT JOIN Payment p ON bs.booking_id = p.booking_id

ORDER BY bs.created_at DESC
LIMIT 20;

-- OPTIMIZATION 4: Create a materialized view for frequently accessed data
-- Note: MySQL doesn't support materialized views, so we'll create a regular view
-- and suggest refresh strategies

CREATE OR REPLACE VIEW v_booking_details AS
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status as booking_status,
    b.created_at as booking_date,
    
    -- Guest information
    g.user_id as guest_id,
    CONCAT(g.first_name, ' ', g.last_name) as guest_name,
    g.email as guest_email,
    
    -- Property information
    p.property_id,
    p.name as property_name,
    p.location as property_location,
    p.price_per_night,
    
    -- Host information
    h.user_id as host_id,
    CONCAT(h.first_name, ' ', h.last_name) as host_name,
    h.email as host_email,
    
    -- Payment information
    CASE 
        WHEN pay.payment_id IS NOT NULL THEN 'Paid'
        WHEN b.status = 'confirmed' THEN 'Payment Due'
        ELSE 'No Payment Required'
    END as payment_status,
    pay.payment_method,
    pay.amount as payment_amount,
    pay.payment_date

FROM Booking b
    JOIN User g ON b.user_id = g.user_id
    JOIN Property p ON b.property_id = p.property_id
    JOIN User h ON p.host_id = h.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id;

-- Now use the view for simplified queries
SELECT * FROM v_booking_details
WHERE booking_status = 'confirmed'
ORDER BY booking_date DESC
LIMIT 20;

-- ================================================================
-- SPECIFIC OPTIMIZATION SCENARIOS
-- ================================================================

-- SCENARIO 1: Recent bookings for a specific user (Guest Dashboard)
-- Optimized with proper indexing and minimal data selection

SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status,
    p.name as property_name,
    p.location,
    CONCAT(h.first_name, ' ', h.last_name) as host_name,
    pay.payment_method

FROM Booking b
    JOIN Property p ON b.property_id = p.property_id
    JOIN User h ON p.host_id = h.user_id  
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id

WHERE b.user_id = ? -- Parameter for specific user
    AND b.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)

ORDER BY b.created_at DESC
LIMIT 10;

-- SCENARIO 2: Host's property bookings summary
-- Optimized for host dashboard with aggregation

SELECT 
    p.property_id,
    p.name as property_name,
    COUNT(b.booking_id) as total_bookings,
    COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) as confirmed_bookings,
    SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) as total_revenue,
    AVG(CASE WHEN b.status = 'confirmed' THEN b.total_price END) as avg_booking_value,
    MAX(b.created_at) as last_booking_date

FROM Property p
    LEFT JOIN Booking b ON p.property_id = b.property_id

WHERE p.host_id = ?  -- Parameter for specific host
    AND (b.created_at IS NULL OR b.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR))

GROUP BY p.property_id, p.name
ORDER BY total_revenue DESC;

-- SCENARIO 3: Property availability check (Most critical for performance)
-- Highly optimized availability query

DELIMITER //
CREATE PROCEDURE CheckPropertyAvailability(
    IN prop_id CHAR(36),
    IN check_in DATE,
    IN check_out DATE
)
BEGIN
    DECLARE availability_status VARCHAR(20) DEFAULT 'Available';
    DECLARE conflict_count INT DEFAULT 0;
    
    -- Check for booking conflicts using optimized query
    SELECT COUNT(*) INTO conflict_count
    FROM Booking b USE INDEX (idx_booking_property_dates_status)
    WHERE b.property_id = prop_id
        AND b.status IN ('confirmed', 'pending')
        AND NOT (
            check_out <= b.start_date OR 
            check_in >= b.end_date
        );
    
    IF conflict_count > 0 THEN
        SET availability_status = 'Not Available';
    END IF;
    
    SELECT 
        prop_id as property_id,
        check_in,
        check_out,
        availability_status,
        conflict_count as conflicting_bookings;
        
END //
DELIMITER ;

-- Usage example:
CALL CheckPropertyAvailability('650e8400-e29b-41d4-a716-446655440001', '2024-08-01', '2024-08-05');

-- ================================================================
-- PERFORMANCE COMPARISON QUERIES
-- ================================================================

-- Enable query profiling to measure performance
SET profiling = 1;

-- Run original complex query
SELECT b.booking_id, b.start_date, b.end_date, b.total_price, b.status,
       guest.first_name, guest.last_name, guest.email,
       p.name, p.description, p.location, p.price_per_night,
       host.first_name as host_first_name, host.last_name as host_last_name,
       pay.payment_id, pay.amount, pay.payment_date, pay.payment_method
FROM Booking b
    JOIN User guest ON b.user_id = guest.user_id
    JOIN Property p ON b.property_id = p.property_id
    JOIN User host ON p.host_id = host.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;

-- Run optimized query
SELECT * FROM v_booking_details
ORDER BY booking_date DESC
LIMIT 20;

-- Check query performance
SHOW PROFILES;

-- Disable profiling
SET profiling = 0;

-- ================================================================
-- ADDITIONAL OPTIMIZATION TECHNIQUES
-- ================================================================

-- TECHNIQUE 1: Use UNION for different booking statuses instead of OR conditions
-- This can use different indexes effectively

SELECT booking_id, start_date, end_date, status, total_price
FROM Booking
WHERE status = 'confirmed'
    AND created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)

UNION ALL

SELECT booking_id, start_date, end_date, status, total_price
FROM Booking
WHERE status = 'pending'
    AND created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)

ORDER BY start_date DESC;

-- TECHNIQUE 2: Use EXISTS instead of IN for better performance with large datasets
-- Find properties with high ratings

SELECT p.property_id, p.name, p.location
FROM Property p
WHERE EXISTS (
    SELECT 1
    FROM Review r
    WHERE r.property_id = p.property_id
    HAVING AVG(r.rating) > 4.0
)
ORDER BY p.name;

-- TECHNIQUE 3: Optimize COUNT queries with approximate solutions for large datasets
-- Use information_schema for quick counts when exact counts aren't critical

SELECT 
    TABLE_NAME,
    TABLE_ROWS as approximate_count
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'airbnb_db'
    AND TABLE_NAME = 'Booking';

-- ================================================================
-- QUERY CACHING AND OPTIMIZATION HINTS
-- ================================================================

-- Enable query cache for repeated queries (if supported)
-- Note: Query cache is deprecated in MySQL 8.0+
-- SET GLOBAL query_cache_type = ON;
-- SET GLOBAL query_cache_size = 268435456; -- 256MB

-- Use SQL hints for specific optimization strategies
SELECT /*+ USE_INDEX(b, idx_booking_created_status_price) */
    b.booking_id,
    b.total_price,
    b.status
FROM Booking b
WHERE b.status = 'confirmed'
ORDER BY b.created_at DESC
LIMIT 10;

-- Force specific join order when needed
SELECT STRAIGHT_JOIN
    b.booking_id,
    p.name,
    u.first_name
FROM Booking b
    JOIN Property p ON b.property_id = p.property_id
    JOIN User u ON b.user_id = u.user_id
WHERE b.status = 'confirmed';

-- ================================================================
-- MONITORING AND MAINTENANCE QUERIES
-- ================================================================

-- Query to identify slow queries
SELECT 
    DIGEST_TEXT,
    COUNT_STAR as exec_count,
    AVG_TIMER_WAIT/1000000000000 as avg_exec_time_sec,
    SUM_TIMER_WAIT/1000000000000 as total_exec_time_sec
FROM performance_schema.events_statements_summary_by_digest
WHERE DIGEST_TEXT LIKE '%Booking%'
ORDER BY avg_exec_time_sec DESC
LIMIT 10;

-- Monitor index usage
SELECT 
    OBJECT_SCHEMA,
    OBJECT_NAME,
    INDEX_NAME,
    COUNT_FETCH,
    COUNT_INSERT,
    COUNT_UPDATE,
    COUNT_DELETE
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE OBJECT_SCHEMA = 'airbnb_db'
ORDER BY COUNT_FETCH DESC;