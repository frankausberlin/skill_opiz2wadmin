#!/bin/bash

# Orange Pi Zero 2W SD Card Optimization Script
# Target OS: Ubuntu 24.04 (Noble Numbat)
# Purpose: Reduce SD card wear by moving writes to RAM
# License: MIT

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root (use sudo)"
    exit 1
fi

# Check OS version
if ! grep -q "Ubuntu 24.04" /etc/os-release 2>/dev/null; then
    print_warning "This script is designed for Ubuntu 24.04. Proceeding anyway..."
fi

print_header "Orange Pi Zero 2W SD Card Optimization"
echo ""
echo "This script will:"
echo "  • Install Log2Ram (RAM-based logging)"
echo "  • Configure Zram (compressed swap in RAM)"
echo "  • Set up Tmpfs (RAM-based /tmp)"
echo "  • Optimize /etc/fstab with noatime"
echo "  • Configure Journald for volatile storage"
echo "  • Set up Agent Journaling System"
echo ""
print_warning "IMPORTANT: Changes will take effect after reboot"
print_warning "Ensure you have a backup before proceeding"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "Installation cancelled"
    exit 1
fi

# Backup /etc/fstab
print_header "Creating Backup"
cp /etc/fstab /etc/fstab.backup-$(date +%Y%m%d-%H%M%S)
print_success "Backed up /etc/fstab"

# 1. Install Dependencies
print_header "Installing Dependencies"
echo "This may take a few minutes..."

# Add log2ram repository
echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ stable main" | tee /etc/apt/sources.list.d/azlux.list > /dev/null

# Download keyring (try wget first, fall back to curl)
if command -v wget >/dev/null 2>&1; then
    wget -q -O /usr/share/keyrings/azlux-archive-keyring.gpg https://azlux.fr/repo.gpg
    print_success "Downloaded repository keyring (wget)"
elif command -v curl >/dev/null 2>&1; then
    curl -sL -o /usr/share/keyrings/azlux-archive-keyring.gpg https://azlux.fr/repo.gpg
    print_success "Downloaded repository keyring (curl)"
else
    print_error "Neither wget nor curl is installed"
    exit 1
fi

# Update package list
apt update -qq
print_success "Updated package lists"

# Install packages
apt install -y log2ram zram-config > /dev/null 2>&1
print_success "Installed log2ram and zram-config"

# 2. Configure Log2Ram
print_header "Configuring Log2Ram"

# Check available RAM
TOTAL_RAM=$(free -m | awk 'NR==2{print $2}')
if [ "$TOTAL_RAM" -lt 2048 ]; then
    LOG2RAM_SIZE="128M"
    print_warning "Less than 2GB RAM detected, setting Log2Ram to 128M"
else
    LOG2RAM_SIZE="256M"
    print_success "Setting Log2Ram to 256M"
fi

# Configure log2ram
cat > /etc/log2ram.conf <<EOF
# Adapted for Orange Pi Zero 2W
SIZE=$LOG2RAM_SIZE
USE_RSYNC=true
MAIL=false
PATH_DISK="/var/log"
ZL2R=true
COMP_ALG=lz4
LOG_DISK_SIZE=100M
EOF

print_success "Configured Log2Ram"

# Enable log2ram
systemctl enable log2ram > /dev/null 2>&1
print_success "Enabled Log2Ram service"

# 3. Configure Zram
print_header "Configuring Zram"

# Zram-config should work out of the box, but we can tune it
if [ -f /etc/default/zramswap ]; then
    # Configure zram to use more RAM
    sed -i 's/^#*PERCENTAGE=.*/PERCENTAGE=50/' /etc/default/zramswap
    print_success "Configured Zram to use 50% of RAM"
else
    print_warning "zram-config not found, may need manual configuration"
fi

# 4. Optimize /etc/fstab
print_header "Optimizing /etc/fstab"

# Add noatime to root partition if not present
if ! awk '$2 == "/" {print $4}' /etc/fstab | grep -q "noatime"; then
    # Backup and modify
    sed -i.bak '/ \/ / s/\(defaults\)/\1,noatime/' /etc/fstab
    # If defaults is not present, try different pattern
    if ! grep "noatime" /etc/fstab | grep -q " / "; then
        sed -i '/ \/ / s/\([^ ]* [ ]*\/ [ ]*[^ ]* [ ]*\)\([^ ]*\)/\1\2,noatime/' /etc/fstab
    fi
    print_success "Added noatime to root partition"
