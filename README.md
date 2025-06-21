# PK-Basic Installation Script for Endeavor OS

A comprehensive installation script for Endeavor OS that automatically installs essential applications for daily use.

## 🎯 What This Script Installs

- **Brave Browser** - Privacy-focused web browser
- **PIA VPN** - Private Internet Access VPN client
- **qBittorrent** - Free and open-source BitTorrent client
- **ProtonVPN** - Secure VPN service with both CLI and GUI
- **Spotify** - Music streaming service
- **Cursor** - AI-powered code editor
- **Freetube** - Privacy-focused YouTube client
- **Librewolf** - Privacy-focused Firefox fork
- **VLC Media Player** - Universal media player
- **Linux Mint Software Store** - User-friendly application installer

## 🚀 Quick Start

### Prerequisites

- Endeavor OS (or any Arch-based Linux distribution)
- Internet connection
- Sudo privileges

### Installation

1. **Download the script:**
   ```bash
   # If you're in the PK-ENDEAVOR directory
   ./PK-Basic.sh
   ```

2. **Or make it executable and run:**
   ```bash
   chmod +x PK-Basic.sh
   ./PK-Basic.sh
   ```

3. **The script will:**
   - Update your system packages
   - Install yay (AUR helper) if not present
   - Install all requested applications
   - Provide colored status updates throughout the process

## 📋 What the Script Does

### System Preparation
- Updates all system packages
- Installs yay (AUR helper) for accessing user repositories
- Checks for existing installations to avoid duplicates

### Application Installation
1. **Brave Browser**: Adds official Brave repository and installs the browser
2. **qBittorrent**: Installs from official repositories
3. **Spotify**: Installs from AUR
4. **Cursor Editor**: Downloads and converts the .deb package for Arch compatibility
5. **PIA VPN**: Installs the official PIA application from AUR
6. **ProtonVPN**: Installs both CLI and GUI versions
7. **Freetube**: Installs privacy-focused YouTube client from AUR
8. **Librewolf**: Installs privacy-focused Firefox fork from AUR
9. **VLC Media Player**: Installs universal media player from official repositories
10. **Linux Mint Software Store**: Installs user-friendly application installer from AUR

### Safety Features
- Checks if applications are already installed
- Validates system compatibility
- Provides detailed error messages
- Uses colored output for better readability
- Exits on any critical error

## 🔧 Post-Installation Setup

After running the script, you may need to:

### VPN Applications
- **PIA VPN**: Launch the application and log in with your PIA credentials
- **ProtonVPN**: 
  - CLI: Run `protonvpn init` to configure
  - GUI: Launch and log in with your ProtonVPN account

### Applications
- **Spotify**: Launch and log in with your Spotify account
- **Cursor**: First launch may take longer as it downloads additional components
- **Brave Browser**: Ready to use immediately
- **Freetube**: Privacy-focused YouTube alternative, no account required
- **Librewolf**: Privacy-focused browser based on Firefox
- **VLC Media Player**: Supports most media formats out of the box
- **Linux Mint Software Store**: Browse and install applications with descriptions and ratings

## 🛠️ Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   chmod +x PK-Basic.sh
   ```

2. **yay Installation Fails**
   - Ensure you have `git` and `base-devel` installed
   - Check your internet connection

3. **AUR Package Installation Issues**
   - Try updating yay: `yay -Syu`
   - Check if the package name has changed

4. **Cursor Installation Issues**
   - The script uses debtap to convert .deb to .pkg.tar.zst
   - If it fails, you can manually download from the official website

### Manual Installation

If the script fails for a specific application, you can install them manually:

```bash
# Brave Browser
sudo pacman -S brave-browser

# qBittorrent
sudo pacman -S qbittorrent

# Spotify
yay -S spotify

# PIA VPN
yay -S pia-app

# ProtonVPN
sudo pacman -S protonvpn-cli-ng
yay -S protonvpn-gui

# Freetube
yay -S freetube-bin

# Librewolf
yay -S librewolf-bin

# VLC Media Player
sudo pacman -S vlc

# Linux Mint Software Store
yay -S mintinstall
```

## 📝 Script Features

- **Colored Output**: Easy-to-read status messages
- **Error Handling**: Graceful error handling with informative messages
- **Duplicate Prevention**: Checks for existing installations
- **System Validation**: Ensures compatibility with Arch-based systems
- **Non-interactive**: Runs without user intervention (except sudo password)

## 🤝 Contributing

Feel free to modify this script for your specific needs. Common modifications:

- Add more applications
- Change installation methods
- Add configuration options
- Modify the output formatting

## 📄 License

This script is provided as-is for educational and personal use. Modify as needed for your requirements.

## ⚠️ Disclaimer

This script modifies system packages and repositories. Always review the script before running it on your system. The author is not responsible for any issues that may arise from using this script.

---

**Happy computing on Endeavor OS! 🐧** 