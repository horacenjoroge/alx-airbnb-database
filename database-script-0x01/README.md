# AirBnB Database Schema

This directory contains the Data Definition Language (DDL) scripts for creating the AirBnB database schema.

## Files

- `schema.sql` - Complete database schema with tables, constraints, indexes, views, and triggers

## Schema Overview

The database consists of 6 main entities:

1. **User** - Stores user information (guests, hosts, admins)
2. **Property** - Property listings with details and pricing
3. **Booking** - Reservation records linking users and properties
4. **Payment** - Payment information for each booking
5. **Review** - User reviews and ratings for properties
6. **Message** - Communication system between users

## Key Features

### Data Types
- **UUID Primary Keys**: All tables use UUID for primary keys
- **ENUM Types**: Used for constrained values (role, status, payment_method)
- **Timestamps**: Automatic timestamp management
- **Decimal**: Precise monetary values

### Constraints
- **Foreign Key Constraints**: Maintain referential integrity
- **Check Constraints**: Validate data ranges and business rules
- **Unique Constraints**: Prevent duplicate data
- **NOT NULL Constraints**: Ensure required fields

### Performance Optimizations
- **Strategic Indexes**: Optimized for common query patterns
- **Composite Indexes**: Multi-column indexes for complex queries
- **Views**: Pre-defined joins for common data access patterns

### Business Logic
- **Triggers**: Automatic timestamp updates and booking validation
- **Check Constraints**: Date validation and price validation
- **Unique Constraints**: Prevent duplicate reviews per user/property

## How to Use

1. **Create Database:**
   ```sql
   CREATE DATABASE airbnb_db;
   USE airbnb_db;
   ```

2. **Run Schema:**
   ```bash
   mysql -u username -p airbnb_db < schema.sql
   ```

3. **Verify Installation:**
   ```sql
   SHOW TABLES;
   DESCRIBE User;
   ```

## Table Relationships

```
User (1:N) Property (1:N) Booking (1:1) Payment
User (1:N) Booking
User (1:N) Review
Property (1:N) Review
User (M:N) Message (self-referencing)
```

## Indexes Created

### Primary Indexes
- All primary keys (UUID) are automatically indexed

### Performance Indexes
- `User.email` (unique lookup)
- `Property.host_id` (find properties by host)
- `Booking.property_id, user_id` (booking queries)
- `Review.property_id, user_id` (review queries)
- `Message.sender_id, recipient_id` (message queries)

### Composite Indexes
- `Booking(property_id, start_date, end_date, status)` - availability queries
- `Review(property_id, rating, created_at)` - property ratings
- `Message(sender_id, recipient_id, sent_at)` - conversation threads

## Views Available

1. **PropertyWithHost** - Properties with host information
2. **BookingDetails** - Complete booking information with user/property details
3. **PropertyReviews** - Reviews with reviewer and property information

## Triggers

1. **update_property_timestamp** - Updates property timestamp when bookings are made
2. **validate_booking_overlap** - Prevents overlapping bookings for the same property

## Security Considerations

- Password stored as hash only
- Foreign key constraints prevent orphaned records
- Cascade deletes maintain data consistency
- Check constraints prevent invalid data entry

## Performance Notes

- UUID primary keys provide uniqueness across distributed systems
- Composite indexes optimize common multi-table queries
- Views reduce complex JOIN overhead for frequent queries
- Triggers maintain data consistency automatically