else
    print_success "noatime already present on root partition"
fi

# Add tmpfs for /tmp if not present
if ! grep -q "^tmpfs.*/tmp" /etc/fstab; then
    echo "tmpfs /tmp tmpfs defaults,noatime,nosuid,nodev,mode=1777 0 0" >> /etc/fstab
    print_success "Added tmpfs for /tmp"
else
    print_success "tmpfs for /tmp already configured"
fi

# Add tmpfs for /var/tmp if not present
if ! grep -q "^tmpfs.*/var/tmp" /etc/fstab; then
    echo "tmpfs /var/tmp tmpfs defaults,noatime,nosuid,nodev,mode=1777 0 0" >> /etc/fstab
    print_success "Added tmpfs for /var/tmp"
else
    print_success "tmpfs for /var/tmp already configured"
fi

# 5. Configure Journald
print_header "Configuring Journald"

# Create journald config directory if it doesn't exist
mkdir -p /etc/systemd/journald.conf.d/

# Configure volatile storage (logs in RAM only)
cat > /etc/systemd/journald.conf.d/99-volatile.conf <<EOF
# Orange Pi Zero 2W SD Card Optimization
# Store journal in RAM only (volatile)
# Trade-off: Logs lost on reboot, but SD card lifespan extended

[Journal]
Storage=volatile
RuntimeMaxUse=64M
RuntimeMaxFileSize=8M
SystemMaxUse=64M
MaxFileSec=1day
MaxRetentionSec=1week
EOF

print_success "Configured Journald for volatile storage"

# 6. Set up Agent Journaling System
print_header "Setting up Agent Journaling System"
mkdir -p /home/frank/labor/agent_journal
# Copy instructions to the journal folder if they exist in the skill directory
SKILL_DIR=$(dirname "$(readlink -f "$0")")/..
if [ -f "$SKILL_DIR/INSTRUCTION_FOR_AGENT_JOURNAL.md" ]; then
    cp "$SKILL_DIR/INSTRUCTION_FOR_AGENT_JOURNAL.md" /home/frank/labor/agent_journal/
    print_success "Copied instructions to /home/frank/labor/agent_journal/"
fi
print_success "Created /home/frank/labor/agent_journal"

# 7. Disable Unnecessary Services (Optional)
print_header "Checking System Services"

# Check for unattended-upgrades (optional to disable)
if systemctl is-enabled unattended-upgrades >/dev/null 2>&1; then
    print_warning "unattended-upgrades is enabled (causes periodic SD writes)"
    echo "  Consider disabling with: sudo systemctl disable unattended-upgrades"
fi

# Check for apt-daily timer
if systemctl is-enabled apt-daily.timer >/dev/null 2>&1; then
    print_warning "apt-daily.timer is enabled (causes periodic SD writes)"
    echo "  Consider disabling with: sudo systemctl disable apt-daily.timer"
fi

# 7. Verify Configuration
print_header "Verification Summary"

echo ""
echo "Configuration completed successfully!"
echo ""
echo "Changes made:"
echo "  ✓ Log2Ram installed (size: $LOG2RAM_SIZE)"
echo "  ✓ Zram configured (50% of RAM)"
echo "  ✓ Tmpfs configured for /tmp and /var/tmp"
echo "  ✓ noatime added to root partition"
echo "  ✓ Journald configured for volatile storage"
echo "  ✓ Agent Journaling System initialized"
echo ""

# Show current fstab for review
print_header "Current /etc/fstab"
cat /etc/fstab
echo ""

# Memory usage info
print_header "Memory Information"
free -h
echo ""

print_header "Next Steps"
echo ""
print_warning "REBOOT REQUIRED for changes to take effect"
echo ""
echo "After reboot, verify configuration with:"
echo "  • Check Log2Ram: systemctl status log2ram"
echo "  • Check Zram: zramctl"
echo "  • Check tmpfs mounts: df -h | grep tmpfs"
echo "  • Monitor writes: sudo iotop -o"
echo ""
echo "For more information, see:"
echo "  • references/sd_card_optimization.md"
echo "  • references/monitoring_commands.md"
echo ""

read -p "Reboot now? (y/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_success "Rebooting system..."
    reboot
else
    print_warning "Remember to reboot for changes to take effect!"
fi

print_success "Script completed successfully"
