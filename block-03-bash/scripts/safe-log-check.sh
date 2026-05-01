#!/bin/bash
set -euo pipefail

# ------- Input Validation -------
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <log-file-path>"
    exit 1
fi

# ------- Variables -------
logfilepath="$1"
tmpfile=$(mktemp)
echo "Temp file: $tmpfile"

# ------- Trap — cleanup on any exit -------
trap 'echo "[$(date +%H:%M:%S)] $0 exiting - cleanup complete"; rm -f "$tmpfile"' EXIT

# ------- File Check -------
# Required because if suppresses set -e — grep inside if won't stop the script
if [[ ! -f "$logfilepath" ]]; then
    echo "Error: file not found: $logfilepath"
    exit 1
fi

# ------- Grep and Report -------
if grep -i "error" "$logfilepath" > "$tmpfile"; then
    echo "Errors found:"
    cat "$tmpfile"
else
    echo "No errors found"
fi

exit 0