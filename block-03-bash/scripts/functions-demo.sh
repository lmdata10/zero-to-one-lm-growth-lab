#!/bin/bash
# functions-demo.sh
# Block 3 — Topic 6: Functions
# Demonstrates function definition, arguments, return codes, output capture, and local scope

# -------- print_header ------------
print_header() {
    echo "============================="
    echo "$1"
    echo "============================="
}

# -------- check_file ------------
check_file() {
    if [[ -f "$1" ]]; then
        return 0    # success — file exists
    fi
    return 1        # failure — file not found
}

# -------- get_filename ------------
get_filename() {
    echo $(basename "$1")   # echo output, capture with $() outside
}

# -------- validate_env ------------
validate_env() {
    if [[ "$1" == "prod" || "$1" == "staging" || "$1" == "dev" ]]; then
        return 0
    else
        return 1
    fi
}

# -------- counter ------------
counter() {
    local count=0   # local — does not leak outside the function
    while [[ $count -lt 3 ]]; do
        count=$((count + 1))
        echo "$count"
    done
}

# -------- Main ------------
print_header "System Health Check"
print_header "Log Report"

if check_file "/var/log/messages"; then
    echo "file found"
else
    echo "file not found"
fi

name=$(get_filename "/var/log/messages")
echo "$name"

if validate_env "prod"; then
    echo "valid env: prod"
else
    echo "invalid env: prod"
fi

counter
echo "Outside function: $count"    # empty — count is local