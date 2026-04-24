#!/bin/bash
# report-header.sh
# Block 3 — Topic 2: Variables and Quoting Rules
# Generates a formatted report header from a hardcoded log file path
# Topic 3 will replace the hardcoded path with a command-line argument

# ─── Variables ──────────────────────────────────────────────────────
path="/var/log/messages"
report=$(basename "$path")      # extracts filename from full path
location=$(dirname "$path")     # extracts directory from full path
date=$(date +"%Y-%m-%d")        # current date in YYYY-MM-DD format

# ─── Output ─────────────────────────────────────────────────────────
echo "============================="
echo "Report:    $report"
echo "Location:  $location"
echo "Generated: $date"
echo "============================="