-- Check data types for all the tables used in booking
SELECT 
    t.TABLE_NAME,
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    CASE 
        WHEN c.DATA_TYPE = 'smallint' THEN 'short (Int16)'
        WHEN c.DATA_TYPE = 'int' THEN 'int (Int32)'
        WHEN c.DATA_TYPE = 'bigint' THEN 'long (Int64)'
        WHEN c.DATA_TYPE = 'tinyint' THEN 'byte'
        ELSE c.DATA_TYPE
    END AS CSharpType
FROM INFORMATION_SCHEMA.TABLES t
INNER JOIN INFORMATION_SCHEMA.COLUMNS c ON t.TABLE_NAME = c.TABLE_NAME
WHERE t.TABLE_NAME IN (
    'TransportService', 'PaymentMode', 'Location', 'Commodity', 
    'Equipment', 'Container', 'Vessel', 'Customer', 'Port',
    'LocationType', 'VesselSchedule'
)
AND c.COLUMN_NAME LIKE '%Id'
ORDER BY t.TABLE_NAME, c.ORDINAL_POSITION;
