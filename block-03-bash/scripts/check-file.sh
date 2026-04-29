#!/bin/bash
# check-file.sh
# Block 3 — Topic 4: Conditionals
# Checks whether a path is a regular file, a directory, or does not exist
# Usage: ./check-file.sh <path>

# ====== Input Validation =============
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <log-file-path>"
    exit 1
fi

# ====== Variables =============
path="$1"

# ====== File Check =============
if [[ -f "$path" ]]; then
    echo "File exists: $path"
elif [[ -d "$path" ]]; then
    echo "Directory exists: $path"
else
    echo "File not found: $path"
fi