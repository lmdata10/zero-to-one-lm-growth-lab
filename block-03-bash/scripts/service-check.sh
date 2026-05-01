#!/bin/bash

# ------- Input Validation -----------------------
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <service-file> <output-file-path>"
    exit 1
fi

service_file="$1"
output_path="$2"

if [[ ! -f "$service_file" || ! -r "$service_file" ]]; then
    echo "Error: file not found or not readable: $service_file"
    exit 1
fi

if [[ ! -s "$service_file" ]]; then
    echo "Warning: file is empty: $service_file"
    exit 0
fi

# ------- Counters ---------------------
running=0
stopped=0
total=0

# ------- Service Check Loop ---------------------
while IFS= read -r service; do
    total=$((total + 1))

    if systemctl is-active --quiet "$service"; then
        echo "$service: RUNNING" >> "$output_path"
        running=$((running + 1))
    else
        echo "$service: STOPPED" >> "$output_path"
        stopped=$((stopped + 1))
    fi
done < "$service_file"

# ------- Summary — > overwrites, then >> appends ---------------------
echo "--- Summary ---" > "$output_path"
echo "Total:   $total" >> "$output_path"
echo "Running: $running" >> "$output_path"
echo "Stopped: $stopped" >> "$output_path"

cat "$output_path"
exit 0