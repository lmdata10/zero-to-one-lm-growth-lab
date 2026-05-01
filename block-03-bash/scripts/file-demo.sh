#!/bin/bash
set -euo pipefail
# file-demo.sh
# Block 3 — Topic 8: Working with Files
# Reads a file line by line and prints each line with a counter
# Usage: ./file-demo.sh <file-path>

# ------- Input Validation ------------------------
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <file-path>"
    exit 1
fi

# ------- Variables -------------------------
filepath="$1"

# ------- File Check ------------------------
if [[ ! -f "$filepath" || ! -r "$filepath" ]]; then
    echo "Error: file not found or not readable: $filepath"
    exit 1
fi

if [[ ! -s "$filepath" ]]; then
    echo "Warning: file is empty: $filepath"
    exit 0
fi

# ------- Read File Line by Line ------------------------
count=1
while IFS= read -r line; do    # IFS= preserves whitespace, -r prevents backslash interpretation
    echo "$count: $line"
    count=$((count + 1))
done < "$filepath"