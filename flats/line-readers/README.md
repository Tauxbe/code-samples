# Pipe-Delimited Quoted File Line Readers

This directory contains example scripts in multiple languages to validate and parse a pipe-delimited, quoted text file. Each script checks that every row has the same number of tokens as the header row, even if delimiters appear inside quoted fields.

## Usage

All scripts accept a filename as a command line argument. If no filename is provided, they default to `ks_sor_kansas_sex_offender_registry_natcrim_snapshot_20250617.txt`.

---

### Bash

```sh
bash parser_example.sh ks_sor_kansas_sex_offender_registry_natcrim_snapshot_20250617.txt
```

---

### JavaScript (Node.js)

```sh
node parser_example.js ks_sor_kansas_sex_offender_registry_natcrim_snapshot_20250617.txt
```

---

### PHP

```sh
php parser_example.php ks_sor_kansas_sex_offender_registry_natcrim_snapshot_20250617.txt
```

---

### C#

Compile:
```sh
mcs ParserExample.cs
```

Run:
```sh
mono ParserExample.exe ks_sor_kansas_sex_offender_registry_natcrim_snapshot_20250617.txt
```

---

## Notes
- All scripts will print a warning if a row does not match the expected number of tokens.
- You can substitute any compatible pipe-delimited, quoted file as the argument.
