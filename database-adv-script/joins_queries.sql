-- AirBnB Database Advanced Scripts - Complex JOIN Queries
-- File: joins_queries.sql

USE airbnb_db;

-- ================================================================
-- MANDATORY JOIN QUERIES
-- ================================================================

-- 1. INNER JOIN: Retrieve all bookings and the respective users who made those bookings
-- This query shows only bookings that have corresponding users (should show all in our case)

SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status as booking_status,
    b.created_at as booking_date,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
ORDER BY b.created_at DESC;

-- 2. LEFT JOIN: Retrieve all properties and their reviews, including properties that have no reviews
-- This query shows all properties, even those without reviews (NULL values for review columns)

SELECT 
    p.property_id,
    p.name as property_name,
    p.location,
    p.price_per_night,
    p.description,
    r.review_id,
    r.rating,
    r.comment,
    r.created_at as review_date,
    CONCAT(u.first_name, ' ', u.last_name) as reviewer_name
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id
LEFT JOIN User u ON r.user_id = u.user_id
ORDER BY p.property_id, r.created_at DESC;

-- 3. FULL OUTER JOIN: Retrieve all users and all bookings
-- Note: MySQL doesn't support FULL OUTER JOIN directly, so we use UNION of LEFT and RIGHT JOINs
-- This query shows all users (even those without bookings) and all bookings (even orphaned ones)

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status as booking_status
FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id

UNION

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status as booking_status
FROM User u
RIGHT JOIN Booking b ON u.user_id = b.user_id
WHERE u.user_id IS NULL  -- Only include orphaned bookings (shouldn't exist in our schema)

ORDER BY user_id, booking_id;

-- ================================================================
-- ADDITIONAL COMPLEX JOIN EXAMPLES
-- ================================================================

-- 4. Multiple INNER JOINs: Complete booking details with property and host information
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    
    -- Guest information
    CONCAT(guest.first_name, ' ', guest.last_name) as guest_name,
    guest.email as guest_email,
    
    -- Property information
    p.name as property_name,
    p.location as property_location,
    p.price_per_night,
    
    -- Host information
    CONCAT(host.first_name, ' ', host.last_name) as host_name,
    host.email as host_email,
    
    -- Payment information (if exists)
    pay.payment_method,
    pay.amount as payment_amount,
    pay.payment_date
    
FROM Booking b
INNER JOIN User guest ON b.user_id = guest.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN User host ON p.host_id = host.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;

-- 5. LEFT JOIN with aggregation: Properties with booking statistics
SELECT 
    p.property_id,
    p.name as property_name,
    p.location,
    p.price_per_night,
    CONCAT(host.first_name, ' ', host.last_name) as host_name,
    
    -- Booking statistics
    COUNT(b.booking_id) as total_bookings,
    COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) as confirmed_bookings,
    COUNT(CASE WHEN b.status = 'pending' THEN 1 END) as pending_bookings,
    COUNT(CASE WHEN b.status = 'canceled' THEN 1 END) as canceled_bookings,
    
    -- Revenue statistics
    SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) as total_revenue,
    AVG(CASE WHEN b.status = 'confirmed' THEN b.total_price END) as avg_booking_value,
    
    -- Date statistics
    MIN(b.start_date) as first_booking_date,
    MAX(b.end_date) as last_booking_date

FROM Property p
LEFT JOIN User host ON p.host_id = host.user_id
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location, p.price_per_night, host.first_name, host.last_name
ORDER BY total_revenue DESC;

-- 6. RIGHT JOIN: All bookings with property details (even if property is deleted)
-- This would show bookings even if the property no longer exists (shouldn't happen with FK constraints)
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    p.property_id,
    p.name as property_name,
    p.location,
    p.price_per_night,
    CASE 
        WHEN p.property_id IS NULL THEN 'Property Deleted'
        ELSE 'Active Property'
    END as property_status
FROM Property p
RIGHT JOIN Booking b ON p.property_id = b.property_id
ORDER BY b.created_at DESC;

-- 7. Self JOIN: Find users from the same location (using a derived location from properties)
-- This demonstrates self-join concept even though our User table doesn't have location
WITH user_locations AS (
    SELECT DISTINCT
        u.user_id,
        u.first_name,
        u.last_name,
        p.location
    FROM User u
    JOIN Property p ON u.user_id = p.host_id
    WHERE u.role = 'host'
)
SELECT 
    u1.user_id as user1_id,
    CONCAT(u1.first_name, ' ', u1.last_name) as user1_name,
    u2.user_id as user2_id,
    CONCAT(u2.first_name, ' ', u2.last_name) as user2_name,
    u1.location
FROM user_locations u1
JOIN user_locations u2 ON u1.location = u2.location AND u1.user_id < u2.user_id
ORDER BY u1.location, u1.user_id;

-- 8. Complex LEFT JOIN with multiple conditions: Properties with recent reviews
SELECT 
    p.property_id,
    p.name as property_name,
    p.location,
    p.price_per_night,
    
    -- Recent review information (last 6 months)
    r.review_id,
    r.rating,
    r.comment,
    r.created_at as review_date,
    CONCAT(reviewer.first_name, ' ', reviewer.last_name) as reviewer_name,
    
    -- Days since review
    DATEDIFF(CURRENT_DATE, r.created_at) as days_since_review
    
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id 
    AND r.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
LEFT JOIN User reviewer ON r.user_id = reviewer.user_id
ORDER BY p.property_id, r.created_at DESC;

-- ================================================================
-- ADVANCED JOIN SCENARIOS
-- ================================================================

-- 9. Multiple LEFT JOINs with COALESCE: Complete property dashboard
SELECT 
    p.property_id,
    p.name as property_name,
    p.location,
    p.price_per_night,
    
    -- Host information
    CONCAT(host.first_name, ' ', host.last_name) as host_name,
    host.email as host_email,
    
    -- Booking statistics with NULL handling
    COALESCE(COUNT(b.booking_id), 0) as total_bookings,
    COALESCE(SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price END), 0) as total_revenue,
    
    -- Review statistics with NULL handling
    COALESCE(COUNT(r.review_id), 0) as total_reviews,
    COALESCE(AVG(r.rating), 0) as average_rating,
    
    -- Message statistics
    COALESCE(COUNT(m.message_id), 0) as total_messages_received,
    
    -- Property status
    CASE 
        WHEN COUNT(b.booking_id) = 0 THEN 'No Bookings Yet'
        WHEN COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) > 0 THEN 'Active'
        ELSE 'Bookings Pending'
    END as property_status

