# Quoted File Line Readers

This directory contains example scripts in multiple languages to validate and parse a pipe-delimited, quoted text file. Each script checks that every row has the same number of tokens as the header row, even if delimiters appear inside quoted fields.

## Usage

All scripts accept a filename as a command line argument. If no filename is provided, they default to `flatfile_data.txt`.

---

### Bash

```sh
bash parser_example.sh flatfile_data.txt
```

---

### JavaScript (Node.js)

```sh
node parser_example.js flatfile_data.txt
```

---

### PHP

```sh
php parser_example.php flatfile_data.txt
```

---

### C#

Compile:
```sh
mcs ParserExample.cs
```

Run:
```sh
mono ParserExample.exe flatfile_data.txt
```

---

### Emacs Lisp

1. Open `line_reader_emacs.el` in Emacs.
2. Run:
   - `M-x eval-buffer`
   - `M-x line-reader-check-file` and select your `flatfile_data.txt` file.

---

### PostgreSQL

In psql or a SQL script:
```sql
\i line_reader_postgresql.sql
```

---

### SQL Server (MSSQL)

In SQL Server Management Studio or sqlcmd:
```sql
-- Edit the file path and table name as needed
:r line_reader_mssql.sql
```

---

### MongoDB

```sh
# Usage: ./line_reader_mongodb.sh [filename] [delimiter] [db] [collection]
# Default filename: flatfile_data.txt
# Default delimiter: |
# Default db: natcrim
# Default collection: sor_data
./line_reader_mongodb.sh
./line_reader_mongodb.sh mydata.csv , mydb mycollection
```

---

## Notes
- All scripts will print a warning if a row does not match the expected number of tokens.
- You can substitute any compatible delimited, quoted file as the argument.
