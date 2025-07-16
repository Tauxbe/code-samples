import csv
import sys

# Usage: python line_reader.py [filename] [delimiter]
# Default filename: flatfile_data.txt
# Default delimiter: |

def main():
    file_path = sys.argv[1] if len(sys.argv) > 1 else "flatfile_data.txt"
    delimiter = sys.argv[2] if len(sys.argv) > 2 else '|'

    with open(file_path, newline='', encoding='utf-8') as f:
        reader = csv.reader(f, delimiter=delimiter, quotechar='"')
        header = next(reader)
        num_columns = len(header)
        print(f"expecting: {num_columns} tokens")
        for i, row in enumerate(reader, start=2):  # start=2 to account for header row
            if len(row) != num_columns:
                print(f"Warning: Line {i} has {len(row)} tokens, expected {num_columns}.")
            else:
                print(f"Line {i} is valid with {len(row)} tokens.")
                # Process the valid row as needed

if __name__ == "__main__":
    main()
