# Linux-specific zsh configuration

# Add user's private bin directories to PATH if they exist
if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
fi

# Arch Linux specific
if [[ "$DISTRO" == "arch" ]] || command -v pacman &> /dev/null; then
    # Load Arch Linux specific oh-my-zsh plugin
    zinit snippet OMZP::archlinux

    # Check for AUR helper
    if pacman -Qi yay &>/dev/null ; then
       aurhelper="yay"
    elif pacman -Qi paru &>/dev/null ; then
       aurhelper="paru"
    fi

    # AUR helper aliases (standardized: un/up/pl/pa/pc/po)
    alias un='$aurhelper -Rns'                      # uninstall package
    alias up='$aurhelper -Syu'                      # update system
    alias pl='$aurhelper -Qs'                       # list installed packages
    alias pa='$aurhelper -Ss'                       # list available packages
    alias pc='$aurhelper -Sc'                       # remove unused cache
    alias po='$aurhelper -Qtdq | $aurhelper -Rns -' # remove unused packages
fi

# Ubuntu/Debian specific
if [[ "$DISTRO" == "ubuntu" ]] || [[ "$DISTRO" == "debian" ]] || command -v apt-get &> /dev/null; then
    # APT aliases (standardized with Arch: un/up/pl/pa/pc/po)
    alias un='sudo apt-get remove'                               # uninstall package
    alias up='sudo apt-get update && sudo apt-get upgrade'       # update system
    alias pl='dpkg --get-selections | grep -v deinstall'         # list installed packages
    alias pa='apt-cache search'                                  # list available packages
    alias pc='sudo apt-get clean && sudo apt-get autoclean'      # remove unused cache
    alias po='sudo apt-get autoremove'                           # remove unused packages
    alias ins='sudo apt-get install'                             # install package (apt-specific)
fi