FROM Property p
LEFT JOIN User host ON p.host_id = host.user_id
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
LEFT JOIN Message m ON host.user_id = m.recipient_id
GROUP BY p.property_id, p.name, p.location, p.price_per_night, 
         host.first_name, host.last_name, host.email
ORDER BY total_revenue DESC, average_rating DESC;

-- 10. Cross JOIN example: All possible user-property combinations (for recommendation system)
-- Limited to prevent large result sets
SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) as guest_name,
    u.email,
    p.property_id,
    p.name as property_name,
    p.location,
    p.price_per_night,
    
    -- Check if user has already booked this property
    CASE 
        WHEN b.booking_id IS NOT NULL THEN 'Already Booked'
        ELSE 'Potential Match'
    END as booking_status

FROM User u
CROSS JOIN Property p
LEFT JOIN Booking b ON u.user_id = b.user_id AND p.property_id = b.property_id
WHERE u.role = 'guest' 
    AND p.property_id IS NOT NULL
ORDER BY u.user_id, p.price_per_night;

-- ================================================================
-- PERFORMANCE ANALYSIS QUERIES
-- ================================================================

-- 11. JOIN performance comparison: Analyze execution plans
-- Inner Join - Most efficient for existing relationships
EXPLAIN FORMAT=JSON
SELECT b.booking_id, u.first_name, u.last_name, p.name
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id;

-- Left Join - Good for optional relationships
EXPLAIN FORMAT=JSON
SELECT p.name, r.rating, r.comment
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id;

-- Multiple Left Joins - Monitor for performance with large datasets
EXPLAIN FORMAT=JSON
SELECT p.name, b.booking_id, r.rating, pay.amount
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id;

-- ================================================================
-- JOIN BEST PRACTICES DEMONSTRATION
-- ================================================================

-- 12. Using table aliases for readability
SELECT 
    b.booking_id,
    guest.first_name as guest_first_name,
    guest.last_name as guest_last_name,
    prop.name as property_name,
    host.first_name as host_first_name,
    host.last_name as host_last_name
FROM Booking b
JOIN User guest ON b.user_id = guest.user_id
JOIN Property prop ON b.property_id = prop.property_id
JOIN User host ON prop.host_id = host.user_id
WHERE b.status = 'confirmed';

-- 13. Avoiding Cartesian products with proper JOIN conditions
-- BAD EXAMPLE (commented out to prevent issues):
-- SELECT * FROM User, Property, Booking;  -- This would create a Cartesian product

-- GOOD EXAMPLE with proper JOIN conditions:
SELECT 
    u.first_name,
    u.last_name,
    p.name,
    b.start_date
FROM User u
JOIN Property p ON u.user_id = p.host_id  -- Proper JOIN condition
JOIN Booking b ON p.property_id = b.property_id  -- Proper JOIN condition
WHERE u.role = 'host';

-- ================================================================
-- SUMMARY QUERIES FOR ANALYSIS
-- ================================================================

-- 14. Summary: JOIN types usage analysis
SELECT 'INNER JOIN Results' as query_type, COUNT(*) as result_count
FROM Booking b INNER JOIN User u ON b.user_id = u.user_id

UNION ALL

SELECT 'LEFT JOIN Results (Properties)', COUNT(*) 
FROM Property p LEFT JOIN Review r ON p.property_id = r.property_id

UNION ALL

SELECT 'FULL OUTER JOIN Simulation Results', COUNT(*)
FROM (
    SELECT u.user_id FROM User u LEFT JOIN Booking b ON u.user_id = b.user_id
    UNION
    SELECT u.user_id FROM User u RIGHT JOIN Booking b ON u.user_id = b.user_id
) as full_outer_result;