#!/bin/bash

# Argument parsing for install scripts

CLEAN_RUN=false

parse_args() {
    for arg in "$@"; do
        case $arg in
            -c|--clean)
                CLEAN_RUN=true
                ;;
        esac
    done
}
