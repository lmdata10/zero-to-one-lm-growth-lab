#!/bin/bash
logfile="health-$(date +"%Y-%m-%d").log"   # defined first
{
    echo "=== Hostname ==="
    hostname
    echo "=== Date ==="
    date
    date +"%Y-%m-%d"
    echo "=== Uptime ==="
    uptime
    echo "=== Top Processes (Memory) ==="
    ps aux --sort=-%mem | head -4
} > $logfile
echo "$logfile"                             # prints path to terminal