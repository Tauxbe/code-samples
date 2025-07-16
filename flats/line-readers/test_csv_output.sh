#!/bin/bash

# Test script to show CSV output without MongoDB import
# Usage: ./test_csv_output.sh [filename]

FILE="${1:-test_quoted.txt}"
DELIM="${2:-|}"

if [ ! -f "$FILE" ]; then
    echo "[ERROR] Input file '$FILE' not found!" >&2
    exit 1
fi

echo "[INFO] Processing pipe-delimited file: $FILE" >&2

# AWK script to parse pipe-delimited data with proper quote handling
awk -v delim="$DELIM" '
function csv_escape(str) {
    if (str ~ /^".*"$/) {
        str = substr(str, 2, length(str) - 2);
    }
    gsub(/"/, "\"\"", str);
    return "\"" str "\"";
}

function parse_line(line) {
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
            fields[++fields_count] = current_field;
            current_field = "";
        } else {
            current_field = current_field char;
        }
        i++;
    }
    
    fields[++fields_count] = current_field;
    return fields_count;
}

BEGIN { OFS = "," }

{
    field_count = parse_line($0);
    
    if (NR == 1) {
        expected_fields = field_count;
        printf "[INFO] Header row has %d fields\n", expected_fields > "/dev/stderr";
    }
    
    for (j = 1; j <= field_count; j++) {
        printf "%s%s", csv_escape(fields[j]), (j < field_count ? OFS : ORS);
    }
}
' "$FILE"
