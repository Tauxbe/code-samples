const fs = require('fs');
const path = require('path');

const filePath = process.argv[2] ? path.resolve(process.argv[2]) : path.join(__dirname, 'ks_sor_kansas_sex_offender_registry_natcrim_snapshot_20250617.txt');

function parsePipeDelimitedQuoted(filePath) {
    const data = fs.readFileSync(filePath, 'utf8');
    const lines = data.split(/\r?\n/).filter(line => line.trim() !== '');
    if (lines.length === 0) {
        console.log('File is empty.');
        return;
    }
    // Use a regex to split on pipes not inside quotes
    const splitLine = (line) => {
        const regex = /\"([^\"]*)\"|[^|]+/g;
        let match;
        let tokens = [];
        let lastIndex = 0;
        let inQuotes = false;
        let current = '';
        for (let i = 0; i < line.length; i++) {
            const char = line[i];
            if (char === '"') {
                inQuotes = !inQuotes;
                current += char;
            } else if (char === '|' && !inQuotes) {
                tokens.push(current.replace(/^"|"$/g, ''));
                current = '';
            } else {
                current += char;
            }
        }
        tokens.push(current.replace(/^"|"$/g, ''));
        return tokens;
    };

    const header = splitLine(lines[0]);
    const numColumns = header.length;
    console.log('expecting:', numColumns, 'tokens');
    for (let i = 1; i < lines.length; i++) {
        const row = splitLine(lines[i]);
        if (row.length !== numColumns) {
            console.log(`Warning: Line ${i + 1} has ${row.length} tokens, expected ${numColumns}.`);
        } else {
            console.log(`Line ${i + 1} is valid with ${row.length} tokens.`);
            // Process the valid row as needed
        }
    }
}

parsePipeDelimitedQuoted(filePath);
