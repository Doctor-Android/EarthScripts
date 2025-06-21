#!/bin/bash

# =============================================================================
# ENDEAVOR OS CUSTOM LIVE USB CREATOR
# =============================================================================
# This script creates a custom Endeavor OS live USB with pre-installed scripts:
# - PK-Basic.sh (Essential applications)
# - PK-Stable.sh (System stability tools)
# - PK-CyberSec.sh (Cybersecurity toolkit)
# - SwordofKings.sh (Gaming setup)
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
ENDEAVOR_ISO_URL="https://github.com/endeavouros-team/iso/releases/download/1-EndeavourOS-ISO-releases-archive/endeavouros-2024.12.09-x86_64.iso"
ENDEAVOR_ISO_NAME="endeavouros-2024.12.09-x86_64.iso"
WORK_DIR="$HOME/endeavor-live-usb"
MOUNT_DIR="$WORK_DIR/mount"
EXTRACT_DIR="$WORK_DIR/extract"
CUSTOM_DIR="$WORK_DIR/custom"
SCRIPTS_DIR="$CUSTOM_DIR/scripts"
SCRIPTS=("PK-Basic.sh" "PK-Stable.sh" "PK-CyberSec.sh" "SwordofKings.sh")

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}================================${NC}"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root!"
        print_warning "Run with sudo only when prompted for specific operations."
        exit 1
    fi
}

# Function to check dependencies
check_dependencies() {
    print_header "Checking Dependencies"
    
    local missing_deps=()
    
    # Check for required packages
    local required_packages=(
        "wget" "curl" "xorriso" "isolinux" "syslinux" 
        "squashfs-tools" "mtools" "dosfstools" "rsync"
        "archiso" "arch-install-scripts"
    )
    
    for pkg in "${required_packages[@]}"; do
        if ! command -v "$pkg" &> /dev/null; then
            missing_deps+=("$pkg")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_status "Installing missing dependencies..."
        
        # Install missing packages
        sudo pacman -S --needed --noconfirm "${missing_deps[@]}" || {
            print_error "Failed to install dependencies"
            exit 1
        }
    fi
    
    print_status "All dependencies are installed"
}

# Function to get USB device
get_usb_device() {
    print_header "USB Device Selection"
    
    print_status "Available USB devices:"
    lsblk -d -o NAME,SIZE,MODEL | grep -E "sd[a-z]$|nvme[0-9]n[0-9]$" || true
    
    echo
    print_warning "WARNING: This will completely erase the selected USB device!"
    print_warning "Make sure to backup any important data!"
    echo
    
    read -p "Enter USB device (e.g., /dev/sdb): " USB_DEVICE
    
    if [[ ! -b "$USB_DEVICE" ]]; then
        print_error "Invalid device: $USB_DEVICE"
        exit 1
    fi
    
    # Confirm device selection
    echo
    print_warning "You selected: $USB_DEVICE"
    print_warning "This device will be completely erased!"
    read -p "Are you sure? (yes/no): " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        print_status "Operation cancelled"
        exit 0
    fi
}

# Function to download Endeavor OS ISO
download_iso() {
    print_header "Downloading Endeavor OS ISO"
    
    if [[ -f "$WORK_DIR/$ENDEAVOR_ISO_NAME" ]]; then
        print_status "ISO already exists, skipping download"
        return
    fi
    
    print_status "Downloading Endeavor OS ISO..."
    wget -O "$WORK_DIR/$ENDEAVOR_ISO_NAME" "$ENDEAVOR_ISO_URL" || {
        print_error "Failed to download ISO"
        exit 1
    }
    
    print_status "ISO downloaded successfully"
}

# Function to extract and prepare ISO
extract_iso() {
    print_header "Extracting ISO"
    
    # Create directories
    mkdir -p "$MOUNT_DIR" "$EXTRACT_DIR" "$CUSTOM_DIR" "$SCRIPTS_DIR"
    
    # Mount ISO
    print_status "Mounting ISO..."
    sudo mount -o loop "$WORK_DIR/$ENDEAVOR_ISO_NAME" "$MOUNT_DIR"
    
    # Copy ISO contents
    print_status "Copying ISO contents..."
    rsync -av "$MOUNT_DIR/" "$EXTRACT_DIR/"
    
    # Unmount ISO
    sudo umount "$MOUNT_DIR"
    
    print_status "ISO extracted successfully"
}

