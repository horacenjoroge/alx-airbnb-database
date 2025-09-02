# AirBnB Database - Subqueries Implementation

This document explains the implementation of both correlated and non-correlated subqueries in the AirBnB database system.

## Overview

Subqueries are nested queries that allow for complex data retrieval by using the result of one query as input to another. This implementation demonstrates both types of subqueries with practical examples.

## Types of Subqueries Implemented

### 1. Non-Correlated Subqueries

Non-correlated subqueries are independent of the outer query and can be executed separately.

#### Example 1: Properties with Average Rating > 4.0
```sql
SELECT p.property_id, p.name, p.location, p.price_per_night
FROM Property p
WHERE p.property_id IN (
    SELECT r.property_id
    FROM Review r
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
);
```

**Explanation:**
- The inner query calculates average ratings per property
- The outer query retrieves property details for those with ratings > 4.0
- The subquery executes once and returns a list of property IDs

### 2. Correlated Subqueries

Correlated subqueries reference columns from the outer query and execute once for each row in the outer query.

#### Example 2: Users with More Than 3 Bookings
```sql
SELECT u.user_id, u.first_name, u.last_name, u.email
FROM User u
WHERE u.role = 'guest'
AND (
    SELECT COUNT(*)
    FROM Booking b
    WHERE b.user_id = u.user_id
) > 3;
```

**Explanation:**
- The inner query counts bookings for each user from the outer query
- The subquery executes once for each user row
- Only users with more than 3 bookings are returned

## Query Performance Analysis

### Non-Correlated Subquery Performance
- **Execution**: Inner query executes once
- **Efficiency**: Generally more efficient for large datasets
- **Use Case**: When the inner query result doesn't depend on outer query rows

### Correlated Subquery Performance
- **Execution**: Inner query executes for each outer query row
- **Efficiency**: Can be slower for large datasets
- **Use Case**: When inner query needs data from each outer query row

## Advanced Subquery Examples

### 1. Properties with Above-Average Pricing by Location
```sql
SELECT p.property_id, p.name, p.location, p.price_per_night
FROM Property p
WHERE p.price_per_night > (
    SELECT AVG(p2.price_per_night)
    FROM Property p2
    WHERE p2.location = p.location
);
```

### 2. Users Who Have Never Made a Booking
```sql
SELECT u.user_id, u.first_name, u.last_name
FROM User u
WHERE u.role = 'guest'
AND NOT EXISTS (
    SELECT 1
    FROM Booking b
    WHERE b.user_id = u.user_id
);
```

### 3. Most Expensive Property in Each Location
```sql
SELECT p.property_id, p.name, p.location, p.price_per_night
FROM Property p
WHERE p.price_per_night = (
    SELECT MAX(p2.price_per_night)
    FROM Property p2
    WHERE p2.location = p.location
);
```

## Optimization Tips

### For Non-Correlated Subqueries:
1. **Use Indexes**: Ensure proper indexing on columns used in WHERE clauses
2. **Consider JOINs**: Sometimes JOIN operations can be more efficient
3. **Use EXISTS**: For existence checks, EXISTS can be faster than IN

### For Correlated Subqueries:
1. **Index Correlation Columns**: Index columns used in the correlation condition
2. **Limit Outer Query**: Use WHERE conditions to reduce outer query rows
3. **Consider Window Functions**: Sometimes window functions can replace correlated subqueries

## Execution Plan Analysis

### Non-Correlated Subquery Plan:
```
1. Execute inner query once
2. Store results in temporary table/memory
3. Use results to filter outer query
4. Return final result set
```

### Correlated Subquery Plan:
```
1. Read first row from outer query
2. Execute inner query with outer row values
3. Evaluate condition
4. Repeat for each outer query row
5. Return filtered result set
```

## Best Practices

1. **Choose the Right Type**: Use non-correlated when possible for better performance
2. **Proper Indexing**: Index all columns used in subquery conditions
3. **Test Performance**: Always test with realistic data volumes
4. **Consider Alternatives**: JOINs, window functions, or CTEs might be more efficient
5. **Readable Code**: Use meaningful aliases and proper formatting

## Sample Data Results

Based on the sample data in the database:

### Properties with Rating > 4.0:
- Cozy Downtown Apartment (4.5 avg rating)
- Beach House Paradise (4.0 avg rating)
- Mountain Cabin Retreat (5.0 avg rating)
- Victorian Mansion Room (4.0 avg rating)

### Users with > 3 Bookings:
- Currently no users in sample data have more than 3 bookings
- Sample data contains 1-2 bookings per user maximum

## Testing Instructions

1. **Load Sample Data**: Ensure the database has sample data loaded
2. **Execute Queries**: Run each query in the subqueries.sql file
3. **Analyze Results**: Compare results with expected outcomes
4. **Performance Testing**: Use EXPLAIN to analyze execution plans
5. **Index Testing**: Test queries with and without indexes

## Files Structure
```
database-adv-script/
├── subqueries.sql          # All subquery implementations
├── README.md              # This documentation file
└── test_results.sql       # Sample test queries and results
```