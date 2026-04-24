#!/bin/bash
# variables.sh
# Block 3 — Topic 2: Variables and Quoting Rules
# Demonstrates variable declaration, quoting behaviour, command substitution, and arithmetic expansion

# ─── Basic Variables ────────────────────────────────────────────────
name="lm"
filename="variables.sh"
date=$(date +"%Y-%m-%d")

echo "$name"
echo "$filename"
echo "$date"

# ─── Quoting Behaviour ──────────────────────────────────────────────
# Double quotes expand variables — single quotes are literal
greeting="hello $name"
literal='hello $name'

echo "$greeting"    # prints: hello lm
echo "$literal"     # prints: hello $name

# ─── Command Substitution Inside a String ───────────────────────────
first="platform"
second="engineering"
combined="$first $second"

echo "$combined"
echo "I am learning $combined and it is $(date +"%Y")"

# ─── Arithmetic Expansion ───────────────────────────────────────────
# $(( )) does math — $( ) runs commands — not interchangeable
count=5
echo "There are $count items"
echo "Next count is $((count + 1))"
echo "Double is $((count * 2))"

# ─── basename and dirname ───────────────────────────────────────────
# Extract filename and directory from a full path
path="/var/log/messages"
filename=$(basename "$path")
directory=$(dirname "$path")

echo "Full path: $path"
echo "File: $filename"
echo "Directory: $directory"