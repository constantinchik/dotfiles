#!/bin/bash

# Determine the root of the repository
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)

# Create a unique backup folder with current date and timestamp
BACKUP_DIR="$HOME/.config/backup/backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Loop through each non ignored file in the repository
git ls-files -z |
while IFS= read -r -d '' file; do
    # Get the relative path of the file
    REL_PATH="${file#$REPO_ROOT/}"
    TARGET="$HOME/$REL_PATH"
    
    # Check if the file exists in the home directory
    if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
        # Create the directory if it doesn't exist
        mkdir -p "$(dirname "$BACKUP_DIR/$REL_PATH")" 
        # Copy the file to the backup directory
        cp "$HOME/$REL_PATH" "$BACKUP_DIR/$REL_PATH"
    fi
done

if [ "$(ls -A "$BACKUP_DIR")" ]; then
    echo "Files backed up to $BACKUP_DIR"
else
    echo "No files to back up"
    rmdir "$BACKUP_DIR"
fi
