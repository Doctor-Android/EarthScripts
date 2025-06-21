#!/bin/bash

# PK-CyberSec Installation Script for Endeavor OS
# Comprehensive Cybersecurity Tools Installation
# Includes: Kali Linux Tools, Black Arch Tools, Custom Security Tools
# Categories: Vulnerability Assessment, Penetration Testing, Network Security, Malware Analysis, Forensics

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

print_cyber() {
    echo -e "${PURPLE}[CYBER]${NC} $1"
}

print_sec() {
    echo -e "${CYAN}[SEC]${NC} $1"
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
    echo "    PK-CyberSec Installation Script"
    echo "    Comprehensive Security Tools"
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
    
    # Add Black Arch repository
    print_cyber "Setting up Black Arch repository..."
    if ! grep -q "blackarch" /etc/pacman.conf; then
        curl -O https://blackarch.org/strap.sh
        chmod +x strap.sh
        sudo ./strap.sh
        rm strap.sh
        print_success "Black Arch repository added"
    else
        print_warning "Black Arch repository already exists"
    fi
    
    # Update package database
    sudo pacman -Sy
    
    echo ""
    print_cyber "Starting comprehensive security tools installation..."
    echo ""
    
    # ========================================
    # NETWORK SECURITY & RECONNAISSANCE
    # ========================================
    print_sec "Installing Network Security & Reconnaissance Tools..."
    
    # Network scanning and enumeration
    install_package "nmap" "Nmap Network Scanner"
    install_package "masscan" "Masscan Port Scanner"
    install_package "netcat" "Netcat Network Utility"
    install_package "wireshark-qt" "Wireshark Network Analyzer"
    install_package "tshark" "TShark CLI Network Analyzer"
    install_package "tcpdump" "Tcpdump Packet Analyzer"
    install_package "ettercap-gtk" "Ettercap Network Security Tool"
    install_package "aircrack-ng" "Aircrack-ng WiFi Security Suite"
    install_package "kismet" "Kismet Wireless Detector"
    install_package "reaver" "Reaver WiFi Attack Tool"
    install_package "wash" "Wash WPS Detection Tool"
    install_package "bully" "Bully WPS Attack Tool"
    
    # DNS and enumeration tools
    install_package "dnsutils" "DNS Utilities"
    install_package "whois" "Whois Lookup Tool"
    install_package "dig" "DNS Lookup Utility"
    install_aur_package "enum4linux" "Enum4linux SMB Enumeration"
    install_aur_package "nbtscan" "NBTscan Network Scanner"
    install_aur_package "onesixtyone" "Onesixtyone SNMP Scanner"
    install_aur_package "snmpwalk" "SNMPwalk Network Tool"
    
    # ========================================
    # WEB APPLICATION SECURITY
    # ========================================
    print_sec "Installing Web Application Security Tools..."
    
    # Web vulnerability scanners
    install_package "nikto" "Nikto Web Scanner"
    install_package "dirb" "Dirb Web Directory Scanner"
    install_package "dirbuster" "DirBuster Directory Scanner"
    install_package "gobuster" "Gobuster Directory/Subdomain Scanner"
    install_package "wfuzz" "Wfuzz Web Fuzzer"
    install_package "sqlmap" "SQLMap SQL Injection Tool"
    install_package "whatweb" "WhatWeb Web Application Fingerprinter"
    install_package "wpscan" "WPScan WordPress Security Scanner"
    install_package "joomscan" "JoomScan Joomla Security Scanner"
    install_package "uniscan" "Uniscan Web Vulnerability Scanner"
    
    # Web proxies and interceptors
    install_package "burpsuite" "Burp Suite Web Security Platform"
    install_package "zaproxy" "OWASP ZAP Web Security Tool"
    install_package "mitmproxy" "MITM Proxy"
    
    # Mobile web penetration testing
    install_aur_package "penmw" "PenMW Mobile Web Penetration Testing"
    
    # ========================================
    # EXPLOITATION FRAMEWORKS
    # ========================================
    print_sec "Installing Exploitation Frameworks..."
    
    # Metasploit Framework
    install_package "metasploit" "Metasploit Framework"
    
    # Social engineering tools
    install_package "set" "Social Engineering Toolkit"
    install_package "beef-xss" "BeEF Browser Exploitation Framework"
    
    # ========================================
    # PASSWORD ATTACKS & CRACKING
    # ========================================
    print_sec "Installing Password Attack & Cracking Tools..."
    
    # Password cracking
    install_package "john" "John the Ripper Password Cracker"
    install_package "hashcat" "Hashcat Password Recovery Tool"
    install_package "hydra" "Hydra Network Login Cracker"
    install_package "medusa" "Medusa Network Login Cracker"
    install_package "crunch" "Crunch Wordlist Generator"
    install_package "cewl" "CeWL Custom Wordlist Generator"
    install_package "wordlists" "Wordlists Collection"
    
    # ========================================
    # WIRELESS SECURITY
    # ========================================
    print_sec "Installing Wireless Security Tools..."
    
    # WiFi tools
    install_package "wifite" "Wifite WiFi Attack Tool"
    install_package "fern-wifi-cracker" "Fern WiFi Cracker"
    install_package "wifiphisher" "Wifiphisher WiFi Security Testing"
    install_package "airgeddon" "Airgeddon WiFi Security Tool"
    install_package "fluxion" "Fluxion WiFi Security Tool"
    
    # ========================================
    # FORENSICS & DIGITAL INVESTIGATION
    # ========================================
    print_sec "Installing Forensics & Digital Investigation Tools..."
    
    # Memory forensics
    install_package "volatility" "Volatility Memory Forensics"
    install_package "volatility3" "Volatility3 Memory Forensics"
    
    # Disk forensics
    install_package "autopsy" "Autopsy Digital Forensics Platform"
    install_package "sleuthkit" "Sleuth Kit Digital Forensics"
    install_package "testdisk" "TestDisk Data Recovery"
    install_package "photorec" "PhotoRec Data Recovery"
    install_package "foremost" "Foremost Data Recovery"
    install_package "scalpel" "Scalpel Data Recovery"
    
    # Network forensics
    install_package "xplico" "Xplico Network Forensics"
    install_package "networkminer" "NetworkMiner Network Forensics"
    
    # ========================================
    # MALWARE ANALYSIS
    # ========================================
    print_sec "Installing Malware Analysis Tools..."
    
    # Static analysis
    install_package "pefile" "PEfile PE File Analysis"
    install_package "yara" "YARA Pattern Matching"
    install_package "strings" "Strings Binary Analysis"
    install_package "hexdump" "Hexdump Binary Analysis"
    install_package "objdump" "Objdump Object File Analysis"
    install_package "readelf" "Readelf ELF File Analysis"
    
    # Dynamic analysis
    install_package "cuckoo" "Cuckoo Sandbox"
    install_package "joesandbox" "Joe Sandbox"
    
    # ========================================
    # REVERSE ENGINEERING
    # ========================================
    print_sec "Installing Reverse Engineering Tools..."
    
    # Disassemblers and debuggers
    install_package "radare2" "Radare2 Reverse Engineering Framework"
    install_package "ghidra" "Ghidra Software Reverse Engineering"
    install_package "ida-free" "IDA Free Disassembler"
    install_package "x64dbg" "x64dbg Debugger"
    install_package "ollydbg" "OllyDbg Debugger"
    install_package "windbg" "WinDbg Debugger"
    
    # ========================================
    # STEGANOGRAPHY & CRYPTOGRAPHY
    # ========================================
    print_sec "Installing Steganography & Cryptography Tools..."
    
    # Steganography
    install_package "steghide" "Steghide Steganography Tool"
    install_package "stegsolve" "StegSolve Steganography Tool"
    install_package "binwalk" "Binwalk Firmware Analysis"
    install_package "exiftool" "ExifTool Metadata Reader"
    
    # Cryptography
    install_package "openssl" "OpenSSL Cryptography Toolkit"
    install_package "gpg" "GNU Privacy Guard"
    install_package "ccrypt" "Ccrypt File Encryption"
    install_package "bcrypt" "Bcrypt File Encryption"
    
    # ========================================
    # HONEYPOTS & TRAPS
    # ========================================
    print_sec "Installing Honeypots & Traps..."
    
    # Honeypots
    install_aur_package "honeyd" "Honeyd Honeypot Daemon"
    install_aur_package "dionaea" "Dionaea Honeypot"
    install_aur_package "cowrie" "Cowrie SSH Honeypot"
    install_aur_package "kippo" "Kippo SSH Honeypot"
    install_aur_package "glastopf" "Glastopf Web Honeypot"
    install_aur_package "thug" "Thug Low-Interaction Honeyclient"
    
    # ========================================
    # NETWORK TRICKS & ADVANCED TOOLS
    # ========================================
    print_sec "Installing Network Tricks & Advanced Tools..."
    
    # Network manipulation
    install_package "arptables" "Arptables ARP Filtering"
    install_package "ebtables" "Ebtables Ethernet Bridge Filtering"
    install_package "iptables" "Iptables Packet Filtering"
    install_package "nftables" "Nftables Packet Filtering"
    install_package "conntrack-tools" "Conntrack Tools"
    install_package "ipset" "Ipset IP Set Management"
    
    # Traffic analysis
    install_package "iftop" "Iftop Network Monitor"
    install_package "htop" "Htop Process Monitor"
    install_package "iotop" "Iotop I/O Monitor"
    install_package "nethogs" "Nethogs Network Monitor"
    install_package "bandwhich" "Bandwhich Bandwidth Monitor"
    
    # ========================================
    # ADDITIONAL SECURITY TOOLS
    # ========================================
    print_sec "Installing Additional Security Tools..."
    
    # OSINT tools
    install_aur_package "maltego" "Maltego OSINT Tool"
    install_aur_package "recon-ng" "Recon-ng Reconnaissance Framework"
    install_aur_package "theharvester" "TheHarvester OSINT Tool"
    install_aur_package "spiderfoot" "SpiderFoot OSINT Automation"
    
    # Vulnerability assessment
    install_package "openvas" "OpenVAS Vulnerability Scanner"
    install_package "nessus" "Nessus Vulnerability Scanner"
    install_package "qualys" "Qualys Vulnerability Scanner"
    
    # Container security
    install_package "trivy" "Trivy Container Security Scanner"
    install_package "clair" "Clair Container Security Scanner"
    install_package "anchore" "Anchore Container Security"
    
    # ========================================
    # CUSTOM TOOLS & SCRIPTS
    # ========================================
    print_sec "Installing Custom Tools & Scripts..."
    
    # Create security tools directory
    sudo mkdir -p /opt/security-tools
    
    # Install custom scripts
    if [ ! -d "/opt/nmapAutomator" ]; then
        print_status "Installing Nmap Automation Script..."
        sudo git clone https://github.com/21y4d/nmapAutomator.git /opt/nmapAutomator
        print_success "Nmap Automation Script installed"
    fi
    
    if [ ! -d "/opt/PEASS" ]; then
        print_status "Installing Privilege Escalation Awesome Scripts..."
        sudo git clone https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite.git /opt/PEASS
        print_success "PEASS installed"
    fi
    
    if [ ! -d "/opt/LinEnum" ]; then
        print_status "Installing Linux Enumeration Script..."
        sudo git clone https://github.com/rebootuser/LinEnum.git /opt/LinEnum
        print_success "LinEnum installed"
    fi
    
    if [ ! -d "/opt/discover" ]; then
        print_status "Installing Discover Script..."
        sudo git clone https://github.com/leebaird/discover.git /opt/discover
        print_success "Discover Script installed"
    fi
    
    # ========================================
    # PYTHON SECURITY TOOLS
    # ========================================
    print_sec "Installing Python Security Tools..."
    
    # Install pip if not present
    if ! command_exists pip; then
        install_package "python-pip" "Python Pip"
    fi
    
    # Python security packages
    pip install --user requests
    pip install --user beautifulsoup4
    pip install --user lxml
    pip install --user paramiko
    pip install --user scapy
    pip install --user impacket
    pip install --user pwntools
    pip install --user ropgadget
    pip install --user angr
    pip install --user unicorn
    pip install --user keystone-engine
    pip install --user capstone
    pip install --user pefile
    pip install --user yara-python
    pip install --user peid
    pip install --user pyinstaller
    pip install --user py2exe
    
    # ========================================
    # AI PENTESTING TOOLS
    # ========================================
    print_sec "Installing PentestGPT (AI Pentesting Assistant)..."

    # Ensure Python and pip are installed
    install_package "python" "Python 3"
    install_package "python-pip" "Python Pip"
    pip install --user --upgrade pip

    # Clone PentestGPT
    if [ ! -d "/opt/PentestGPT" ]; then
        print_status "Cloning PentestGPT repository..."
        sudo git clone https://github.com/GreyDGL/PentestGPT.git /opt/PentestGPT
        print_success "PentestGPT cloned"
    else
        print_warning "PentestGPT already cloned"
    fi

    # Install requirements
    print_status "Installing PentestGPT requirements..."
    pip install --user -r /opt/PentestGPT/requirements.txt

    print_success "PentestGPT installed! To use, set your OpenAI API key in /opt/PentestGPT/configs/config.yaml"

    # Add alias for PentestGPT
    echo "alias pentestgpt='python3 /opt/PentestGPT/pentestgpt_cli.py'" | sudo tee -a /etc/bash.bashrc
    
    # ========================================
    # CONFIGURATION & SETUP
    # ========================================
    print_sec "Configuring Security Environment..."
    
    # Create security aliases
    echo "# Security Tools Aliases" | sudo tee -a /etc/bash.bashrc
    echo "alias nmap='sudo nmap'" | sudo tee -a /etc/bash.bashrc
    echo "alias wireshark='sudo wireshark'" | sudo tee -a /etc/bash.bashrc
    echo "alias tcpdump='sudo tcpdump'" | sudo tee -a /etc/bash.bashrc
    echo "alias aircrack-ng='sudo aircrack-ng'" | sudo tee -a /etc/bash.bashrc
    
    # Set up environment variables
    echo "export PATH=\$PATH:/opt/security-tools" | sudo tee -a /etc/environment
    
    # Create desktop shortcuts for major tools
    sudo mkdir -p /usr/share/applications/security
    
    # ========================================
    # FINAL SETUP & CLEANUP
    # ========================================
    print_sec "Finalizing Installation..."
    
    # Update package database
    sudo pacman -Sy
    
    # Clean up
    sudo pacman -Sc --noconfirm
    
    echo ""
    echo "=========================================="
    print_success "PK-CyberSec installation completed!"
    echo "=========================================="
    echo ""
    echo "🎯 Installed Security Categories:"
    echo "  • Network Security & Reconnaissance"
    echo "  • Web Application Security"
    echo "  • Exploitation Frameworks"
    echo "  • Password Attacks & Cracking"
    echo "  • Wireless Security"
    echo "  • Forensics & Digital Investigation"
    echo "  • Malware Analysis"
    echo "  • Reverse Engineering"
    echo "  • Steganography & Cryptography"
    echo "  • Honeypots & Traps"
    echo "  • Network Tricks & Advanced Tools"
    echo "  • Additional Security Tools"
    echo "  • Custom Tools & Scripts"
    echo "  • Python Security Tools"
    echo "  • AI Pentesting Tools"
    echo ""
    echo "🔧 Post-Installation Steps:"
    echo "  • Log out and back in for environment changes"
    echo "  • Configure your wireless card for monitor mode"
    echo "  • Set up your preferred text editor for scripts"
    echo "  • Review and configure firewall rules"
    echo "  • Set up virtual machines for malware analysis"
    echo "  • Configure your proxy settings for web tools"
    echo ""
    echo "⚠️  Important Security Notes:"
    echo "  • These tools are for authorized testing only"
    echo "  • Always obtain proper permissions before testing"
    echo "  • Some tools may require additional configuration"
    echo "  • Keep tools updated regularly for security"
    echo "  • Consider using isolated environments for testing"
    echo ""
    echo "🚀 Your cybersecurity toolkit is ready!"
    echo ""
}

# Run main function
main "$@"