# Function to copy custom scripts
copy_scripts() {
    print_header "Copying Custom Scripts"
    
    # Copy all PK scripts
    for script in "${SCRIPTS[@]}"; do
        if [[ -f "$script" ]]; then
            cp "$script" "$SCRIPTS_DIR/"
            chmod +x "$SCRIPTS_DIR/$script"
            print_status "Copied $script"
        else
            print_warning "Script $script not found, skipping"
        fi
    done
    
    # Copy README files
    local readmes=("README.md" "README-Stable.md" "README-CyberSec.md" "SwordofKings-README.md")
    
    for readme in "${readmes[@]}"; do
        if [[ -f "$readme" ]]; then
            cp "$readme" "$SCRIPTS_DIR/"
            print_status "Copied $readme"
        fi
    done
    
    print_status "Scripts copied successfully"
}

# Function to create auto-install script
create_auto_install() {
    print_header "Creating Auto-Install Script"
    
    cat > "$SCRIPTS_DIR/auto-install.sh" << 'EOF'
#!/bin/bash

# Auto-install script for custom Endeavor OS live USB
# This script runs automatically on first boot

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if this is the first boot
if [[ -f "/tmp/custom-installed" ]]; then
    print_status "Custom packages already installed, skipping"
    exit 0
fi

print_status "Starting custom package installation..."

# Update system first
print_status "Updating system..."
sudo pacman -Syu --noconfirm

# Install essential packages
print_status "Installing essential packages..."
sudo pacman -S --needed --noconfirm \
    yay \
    reflector \
    timeshift \
    apparmor \
    firejail \
    ufw \
    fail2ban \
    htop \
    neofetch \
    wget \
    curl \
    git \
    vim \
    nano

# Run PK-Basic installation
if [[ -f "/scripts/PK-Basic.sh" ]]; then
    print_status "Running PK-Basic installation..."
    chmod +x /scripts/PK-Basic.sh
    /scripts/PK-Basic.sh
fi

# Run PK-Stable installation
if [[ -f "/scripts/PK-Stable.sh" ]]; then
    print_status "Running PK-Stable installation..."
    chmod +x /scripts/PK-Stable.sh
    /scripts/PK-Stable.sh
fi

# Run PK-CyberSec installation
if [[ -f "/scripts/PK-CyberSec.sh" ]]; then
    print_status "Running PK-CyberSec installation..."
    chmod +x /scripts/PK-CyberSec.sh
    /scripts/PK-CyberSec.sh
fi

# Run SwordofKings installation
if [[ -f "/scripts/SwordofKings.sh" ]]; then
    print_status "Running SwordofKings installation..."
    chmod +x /scripts/SwordofKings.sh
    /scripts/SwordofKings.sh
fi

# Mark as installed
echo "$(date): Custom packages installed" > /tmp/custom-installed

print_status "Custom installation completed successfully!"
print_status "You can now use all your custom scripts and tools."
EOF

    chmod +x "$SCRIPTS_DIR/auto-install.sh"
    print_status "Auto-install script created"
}

# Function to modify boot configuration
modify_boot_config() {
    print_header "Modifying Boot Configuration"
    
    # Create custom boot entry
    cat > "$EXTRACT_DIR/EFI/BOOT/grub.cfg" << 'EOF'
# Custom Endeavor OS Live USB Boot Configuration

set timeout=5
set default=0

menuentry "Endeavor OS Custom Live" {
    linux /arch/boot/x86_64/vmlinuz-linux archisobasedir=arch archisolabel=ENDEAVOR_OS_20241209 cow_spacesize=4G copytoram=n
    initrd /arch/boot/x86_64/initramfs-linux.img
}

menuentry "Endeavor OS Custom Live (Safe Mode)" {
    linux /arch/boot/x86_64/vmlinuz-linux archisobasedir=arch archisolabel=ENDEAVOR_OS_20241209 cow_spacesize=4G copytoram=n nomodeset
    initrd /arch/boot/x86_64/initramfs-linux.img
}

menuentry "Endeavor OS Custom Live (Install)" {
    linux /arch/boot/x86_64/vmlinuz-linux archisobasedir=arch archisolabel=ENDEAVOR_OS_20241209 cow_spacesize=4G copytoram=n
    initrd /arch/boot/x86_64/initramfs-linux.img
}
EOF

    print_status "Boot configuration modified"
}

