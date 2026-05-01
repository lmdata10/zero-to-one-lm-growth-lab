#!/bin/bash
set -euo pipefail
# error-handling.sh
# Block 3 — Topic 7: Exit Codes and Error Handling
# Demonstrates set -euo pipefail, traps, and pipefail behaviour

# ------- Trap Setup -------─
tmpfile=$(mktemp)
echo "Temp file: $tmpfile"

trap 'echo "[$(date +%H:%M:%S)] $0 exiting - cleanup complete"; rm -f "$tmpfile"' EXIT
trap 'echo "[$(date +%H:%M:%S)] $0 interrupted"; exit 1' INT

# ------- set -u Demo -------
# Uncomment to test undefined variable behaviour
# echo "variable: $undefined"

# ------- set -e Demo -------
# Uncomment to test exit on failure
# echo "Before failure"
# cp /fake/nonexistent/file /tmp/
# echo "After failure"    # never runs with set -e

# ------- || true Demo -------
# Allow a command to fail without stopping the script
cp /fake/nonexistent/file /tmp/ || true

# ------- pipefail Demo -------
echo "--- Without pipefail ---"
bash -c 'ls /fake/path 2>/dev/null | cat; echo "Exit: $?"'

echo "--- With pipefail ---"
bash -c 'set -o pipefail; ls /fake/path 2>/dev/null | cat; echo "Exit: $?"'

# ------- Normal Work -------
echo "Working... (press Ctrl+C to interrupt)"
sleep 5

echo "done" > "$tmpfile"
cat "$tmpfile"