-- AirBnB Database Sample Data
USE airbnb_db;

-- Disable foreign key checks temporarily for easier insertion
SET FOREIGN_KEY_CHECKS = 0;

-- Clear existing data (if any)
DELETE FROM Message;
DELETE FROM Review;
DELETE FROM Payment;
DELETE FROM Booking;
DELETE FROM Property;
DELETE FROM User;

-- Reset auto-increment counters
ALTER TABLE Message AUTO_INCREMENT = 1;
ALTER TABLE Review AUTO_INCREMENT = 1;
ALTER TABLE Payment AUTO_INCREMENT = 1;
ALTER TABLE Booking AUTO_INCREMENT = 1;
ALTER TABLE Property AUTO_INCREMENT = 1;
ALTER TABLE User AUTO_INCREMENT = 1;

-- Insert Users
INSERT INTO User (user_id, first_name, last_name, email, password_hash, phone_number, role, created_at) VALUES
-- Hosts
('550e8400-e29b-41d4-a716-446655440001', 'John', 'Smith', 'john.smith@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567890', 'host', '2023-01-15 08:00:00'),
('550e8400-e29b-41d4-a716-446655440002', 'Sarah', 'Johnson', 'sarah.johnson@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567891', 'host', '2023-02-10 09:30:00'),
('550e8400-e29b-41d4-a716-446655440003', 'Michael', 'Brown', 'michael.brown@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567892', 'host', '2023-03-05 14:20:00'),
('550e8400-e29b-41d4-a716-446655440004', 'Emma', 'Davis', 'emma.davis@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567893', 'host', '2023-04-12 11:45:00'),

-- Guests
('550e8400-e29b-41d4-a716-446655440005', 'David', 'Wilson', 'david.wilson@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567894', 'guest', '2023-05-20 16:10:00'),
('550e8400-e29b-41d4-a716-446655440006', 'Lisa', 'Miller', 'lisa.miller@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567895', 'guest', '2023-06-15 10:25:00'),
('550e8400-e29b-41d4-a716-446655440007', 'James', 'Garcia', 'james.garcia@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567896', 'guest', '2023-07-08 13:55:00'),
('550e8400-e29b-41d4-a716-446655440008', 'Jennifer', 'Martinez', 'jennifer.martinez@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567897', 'guest', '2023-08-22 15:40:00'),
('550e8400-e29b-41d4-a716-446655440009', 'Robert', 'Anderson', 'robert.anderson@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567898', 'guest', '2023-09-10 12:15:00'),
('550e8400-e29b-41d4-a716-446655440010', 'Maria', 'Taylor', 'maria.taylor@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567899', 'guest', '2023-10-05 09:50:00'),

-- Admin
('550e8400-e29b-41d4-a716-446655440011', 'Admin', 'User', 'admin@airbnb.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567800', 'admin', '2023-01-01 00:00:00');

