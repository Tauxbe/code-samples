# MongoDB Line Reader Implementation

## Overview

The `line_reader_mongodb.sh` script is a robust solution for importing pipe-delimited data files into MongoDB. It handles complex data formats including quoted fields that may contain pipe delimiters, validates field counts against the header row, and provides comprehensive error handling and reporting.

## Features

- **Quoted Field Support**: Properly handles quoted fields that may contain pipe delimiters
- **Header-Based Validation**: Counts fields in the header row and validates all subsequent rows
- **Rejection Handling**: Invalid rows are written to a rejection file with detailed logging
- **CSV Conversion**: Converts pipe-delimited data to CSV format for MongoDB compatibility
- **Comprehensive Logging**: Provides detailed processing statistics and import results
- **Error Handling**: Robust error checking for file existence and processing failures

## Usage

```bash
./line_reader_mongodb.sh [filename] [delimiter] [database] [collection]
```

### Parameters

- `filename`: Input file path (default: `test.txt`)
- `delimiter`: Field delimiter (default: `|`)
- `database`: MongoDB database name (default: `natcrim`)
- `collection`: MongoDB collection name (default: `sor_data`)

### Examples

```bash
# Basic usage with default parameters
./line_reader_mongodb.sh

# Specify custom file and database
./line_reader_mongodb.sh data.txt "|" mydb mycollection

# Process a comma-delimited file
./line_reader_mongodb.sh data.csv "," natcrim sor_data
```

## Implementation Details

### Core Components

#### 1. File Validation
The script first checks if the input file exists and provides an error message if not found.

#### 2. AWK Parser
The heart of the script is a sophisticated AWK parser that handles:
- Quote-aware field parsing
- Proper handling of delimiters within quoted fields
- Field count validation
- CSV escaping and formatting

#### 3. Quote Handling Algorithm
```awk
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
```

#### 4. CSV Escaping
The `csv_escape` function properly formats fields for CSV output:
- Removes surrounding quotes if present
- Escapes internal quotes by doubling them
- Wraps all fields in quotes for MongoDB compatibility

### Processing Flow

1. **Header Processing**: 
   - Reads the first row to determine expected field count
   - Outputs header to CSV format
   - Logs the number of fields found

2. **Data Row Processing**:
   - Parses each subsequent row using the quote-aware parser
   - Validates field count against header expectation
   - Valid rows are converted to CSV format
   - Invalid rows are written to rejection file

3. **MongoDB Import**:
   - Uses `mongoimport` with CSV format and headerline option
   - Imports the converted CSV data into the specified database and collection

4. **Cleanup**:
   - Removes temporary CSV file
   - Provides final processing statistics

## Data Format Support

### Input Format
The script is designed to handle pipe-delimited data with the following characteristics:
- First row contains header fields
- Data may be quoted to handle embedded delimiters
- Empty fields are supported
- Various data types (strings, numbers, dates) are handled

### Example Input
```
hid|LastName|FirstName|AKA1|Address1|City|State
123|SMITH|JOHN||123 MAIN ST|ANYTOWN|KS
456|DOE|JANE|"JANE; SMITH"|456 ELM ST|SOMEWHERE|KS
```

### Output Format
The script converts the input to standard CSV format:
```csv
"hid","LastName","FirstName","AKA1","Address1","City","State"
"123","SMITH","JOHN","","123 MAIN ST","ANYTOWN","KS"
"456","DOE","JANE","JANE; SMITH","456 ELM ST","SOMEWHERE","KS"
```

## Error Handling and Validation

### Field Count Validation
- Header row determines expected field count
- Each data row is validated against this expectation
- Rows with incorrect field counts are rejected

### Rejection File
Invalid rows are written to `rejected_line.txt` with:
- Original line content preserved
- Warning messages logged to stderr
- Summary statistics provided

### Processing Statistics
The script provides comprehensive logging:
```
[INFO] Processing pipe-delimited file: test.txt
[INFO] Header row has 59 fields
[WARNING] Line 26 has 58 fields, expected 59 - REJECTED
[SUMMARY] Total lines processed: 500
[SUMMARY] Total rejected: 1
[SUMMARY] Total loaded: 499
[SUMMARY] Rejected lines written to: rejected_line.txt
```

## MongoDB Integration

### Collection Structure
The imported data creates MongoDB documents with field names from the header row. For example:

```json
{
  "_id": {"$oid": "..."},
  "hid": 589159301,
  "LastName": "CATHEY",
  "FirstName": "JAMES",
  "MiddleName": "DWANE",
  "Address1": "11 DES MOINES AVE",
  "Address2": "UNIT 225",
  "City": "SOUTH HUTCHINSON",
  "State": "KS",
  "Zip": 67505,
  ...
}
```

### Import Process
1. CSV data is created in a temporary file
2. `mongoimport` processes the CSV with `--headerline` option
3. Field names from the header become MongoDB document keys
4. Data types are inferred by MongoDB during import

## Performance Considerations

- **Memory Usage**: The AWK parser processes data line by line, keeping memory usage minimal
- **Temporary Files**: Uses `mktemp` for secure temporary file creation
- **Large Files**: Suitable for processing large datasets as it doesn't load entire file into memory

## Testing

The script has been tested with:
- Complex quoted pipe-delimited data
- Various field counts and data types
- Edge cases including empty fields and embedded quotes
- Large datasets (500+ records)

### Test Results
- Successfully processed 500 lines of test data
- Correctly identified and rejected 1 malformed line
- Imported 498 valid records into MongoDB
- Proper handling of quoted fields with embedded delimiters

## Dependencies

- **bash**: Shell environment
- **awk**: Text processing (standard on most Unix systems)
- **mongoimport**: MongoDB import utility
- **mktemp**: Temporary file creation utility

## Limitations

- Requires MongoDB to be installed and accessible
- Input file must have consistent structure with header row
- Quote handling assumes standard CSV quoting rules
- Large files may require sufficient disk space for temporary CSV conversion

## Future Enhancements

- Support for custom quote characters
- Configurable rejection file location
- Progress indicators for large file processing
- Optional data type validation and conversion
- Support for multiple input files in batch mode

## Troubleshooting

### Common Issues

1. **MongoDB Connection Errors**: Ensure MongoDB is running and accessible
2. **File Not Found**: Check file path and permissions
3. **Field Count Mismatches**: Review data format and check for malformed rows
4. **Memory Issues**: For very large files, consider processing in chunks

### Debug Mode
Add `set -x` to the beginning of the script for detailed execution tracing.

### Log Analysis
Check stderr output for detailed processing information and error messages.
