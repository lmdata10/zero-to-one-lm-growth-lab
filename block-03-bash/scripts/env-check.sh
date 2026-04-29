#!/bin/bash
# env-check.sh
# Block 3 — Topic 4: Conditionals
# Validates that the argument is a known environment name
# Usage: ./env-check.sh <environment>

# ========= Input Validation ===============
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

# ========= Variables ===============
env="$1"

# ========= Environment Check ===============
if [[ $env == "prod" || $env == "staging" || $env == "dev" ]]; then
    echo "Valid environment: $env"
    if [[ $env == "prod" ]]; then
        echo "Warning: you are targeting production"
    fi
else
    echo "Error: unknown environment '$env'"
    exit 1
fi