#!/bin/bash

# Import a pipe-delimited file with quoted fields into MongoDB using mongoimport
# Handles pipes within quoted data and validates token count against header row

# Usage: ./line_reader_mongodb.sh [filename] [delimiter] [db] [collection]
# Default filename: test.txt
# Default delimiter: |
# Default db: natcrim
# Default collection: sor_data

FILE="${1:-test.txt}"
DELIM="${2:-|}"
DB="${3:-natcrim}"
COLLECTION="${4:-sor_data}"

# Check if input file exists
if [ ! -f "$FILE" ]; then
    echo "[ERROR] Input file '$FILE' not found!" >&2
    exit 1
fi

echo "[INFO] Processing pipe-delimited file: $FILE" >&2
echo "[INFO] Converting to CSV format for MongoDB import..." >&2

# Always convert to CSV since we need to handle quoted pipe-delimited data
TMPFILE=$(mktemp /tmp/line_reader_mongodb.XXXXXX.csv)
REJECTED="rejected_line.txt"
> "$REJECTED"

# AWK script to parse pipe-delimited data with proper quote handling
awk -v delim="$DELIM" -v rejected="$REJECTED" '
function csv_escape(str) {
    # Remove surrounding quotes if present, then escape internal quotes and wrap in quotes
    if (str ~ /^".*"$/) {
        str = substr(str, 2, length(str) - 2);
    }
    gsub(/"/, "\"\"", str);
    return "\"" str "\"";
}

function parse_line(line) {
    # Parse a line respecting quoted fields
    delete fields;
    fields_count = 0;
    current_field = "";
    in_quotes = 0;
    i = 1;
    
    while (i <= length(line)) {
        char = substr(line, i, 1);
        
        if (char == "\"") {
            in_quotes = !in_quotes;
            current_field = current_field char;
        } else if (char == delim && !in_quotes) {
            # End of field
            fields[++fields_count] = current_field;
            current_field = "";
        } else {
            current_field = current_field char;
        }
        i++;
    }
    
    # Add the last field
    fields[++fields_count] = current_field;
    return fields_count;
}

BEGIN { 
    OFS = ","; 
    total_lines = 0; 
    rejected_count = 0; 
    loaded_count = 0; 
    expected_fields = 0;
}

{
    total_lines++;
    field_count = parse_line($0);
    
    if (NR == 1) {
        # Header row - determine expected field count
        expected_fields = field_count;
        printf "[INFO] Header row has %d fields\n", expected_fields > "/dev/stderr";
        
        # Output header row to CSV
        for (j = 1; j <= field_count; j++) {
            printf "%s%s", csv_escape(fields[j]), (j < field_count ? OFS : ORS);
        }
        loaded_count++;
    } else {
        # Data row - validate field count
        if (field_count != expected_fields) {
            printf "[WARNING] Line %d has %d fields, expected %d - REJECTED\n", NR, field_count, expected_fields > "/dev/stderr";
            print $0 >> rejected;
            rejected_count++;
        } else {
            # Output valid data row to CSV
            for (j = 1; j <= field_count; j++) {
                printf "%s%s", csv_escape(fields[j]), (j < field_count ? OFS : ORS);
            }
            loaded_count++;
        }
    }
}

END {
    printf "\n[SUMMARY] Total lines processed: %d\n", total_lines > "/dev/stderr";
    printf "[SUMMARY] Total rejected: %d\n", rejected_count > "/dev/stderr";
    printf "[SUMMARY] Total loaded: %d\n", loaded_count > "/dev/stderr";
    if (rejected_count > 0) {
        printf "[SUMMARY] Rejected lines written to: %s\n", rejected > "/dev/stderr";
    }
}
' "$FILE" > "$TMPFILE"

# Check if CSV conversion was successful
if [ $? -eq 0 ]; then
    echo "[INFO] CSV conversion completed successfully" >&2
    echo "[INFO] Importing into MongoDB database: $DB, collection: $COLLECTION" >&2
    
    # Import into MongoDB
    mongoimport --type csv --headerline --db "$DB" --collection "$COLLECTION" --file "$TMPFILE"
    
    if [ $? -eq 0 ]; then
        echo "[INFO] MongoDB import completed successfully" >&2
    else
        echo "[ERROR] MongoDB import failed" >&2
        exit 1
    fi
else
    echo "[ERROR] CSV conversion failed" >&2
    exit 1
fi

# Clean up temporary file
rm "$TMPFILE"

# Notes:
# - This script properly handles quoted pipe-delimited data
# - Field count validation is performed against the header row
# - Rejected rows are written to rejected_line.txt
# - The script assumes the first row is a header
