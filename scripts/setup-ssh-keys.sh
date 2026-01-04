#!/bin/bash

# SSH Key Setup for WSL
# Generates ed25519 keys for macbook access and n8n automation
# Disables password authentication after keys are configured

set -e

SSH_DIR="$HOME/.ssh"
KEY_MACBOOK="$SSH_DIR/id_macbook"
KEY_N8N="$SSH_DIR/id_n8n"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${CYAN}→${NC} $1"
}

check_keys() {
    local missing=()

    if [[ ! -f "$KEY_MACBOOK" ]]; then
        missing+=("id_macbook")
    fi

    if [[ ! -f "$KEY_N8N" ]]; then
        missing+=("id_n8n")
    fi

    echo "${missing[@]}"
}

show_env_vars() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Add these to your home-server/.env file:${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "N8N_SSH_PRIVATE_KEY_PATH=$KEY_N8N"
    echo "WSL_SSH_HOST=192.168.2.100"
    echo "WSL_SSH_USER=$(whoami)"
    echo ""
}

show_public_keys() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Public keys (add to remote machines' authorized_keys):${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    if [[ -f "${KEY_MACBOOK}.pub" ]]; then
        echo -e "${GREEN}Macbook key (${KEY_MACBOOK}.pub):${NC}"
        cat "${KEY_MACBOOK}.pub"
        echo ""
    fi

    if [[ -f "${KEY_N8N}.pub" ]]; then
        echo -e "${GREEN}n8n key (${KEY_N8N}.pub):${NC}"
        cat "${KEY_N8N}.pub"
        echo ""
    fi
}

show_client_setup_instructions() {
    local wsl_ip=$(hostname -I | awk '{print $1}')
    local wsl_user=$(whoami)

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}CLIENT SETUP INSTRUCTIONS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}To SSH into this machine from client devices:${NC}"
    echo ""
    echo -e "${GREEN}1. MacBook Setup:${NC}"
    echo "   Copy the private key content below to ~/.ssh/id_wsl on your MacBook:"
    echo ""
    if [[ -f "${KEY_MACBOOK}" ]]; then
        echo -e "${CYAN}--- BEGIN PRIVATE KEY (copy everything including BEGIN/END lines) ---${NC}"
        cat "${KEY_MACBOOK}"
        echo -e "${CYAN}--- END PRIVATE KEY ---${NC}"
    fi
    echo ""
    echo "   On MacBook, save to ~/.ssh/id_wsl then run: chmod 600 ~/.ssh/id_wsl"
    echo "   Then run the macOS install script to configure SSH automatically."
    echo ""
    echo -e "${GREEN}2. n8n Server Setup:${NC}"
    echo "   Configure n8n SSH credentials with:"
    echo "     Host: ${wsl_ip}"
    echo "     User: ${wsl_user}"
    echo "     Private Key: (copy content below)"
    echo ""
    if [[ -f "${KEY_N8N}" ]]; then
        echo -e "${CYAN}--- BEGIN PRIVATE KEY (for n8n) ---${NC}"
        cat "${KEY_N8N}"
        echo -e "${CYAN}--- END PRIVATE KEY ---${NC}"
    fi
    echo ""
    echo -e "${YELLOW}Note: WSL IP may change after restart. Consider using a static IP.${NC}"
    echo ""
}

generate_key() {
    local key_path=$1
    local comment=$2
    local key_name=$(basename "$key_path")

    if [[ -f "$key_path" ]]; then
        print_status "$key_name already exists"
        return 0
    fi

    print_info "Generating $key_name..."
    ssh-keygen -t ed25519 -f "$key_path" -C "$comment" -N ""
    chmod 600 "$key_path"
    chmod 644 "${key_path}.pub"
    print_status "$key_name generated"
}

add_to_authorized_keys() {
    local pub_key=$1
    local key_name=$(basename "$pub_key" .pub)

    if [[ ! -f "$pub_key" ]]; then
        return 1
    fi

    # Ensure authorized_keys exists
    touch "$AUTHORIZED_KEYS"
    chmod 600 "$AUTHORIZED_KEYS"

    # Check if key already in authorized_keys
    if grep -qF "$(cat "$pub_key")" "$AUTHORIZED_KEYS" 2>/dev/null; then
        print_status "$key_name already in authorized_keys"
    else
        cat "$pub_key" >> "$AUTHORIZED_KEYS"
        print_status "$key_name added to authorized_keys"
    fi
}

disable_password_auth() {
    local sshd_config="/etc/ssh/sshd_config"

    print_info "Disabling password authentication..."

    # Check current status
    if grep -q "^PasswordAuthentication no" "$sshd_config" 2>/dev/null; then
        print_status "Password authentication already disabled"
        return 0
    fi

    # Disable password authentication
    sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$sshd_config"

    # Restart SSH service
    if command -v systemctl &> /dev/null; then
        sudo systemctl restart ssh
        print_status "Password authentication disabled and SSH restarted"
    else
        print_warning "Please restart SSH service manually"
    fi
}

main() {
    echo ""
    echo -e "${CYAN}SSH Key Setup for WSL${NC}"
    echo -e "${CYAN}=====================${NC}"
    echo ""

    # Ensure .ssh directory exists
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"

    # Check which keys are missing
    missing_keys=$(check_keys)

    if [[ -z "$missing_keys" ]]; then
        print_status "All SSH keys already configured"
        show_env_vars
        show_public_keys
        show_client_setup_instructions
        exit 0
    fi

    print_warning "Missing SSH keys: $missing_keys"
    echo ""
    echo "These keys are used for:"
    echo "  - id_macbook: SSH access from your MacBook"
    echo "  - id_n8n: n8n automation to run commands on this machine"
    echo ""

    read -p "Generate missing SSH keys now? (y/n): " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        print_warning "SSH key generation skipped"
        echo ""
        echo "To generate keys later, run:"
        echo "  ./scripts/setup-ssh-keys.sh"
        echo ""
        print_warning "Password authentication remains ENABLED until keys are configured."
        print_warning "This is less secure for SSH access."
        echo ""
        exit 0
    fi

    echo ""

    # Generate missing keys
    generate_key "$KEY_MACBOOK" "macbook-access"
    generate_key "$KEY_N8N" "n8n-automation"

    # Add public keys to authorized_keys
    echo ""
    print_info "Adding public keys to authorized_keys..."
    add_to_authorized_keys "${KEY_MACBOOK}.pub"
    add_to_authorized_keys "${KEY_N8N}.pub"

    # Disable password authentication (requires sudo)
    echo ""
    echo -e "${YELLOW}The next step requires sudo to disable password authentication${NC}"
    echo -e "${YELLOW}and restart the SSH server.${NC}"
    echo ""
    disable_password_auth

    # Show configuration info
    show_env_vars
    show_public_keys
    show_client_setup_instructions

    echo -e "${GREEN}SSH key setup complete!${NC}"
    echo ""
}

main "$@"
