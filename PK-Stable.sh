#!/bin/bash

# PK-Stable Installation Script for Endeavor OS
# Comprehensive System Stability Enhancement
# Includes: LTS Kernel, BTRFS, Timeshift, Mirror Optimization, System Hardening

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_stable() {
    echo -e "${PURPLE}[STABLE]${NC} $1"
}

print_system() {
    echo -e "${CYAN}[SYSTEM]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if package is installed
package_installed() {
    pacman -Q "$1" >/dev/null 2>&1
}

# Function to install package if not already installed
install_package() {
    local package=$1
    local description=$2
    
    if package_installed "$package"; then
        print_warning "$description ($package) is already installed"
    else
        print_status "Installing $description ($package)..."
        sudo pacman -S --noconfirm "$package"
        print_success "$description installed successfully"
    fi
}

# Function to install AUR package
install_aur_package() {
    local package=$1
    local description=$2
    
    if package_installed "$package"; then
        print_warning "$description ($package) is already installed"
    else
        print_status "Installing $description ($package) from AUR..."
        yay -S --noconfirm "$package"
        print_success "$description installed successfully"
    fi
}

# Function to check filesystem type
get_filesystem_type() {
    df -T / | awk 'NR==2 {print $2}'
}

# Function to check if BTRFS is being used
is_btrfs() {
    if [ "$(get_filesystem_type)" = "btrfs" ]; then
        return 0
    else
        return 1
    fi
}

# Main installation function
main() {
    echo "=========================================="
    echo "    PK-Stable Installation Script"
    echo "    Endeavor OS Stability Enhancement"
    echo "=========================================="
    echo ""
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        exit 1
    fi
    
    # Check if we're on an Arch-based system
    if ! command_exists pacman; then
        print_error "This script is designed for Arch-based systems"
        exit 1
    fi
    
    # Check for yay (AUR helper)
    if ! command_exists yay; then
        print_status "Installing yay (AUR helper)..."
        sudo pacman -S --needed git base-devel
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
        print_success "yay installed"
    else
        print_status "yay is already installed"
    fi
    
    echo ""
    print_stable "Starting comprehensive stability enhancement..."
    echo ""
    
    # ========================================
    # KERNEL & BASE SYSTEM STABILITY
    # ========================================
    print_system "Installing LTS Kernel & Base System Stability..."
    
    # Install LTS kernel
    print_status "Installing LTS kernel for enhanced stability..."
    install_package "linux-lts" "Linux LTS Kernel"
    install_package "linux-lts-headers" "Linux LTS Headers"
    
    # Install additional stability packages
    install_package "linux-firmware" "Linux Firmware"
    install_package "intel-ucode" "Intel Microcode"
    install_package "amd-ucode" "AMD Microcode"
    
    # Update GRUB configuration
    print_status "Updating GRUB configuration..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    print_success "GRUB configuration updated"
    
    # Set LTS kernel as default (optional)
    print_warning "Consider setting LTS kernel as default in GRUB for maximum stability"
    print_status "You can do this by editing /etc/default/grub and setting GRUB_DEFAULT=1"
    
    # ========================================
    # FILE SYSTEM & ROLLBACKS
    # ========================================
    print_system "Setting up File System & Rollbacks..."
    
    # Check filesystem type
    if is_btrfs; then
        print_success "BTRFS filesystem detected - excellent for stability!"
        
        # Install BTRFS tools
        install_package "btrfs-progs" "BTRFS Tools"
        
        # Create BTRFS subvolumes if they don't exist
        print_status "Setting up BTRFS subvolumes for better organization..."
        sudo btrfs subvolume list /
        
        # Install Timeshift for BTRFS snapshots
        print_status "Installing Timeshift for BTRFS snapshots..."
        install_aur_package "timeshift" "Timeshift System Restore"
        
        # Configure Timeshift for BTRFS
        print_status "Configuring Timeshift for BTRFS..."
        sudo timeshift --create --comments "Initial snapshot after PK-Stable installation"
        print_success "Initial Timeshift snapshot created"
        
    else
        print_warning "Non-BTRFS filesystem detected: $(get_filesystem_type)"
        print_status "Consider migrating to BTRFS for better stability and rollback capabilities"
        
        # Install Timeshift for RSYNC (works with any filesystem)
        print_status "Installing Timeshift for RSYNC snapshots..."
        install_aur_package "timeshift" "Timeshift System Restore"
    fi
    
    # ========================================
    # PACKAGE MANAGEMENT STABILITY
    # ========================================
    print_system "Configuring Package Management for Stability..."
    
    # Install Endeavor OS update notifier
    install_package "eos-update-notifier" "Endeavor OS Update Notifier"
    
    # Install additional package management tools
    install_package "pacman-contrib" "Pacman Contrib Tools"
    install_package "pkgfile" "Package File Finder"
    install_package "pkgstats" "Package Statistics"
    
    # Create pacman hooks for stability
    print_status "Creating pacman hooks for stability..."
    sudo mkdir -p /etc/pacman.d/hooks
    
    # Create hook to update pkgfile database
    cat << 'EOF' | sudo tee /etc/pacman.d/hooks/pkgfile.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Path
Target = usr/bin/*

[Action]
Description = Updating pkgfile database...
When = PostTransaction
Exec = /usr/bin/pkgfile --update
