-- SQL Server (MSSQL) BULK INSERT example for importing a pipe-delimited, quoted file
-- Adjust the table name and column list as needed

BULK INSERT dbo.YourTableName
FROM 'C:\path\to\flatfile_data.txt'
WITH (
    FIRSTROW = 2, -- Skip header row
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '\n',
    FORMAT = 'CSV',
    TEXTQUALIFIER = '"',
    TABLOCK
);

-- Notes:
-- 1. Replace dbo.YourTableName with your actual table name.
-- 2. The FORMAT = 'CSV' and TEXTQUALIFIER = '"' options require SQL Server 2022 or later.
--    For earlier versions, use a format file or preprocess the file to remove quotes.
-- 3. Ensure the SQL Server service account has access to the file path.
-- 4. If your file uses Windows line endings, you may need ROWTERMINATOR = '\r\n'.
