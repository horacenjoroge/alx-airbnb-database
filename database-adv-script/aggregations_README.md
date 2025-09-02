# AirBnB Database - Aggregations and Window Functions

This document demonstrates the implementation and usage of SQL aggregation functions and window functions in the AirBnB database system.

## Overview

SQL aggregations and window functions are powerful tools for data analysis. This implementation showcases various techniques for analyzing booking patterns, property performance, and user behavior.

## Aggregation Functions with GROUP BY

### 1. Total Bookings by User

**Query Purpose**: Count total bookings made by each user, broken down by booking status.

```sql
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(b.booking_id) as total_bookings,
    COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) as confirmed_bookings
FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id
WHERE u.role = 'guest'
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_bookings DESC;
```

**Key Concepts**:
- `COUNT()` function for counting records
- `LEFT JOIN` to include users with zero bookings
- `CASE WHEN` for conditional counting
- `GROUP BY` for aggregating per user

### 2. Revenue Analysis by Host

**Query Purpose**: Calculate total revenue, average booking value, and property statistics for each host.

```sql
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(DISTINCT p.property_id) as total_properties,
    SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) as total_revenue,
    AVG(CASE WHEN b.status = 'confirmed' THEN b.total_price END) as avg_booking_value
FROM User u
JOIN Property p ON u.user_id = p.host_id
LEFT JOIN Booking b ON p.property_id = b.property_id
WHERE u.role = 'host'
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_revenue DESC;
```

**Key Concepts**:
- `SUM()` for revenue calculation
- `AVG()` for average booking value
- `COUNT(DISTINCT)` for unique property count
- Multiple table joins with aggregation

## Window Functions

### 1. Ranking Properties by Bookings

**Query Purpose**: Use different ranking functions to rank properties based on total bookings.

```sql
SELECT 
    p.property_id,
    p.name,
    COUNT(b.booking_id) as total_bookings,
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) as row_number_rank,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) as booking_rank,
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) as dense_booking_rank
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.price_per_night
ORDER BY booking_percentile DESC;
```

**Key Concepts**:
- `PERCENT_RANK()` calculates percentile rankings (0 to 1)
- `NTILE(n)` divides data into n equal groups
- Useful for identifying top/bottom performers

## Performance Considerations

### Aggregation Optimization
1. **Indexing**: Create indexes on columns used in `GROUP BY` and `WHERE` clauses
2. **Filtering**: Apply `WHERE` conditions before `GROUP BY` when possible
3. **Selective Joins**: Use appropriate join types to avoid unnecessary data

### Window Function Optimization
1. **Partitioning**: Use `PARTITION BY` to reduce window size
2. **Ordering**: Index columns used in `ORDER BY` within window functions
3. **Frame Specification**: Use appropriate window frames (`ROWS`, `RANGE`)

## Sample Results Analysis

Based on the AirBnB sample data:

### User Booking Statistics
```
User Name           | Total Bookings | Confirmed | Pending | Canceled
--------------------|----------------|-----------|---------|----------
David Wilson        | 2              | 1         | 1       | 0
Lisa Miller         | 2              | 1         | 0       | 1
James Garcia        | 2              | 1         | 0       | 1
Jennifer Martinez   | 1              | 1         | 0       | 0
Robert Anderson     | 1              | 1         | 0       | 0
Maria Taylor        | 1              | 0         | 1       | 0
```

### Property Ranking by Bookings
```
Property Name              | Total Bookings | Row Number | Rank | Dense Rank
---------------------------|----------------|------------|------|------------
Cozy Downtown Apartment    | 2              | 1          | 1    | 1
Beach House Paradise       | 1              | 2          | 2    | 2
Mountain Cabin Retreat     | 1              | 3          | 2    | 2
Victorian Mansion Room     | 1              | 4          | 2    | 2
Luxury Penthouse Suite     | 1              | 5          | 2    | 2
```

### Host Revenue Analysis
```
Host Name      | Properties | Total Bookings | Revenue  | Avg Booking
---------------|------------|----------------|----------|-------------
John Smith     | 2          | 3              | $1,150   | $575
Sarah Johnson  | 2          | 2              | $1,000   | $1,000
Michael Brown  | 2          | 1              | $900     | $900
Emma Davis     | 2          | 1              | $880     | $880
```

## Common Use Cases

### Business Intelligence Queries

1. **Monthly Revenue Trends**
   - Track booking patterns over time
   - Identify seasonal trends
   - Compare year-over-year performance

2. **Property Performance Analysis**
   - Rank properties by various metrics
   - Identify top and bottom performers
   - Analyze price vs. booking correlation

3. **User Behavior Analysis**
   - Track user booking patterns
   - Identify loyal customers
   - Analyze booking value trends

