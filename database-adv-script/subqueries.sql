-- AirBnB Database Advanced Scripts - Subqueries
-- File: subqueries.sql

USE airbnb_db;

-- ================================================================
-- NON-CORRELATED SUBQUERIES
-- ================================================================

-- 1. Find all properties where the average rating is greater than 4.0
-- This query uses a non-correlated subquery to filter properties
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.price_per_night,
    CONCAT(u.first_name, ' ', u.last_name) as host_name
FROM Property p
JOIN User u ON p.host_id = u.user_id
WHERE p.property_id IN (
    SELECT r.property_id
    FROM Review r
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
)
ORDER BY p.name;

-- Alternative approach using EXISTS (also non-correlated in this context)
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.price_per_night
FROM Property p
WHERE EXISTS (
    SELECT 1
    FROM Review r
    WHERE r.property_id = p.property_id
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
)
ORDER BY p.name;

-- ================================================================
-- CORRELATED SUBQUERIES
-- ================================================================

-- 2. Find users who have made more than 3 bookings (correlated subquery)
-- This query uses a correlated subquery where the inner query references the outer query
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role
FROM User u
WHERE u.role = 'guest'
AND (
    SELECT COUNT(*)
    FROM Booking b
    WHERE b.user_id = u.user_id
) > 3
ORDER BY u.first_name, u.last_name;

-- Alternative correlated subquery to show booking count
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id) as total_bookings
FROM User u
WHERE u.role = 'guest'
AND (
    SELECT COUNT(*)
    FROM Booking b
    WHERE b.user_id = u.user_id
) > 3
ORDER BY total_bookings DESC;

-- ================================================================
-- ADDITIONAL COMPLEX SUBQUERY EXAMPLES
-- ================================================================

-- 3. Find properties with above-average pricing in their location
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.price_per_night,
    (
        SELECT AVG(p2.price_per_night)
        FROM Property p2
        WHERE p2.location = p.location
    ) as avg_location_price
FROM Property p
WHERE p.price_per_night > (
    SELECT AVG(p2.price_per_night)
    FROM Property p2
    WHERE p2.location = p.location
)
ORDER BY p.location, p.price_per_night DESC;

-- 4. Find users who have never made a booking (correlated subquery with NOT EXISTS)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    u.created_at
FROM User u
WHERE u.role = 'guest'
AND NOT EXISTS (
    SELECT 1
    FROM Booking b
    WHERE b.user_id = u.user_id
)
ORDER BY u.created_at DESC;

-- 5. Find properties that have received more reviews than the average
SELECT 
    p.property_id,
    p.name,
    p.location,
    (
        SELECT COUNT(*)
        FROM Review r
        WHERE r.property_id = p.property_id
    ) as review_count,
    (
        SELECT AVG(review_counts.cnt)
        FROM (
            SELECT COUNT(*) as cnt
            FROM Review r2
            GROUP BY r2.property_id
        ) as review_counts
    ) as avg_reviews_per_property
FROM Property p
WHERE (
    SELECT COUNT(*)
    FROM Review r
    WHERE r.property_id = p.property_id
) > (
    SELECT AVG(review_counts.cnt)
    FROM (
        SELECT COUNT(*) as cnt
        FROM Review r2
        GROUP BY r2.property_id
    ) as review_counts
)
ORDER BY review_count DESC;

-- 6. Find hosts with properties that have all been rated above 3.5
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email
FROM User u
WHERE u.role = 'host'
AND NOT EXISTS (
    SELECT 1
    FROM Property p
    WHERE p.host_id = u.user_id
    AND EXISTS (
        SELECT 1
        FROM Review r
        WHERE r.property_id = p.property_id
        AND r.rating <= 3.5
    )
)
AND EXISTS (
    SELECT 1
    FROM Property p
    WHERE p.host_id = u.user_id
)
ORDER BY u.first_name, u.last_name;

-- 7. Find the most expensive property in each location
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.price_per_night
FROM Property p
WHERE p.price_per_night = (
    SELECT MAX(p2.price_per_night)
    FROM Property p2
    WHERE p2.location = p.location
)
ORDER BY p.location, p.price_per_night DESC;