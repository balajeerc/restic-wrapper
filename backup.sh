#!/usr/bin/env bash

set -a
set -e

source config.sh

# Function to send alert to Opsgenie
send_opsgenie_alert() {
    local message="$1"
    local notes="$2"
    
    if [ -n "$OPSGENIE_API_KEY" ]; then
        curl -X POST "${OPSGENIE_API_URL}" \
             -H "Content-Type: application/json" \
             -H "Authorization: GenieKey ${OPSGENIE_API_KEY}" \
             -d @- <<EOF
{
  "message": "Restic Backup Error",
  "description": "${message}",
  "note": "${notes}",
  "priority": "P1"
}
EOF
    fi
}

# Subcommand: init
init() {
    echo "Initializing Restic repository..."
    restic init
    if [ $? -eq 0 ]; then
        echo "Repository initialized successfully."
    else
        echo "Failed to initialize repository."
        exit 1
    fi
}

# Subcommand: backup
backup() {
    output=""
    error_output=""

    output+="==================================================\n"
    output+="Starting backup on: $(date)\n"

    trap 'send_opsgenie_alert "An error occurred during the backup process. Check the logs for details." "$error_output" && echo -e "$output" >> log.txt && exit 1' ERR

    for directory in "${DIRECTORIES_TO_BACKUP[@]}"; do
        output+="Backing up directory: $directory\n"
      
        backup_output=$(restic --verbose backup "$directory" 2>&1) || {
            error_output="$backup_output"
            output+="$error_output\n"
            false 
        }

        output+="$backup_output\n"
    done

    forget_output=$(restic forget --keep-last "$SNAPSHOTS_COUNT" --prune 2>&1)
    output+="Forget and Prune Output:\n$forget_output\n"

    output+="Backup completed on: $(date)\n"
    echo -e "$output" >> log.txt
    echo -e "$output"
}

# Main: handle subcommands
case "$1" in
    init)
        init
        ;;
    backup)
        backup
        ;;
    *)
        echo "Usage: $0 {init|backup}"
        exit 1
        ;;
esac