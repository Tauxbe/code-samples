<?php
// PHP script to check if each line in a delimited, quoted file has the same number of tokens as the header
$file = $argc > 1 ? $argv[1] : 'flatfile_data.txt';
$delimiter = $argc > 2 ? $argv[2] : '|';

if (!file_exists($file)) {
    echo "File not found: $file\n";
    exit(1);
}

$handle = fopen($file, 'r');
if (!$handle) {
    echo "Could not open file: $file\n";
    exit(1);
}

// Read header row
$header = fgetcsv($handle, 0, $delimiter, '"');
$numColumns = count($header);
echo "expecting: $numColumns tokens\n";

$lineNum = 2; // Data starts at line 2
while (($row = fgetcsv($handle, 0, $delimiter, '"')) !== false) {
    $numTokens = count($row);
    if ($numTokens !== $numColumns) {
        echo "Warning: Line $lineNum has $numTokens tokens, expected $numColumns.\n";
    } else {
        echo "Line $lineNum is valid with $numTokens tokens.\n";
        // Process the valid row as needed
    }
    $lineNum++;
}

fclose($handle);
