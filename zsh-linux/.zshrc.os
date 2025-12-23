# Linux-specific zsh configuration

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

    # AUR helper aliases
    alias un='$aurhelper -Rns' # uninstall package
    alias up='$aurhelper -Syu' # update system/package/aur
    alias pl='$aurhelper -Qs' # list installed package
    alias pa='$aurhelper -Ss' # list availabe package
    alias pc='$aurhelper -Sc' # remove unused cache
    alias po='$aurhelper -Qtdq | $aurhelper -Rns -' # remove unused packages
fi

# Ubuntu/Debian specific
if [[ "$DISTRO" == "ubuntu" ]] || [[ "$DISTRO" == "debian" ]] || command -v apt-get &> /dev/null; then
    # APT aliases
    alias upd='sudo apt-get update' # update package database
    alias upg='sudo apt-get upgrade' # upgrade packages
    alias ins='sudo apt-get install' # install package
    alias rem='sudo apt-get remove' # remove package
    alias pur='sudo apt-get purge' # purge package and config
    alias acs='apt-cache search' # search for packages
    alias acsh='apt-cache show' # show package info
fi
