# AirBnB Database Sample Data

This directory contains sample data to populate the AirBnB database with realistic test data.

## Files

- `seed.sql` - Complete sample data insertion script

## Sample Data Overview

### Users (11 total)
- **4 Hosts**: Property owners with listings
- **6 Guests**: Users who book properties
- **1 Admin**: System administrator

### Properties (8 total)
Diverse property types across major US cities:
- **New York, NY**: Downtown apartment, Luxury penthouse
- **Miami, FL**: Beach house, Art Deco studio
- **Denver, CO**: Mountain cabin, Urban loft
- **San Francisco, CA**: Victorian mansion room, Tech hub apartment

### Bookings (9 total)
- **5 Confirmed**: Completed with payments
- **2 Pending**: Awaiting confirmation
- **2 Canceled**: Canceled bookings

### Payments (5 total)
- Payment methods: Credit card, PayPal, Stripe
- Total revenue: $3,930.00

### Reviews (8 total)
- Rating distribution: 3 (1 review), 4 (3 reviews), 5 (4 reviews)
- Average rating: 4.4/5.0

### Messages (16 total)
- Booking inquiries and confirmations
- Property-related questions
- Host-guest communication threads

## Data Relationships

The sample data demonstrates realistic relationships:

1. **Host-Property**: Each host owns 1-2 properties
2. **Guest-Booking**: Guests have multiple bookings across different properties
3. **Booking-Payment**: Each confirmed booking has corresponding payment
4. **Property-Review**: Reviews from actual guests who stayed
5. **User Communication**: Message threads between hosts and guests

## Realistic Scenarios Included

### Booking Lifecycle
- Inquiry → Confirmation → Payment → Stay → Review
- Pending bookings waiting for confirmation
- Canceled bookings for various reasons

### User Interactions
- Pre-booking questions about amenities
- Host recommendations for local attractions
- Follow-up communications

### Property Diversity
- Different price ranges: $120-$350 per night
- Various locations and property types
- Different host communication styles

## Data Quality Features

### Temporal Consistency
- Users created before properties
- Properties created before bookings
- Bookings created before payments
- Stays completed before reviews

### Business Logic Compliance
- No overlapping bookings for same property
- Payment amounts match booking totals
- Reviews only from guests who actually stayed
- Messages between related users

### Realistic Content
- Authentic property descriptions
- Genuine review comments
- Natural conversation flows in messages
- Appropriate pricing for locations

## How to Use

1. **Prerequisites**: Schema must be created first
   ```bash
   mysql -u username -p airbnb_db < ../database-script-0x01/schema.sql
   ```

2. **Load Sample Data**:
   ```bash
   mysql -u username -p airbnb_db < seed.sql
   ```

3. **Verify Installation**:
   The script includes verification queries at the end showing:
   - Record counts per table
   - User distribution by role
   - Booking statistics by status
   - Review rating distribution

## Sample Queries to Test

```sql
-- Find all properties with their host information
SELECT p.name, p.location, p.price_per_night, 
       CONCAT(u.first_name, ' ', u.last_name) as host_name
FROM Property p
JOIN User u ON p.host_id = u.user_id;

-- Get booking details with guest and property info
SELECT b.booking_id, b.start_date, b.end_date, b.status,
       CONCAT(guest.first_name, ' ', guest.last_name) as guest_name,
       p.name as property_name,
       CONCAT(host.first_name, ' ', host.last_name) as host_name
FROM Booking b
JOIN User guest ON b.user_id = guest.user_id
JOIN Property p ON b.property_id = p.property_id
JOIN User host ON p.host_id = host.user_id;

-- Average rating per property
SELECT p.name, AVG(r.rating) as avg_rating, COUNT(r.review_id) as review_count
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name;
```

## Business Insights from Sample Data

- **Revenue**: $3,930 from 5 confirmed bookings
- **Average Booking Value**: $786
- **Occupancy**: Mix of confirmed, pending, and canceled bookings
- **Guest Satisfaction**: 4.4/5 average rating
- **Communication**: Active host-guest messaging

This sample data provides a solid foundation for testing queries, developing features, and demonstrating the AirBnB platform functionality.