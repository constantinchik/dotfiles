#!/bin/bash

# Function to print usage information
usage() {
    echo "Usage: $0 <backup_folder_name>"
    exit 1
}

# Check if the backup folder is provided
if [ $# -ne 1 ]; then
    usage
fi

BACKUP_BASE_DIR="$HOME/.config/backup"
BACKUP_DIR="$BACKUP_BASE_DIR/$1"

# Check if the provided backup folder exists and is a directory
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: $1 backup does not exist under $HOME/.config/backup/"
    exit 1
fi

# Iterate over the files and folders in the backup folder
for ITEM in $(find "*" "$BACKUP_DIR" ); do
    REL_PATH="${ITEM#$BACKUP_DIR/}"
    TARGET="$HOME/$REL_PATH"

    # Delete if the file exists in the target location
    if [ -e "$TARGET" ]; then
        rm "$TARGET"
    fi

    # Create a folder if does not exist
    mkdir -p "$(dirname "$TARGET")" 

    # Copy the file or folder from the backup to the home directory
    cp "$ITEM" "$TARGET"

    echo "Restored $REL_PATH to $TARGET"
done

echo "Restoration completed."
