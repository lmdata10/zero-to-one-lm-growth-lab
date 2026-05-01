#!/bin/bash
set -euo pipefail
# write-report.sh
# Block 3 — Topic 8: Working with Files
# Writes a formatted report to a specified output file using a heredoc
# Usage: ./write-report.sh <output-file-path>

# ------- Input Validation ------------------------
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <output-file-path>"
    exit 1
fi

# ------- Variables ------------------------
filepath="$1"

# ------- Write Report ------------------------
cat > "$filepath" << EOF
Report generated: $(date)
Host:             $(hostname)
Summary:          heredoc redirection demo
EOF

# ------- Confirm Output ------------------------
echo "Report written to: $filepath"
cat "$filepath"