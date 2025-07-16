-- PostgreSQL COPY example for importing a pipe-delimited, quoted file
-- Adjust the table name and column list as needed

COPY your_table_name (column1, column2, ...)
FROM '/absolute/path/to/flatfile_data.txt'
WITH (
    FORMAT csv,
    DELIMITER '|',
    HEADER true,
    QUOTE '"',
    ESCAPE '"'
);

-- Notes:
-- 1. Replace your_table_name and the column list with your actual table and columns.
-- 2. The file path must be absolute and accessible to the PostgreSQL server process.
-- 3. If running from a client, use \copy instead of COPY and provide a local path.
-- 4. The HEADER true option skips the first row (header).
-- 5. QUOTE and ESCAPE are set to handle quoted fields and embedded delimiters.
