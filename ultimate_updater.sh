#!/bin/bash
set -e  # Exit on error
set -u  # Exit on undefined variable

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    log_info "Requesting root privileges..."
    exec sudo bash "$0" "$@"
fi

# Display start time
log_info "Update started at $(date)"

# Function to update Flatpak packages
update_flatpak() {
    if command -v flatpak &> /dev/null; then
        log_info "Updating Flatpak packages..."
        flatpak update -y --noninteractive
        
        log_info "Cleaning Flatpak cache..."
        rm -rf /var/tmp/flatpak-cache-* 2>/dev/null || true
        
        log_info "Removing unused Flatpak packages..."
        flatpak uninstall --unused -y --noninteractive 2>/dev/null || true
    fi
}

# Detect package manager and update
if [ -d /etc/dnf ]; then
    log_info "Detected DNF package manager"
    
    dnf update -y --refresh
    
    log_info "Checking for unsatisfied dependencies..."
    dnf repoquery --unsatisfied || true
    
    log_info "Removing unused packages..."
    dnf autoremove -y
    
    log_info "Synchronizing distribution packages..."
    dnf distro-sync -y --allowerasing
    
    update_flatpak

elif [ -d /etc/apt ]; then
    log_info "Detected APT package manager"
    
    apt update
    apt full-upgrade -y
    
    log_info "Cleaning up packages..."
    apt autoremove -y
    apt autoclean -y
    
    update_flatpak

elif [ -d /etc/pacman.d ]; then
    log_info "Detected Pacman package manager"
    
    pacman -Syu --noconfirm
    
    log_info "Cleaning package cache..."
    pacman -Sc --noconfirm 2>/dev/null || true
    
    update_flatpak

else
    log_error "No supported package manager found"
    exit 1
fi

# System maintenance tasks
log_info "Refreshing swap..."
swapoff -a && swapon -a

if command -v bleachbit &> /dev/null; then
    log_info "Running BleachBit cleanup..."
    bleachbit -c --preset 2>/dev/null || bleachbit -c system.cache system.tmp 2>/dev/null || true
fi

if command -v fstrim &> /dev/null; then
    log_info "Trimming filesystems..."
    fstrim -Av --quiet-unsupported 2>/dev/null || true
fi

# Display completion time
log_info "Update completed at $(date)"
log_info "System update finished successfully!"