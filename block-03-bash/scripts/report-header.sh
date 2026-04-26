#!/bin/bash
# report-header.sh
# Block 3 — Topic 2: Variables and Quoting Rules
# Generates a formatted report header from a hardcoded log file path
# Topic 3 will replace the hardcoded path with a command-line argument
# Block 3 — Topic 3: User Input and Positional Parameters
# Usage: ./report-header.sh <log-file-path> <environment>

# ─── Variables ──────────────────────────────────────────────────────
path="$1"
report=$(basename "$path")      # extracts filename from full path
location=$(dirname "$path")     # extracts directory from full path
date=$(date +"%Y-%m-%d")        # current date in YYYY-MM-DD format
environment="$2"                # environment name — prod / staging / dev
arg=$#                          # total arguments passed — used for validation in Topic 4

# ─── Output ─────────────────────────────────────────────────────────
echo "============================="
echo "Report:      $report"
echo "Location:    $location"
echo "Generated:   $date"
echo "Environment: $environment"
echo "Args passed: $arg"
echo "============================="