-- Oracle SQL*Loader control file for importing a pipe-delimited, quoted file
-- Save this as line_reader_oracle.ctl and adjust table/column names as needed

LOAD DATA
INFILE 'flatfile_data.txt'
BADFILE 'flatfile_data.bad'
DISCARDFILE 'flatfile_data.dsc'
INTO TABLE your_table_name
FIELDS TERMINATED BY '|'
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    column1,
    column2,
    -- ... add all columns in order ...
)

-- Notes:
-- 1. Replace your_table_name and the column list with your actual table and columns.
-- 2. The file must be accessible to the Oracle server or client running SQL*Loader.
-- 3. To run: sqlldr username/password@db control=line_reader_oracle.ctl
-- 4. The OPTIONALLY ENCLOSED BY '"' handles quoted fields and embedded delimiters.
-- 5. TRAILING NULLCOLS allows missing columns at the end of a row to be set to NULL.
