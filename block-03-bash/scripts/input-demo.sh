#!/bin/bash
# input-demo.sh
# Block 3 — Topic 3: User Input and Positional Parameters
# Demonstrates read for interactive input — service name and environment

# ─── Interactive Input ───────────────────────────────────────────────
read -p "Enter service name: " service_name
read -p "Enter the related environment: " env

# ─── Output ─────────────────────────────────────────────────────────
echo "Service: $service_name | Environment: $env"