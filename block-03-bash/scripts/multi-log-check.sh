#!/bin/bash
# multi-log-check.sh
# Block 3 — Topic 5: Loops
# Checks existence of multiple log files passed as arguments
# Usage: ./multi-log-check.sh <log_file1> <log_file2> ...

# ------- Input Validation --------------
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <log_file1> <log_file2> ..."
    exit 1
fi

# ------- Variables --------------
total=0
missing=0

# ------- File Check Loop --------------
for path in "$@"; do
    if [[ -f "$path" ]]; then
        echo "OK: $path"
    else
        echo "MISSING: $path"
        missing=$((missing + 1))
    fi
    total=$((total + 1))
done

# ------- Summary --------------
echo "============================="
echo "Total Files Checked: $total"
echo "Total Files Missing: $missing"
echo "============================="
exit 0