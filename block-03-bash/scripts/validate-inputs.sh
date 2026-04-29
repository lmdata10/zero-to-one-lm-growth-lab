#!/bin/bash
# validate-inputs.sh
# Block 3 — Topic 4: Conditionals
# Validates log file path and environment name before any processing
# Usage: ./validate-inputs.sh <file-path> <environment>

# ========= Input Validation ===============
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <file-path> <environment>"
    exit 1
fi

# =========== Variables ======================
path="$1"
env="$2"

# =========== File Check ======================
if [[ ! -f "$path" ]]; then
    echo "Error: file not found: $path"
    exit 1
fi

# =========== Environment Check ======================
if [[ $env == "prod" || $env == "staging" || $env == "dev" ]]; then
    if [[ $env == "prod" ]]; then
        echo "Warning: you are targeting production"
    fi
else
    echo "Error: unknown environment '$env'"
    exit 1
fi

# =========== Summary ======================
echo "============================="
echo "File:        $path"
echo "Environment: $env"
echo "Status:      all checks passed"
echo "============================="
exit 0