# Function to create desktop shortcuts
create_desktop_shortcuts() {
    print_header "Creating Desktop Shortcuts"
    
    # Create applications directory
    mkdir -p "$EXTRACT_DIR/arch/airootfs/usr/share/applications"
    
    # PK-Basic shortcut
    cat > "$EXTRACT_DIR/arch/airootfs/usr/share/applications/pk-basic.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=PK-Basic Installer
Comment=Install essential applications
Exec=lxterminal -e "sudo /scripts/PK-Basic.sh"
Icon=system-software-install
Terminal=true
Categories=System;
EOF

    # PK-Stable shortcut
    cat > "$EXTRACT_DIR/arch/airootfs/usr/share/applications/pk-stable.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=PK-Stable Installer
Comment=Install system stability tools
Exec=lxterminal -e "sudo /scripts/PK-Stable.sh"
Icon=system-software-install
Terminal=true
Categories=System;
EOF

    # PK-CyberSec shortcut
    cat > "$EXTRACT_DIR/arch/airootfs/usr/share/applications/pk-cybersec.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=PK-CyberSec Installer
Comment=Install cybersecurity tools
Exec=lxterminal -e "sudo /scripts/PK-CyberSec.sh"
Icon=security-high
Terminal=true
Categories=System;
EOF

    # SwordofKings shortcut
    cat > "$EXTRACT_DIR/arch/airootfs/usr/share/applications/swordofkings.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=SwordofKings Installer
Comment=Install gaming tools and launchers
Exec=lxterminal -e "sudo /scripts/SwordofKings.sh"
Icon=applications-games
Terminal=true
Categories=Game;
EOF

    print_status "Desktop shortcuts created"
}

# Function to create welcome script
create_welcome_script() {
    print_header "Creating Welcome Script"
    
    cat > "$EXTRACT_DIR/arch/airootfs/usr/local/bin/welcome-custom" << 'EOF'
#!/bin/bash

# Custom welcome script for Endeavor OS Live USB

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}================================${NC}"
echo -e "${CYAN}  ENDEAVOR OS CUSTOM LIVE USB${NC}"
echo -e "${CYAN}================================${NC}"
echo
echo -e "${GREEN}Welcome to your custom Endeavor OS Live USB!${NC}"
echo
echo -e "${YELLOW}Available Custom Scripts:${NC}"
echo -e "  ${BLUE}• PK-Basic.sh${NC} - Essential applications"
echo -e "  ${BLUE}• PK-Stable.sh${NC} - System stability tools"
echo -e "  ${BLUE}• PK-CyberSec.sh${NC} - Cybersecurity toolkit"
echo -e "  ${BLUE}• SwordofKings.sh${NC} - Gaming setup"
echo
echo -e "${PURPLE}To install all packages automatically:${NC}"
echo -e "  sudo /scripts/auto-install.sh"
echo
echo -e "${PURPLE}To run individual scripts:${NC}"
echo -e "  sudo /scripts/PK-Basic.sh"
echo -e "  sudo /scripts/PK-Stable.sh"
echo -e "  sudo /scripts/PK-CyberSec.sh"
echo -e "  sudo /scripts/SwordofKings.sh"
echo
echo -e "${YELLOW}Desktop shortcuts are available in the Applications menu${NC}"
echo
echo -e "${GREEN}Enjoy your custom Endeavor OS experience!${NC}"
echo
EOF

    chmod +x "$EXTRACT_DIR/arch/airootfs/usr/local/bin/welcome-custom"
    print_status "Welcome script created"
}

