-- AirBnB Database Advanced Scripts - Table Partitioning Implementation
-- File: partitioning.sql

USE airbnb_db;

-- ================================================================
-- PARTITIONING ANALYSIS AND PREPARATION
-- ================================================================

-- First, let's analyze the current Booking table structure
DESCRIBE Booking;

-- Check current table size and row distribution
SELECT 
    COUNT(*) as total_bookings,
    MIN(start_date) as earliest_booking,
    MAX(start_date) as latest_booking,
    YEAR(MIN(start_date)) as min_year,
    YEAR(MAX(start_date)) as max_year
FROM Booking;

-- Analyze booking distribution by year and month
SELECT 
    YEAR(start_date) as booking_year,
    MONTH(start_date) as booking_month,
    COUNT(*) as bookings_count,
    SUM(total_price) as total_revenue
FROM Booking
GROUP BY YEAR(start_date), MONTH(start_date)
ORDER BY booking_year, booking_month;

-- ================================================================
-- BACKUP EXISTING DATA BEFORE PARTITIONING
-- ================================================================

-- Create backup table with all existing data
CREATE TABLE Booking_backup AS
SELECT * FROM Booking;

-- Verify backup
SELECT COUNT(*) as backup_count FROM Booking_backup;

-- ================================================================
-- DROP EXISTING FOREIGN KEY CONSTRAINTS
-- ================================================================

-- We need to temporarily drop foreign keys to recreate the table with partitioning
-- First, identify all foreign key constraints on Booking table

SELECT 
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'airbnb_db' 
    AND TABLE_NAME = 'Booking'
    AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Drop foreign key constraints
ALTER TABLE Payment DROP FOREIGN KEY payment_ibfk_1;
ALTER TABLE Booking DROP FOREIGN KEY booking_ibfk_1;
ALTER TABLE Booking DROP FOREIGN KEY booking_ibfk_2;

-- ================================================================
-- CREATE PARTITIONED BOOKING TABLE
-- ================================================================

-- Drop the existing table (data is safe in backup)
DROP TABLE Booking;

