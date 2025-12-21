#!/bin/bash

# Clean Neovim cache and plugins

_CLEAN_NVIM_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$_CLEAN_NVIM_DIR/../common/colors.sh"

clean_nvim() {
    echo -e "${YELLOW}Cleaning Neovim data...${NC}"
    rm -rf ~/.local/share/nvim
    rm -rf ~/.local/state/nvim
    rm -rf ~/.cache/nvim
    echo -e "${YELLOW}Neovim cache cleared.${NC}"
}
