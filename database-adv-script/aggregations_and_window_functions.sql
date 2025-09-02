-- AirBnB Database Advanced Scripts - Aggregations and Window Functions
-- File: aggregations_and_window_functions.sql

USE airbnb_db;

-- ================================================================
-- AGGREGATION FUNCTIONS WITH GROUP BY
-- ================================================================

-- 1. Total number of bookings made by each user using COUNT and GROUP BY
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(b.booking_id) as total_bookings,
    COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) as confirmed_bookings,
    COUNT(CASE WHEN b.status = 'pending' THEN 1 END) as pending_bookings,
    COUNT(CASE WHEN b.status = 'canceled' THEN 1 END) as canceled_bookings
FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id
WHERE u.role = 'guest'
GROUP BY u.user_id, u.first_name, u.last_name, u.email
ORDER BY total_bookings DESC, u.first_name;

-- 2. Additional aggregation: Total revenue per host
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(DISTINCT p.property_id) as total_properties,
    COUNT(b.booking_id) as total_bookings,
    SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) as total_revenue,
    AVG(CASE WHEN b.status = 'confirmed' THEN b.total_price END) as avg_booking_value,
    MIN(p.price_per_night) as min_property_price,
    MAX(p.price_per_night) as max_property_price
FROM User u
JOIN Property p ON u.user_id = p.host_id
LEFT JOIN Booking b ON p.property_id = b.property_id
WHERE u.role = 'host'
GROUP BY u.user_id, u.first_name, u.last_name, u.email
ORDER BY total_revenue DESC;

-- 3. Property performance summary with aggregations
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.price_per_night,
    COUNT(b.booking_id) as total_bookings,
    COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) as confirmed_bookings,
    SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) as total_revenue,
    COUNT(r.review_id) as total_reviews,
    AVG(r.rating) as avg_rating,
    MIN(b.start_date) as first_booking_date,
    MAX(b.end_date) as last_booking_date
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name, p.location, p.price_per_night
ORDER BY total_revenue DESC;

-- ================================================================
-- WINDOW FUNCTIONS
-- ================================================================

-- 4. Rank properties based on total number of bookings using ROW_NUMBER and RANK
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.price_per_night,
    COUNT(b.booking_id) as total_bookings,
    SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) as total_revenue,
    -- ROW_NUMBER: Unique ranking (1, 2, 3, 4, 5...)
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC, p.name) as row_number_rank,
    -- RANK: Same values get same rank with gaps (1, 2, 2, 4, 5...)
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) as booking_rank,
    -- DENSE_RANK: Same values get same rank without gaps (1, 2, 2, 3, 4...)
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) as dense_booking_rank
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location, p.price_per_night
ORDER BY total_bookings DESC, p.name;

-- 5. Rank properties by location based on bookings
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.price_per_night,
    COUNT(b.booking_id) as total_bookings,
    -- Rank within each location
    ROW_NUMBER() OVER (PARTITION BY p.location ORDER BY COUNT(b.booking_id) DESC) as location_rank,
    RANK() OVER (PARTITION BY p.location ORDER BY COUNT(b.booking_id) DESC) as location_booking_rank,
    -- Overall rank across all properties
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) as overall_rank
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location, p.price_per_night
ORDER BY p.location, total_bookings DESC;

-- ================================================================
-- ADVANCED WINDOW FUNCTIONS
-- ================================================================