-- Create new partitioned Booking table
-- Partitioned by RANGE on start_date (monthly partitions)
CREATE TABLE Booking (
    booking_id CHAR(36) NOT NULL DEFAULT (UUID()),
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price > 0),
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (booking_id, start_date),  -- Composite key including partition key
    
    -- Check constraint to ensure end_date is after start_date
    CONSTRAINT chk_booking_dates CHECK (end_date > start_date),
    
    -- Indexes (will be created on each partition)
    INDEX idx_booking_property_id (property_id),
    INDEX idx_booking_user_id (user_id),
    INDEX idx_booking_dates (start_date, end_date),
    INDEX idx_booking_status (status),
    INDEX idx_booking_created (created_at)
)
PARTITION BY RANGE (YEAR(start_date) * 100 + MONTH(start_date)) (
    -- Historical partitions (2023)
    PARTITION p202301 VALUES LESS THAN (202302),  -- Jan 2023
    PARTITION p202302 VALUES LESS THAN (202303),  -- Feb 2023
    PARTITION p202303 VALUES LESS THAN (202304),  -- Mar 2023
    PARTITION p202304 VALUES LESS THAN (202305),  -- Apr 2023
    PARTITION p202305 VALUES LESS THAN (202306),  -- May 2023
    PARTITION p202306 VALUES LESS THAN (202307),  -- Jun 2023
    PARTITION p202307 VALUES LESS THAN (202308),  -- Jul 2023
    PARTITION p202308 VALUES LESS THAN (202309),  -- Aug 2023
    PARTITION p202309 VALUES LESS THAN (202310),  -- Sep 2023
    PARTITION p202310 VALUES LESS THAN (202311),  -- Oct 2023
    PARTITION p202311 VALUES LESS THAN (202312),  -- Nov 2023
    PARTITION p202312 VALUES LESS THAN (202401),  -- Dec 2023
    
    -- Current year partitions (2024)
    PARTITION p202401 VALUES LESS THAN (202402),  -- Jan 2024
    PARTITION p202402 VALUES LESS THAN (202403),  -- Feb 2024
    PARTITION p202403 VALUES LESS THAN (202404),  -- Mar 2024
    PARTITION p202404 VALUES LESS THAN (202405),  -- Apr 2024
    PARTITION p202405 VALUES LESS THAN (202406),  -- May 2024
    PARTITION p202406 VALUES LESS THAN (202407),  -- Jun 2024
    PARTITION p202407 VALUES LESS THAN (202408),  -- Jul 2024
    PARTITION p202408 VALUES LESS THAN (202409),  -- Aug 2024
    PARTITION p202409 VALUES LESS THAN (202410),  -- Sep 2024
    PARTITION p202410 VALUES LESS THAN (202411),  -- Oct 2024
    PARTITION p202411 VALUES LESS THAN (202412),  -- Nov 2024
    PARTITION p202412 VALUES LESS THAN (202501),  -- Dec 2024
    
    -- Future partitions (2025)
    PARTITION p202501 VALUES LESS THAN (202502),  -- Jan 2025
    PARTITION p202502 VALUES LESS THAN (202503),  -- Feb 2025
    PARTITION p202503 VALUES LESS THAN (202504),  -- Mar 2025
    PARTITION p202504 VALUES LESS THAN (202505),  -- Apr 2025
    PARTITION p202505 VALUES LESS THAN (202506),  -- May 2025
    PARTITION p202506 VALUES LESS THAN (202507),  -- Jun 2025
    PARTITION p202507 VALUES LESS THAN (202508),  -- Jul 2025
    PARTITION p202508 VALUES LESS THAN (202509),  -- Aug 2025
    PARTITION p202509 VALUES LESS THAN (202510),  -- Sep 2025
    PARTITION p202510 VALUES LESS THAN (202511),  -- Oct 2025
    PARTITION p202511 VALUES LESS THAN (202512),  -- Nov 2025
    PARTITION p202512 VALUES LESS THAN (202601),  -- Dec 2025
    
    -- Catch-all partition for future dates
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- ================================================================
-- RESTORE DATA TO PARTITIONED TABLE
-- ================================================================

-- Insert data back from backup
INSERT INTO Booking 
SELECT * FROM Booking_backup;

-- Verify data restoration
SELECT COUNT(*) as restored_count FROM Booking;

-- Check partition distribution
SELECT 
    PARTITION_NAME,
    TABLE_ROWS,
    AVG_ROW_LENGTH,
    DATA_LENGTH,
    MAX_DATA_LENGTH,
    INDEX_LENGTH
FROM information_schema.PARTITIONS 
WHERE TABLE_SCHEMA = 'airbnb_db' 
    AND TABLE_NAME = 'Booking'
    AND PARTITION_NAME IS NOT NULL
ORDER BY PARTITION_NAME;

-- ================================================================
-- RECREATE FOREIGN KEY CONSTRAINTS
-- ================================================================

-- Add foreign key constraints back
ALTER TABLE Booking 
ADD CONSTRAINT fk_booking_property 
FOREIGN KEY (property_id) REFERENCES Property(property_id) 
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Booking 
ADD CONSTRAINT fk_booking_user 
FOREIGN KEY (user_id) REFERENCES User(user_id) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Recreate Payment table foreign key
ALTER TABLE Payment 
ADD CONSTRAINT fk_payment_booking 
FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- ================================================================
-- PARTITION MAINTENANCE PROCEDURES
-- ================================================================

-- Procedure to add new monthly partitions automatically
DELIMITER //
CREATE PROCEDURE AddMonthlyPartition(IN target_year INT, IN target_month INT)
BEGIN
    DECLARE partition_name VARCHAR(20);
    DECLARE next_value INT;
    DECLARE sql_stmt TEXT;
    
    -- Calculate partition name and next value
    SET partition_name = CONCAT('p', target_year, LPAD(target_month, 2, '0'));
    SET next_value = target_year * 100 + target_month + 1;
    
    -- Handle December to January transition
    IF target_month = 12 THEN
        SET next_value = (target_year + 1) * 100 + 1;
    END IF;
    
    -- Create the SQL statement
    SET sql_stmt = CONCAT(
        'ALTER TABLE Booking REORGANIZE PARTITION p_future INTO (',
        'PARTITION ', partition_name, ' VALUES LESS THAN (', next_value, '),',
        'PARTITION p_future VALUES LESS THAN MAXVALUE)'
    );
    
    -- Execute the statement
    SET @sql = sql_stmt;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SELECT CONCAT('Added partition ', partition_name, ' successfully') as result;
END //
DELIMITER ;

-- Procedure to drop old partitions (for data retention)
DELIMITER //
CREATE PROCEDURE DropOldPartitions(IN months_to_keep INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE partition_name VARCHAR(20);
    DECLARE partition_date INT;
    DECLARE cutoff_date INT;
    DECLARE sql_stmt TEXT;
    
    -- Calculate cutoff date (YYYYMM format)
    SET cutoff_date = (YEAR(DATE_SUB(NOW(), INTERVAL months_to_keep MONTH)) * 100) + 
                      MONTH(DATE_SUB(NOW(), INTERVAL months_to_keep MONTH));
    
    -- Cursor for old partitions
    DECLARE partition_cursor CURSOR FOR
        SELECT PARTITION_NAME, 
               CAST(SUBSTRING(PARTITION_NAME, 2) AS UNSIGNED) as partition_date
        FROM information_schema.PARTITIONS 
        WHERE TABLE_SCHEMA = 'airbnb_db' 
            AND TABLE_NAME = 'Booking'
            AND PARTITION_NAME IS NOT NULL
            AND PARTITION_NAME != 'p_future'
            AND CAST(SUBSTRING(PARTITION_NAME, 2) AS UNSIGNED) < cutoff_date;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN partition_cursor;
    
    drop_loop: LOOP
        FETCH partition_cursor INTO partition_name, partition_date;
        
        IF done THEN
            LEAVE drop_loop;
        END IF;
        
        -- Drop the partition
        SET sql_stmt = CONCAT('ALTER TABLE Booking DROP PARTITION ', partition_name);
        SET @sql = sql_stmt;
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        SELECT CONCAT('Dropped partition ', partition_name) as result;
    END LOOP;
    
    CLOSE partition_cursor;
END //
DELIMITER ;

-- ================================================================
-- PERFORMANCE TESTING QUERIES
-- ================================================================

-- Test 1: Query specific month (should use single partition)
EXPLAIN PARTITIONS
SELECT COUNT(*) 
FROM Booking 
WHERE start_date >= '2024-03-01' AND start_date < '2024-04-01';

-- Test 2: Query date range spanning multiple months
EXPLAIN PARTITIONS
SELECT b.booking_id, b.start_date, b.end_date, b.total_price
FROM Booking b
WHERE start_date BETWEEN '2024-02-15' AND '2024-04-15';

-- Test 3: Query without date filter (should scan all partitions)
EXPLAIN PARTITIONS
SELECT COUNT(*)
FROM Booking
WHERE status = 'confirmed';

-- Test 4: Query with property filter and date range
EXPLAIN PARTITIONS
SELECT b.booking_id, b.start_date, b.end_date
FROM Booking b
WHERE b.property_id = '650e8400-e29b-41d4-a716-446655440001'
    AND b.start_date >= '2024-01-01'
    AND b.start_date < '2024-07-01';

-- ================================================================
-- PARTITION PRUNING DEMONSTRATION
-- ================================================================

-- Show which partitions are accessed for different queries

-- Query 1: Single month - should access only one partition
SELECT 'Single Month Query' as query_type;
EXPLAIN PARTITIONS
SELECT booking_id, total_price 
FROM Booking 
WHERE start_date >= '2024-03-01' AND start_date <= '2024-03-31';

-- Query 2: Quarter - should access three partitions
SELECT 'Quarterly Query' as query_type;
EXPLAIN PARTITIONS
SELECT SUM(total_price) as quarterly_revenue
FROM Booking 
WHERE start_date >= '2024-01-01' AND start_date <= '2024-03-31'
    AND status = 'confirmed';

-- Query 3: Year - should access 12 partitions
SELECT 'Yearly Query' as query_type;
EXPLAIN PARTITIONS
SELECT COUNT(*) as yearly_bookings
FROM Booking 
WHERE start_date >= '2024-01-01' AND start_date <= '2024-12-31';

-- ================================================================
-- BENCHMARK QUERIES FOR PERFORMANCE COMPARISON
-- ================================================================

-- Enable query profiling
SET profiling = 1;

-- Benchmark 1: Monthly revenue report (benefits from partitioning)
SELECT 
    YEAR(start_date) as year,
    MONTH(start_date) as month,
    COUNT(*) as bookings,
    SUM(total_price) as revenue
FROM Booking
WHERE start_date >= '2024-01-01' AND start_date <= '2024-12-31'
    AND status = 'confirmed'
GROUP BY YEAR(start_date), MONTH(start_date)
ORDER BY year, month;

-- Benchmark 2: Property availability check for specific dates
SELECT COUNT(*) as conflicts
FROM Booking
WHERE property_id = '650e8400-e29b-41d4-a716-446655440001'
    AND status IN ('confirmed', 'pending')
    AND start_date <= '2024-07-15'
    AND end_date >= '2024-07-10';

-- Benchmark 3: User booking history for date range
SELECT booking_id, start_date, end_date, total_price, status
FROM Booking
WHERE user_id = '550e8400-e29b-41d4-a716-446655440005'
    AND start_date >= '2024-01-01'
ORDER BY start_date DESC;

-- Check performance profiles
SHOW PROFILES;
SET profiling = 0;

-- ================================================================
-- PARTITION STATISTICS AND MONITORING
-- ================================================================

-- View partition information
SELECT 
    PARTITION_NAME,
    PARTITION_ORDINAL_POSITION,
    PARTITION_METHOD,
    PARTITION_EXPRESSION,
    PARTITION_DESCRIPTION,
    TABLE_ROWS,
    AVG_ROW_LENGTH,
    DATA_LENGTH/1024/1024 as data_mb,
    INDEX_LENGTH/1024/1024 as index_mb,
    (DATA_LENGTH + INDEX_LENGTH)/1024/1024 as total_mb
FROM information_schema.PARTITIONS 
WHERE TABLE_SCHEMA = 'airbnb_db' 
    AND TABLE_NAME = 'Booking'
    AND PARTITION_NAME IS NOT NULL
ORDER BY PARTITION_ORDINAL_POSITION;

-- Monitor partition pruning effectiveness
CREATE OR REPLACE VIEW v_partition_usage AS
SELECT 
    DATE_FORMAT(start_date, '%Y-%m') as month,
    COUNT(*) as bookings_count,
    SUM(total_price) as total_revenue,
    AVG(total_price) as avg_booking_value,
    MIN(start_date) as first_booking,
    MAX(start_date) as last_booking
FROM Booking
GROUP BY DATE_FORMAT(start_date, '%Y-%m')
ORDER BY month;

-- Query the partition usage view
SELECT * FROM v_partition_usage;

-- ================================================================
-- MAINTENANCE AUTOMATION
-- ================================================================

-- Create event scheduler to automatically add future partitions
-- This will run monthly to add the next month's partition

DELIMITER //
CREATE EVENT IF NOT EXISTS evt_add_monthly_partition
ON SCHEDULE EVERY 1 MONTH
STARTS LAST_DAY(CURDATE()) + INTERVAL 1 DAY
DO BEGIN
    DECLARE next_year INT;
    DECLARE next_month INT;
    
    -- Calculate next month
    SET next_year = YEAR(DATE_ADD(CURDATE(), INTERVAL 2 MONTH));
    SET next_month = MONTH(DATE_ADD(CURDATE(), INTERVAL 2 MONTH));
    
    -- Add the partition
    CALL AddMonthlyPartition(next_year, next_month);
END //
DELIMITER ;

-- Enable event scheduler (if not already enabled)
SET GLOBAL event_scheduler = ON;

-- ================================================================
-- CLEANUP AND VERIFICATION
-- ================================================================

-- Clean up backup table after successful partitioning
-- DROP TABLE Booking_backup;

-- Final verification queries
SELECT 'Partitioning Setup Complete' as status;

SELECT 
    COUNT(*) as total_bookings,
    COUNT(DISTINCT CONCAT(YEAR(start_date), '-', MONTH(start_date))) as months_with_data
FROM Booking;

-- Show partition distribution
SELECT 
    PARTITION_NAME,
    TABLE_ROWS as row_count,
    ROUND((DATA_LENGTH + INDEX_LENGTH)/1024/1024, 2) as size_mb
FROM information_schema.PARTITIONS 
WHERE TABLE_SCHEMA = 'airbnb_db' 
    AND TABLE_NAME = 'Booking'
    AND PARTITION_NAME IS NOT NULL
    AND TABLE_ROWS > 0
ORDER BY PARTITION_NAME;