#!/bin/bash

# Argument parsing and user input for install scripts

CLEAN_RUN=false
MACOS_SETTINGS=""

parse_args() {
    for arg in "$@"; do
        case $arg in
            -c|--clean)
                CLEAN_RUN=true
                ;;
            --macos-settings)
                MACOS_SETTINGS=true
                ;;
            --no-macos-settings)
                MACOS_SETTINGS=false
                ;;
        esac
    done
}

# Reusable yes/no prompt with colors
# Usage: confirm_prompt "Do you want to continue?" && echo "User said yes"
# Default is No (press Enter to skip)
# Returns 0 (true) for yes, 1 (false) for no
confirm_prompt() {
    local prompt="${1:-Continue?}"
    local answer

    while true; do
        echo -en "${BLUE}${prompt}${NC} [${GREEN}y${NC}/${RED}N${NC}]: "
        read -r answer
        # Convert to lowercase (portable)
        answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
        case "$answer" in
            y|yes)
                return 0
                ;;
            n|no|"")
                return 1
                ;;
            *)
                echo -e "${YELLOW}Please answer yes or no.${NC}"
                ;;
        esac
    done
}
