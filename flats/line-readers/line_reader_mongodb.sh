#!/bin/bash

# Example: Import a delimited file (pipe-delimited by default, or any delimiter) into MongoDB using mongoimport
# Usage: ./line_reader_mongodb.sh [filename] [delimiter]
# Default filename: flatfile_data.txt
# Default delimiter: |

FILE="${1:-flatfile_data.txt}"
DELIM="${2:-|}"


# mongoimport expects a CSV, so we convert the delimiter if needed
if [ "$DELIM" != "," ]; then
    TMPFILE="/tmp/$(basename "$FILE").csv"
    awk -v d="$DELIM" -v OFS="," 'BEGIN{FS=d} {for(i=1;i<=NF;i++) $i=$i; print $0}' "$FILE" > "$TMPFILE"
    FILE="$TMPFILE"
fi

# Import into MongoDB (edit --db and --collection as needed)
mongoimport --type csv --headerline --db testdb --collection flatfile --file "$FILE"

if [ -n "$TMPFILE" ]; then
    rm "$TMPFILE"
fi

# Notes:
# - Edit --db and --collection to match your MongoDB setup.
# - The script assumes the first row is a header.
# - For quoted fields with embedded delimiters, more advanced CSV parsing may be needed.
