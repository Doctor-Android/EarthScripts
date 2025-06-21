#!/bin/bash

# PK-Gaming Installation Script for Endeavor OS
# Comprehensive Gaming Tools Installation
# Includes: Steam, Bolt (RuneScape), Minecraft, Bottles, RetroArch, and more gaming platforms

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

print_gaming() {
    echo -e "${PURPLE}[GAMING]${NC} $1"
}

print_game() {
    echo -e "${CYAN}[GAME]${NC} $1"
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
    echo "    PK-Gaming Installation Script"
    echo "    Comprehensive Gaming Tools"
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
    
    # Enable multilib repository for 32-bit games
    print_gaming "Enabling multilib repository for 32-bit games..."
    if ! grep -q "\[multilib\]" /etc/pacman.conf; then
        echo "" | sudo tee -a /etc/pacman.conf
        echo "[multilib]" | sudo tee -a /etc/pacman.conf
        echo "Include = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
        sudo pacman -Sy
        print_success "Multilib repository enabled"
    else
        print_warning "Multilib repository already enabled"
    fi
    
    echo ""
    print_gaming "Starting comprehensive gaming tools installation..."
    echo ""
    
    # ========================================
    # GAMING PLATFORMS & STORES
    # ========================================
    print_game "Installing Gaming Platforms & Stores..."
    
    # Steam
    install_package "steam" "Steam Gaming Platform"
    install_package "steam-native-runtime" "Steam Native Runtime"
    
    # Epic Games Store
    install_aur_package "heroic-games-launcher" "Heroic Games Launcher (Epic Games)"
    
    # GOG Galaxy
    install_aur_package "minigalaxy" "GOG Galaxy Client"
    
    # Itch.io
    install_aur_package "itch" "Itch.io Game Client"
    
    # Humble Bundle
    install_aur_package "humble-bundle" "Humble Bundle Client"
    
    # ========================================
    # WINDOWS GAMING COMPATIBILITY
    # ========================================
    print_game "Installing Windows Gaming Compatibility Tools..."
    
    # Wine and related tools
    install_package "wine" "Wine Windows Compatibility Layer"
    install_package "wine-mono" "Wine Mono Runtime"
    install_package "wine-gecko" "Wine Gecko Runtime"
    install_package "winetricks" "Wine Tricks"
    install_package "playonlinux" "PlayOnLinux Wine Manager"
    
    # Bottles (Modern Wine Manager)
    install_package "bottles" "Bottles Windows Application Manager"
    
    # Lutris (Game Manager)
    install_package "lutris" "Lutris Game Manager"
    install_package "lutris-wine" "Lutris Wine Builds"
    
    # Proton and Steam compatibility
    install_package "proton-ge-custom" "Proton GE Custom Builds"
    install_package "proton-tricks" "Proton Tricks"
    
    # DXVK and VKD3D
    install_package "dxvk" "DirectX to Vulkan Layer"
    install_package "vkd3d" "Direct3D 12 to Vulkan Layer"
    
    # ========================================
    # SPECIFIC GAMES & LAUNCHERS
    # ========================================
    print_game "Installing Specific Games & Launchers..."
    
    # RuneScape - Bolt Launcher
    install_aur_package "runelite" "RuneLite RuneScape Client"
    install_aur_package "bolt" "Bolt RuneScape Launcher"
    
    # Minecraft
    install_package "minecraft-launcher" "Minecraft Launcher"
    install_aur_package "multimc" "MultiMC Minecraft Launcher"
    install_aur_package "prism-launcher" "Prism Launcher (Minecraft)"
    
    # Minecraft Java
    install_package "jre8-openjdk" "Java Runtime Environment 8"
    install_package "jre11-openjdk" "Java Runtime Environment 11"
    install_package "jre17-openjdk" "Java Runtime Environment 17"
    
    # Roblox
    install_aur_package "grapejuice" "Grapejuice Roblox Client"
    
    # League of Legends
    install_aur_package "leagueoflegends" "League of Legends"
    
    # World of Warcraft
    install_aur_package "wine-lol" "Wine for League of Legends"
    
    # OpenMW (Morrowind Engine)
    install_package "openmw" "OpenMW Morrowind Engine"
    
    # ========================================
    # RETRO GAMING & EMULATION
    # ========================================
    print_game "Installing Retro Gaming & Emulation..."
    
    # RetroArch (Main emulation frontend)
    install_package "retroarch" "RetroArch Emulation Frontend"
    install_package "retroarch-assets" "RetroArch Assets"
    install_package "retroarch-autoconfig" "RetroArch Autoconfig"
    
    # Individual emulators
    install_package "dolphin-emu" "Dolphin GameCube/Wii Emulator"
    install_package "pcsx2" "PCSX2 PlayStation 2 Emulator"
    install_package "rpcs3" "RPCS3 PlayStation 3 Emulator"
    install_package "citra" "Citra Nintendo 3DS Emulator"
    install_package "yuzu" "Yuzu Nintendo Switch Emulator"
    install_package "ryujinx" "Ryujinx Nintendo Switch Emulator"
    install_package "cemu" "Cemu Wii U Emulator"
    install_package "mupen64plus" "Mupen64Plus N64 Emulator"
    install_package "mednafen" "Mednafen Multi-System Emulator"
    install_package "fceux" "FCEUX NES Emulator"
    install_package "snes9x" "Snes9x SNES Emulator"
    install_package "gpsp" "gPSP GBA Emulator"
    install_package "desmume" "DeSmuME NDS Emulator"
    install_package "ppsspp" "PPSSPP PSP Emulator"
    install_package "duckstation" "DuckStation PlayStation Emulator"
    install_package "flycast" "Flycast Dreamcast Emulator"
    install_package "mame" "MAME Arcade Emulator"
    install_package "fba" "FinalBurn Alpha Arcade Emulator"
    
    # ========================================
    # GAMING UTILITIES & TOOLS
    # ========================================
    print_game "Installing Gaming Utilities & Tools..."
    
    # Performance monitoring
    install_package "mangohud" "MangoHud Performance Overlay"
    install_package "gamemode" "GameMode Performance Optimizer"
    install_package "gamemode-git" "GameMode Git Version"
    install_package "lib32-gamemode" "GameMode 32-bit Library"
    
    # Input and controller tools
    install_package "antimicrox" "AntiMicroX Game Controller Mapping"
    install_package "jstest-gtk" "Joystick Testing Tool"
    install_package "sdl2" "SDL2 Library"
    install_package "lib32-sdl2" "SDL2 32-bit Library"
    
    # Audio tools
    install_package "pulseaudio" "PulseAudio Sound Server"
    install_package "pulseaudio-alsa" "PulseAudio ALSA Integration"
    install_package "pavucontrol" "PulseAudio Volume Control"
    
    # Graphics and display tools
    install_package "vulkan-icd-loader" "Vulkan ICD Loader"
    install_package "lib32-vulkan-icd-loader" "Vulkan ICD Loader 32-bit"
    install_package "vulkan-tools" "Vulkan Tools"
    install_package "mesa-utils" "Mesa Utilities"
    install_package "glxinfo" "OpenGL Information Tool"
    
    # ========================================
    # GAME DEVELOPMENT TOOLS
    # ========================================
    print_game "Installing Game Development Tools..."
    
    # Game engines
    install_package "godot" "Godot Game Engine"
    install_package "godot4" "Godot 4 Game Engine"
    install_aur_package "unity-hub" "Unity Hub"
    install_aur_package "unreal-engine" "Unreal Engine"
    
    # Development tools
    install_package "blender" "Blender 3D Software"
    install_package "gimp" "GIMP Image Editor"
    install_package "inkscape" "Inkscape Vector Graphics"
    install_package "audacity" "Audacity Audio Editor"
    install_package "krita" "Krita Digital Painting"
    
    # ========================================
    # GAMING COMMUNITY TOOLS
    # ========================================
    print_game "Installing Gaming Community Tools..."
    
    # Discord
    install_package "discord" "Discord Chat Application"
    
    # TeamSpeak
    install_package "teamspeak3" "TeamSpeak 3 Client"
    
    # Mumble
    install_package "mumble" "Mumble Voice Chat"
    
    # OBS Studio (Streaming)
    install_package "obs-studio" "OBS Studio Streaming Software"
    install_package "obs-studio-tytan" "OBS Studio with Tytan"
    
    # ========================================
    # GAME MODDING TOOLS
    # ========================================
    print_game "Installing Game Modding Tools..."
    
    # Archive tools
    install_package "7-zip" "7-Zip Archive Manager"
    install_package "unzip" "Unzip Utility"
    install_package "zip" "Zip Utility"
    
    # Hex editors
    install_package "hexedit" "Hex Editor"
    install_package "bless" "Bless Hex Editor"
    
    # ========================================
    # ADDITIONAL GAMING TOOLS
    # ========================================
    print_game "Installing Additional Gaming Tools..."
    
    # Game launchers and managers
    install_aur_package "legendary" "Legendary Epic Games Launcher"
    install_aur_package "gogdl" "GOG Downloader"
    install_aur_package "itch-setup" "Itch.io Setup"
    
    # Game optimization
    install_package "gamemode" "GameMode Performance Optimizer"
    install_package "mangohud" "MangoHud Performance Overlay"
    install_package "vkbasalt" "VkBasalt Post-Processing"
    
    # Game backup and save management
    install_aur_package "ludusavi" "Ludusavi Game Save Backup"
    install_aur_package "ludusavi-manual" "Ludusavi Manual Game Save Backup"
    
    # ========================================
    # CONFIGURATION & SETUP
    # ========================================
    print_game "Configuring Gaming Environment..."
    
    # Create gaming directory
    mkdir -p ~/Games
    mkdir -p ~/.config/gaming
    
    # Set up Wine environment
    if ! command_exists wine; then
        print_status "Setting up Wine environment..."
        winecfg
    fi
    
    # Configure GameMode
    if command_exists gamemoded; then
        print_status "Configuring GameMode..."
        sudo systemctl enable --now gamemoded
    fi
    
    # Set up Steam
    if command_exists steam; then
        print_status "Steam will be configured on first launch..."
    fi
    
    # ========================================
    # FINAL SETUP & CLEANUP
    # ========================================
    print_game "Finalizing Installation..."
    
    # Update package database
    sudo pacman -Sy
    
    # Clean up
    sudo pacman -Sc --noconfirm
    
    echo ""
    echo "=========================================="
    print_success "PK-Gaming installation completed!"
    echo "=========================================="
    echo ""
    echo "🎮 Installed Gaming Categories:"
    echo "  • Gaming Platforms & Stores"
    echo "  • Windows Gaming Compatibility"
    echo "  • Specific Games & Launchers"
    echo "  • Retro Gaming & Emulation"
    echo "  • Gaming Utilities & Tools"
    echo "  • Game Development Tools"
    echo "  • Gaming Community Tools"
    echo "  • Game Modding Tools"
    echo "  • Additional Gaming Tools"
    echo ""
    echo "🎯 Key Applications Installed:"
    echo "  • Steam Gaming Platform"
    echo "  • Bottles Windows Emulator"
    echo "  • Lutris Game Manager"
    echo "  • RetroArch Emulation Frontend"
    echo "  • Bolt RuneScape Launcher"
    echo "  • Minecraft Launchers"
    echo "  • Heroic Games Launcher (Epic)"
    echo "  • Wine & DXVK"
    echo "  • GameMode Performance Optimizer"
    echo "  • MangoHud Performance Overlay"
    echo ""
    echo "🎮 Post-Installation Steps:"
    echo "  • Launch Steam and log in to your account"
    echo "  • Configure Wine with: winecfg"
    echo "  • Set up Bottles for Windows applications"
    echo "  • Configure RetroArch with cores and ROMs"
    echo "  • Install game-specific mods and tools"
    echo "  • Configure GameMode for performance"
    echo "  • Set up MangoHud for performance monitoring"
    echo ""
    echo "🎮 Gaming Tips:"
    echo "  • Use GameMode for better performance"
    echo "  • MangoHud shows FPS and system info"
    echo "  • Bottles is great for Windows games"
    echo "  • RetroArch supports most retro systems"
    echo "  • Lutris manages game installations"
    echo ""
    echo "🚀 Your gaming setup is ready!"
    echo ""
}

# Run main function
main "$@"
