#!/bin/bash

# This script is required so that for non-existing folders GNU stow will symlink
# only the files from this repository, and not the whole folder (as it might be)
# updated by the application later, but we do not care about all the files
# Ex. vscodium will create lots of files in .config/VSCodium if we symlink the
# whole folder
#
# Not all though. We want nvim configuration to be still symlinked into the
# whole folder as it will not be updated by the application
# So this process is manually creating the folders we want

# Determine the root of the repository
CONFIG_DIR="$HOME/.config/"

mkdir -p "$CONFIG_DIR/VSCodium/User"
mkdir -p "$CONFIG_DIR/kitty"
mkdir -p "$CONFIG_DIR/tmux"

