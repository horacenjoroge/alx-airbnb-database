# AirBnB Database - Entity Relationship Diagram

## Entities Identified

### 1. User
**Attributes:**
- user_id (PK, UUID)
- first_name (VARCHAR, NOT NULL)
- last_name (VARCHAR, NOT NULL)
- email (VARCHAR, UNIQUE, NOT NULL)
- password_hash (VARCHAR, NOT NULL)
- phone_number (VARCHAR, NULL)
- role (ENUM: guest, host, admin, NOT NULL)
- created_at (TIMESTAMP)

### 2. Property
**Attributes:**
- property_id (PK, UUID)
- host_id (FK → User.user_id)
- name (VARCHAR, NOT NULL)
- description (TEXT, NOT NULL)
- location (VARCHAR, NOT NULL)
- price_per_night (DECIMAL, NOT NULL)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

### 3. Booking
**Attributes:**
- booking_id (PK, UUID)
- property_id (FK → Property.property_id)
- user_id (FK → User.user_id)
- start_date (DATE, NOT NULL)
- end_date (DATE, NOT NULL)
- total_price (DECIMAL, NOT NULL)
- status (ENUM: pending, confirmed, canceled, NOT NULL)
- created_at (TIMESTAMP)

### 4. Payment
**Attributes:**
- payment_id (PK, UUID)
- booking_id (FK → Booking.booking_id)
- amount (DECIMAL, NOT NULL)
- payment_date (TIMESTAMP)
- payment_method (ENUM: credit_card, paypal, stripe, NOT NULL)

### 5. Review
**Attributes:**
- review_id (PK, UUID)
- property_id (FK → Property.property_id)
- user_id (FK → User.user_id)
- rating (INTEGER, CHECK: 1-5, NOT NULL)
- comment (TEXT, NOT NULL)
- created_at (TIMESTAMP)

### 6. Message
**Attributes:**
- message_id (PK, UUID)
- sender_id (FK → User.user_id)
- recipient_id (FK → User.user_id)
- message_body (TEXT, NOT NULL)
- sent_at (TIMESTAMP)

## Relationships

### User-Property (1:N)
- One User (host) can own multiple Properties
- Each Property belongs to one User (host)
- Relationship: User.user_id ← Property.host_id

### User-Booking (1:N)
- One User (guest) can make multiple Bookings
- Each Booking belongs to one User (guest)
- Relationship: User.user_id ← Booking.user_id

### Property-Booking (1:N)
- One Property can have multiple Bookings
- Each Booking is for one Property
- Relationship: Property.property_id ← Booking.property_id

### Booking-Payment (1:1)
- Each Booking has one Payment
- Each Payment belongs to one Booking
- Relationship: Booking.booking_id ← Payment.booking_id

### Property-Review (1:N)
- One Property can have multiple Reviews
- Each Review is for one Property
- Relationship: Property.property_id ← Review.property_id

### User-Review (1:N)
- One User can write multiple Reviews
- Each Review is written by one User
- Relationship: User.user_id ← Review.user_id

### User-Message (M:N via self-referencing)
- One User can send multiple Messages
- One User can receive multiple Messages
- Relationships: 
  - User.user_id ← Message.sender_id
  - User.user_id ← Message.recipient_id

## ER Diagram Structure

```
[User] ──┬── owns ────→ [Property] ──── has ────→ [Booking] ──── has ────→ [Payment]
    │                       │              │
    │                       │              │
    │                   reviews        makes by
    │                       │              │
    │                       ↓              ↓
    │                   [Review] ←── writes ──┘
    │
    ├── sends ────→ [Message]
    └── receives ──→ [Message]
```

## Cardinality Summary
- User : Property = 1:N (One host can own multiple properties)
- User : Booking = 1:N (One guest can make multiple bookings)
- Property : Booking = 1:N (One property can be booked multiple times)
- Booking : Payment = 1:1 (Each booking has exactly one payment)
- Property : Review = 1:N (One property can have multiple reviews)
- User : Review = 1:N (One user can write multiple reviews)
- User : Message = M:N (Users can send/receive multiple messages)

## Indexes Required
- Primary keys (automatic)
- User.email (unique index)
- Property.host_id
- Booking.property_id
- Booking.user_id
- Payment.booking_id
- Review.property_id
- Review.user_id
- Message.sender_id
- Message.recipient_id