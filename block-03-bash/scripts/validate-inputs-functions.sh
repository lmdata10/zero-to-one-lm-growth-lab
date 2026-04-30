#!/bin/bash
# validate-inputs-functions.sh
# Block 3 — Topic 6: Functions
# Refactored validate-inputs.sh — all logic in functions, main body is four calls
# Usage: ./validate-inputs-functions.sh <file-path> <environment>

# ----- validate_args ----------
validate_args() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: $0 <file-path> <environment>"
        exit 1
    fi
}

# ----- validate_file ----------
validate_file() {
    local path="$1"
    if [[ ! -f "$path" ]]; then
        echo "Error: file not found: $path"
        exit 1
    fi
}

# ----- validate_env ----------
validate_env() {
    local env="$1"
    if [[ "$env" == "prod" || "$env" == "staging" || "$env" == "dev" ]]; then
        if [[ "$env" == "prod" ]]; then
            echo "Warning: you are targeting production"
        fi
    else
        echo "Error: unknown environment '$env'"
        exit 1
    fi
}

# ----- print_summary ----------
print_summary() {
    local path="$1"
    local env="$2"
    echo "============================="
    echo "File:        $path"
    echo "Environment: $env"
    echo "Status:      all checks passed"
    echo "============================="
}

# ----- Main ----------
validate_args "$@"

path="$1"
env="$2"

validate_file "$path"
validate_env "$env"
print_summary "$path" "$env"