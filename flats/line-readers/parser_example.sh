#!/bin/bash
# Bash script to check if each line in a pipe-delimited, quoted file has the same number of tokens as the header
# Handles quoted fields with embedded delimiters using awk

FILE="${1:-flatfile_data.txt}"
DELIM="${2:-|}"

 # Get the expected number of columns from the header
expected_cols=$(awk -F"$DELIM" 'NR==1 {
    n=0
    s=$0
    inq=0
    for(i=1;i<=length(s);i++){
        c=substr(s,i,1)
        if(c=="\"") inq=!inq
        if(c=="|" && !inq) n++
    }
    print n+1
    exit
}' "$FILE")

echo "expecting: $expected_cols tokens"

awk -v expected_cols="$expected_cols" -v delim="$DELIM" '
BEGIN { FS = delim }
{
    n=0
    s=$0
    inq=0
    for(i=1;i<=length(s);i++){
        c=substr(s,i,1)
        if(c=="\"") inq=!inq
        if(c==delim && !inq) n++
    }
    cols=n+1
    if(NR==1) next
    if(cols != expected_cols) {
        print "Warning: Line " NR " has " cols " tokens, expected " expected_cols "."
    } else {
        print "Line " NR " is valid with " cols " tokens."
    }
}' "$FILE"