# Function to prepare USB device
prepare_usb() {
    print_header "Preparing USB Device"
    
    print_warning "WARNING: This will completely erase $USB_DEVICE!"
    print_status "Formatting USB device..."
    
    # Unmount any existing partitions
    sudo umount "$USB_DEVICE"* 2>/dev/null || true
    
    # Create new partition table
    sudo parted "$USB_DEVICE" mklabel gpt
    
    # Create boot partition (512MB)
    sudo parted "$USB_DEVICE" mkpart primary fat32 1MiB 513MiB
    sudo parted "$USB_DEVICE" set 1 boot on
    
    # Create root partition (rest of space)
    sudo parted "$USB_DEVICE" mkpart primary ext4 513MiB 100%
    
    # Format partitions
    sudo mkfs.fat -F32 "${USB_DEVICE}1"
    sudo mkfs.ext4 "${USB_DEVICE}2"
    
    print_status "USB device prepared successfully"
}

# Function to copy files to USB
copy_to_usb() {
    print_header "Copying Files to USB"
    
    # Mount USB partitions
    sudo mkdir -p /mnt/usb-boot /mnt/usb-root
    sudo mount "${USB_DEVICE}1" /mnt/usb-boot
    sudo mount "${USB_DEVICE}2" /mnt/usb-root
    
    # Copy boot files
    print_status "Copying boot files..."
    sudo cp -r "$EXTRACT_DIR/EFI" /mnt/usb-boot/
    sudo cp -r "$EXTRACT_DIR/arch" /mnt/usb-boot/
    
    # Copy root files
    print_status "Copying root files..."
    sudo cp -r "$EXTRACT_DIR/arch/airootfs/"* /mnt/usb-root/
    
    # Copy custom scripts
    sudo cp -r "$SCRIPTS_DIR" /mnt/usb-root/
    
    # Install GRUB
    print_status "Installing GRUB..."
    sudo grub-install --target=x86_64-efi --efi-directory=/mnt/usb-boot --boot-directory=/mnt/usb-boot --removable
    
    # Unmount USB
    sudo umount /mnt/usb-boot /mnt/usb-root
    sudo rmdir /mnt/usb-boot /mnt/usb-root
    
    print_status "Files copied to USB successfully"
}

# Function to create final ISO
create_final_iso() {
    print_header "Creating Final ISO"
    
    local output_iso="$WORK_DIR/endeavor-custom-$(date +%Y%m%d).iso"
    
    print_status "Creating custom ISO: $output_iso"
    
    # Create ISO using xorriso
    xorriso -as mkisofs \
        -o "$output_iso" \
        -b arch/boot/syslinux/isolinux.bin \
        -c arch/boot/syslinux/boot.cat \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        -r \
        -V "ENDEAVOR_CUSTOM" \
        -cache-inodes \
        -J \
        -l \
        "$EXTRACT_DIR"
    
    print_status "Custom ISO created: $output_iso"
}

# Function to cleanup
cleanup() {
    print_header "Cleaning Up"
    
    # Remove work directory
    if [[ -d "$WORK_DIR" ]]; then
        sudo rm -rf "$WORK_DIR"
    fi
    
    print_status "Cleanup completed"
}

# Main function
main() {
    print_header "Endeavor OS Custom Live USB Creator"
    
    check_root
    check_dependencies
    get_usb_device
    
    # Create work directory
    mkdir -p "$WORK_DIR"
    
    # Build process
    download_iso
    extract_iso
    copy_scripts
    create_auto_install
    modify_boot_config
    create_desktop_shortcuts
    create_welcome_script
    prepare_usb
    copy_to_usb
    
    print_header "Installation Complete!"
    print_status "Your custom Endeavor OS live USB is ready!"
    print_status "USB device: $USB_DEVICE"
    print_status "You can now boot from this USB device."
    print_status "All your custom scripts are available in /scripts/"
    print_status "Run 'welcome-custom' for information about available tools."
    
    # Ask if user wants to create ISO
    read -p "Do you want to create a bootable ISO file? (yes/no): " create_iso
    if [[ "$create_iso" == "yes" ]]; then
        create_final_iso
    fi
    
    # Ask if user wants to cleanup
    read -p "Do you want to cleanup temporary files? (yes/no): " cleanup_files
    if [[ "$cleanup_files" == "yes" ]]; then
        cleanup
    fi
}

# Run main function
main "$@" 