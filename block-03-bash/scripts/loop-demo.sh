#!/bin/bash
# loop-demo.sh
# Block 3 — Topic 5: Loops
# Demonstrates for, while, break, continue, and $@ iteration

# ------ For Loop Over List -----------------
count=1
for env in prod staging dev; do
    echo "$count: $env"
    ((count++))
done

# ------ While Loop -----------------
count=1
while [[ $count -le 5 ]]; do
    echo "Count: $count"
    count=$((count + 1))
done

# ------ For Loop Over $@ -----------------
count=1
for path in "$@"; do
    echo "$count: $path"
    count=$((count + 1))
done

# ------ Break and Continue -----------------
for num in 1 2 3 4 5 6; do
    if [[ $num -eq 3 ]]; then
        continue    # skip 3
    fi
    if [[ $num -eq 5 ]]; then
        break       # stop at 5
    fi
    echo "$num"
done