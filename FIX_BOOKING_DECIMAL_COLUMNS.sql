-- Fix DeclaredValue and Weight columns to be DECIMAL instead of INT
-- This will allow decimal values like 1500.50 instead of just whole numbers

-- First, check if there's any data that would be lost
SELECT 
    BookingId,
    DeclaredValue,
    Weight
FROM Booking
WHERE DeclaredValue IS NOT NULL OR Weight IS NOT NULL;

-- Alter the columns to DECIMAL(18,2)
-- DECIMAL(18,2) means: 18 total digits, 2 after decimal point
-- Example: 9999999999999999.99

ALTER TABLE Booking
ALTER COLUMN Weight DECIMAL(18,2) NULL;

ALTER TABLE Booking
ALTER COLUMN DeclaredValue DECIMAL(18,2) NULL;

-- Verify the changes
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Booking'
AND COLUMN_NAME IN ('DeclaredValue', 'Weight');

PRINT 'Columns updated successfully! Weight and DeclaredValue are now DECIMAL(18,2)';