### Operational Queries

1. **Host Performance Metrics**
   - Calculate host earnings
   - Rank hosts by performance
   - Identify property utilization rates

2. **Market Analysis**
   - Compare pricing by location
   - Analyze competition within areas
   - Track market share by property type

## Testing and Validation

### Query Testing Steps
1. **Data Verification**: Ensure sample data is loaded correctly
2. **Result Validation**: Cross-check aggregated results manually
3. **Performance Testing**: Use `EXPLAIN` to analyze execution plans
4. **Edge Case Testing**: Test with empty result sets and null values

### Expected Results with Sample Data
- **Total Users**: 11 (4 hosts, 6 guests, 1 admin)
- **Total Properties**: 8
- **Total Bookings**: 9 (5 confirmed, 2 pending, 2 canceled)
- **Total Revenue**: $3,930 (confirmed bookings only)

## Best Practices

### Aggregation Best Practices
1. **Use Appropriate Joins**: LEFT JOIN for including zeros, INNER JOIN for existing records only
2. **Handle NULLs**: Use `COALESCE()` or `CASE WHEN` for NULL handling
3. **Performance**: Group by minimal columns needed
4. **Readability**: Use meaningful aliases for calculated columns

### Window Function Best Practices
1. **Partition Wisely**: Use `PARTITION BY` to reduce calculation scope
2. **Order Appropriately**: Ensure correct ordering for ranking functions
3. **Frame Specification**: Be explicit about window frames when needed
4. **Combine Functions**: Use multiple window functions efficiently

## File Structure
```
database-adv-script/
├── aggregations_and_window_functions.sql    # Main SQL script
├── README.md                               # This documentation
└── performance_tests.sql                   # Performance testing queries
```

## Next Steps

1. **Index Creation**: Implement indexes for optimal performance
2. **Query Optimization**: Refactor complex queries for better performance  
3. **Monitoring**: Set up query performance monitoring
4. **Advanced Analytics**: Implement more sophisticated analytical queriesd
GROUP BY p.property_id, p.name
ORDER BY total_bookings DESC;
```

**Ranking Function Differences**:
- **ROW_NUMBER()**: Assigns unique sequential numbers (1, 2, 3, 4, 5...)
- **RANK()**: Same values get same rank with gaps (1, 2, 2, 4, 5...)
- **DENSE_RANK()**: Same values get same rank without gaps (1, 2, 2, 3, 4...)

### 2. Partitioned Rankings

**Query Purpose**: Rank properties within each location separately.

```sql
SELECT 
    p.property_id,
    p.name,
    p.location,
    COUNT(b.booking_id) as total_bookings,
    ROW_NUMBER() OVER (PARTITION BY p.location ORDER BY COUNT(b.booking_id) DESC) as location_rank,
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) as overall_rank
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location
ORDER BY p.location, total_bookings DESC;
```

**Key Concepts**:
- `PARTITION BY` divides data into groups
- Separate ranking within each partition
- Multiple window functions in same query

## Advanced Window Functions

### 1. Running Totals and Moving Averages

```sql
SELECT 
    DATE(b.created_at) as booking_date,
    COUNT(*) as daily_bookings,
    SUM(b.total_price) as daily_revenue,
    SUM(COUNT(*)) OVER (ORDER BY DATE(b.created_at)) as running_total_bookings,
    AVG(SUM(b.total_price)) OVER (
        ORDER BY DATE(b.created_at) 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as moving_avg_revenue_3day
FROM Booking b
WHERE b.status = 'confirmed'
GROUP BY DATE(b.created_at)
ORDER BY booking_date;
```

**Key Concepts**:
- Running totals using window frames
- Moving averages with `ROWS BETWEEN`
- Combining aggregation with window functions

### 2. LAG and LEAD Functions

```sql
SELECT 
    u.user_id,
    b.booking_id,
    b.total_price,
    LAG(b.total_price, 1) OVER (PARTITION BY u.user_id ORDER BY b.created_at) as previous_price,
    LEAD(b.total_price, 1) OVER (PARTITION BY u.user_id ORDER BY b.created_at) as next_price
FROM User u
JOIN Booking b ON u.user_id = b.user_id
ORDER BY u.user_id, b.created_at;
```

**Key Concepts**:
- `LAG()` accesses previous row values
- `LEAD()` accesses next row values
- Useful for comparing consecutive records

### 3. Percentiles and Quartiles

```sql
SELECT 
    p.property_id,
    p.name,
    p.price_per_night,
    COUNT(b.booking_id) as total_bookings,
    PERCENT_RANK() OVER (ORDER BY COUNT(b.booking_id)) as booking_percentile,
    NTILE(4) OVER (ORDER BY COUNT(b.booking_id)) as booking_quartile
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_i