-- Insert Properties
INSERT INTO Property (property_id, host_id, name, description, location, price_per_night, created_at, updated_at) VALUES
-- John Smith's Properties
('650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'Cozy Downtown Apartment', 'Modern 2-bedroom apartment in the heart of downtown. Perfect for business travelers and tourists. Features include WiFi, kitchen, and city views.', 'New York, NY, USA', 150.00, '2023-01-20 10:00:00', '2023-01-20 10:00:00'),
('650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'Luxury Penthouse Suite', 'Stunning penthouse with panoramic city views, modern amenities, and premium furnishings. Ideal for special occasions.', 'New York, NY, USA', 350.00, '2023-02-15 14:30:00', '2023-02-15 14:30:00'),

-- Sarah Johnson's Properties
('650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', 'Beach House Paradise', 'Charming beach house with direct ocean access. Perfect for families and couples seeking relaxation. Includes beach equipment and BBQ area.', 'Miami, FL, USA', 200.00, '2023-03-10 11:45:00', '2023-03-10 11:45:00'),
('650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440002', 'Art Deco Studio', 'Stylish Art Deco studio in trendy South Beach. Walking distance to restaurants, nightlife, and beach.', 'Miami, FL, USA', 120.00, '2023-04-05 09:20:00', '2023-04-05 09:20:00'),

-- Michael Brown's Properties
('650e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440003', 'Mountain Cabin Retreat', 'Rustic log cabin surrounded by nature. Perfect for hiking enthusiasts and those seeking peace. Fireplace and hot tub included.', 'Denver, CO, USA', 180.00, '2023-04-20 16:15:00', '2023-04-20 16:15:00'),
('650e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440003', 'Urban Loft Space', 'Industrial-style loft in trendy neighborhood. High ceilings, exposed brick, and modern amenities.', 'Denver, CO, USA', 140.00, '2023-05-10 13:25:00', '2023-05-10 13:25:00'),

-- Emma Davis's Properties
('650e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440004', 'Victorian Mansion Room', 'Beautiful room in historic Victorian mansion. Elegant decor, garden views, and continental breakfast included.', 'San Francisco, CA, USA', 220.00, '2023-05-25 08:40:00', '2023-05-25 08:40:00'),
('650e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440004', 'Modern Tech Hub Apartment', 'Ultra-modern apartment in tech district. Smart home features, high-speed internet, and close to major tech companies.', 'San Francisco, CA, USA', 280.00, '2023-06-12 15:55:00', '2023-06-12 15:55:00');

-- Insert Bookings
INSERT INTO Booking (booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at) VALUES
-- Confirmed Bookings
('750e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440005', '2024-01-15', '2024-01-18', 450.00, 'confirmed', '2023-12-20 14:30:00'),
('750e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440006', '2024-02-10', '2024-02-15', 1000.00, 'confirmed', '2024-01-15 10:45:00'),
('750e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440007', '2024-03-20', '2024-03-25', 900.00, 'confirmed', '2024-02-18 16:20:00'),
('750e8400-e29b-41d4-a716-446655440004', '650e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440008', '2024-04-12', '2024-04-16', 880.00, 'confirmed', '2024-03-10 11:15:00'),
('750e8400-e29b-41d4-a716-446655440005', '650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440009', '2024-05-01', '2024-05-03', 700.00, 'confirmed', '2024-04-05 09:30:00'),

-- Pending Bookings
('750e8400-e29b-41d4-a716-446655440006', '650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440010', '2024-06-15', '2024-06-18', 360.00, 'pending', '2024-05-20 13:45:00'),
('750e8400-e29b-41d4-a716-446655440007', '650e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440005', '2024-07-10', '2024-07-14', 560.00, 'pending', '2024-06-12 15:20:00'),

-- Canceled Bookings
('750e8400-e29b-41d4-a716-446655440008', '650e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440006', '2024-03-05', '2024-03-08', 840.00, 'canceled', '2024-02-10 12:00:00'),
('750e8400-e29b-41d4-a716-446655440009', '650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440007', '2024-05-20', '2024-05-23', 450.00, 'canceled', '2024-04-25 14:30:00');

-- Insert Payments (only for confirmed bookings)
INSERT INTO Payment (payment_id, booking_id, amount, payment_date, payment_method) VALUES
('850e8400-e29b-41d4-a716-446655440001', '750e8400-e29b-41d4-a716-446655440001', 450.00, '2023-12-20 14:35:00', 'credit_card'),
('850e8400-e29b-41d4-a716-446655440002', '750e8400-e29b-41d4-a716-446655440002', 1000.00, '2024-01-15 10:50:00', 'stripe'),
('850e8400-e29b-41d4-a716-446655440003', '750e8400-e29b-41d4-a716-446655440003', 900.00, '2024-02-18 16:25:00', 'paypal'),
('850e8400-e29b-41d4-a716-446655440004', '750e8400-e29b-41d4-a716-446655440004', 880.00, '2024-03-10 11:20:00', 'credit_card'),
('850e8400-e29b-41d4-a716-446655440005', '750e8400-e29b-41d4-a716-446655440005', 700.00, '2024-04-05 09:35:00', 'stripe');

-- Insert Reviews (only for completed stays)
INSERT INTO Review (review_id, property_id, user_id, rating, comment, created_at) VALUES
('950e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440005', 5, 'Amazing location! The apartment was exactly as described and John was a fantastic host. Would definitely stay again.', '2024-01-19 10:30:00'),
('950e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440006', 4, 'Beautiful beach house with stunning views. The only minor issue was the WiFi was a bit slow, but everything else was perfect.', '2024-02-16 14:45:00'),
('950e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440007', 5, 'The mountain cabin was absolutely perfect for our hiking trip. Clean, cozy, and the hot tub was amazing after long hikes!', '2024-03-26 09:15:00'),
('950e8400-e29b-41d4-a716-446655440004', '650e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440008', 4, 'Lovely Victorian room with beautiful decor. Emma provided excellent recommendations for local restaurants. Highly recommend!', '2024-04-17 16:20:00'),
('950e8400-e29b-41d4-a716-446655440005', '650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440009', 5, 'Incredible penthouse with breathtaking views! Perfect for our anniversary celebration. Luxury at its finest.', '2024-05-04 11:40:00'),
('950e8400-e29b-41d4-a716-446655440006', '650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440006', 4, 'Great downtown location, clean and comfortable. Only minor complaint is street noise at night, but overall excellent stay.', '2024-01-25 13:55:00'),
('950e8400-e29b-41d4-a716-446655440007', '650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440007', 3, 'The studio was nice but smaller than expected. Good location though, and Sarah was responsive to messages.', '2024-02-08 15:30:00'),
('950e8400-e29b-41d4-a716-446655440008', '650e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440008', 5, 'Urban loft was perfect for our city break! Industrial style was exactly what we wanted. Michael was a great host.', '2024-04-02 12:10:00');

-- Insert Messages
INSERT INTO Message (message_id, sender_id, recipient_id, message_body, sent_at) VALUES
-- Booking inquiries and confirmations
('a50e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440001', 'Hi John! I am interested in booking your downtown apartment for January 15-18. Is it available?', '2023-12-18 14:20:00'),
('a50e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440005', 'Hi David! Yes, the apartment is available for those dates. I will send you the booking confirmation shortly. Looking forward to hosting you!', '2023-12-18 15:30:00'),
('a50e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440001', 'Perfect! Thank you so much. Do you have any restaurant recommendations in the area?', '2023-12-18 16:45:00'),
('a50e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440005', 'Absolutely! There is an excellent Italian place called Mario\'s just two blocks away, and a great coffee shop called Bean There on the corner. Both are fantastic!', '2023-12-19 09:15:00'),

-- Beach house booking conversation
('a50e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440002', 'Hello Sarah! Your beach house looks amazing. We are planning a family vacation for February 10-15. Could you tell me more about the amenities?', '2024-01-12 11:30:00'),
('a50e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440006', 'Hi Lisa! The house has direct beach access, full kitchen, BBQ area, beach chairs, umbrellas, and boogie boards. Perfect for families! It sleeps up to 6 people comfortably.', '2024-01-12 13:45:00'),
('a50e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440002', 'That sounds perfect for our family of 4! We will book it right away. Is parking included?', '2024-01-12 14:20:00'),
('a50e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440006', 'Yes, there are 2 parking spaces included. I will also provide a local guide with family-friendly activities and restaurants. Can\'t wait to host you!', '2024-01-12 15:10:00'),

-- Mountain cabin conversation
('a50e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440003', 'Hi Michael! We are avid hikers looking to book your mountain cabin for March 20-25. Are there good hiking trails nearby?', '2024-02-15 10:00:00'),
('a50e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440007', 'Hi James! You will love it here. There are over 15 trails within 10 miles, ranging from easy walks to challenging climbs. I have detailed trail maps and can recommend the best ones based on your experience level.', '2024-02-15 11:30:00'),

-- Follow-up messages
('a50e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440003', 'That sounds perfect! We are intermediate hikers and love a good challenge. Looking forward to the hot tub after those hikes too!', '2024-02-15 12:45:00'),
('a50e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440007', 'Excellent! I have marked the best intermediate trails on the map for you. The hot tub will definitely be perfect after a long day on the trails. See you in March!', '2024-02-15 13:20:00'),

-- Victorian mansion inquiry
('a50e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440004', 'Hello Emma! We are visiting San Francisco for our anniversary and your Victorian mansion room looks beautiful. Is breakfast really included?', '2024-03-05 09:30:00'),
('a50e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440008', 'Hi Jennifer! Yes, continental breakfast is included every morning from 7-10 AM. The room has a beautiful garden view and original Victorian details. Perfect for an anniversary!', '2024-03-05 10:15:00'),
('a50e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440004', 'Wonderful! We will book it right away. Any recommendations for romantic dinner spots nearby?', '2024-03-05 11:00:00'),
('a50e8400-e29b-41d4-a716-446655440016', '550e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440008', 'Absolutely! There is a fantastic French restaurant called Le Petit Bistro just 3 blocks away - very romantic with candlelit tables. I can make a reservation for you if you would like!', '2024-03-05 11:45:00');

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Verify data insertion
SELECT 'Users inserted:' as Info, COUNT(*) as Count FROM User
UNION ALL
SELECT 'Properties inserted:', COUNT(*) FROM Property
UNION ALL
SELECT 'Bookings inserted:', COUNT(*) FROM Booking
UNION ALL
SELECT 'Payments inserted:', COUNT(*) FROM Payment
UNION ALL
SELECT 'Reviews inserted:', COUNT(*) FROM Review
UNION ALL
SELECT 'Messages inserted:', COUNT(*) FROM Message;

-- Show sample data overview
SELECT 
    u.role,
    COUNT(*) as user_count
FROM User u 
GROUP BY u.role;

SELECT 
    b.status,
    COUNT(*) as booking_count,
    SUM(b.total_price) as total_revenue
FROM Booking b 
GROUP BY b.status;

SELECT 
    r.rating,
    COUNT(*) as review_count
FROM Review r 
GROUP BY r.rating 
ORDER BY r.rating;