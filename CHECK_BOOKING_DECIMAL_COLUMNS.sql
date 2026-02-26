-- Check the data types of DeclaredValue and Weight columns in Booking table
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Booking'
AND COLUMN_NAME IN ('DeclaredValue', 'Weight');