-- 6. Running totals and moving averages for booking revenue
SELECT 
    DATE(b.created_at) as booking_date,
    COUNT(*) as daily_bookings,
    SUM(b.total_price) as daily_revenue,
    -- Running total of bookings
    SUM(COUNT(*)) OVER (ORDER BY DATE(b.created_at)) as running_total_bookings,
    -- Running total of revenue
    SUM(SUM(b.total_price)) OVER (ORDER BY DATE(b.created_at)) as running_total_revenue,
    -- Moving average of revenue (3-day window)
    AVG(SUM(b.total_price)) OVER (
        ORDER BY DATE(b.created_at) 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as moving_avg_revenue_3day
FROM Booking b
WHERE b.status = 'confirmed'
GROUP BY DATE(b.created_at)
ORDER BY booking_date;

-- 7. User booking patterns with window functions
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    -- Row number for each user's bookings (chronological order)
    ROW_NUMBER() OVER (PARTITION BY u.user_id ORDER BY b.created_at) as booking_sequence,
    -- Rank bookings by price within each user
    RANK() OVER (PARTITION BY u.user_id ORDER BY b.total_price DESC) as price_rank_within_user,
    -- Calculate difference from previous booking price
    LAG(b.total_price, 1) OVER (PARTITION BY u.user_id ORDER BY b.created_at) as previous_booking_price,
    b.total_price - LAG(b.total_price, 1) OVER (PARTITION BY u.user_id ORDER BY b.created_at) as price_difference,
    -- Calculate difference from next booking price
    LEAD(b.total_price, 1) OVER (PARTITION BY u.user_id ORDER BY b.created_at) as next_booking_price
FROM User u
JOIN Booking b ON u.user_id = b.user_id
WHERE u.role = 'guest'
ORDER BY u.user_id, b.created_at;

-- 8. Property performance with percentiles
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.price_per_night,
    COUNT(b.booking_id) as total_bookings,
    AVG(r.rating) as avg_rating,
    -- Percentile rankings
    PERCENT_RANK() OVER (ORDER BY COUNT(b.booking_id)) as booking_percentile,
    PERCENT_RANK() OVER (ORDER BY p.price_per_night) as price_percentile,
    PERCENT_RANK() OVER (ORDER BY AVG(r.rating)) as rating_percentile,
    -- Quartiles for bookings
    NTILE(4) OVER (ORDER BY COUNT(b.booking_id)) as booking_quartile,
    -- Quartiles for price
    NTILE(4) OVER (ORDER BY p.price_per_night) as price_quartile
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name, p.location, p.price_per_night
ORDER BY booking_percentile DESC;

-- ================================================================
-- COMBINED AGGREGATIONS AND WINDOW FUNCTIONS
-- ================================================================

-- 9. Monthly booking trends with year-over-year comparison
SELECT 
    YEAR(b.created_at) as booking_year,
    MONTH(b.created_at) as booking_month,
    MONTHNAME(b.created_at) as month_name,
    COUNT(*) as monthly_bookings,
    SUM(b.total_price) as monthly_revenue,
    AVG(b.total_price) as avg_booking_value,
    -- Compare with previous month
    LAG(COUNT(*), 1) OVER (ORDER BY YEAR(b.created_at), MONTH(b.created_at)) as prev_month_bookings,
    COUNT(*) - LAG(COUNT(*), 1) OVER (ORDER BY YEAR(b.created_at), MONTH(b.created_at)) as booking_change,
    -- Compare with same month previous year
    LAG(COUNT(*), 12) OVER (ORDER BY YEAR(b.created_at), MONTH(b.created_at)) as same_month_prev_year,
    COUNT(*) - LAG(COUNT(*), 12) OVER (ORDER BY YEAR(b.created_at), MONTH(b.created_at)) as yoy_change
FROM Booking b
WHERE b.status IN ('confirmed', 'pending')
GROUP BY YEAR(b.created_at), MONTH(b.created_at), MONTHNAME(b.created_at)
ORDER BY booking_year, booking_month;

-- 10. Top performing properties by location with window functions
WITH property_performance AS (
    SELECT 
        p.property_id,
        p.name,
        p.location,
        p.price_per_night,
        COUNT(b.booking_id) as total_bookings,
        SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) as total_revenue,
        AVG(r.rating) as avg_rating,
        COUNT(r.review_id) as review_count
    FROM Property p
    LEFT JOIN Booking b ON p.property_id = b.property_id
    LEFT JOIN Review r ON p.property_id = r.property_id
    GROUP BY p.property_id, p.name, p.location, p.price_per_night
)
SELECT 
    *,
    -- Rank within each location
    ROW_NUMBER() OVER (PARTITION BY location ORDER BY total_revenue DESC) as revenue_rank_in_location,
    ROW_NUMBER() OVER (PARTITION BY location ORDER BY total_bookings DESC) as booking_rank_in_location,
    ROW_NUMBER() OVER (PARTITION BY location ORDER BY avg_rating DESC) as rating_rank_in_location,
    -- Overall ranks
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as overall_revenue_rank,
    ROW_NUMBER() OVER (ORDER BY total_bookings DESC) as overall_booking_rank,
    -- Percentiles
    PERCENT_RANK() OVER (ORDER BY total_revenue) as revenue_percentile,
    -- Mark top performer in each location
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY location ORDER BY total_revenue DESC) = 1 
        THEN 'Top Revenue in Location'
        ELSE NULL 
    END as performance_flag
FROM property_performance
ORDER BY location, total_revenue DESC;