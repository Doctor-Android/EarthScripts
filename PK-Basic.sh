#!/bin/bash

# PK-Basic Installation Script for Endeavor OS
# This script installs essential applications for Endeavor OS
# Applications: Brave Browser, PIA VPN, qBittorrent, ProtonVPN, Spotify, Cursor, Freetube, Librewolf, VLC Media Player, Linux Mint Software Store

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Main installation function
main() {
    echo "=========================================="
    echo "    PK-Basic Installation Script"
    echo "    for Endeavor OS"
    echo "=========================================="
    echo ""
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        exit 1
    fi
    
    # Check if we're on an Arch-based system
    if ! command_exists pacman; then
        print_error "This script is designed for Arch-based systems (Endeavor OS)"
        exit 1
    fi
    
    # Update system first
    print_status "Updating system packages..."
    sudo pacman -Syu --noconfirm
    print_success "System updated"
    
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
    print_status "Starting application installations..."
    echo ""
    
    # 1. Install Brave Browser
    print_status "Installing Brave Browser..."
    if ! command_exists brave-browser; then
        # Add Brave repository
        if ! grep -q "brave" /etc/pacman.conf; then
            echo "Adding Brave repository..."
            echo "" | sudo tee -a /etc/pacman.conf
            echo "[brave-browser]" | sudo tee -a /etc/pacman.conf
            echo "SigLevel = Optional TrustAll" | sudo tee -a /etc/pacman.conf
            echo "Server = https://brave-browser-apt-release.s3.brave.com/arch/" | sudo tee -a /etc/pacman.conf
            sudo pacman -Sy
        fi
        sudo pacman -S --noconfirm brave-browser
        print_success "Brave Browser installed"
    else
        print_warning "Brave Browser is already installed"
    fi
    
    # 2. Install qBittorrent
    install_package "qbittorrent" "qBittorrent"
    
    # 3. Install Spotify
    install_aur_package "spotify" "Spotify"
    
    # 4. Install Cursor Editor
    print_status "Installing Cursor Editor..."
    if ! command_exists cursor; then
        # Download and install Cursor
        wget -O cursor.deb "https://download.todesktop.com/230313mzl4w4u92/linux/deb/x64"
        sudo pacman -S --noconfirm debtap
        debtap cursor.deb
        sudo pacman -U --noconfirm cursor-*.pkg.tar.zst
        rm cursor.deb cursor-*.pkg.tar.zst
        print_success "Cursor Editor installed"
    else
        print_warning "Cursor Editor is already installed"
    fi
    
    # 5. Install PIA VPN
    print_status "Installing PIA VPN..."
    if ! command_exists pia; then
        # Install PIA from AUR
        yay -S --noconfirm pia-app
        print_success "PIA VPN installed"
    else
        print_warning "PIA VPN is already installed"
    fi
    
    # 6. Install ProtonVPN
    print_status "Installing ProtonVPN..."
    if ! command_exists protonvpn; then
        # Install ProtonVPN CLI
        sudo pacman -S --noconfirm protonvpn-cli-ng
        # Install ProtonVPN GUI from AUR
        yay -S --noconfirm protonvpn-gui
        print_success "ProtonVPN installed"
    else
        print_warning "ProtonVPN is already installed"
    fi
    
    # 7. Install Freetube
    print_status "Installing Freetube..."
    if ! command_exists freetube; then
        # Install Freetube from AUR
        yay -S --noconfirm freetube-bin
        print_success "Freetube installed"
    else
        print_warning "Freetube is already installed"
    fi
    
    # 8. Install Librewolf
    print_status "Installing Librewolf..."
    if ! command_exists librewolf; then
        # Install Librewolf from AUR
        yay -S --noconfirm librewolf-bin
        print_success "Librewolf installed"
    else
        print_warning "Librewolf is already installed"
    fi
    
    # 9. Install VLC Media Player
    print_status "Installing VLC Media Player..."
    if ! command_exists vlc; then
        # Install VLC from official repositories
        sudo pacman -S --noconfirm vlc
        print_success "VLC Media Player installed"
    else
        print_warning "VLC Media Player is already installed"
    fi
    
    # 10. Install LibreOffice Suite
    print_status "Installing LibreOffice Suite..."
    if ! command_exists libreoffice; then
        # Install LibreOffice and all components
        sudo pacman -S --noconfirm libreoffice-fresh
        # Install additional language packs (optional)
        sudo pacman -S --noconfirm libreoffice-fresh-en-US
        print_success "LibreOffice Suite installed"
        print_status "LibreOffice components:"
        print_status "  • Writer (Word processor)"
        print_status "  • Calc (Spreadsheet)"
        print_status "  • Impress (Presentations)"
        print_status "  • Draw (Vector graphics)"
        print_status "  • Math (Formula editor)"
        print_status "  • Base (Database)"
    else
        print_warning "LibreOffice Suite is already installed"
    fi
    
    # 11. Install Linux Mint Software Store
    print_status "Installing Linux Mint Software Store..."
    if ! command_exists mintinstall; then
        # Install mintinstall from AUR
        yay -S --noconfirm mintinstall
        print_success "Linux Mint Software Store installed"
    else
        print_warning "Linux Mint Software Store is already installed"
    fi
    
    echo ""
    echo "=========================================="
    print_success "PK-Basic installation completed!"
    echo "=========================================="
    echo ""
    echo "Installed applications:"
    echo "  • Brave Browser"
    echo "  • qBittorrent"
    echo "  • Spotify"
    echo "  • Cursor Editor"
    echo "  • PIA VPN"
    echo "  • ProtonVPN"
    echo "  • Freetube"
    echo "  • Librewolf"
    echo "  • VLC Media Player"
    echo "  • LibreOffice Suite"
    echo "  • Linux Mint Software Store"
    echo ""
    echo "Additional notes:"
    echo "  • You may need to log out and back in for some applications to work properly"
    echo "  • For VPN applications, you'll need to configure them with your credentials"
    echo "  • Some applications may require additional setup after installation"
    echo "  • Freetube is a privacy-focused YouTube client"
    echo "  • Librewolf is a privacy-focused Firefox fork"
    echo "  • VLC supports most media formats out of the box"
    echo "  • LibreOffice Suite provides a user-friendly way to create and edit documents"
    echo "  • Linux Mint Software Store provides a user-friendly way to install applications"
    echo ""
}

# Run main function
main "$@" 