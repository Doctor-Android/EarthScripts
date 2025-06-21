#!/bin/bash

# SwordofKings: Debian to Arch Package Converter
# Automatically detects Debian packages and converts them to Arch equivalents

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

print_sword() {
    echo -e "${PURPLE}[SWORD]${NC} $1"
}

print_convert() {
    echo -e "${CYAN}[CONVERT]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if package is installed
package_installed() {
    pacman -Q "$1" >/dev/null 2>&1
}

# Function to check system compatibility
check_compatibility() {
    print_sword "Checking system compatibility..."
    
    # Check if we're on Arch-based system
    if ! command_exists pacman; then
        print_error "SwordofKings requires an Arch-based system (Endeavor OS, Manjaro, etc.)"
        exit 1
    fi
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "SwordofKings should not be run as root"
        exit 1
    fi
    
    # Check for required tools
    if ! command_exists curl; then
        print_status "Installing curl..."
        sudo pacman -S --noconfirm curl
    fi
    
    if ! command_exists jq; then
        print_status "Installing jq..."
        sudo pacman -S --noconfirm jq
    fi
    
    print_success "System compatibility verified"
}

# Function to create package mapping database
create_package_mapping() {
    print_sword "Creating Debian to Arch package mapping database..."
    
    # Create mapping directory
    sudo mkdir -p /opt/swordofkings/mappings
    
    # Create comprehensive package mapping
    cat << 'MAPPING_EOF' | sudo tee /opt/swordofkings/mappings/debian-to-arch.json
{
  "web_servers": {
    "apache2": "apache",
    "nginx": "nginx",
    "lighttpd": "lighttpd"
  },
  "databases": {
    "mysql-server": "mariadb",
    "mysql-client": "mariadb-clients",
    "postgresql": "postgresql",
    "postgresql-client": "postgresql",
    "redis-server": "redis",
    "mongodb": "mongodb"
  },
  "languages": {
    "python3": "python",
    "python3-pip": "python-pip",
    "python3-venv": "python-virtualenv",
    "python3-dev": "python",
    "nodejs": "nodejs",
    "npm": "npm",
    "yarn": "yarn",
    "php": "php",
    "php-fpm": "php-fpm",
    "php-mysql": "php",
    "php-pgsql": "php",
    "php-gd": "php",
    "php-curl": "php",
    "php-xml": "php",
    "php-mbstring": "php",
    "php-zip": "php",
    "java-runtime": "jre-openjdk",
    "java-compiler": "jdk-openjdk",
    "openjdk-11-jdk": "jdk-openjdk",
    "openjdk-11-jre": "jre-openjdk",
    "openjdk-17-jdk": "jdk-openjdk",
    "openjdk-17-jre": "jre-openjdk",
    "golang": "go",
    "rustc": "rust",
    "cargo": "rust"
  },
  "development": {
    "build-essential": "base-devel",
    "gcc": "gcc",
    "g++": "gcc",
    "make": "make",
    "cmake": "cmake",
    "git": "git",
    "subversion": "subversion",
    "mercurial": "mercurial"
  },
  "system_tools": {
    "htop": "htop",
    "iotop": "iotop",
    "nethogs": "nethogs",
    "tree": "tree",
    "rsync": "rsync",
    "wget": "wget",
    "curl": "curl",
    "unzip": "unzip",
    "zip": "zip",
    "tar": "tar",
    "gzip": "gzip",
    "bzip2": "bzip2",
    "xz-utils": "xz"
  },
  "network_tools": {
    "nmap": "nmap",
    "netcat": "netcat",
    "tcpdump": "tcpdump",
    "wireshark": "wireshark",
    "iperf3": "iperf",
    "iftop": "iftop"
  },
  "security": {
    "ufw": "ufw",
    "fail2ban": "fail2ban",
    "rkhunter": "rkhunter",
    "chkrootkit": "chkrootkit",
    "openssh-server": "openssh",
    "openssh-client": "openssh"
  },
  "containers": {
    "docker.io": "docker",
    "docker-ce": "docker",
    "docker-compose": "docker-compose",
    "podman": "podman"
  },
  "monitoring": {
    "prometheus": "prometheus",
    "grafana": "grafana",
    "zabbix-server": "zabbix",
    "zabbix-agent": "zabbix-agent"
  },
  "mail_servers": {
    "postfix": "postfix",
    "dovecot": "dovecot",
    "exim4": "exim"
  },
  "file_servers": {
    "samba": "samba",
    "nfs-kernel-server": "nfs-utils",
    "vsftpd": "vsftpd"
  },
  "dns_servers": {
    "bind9": "bind",
    "dnsmasq": "dnsmasq"
  },
  "dhcp_servers": {
    "isc-dhcp-server": "dhcp"
  },
  "proxy_servers": {
    "squid": "squid",
    "nginx": "nginx"
  },
  "load_balancers": {
    "haproxy": "haproxy",
    "nginx": "nginx"
  },
  "cache_servers": {
    "memcached": "memcached",
    "varnish": "varnish"
  },
  "message_queues": {
    "rabbitmq-server": "rabbitmq",
    "apache-kafka": "apache-kafka"
  },
  "search_servers": {
    "elasticsearch": "elasticsearch",
    "solr": "solr"
  },
  "backup_servers": {
    "rsync": "rsync",
    "bacula": "bacula",
    "borgbackup": "borg"
  },
  "game_servers": {
    "openjdk-11-jre": "jre-openjdk",
    "openjdk-17-jre": "jre-openjdk"
  },
  "gui_tools": {
    "firefox": "firefox",
    "chromium": "chromium",
    "vlc": "vlc",
    "gimp": "gimp",
    "inkscape": "inkscape",
    "libreoffice": "libreoffice-still"
  },
  "text_editors": {
    "vim": "vim",
    "nano": "nano",
    "emacs": "emacs",
    "neovim": "neovim",
    "micro": "micro"
  },
  "terminals": {
    "xterm": "xterm",
    "gnome-terminal": "gnome-terminal",
    "konsole": "konsole",
    "xfce4-terminal": "xfce4-terminal"
  },
  "file_managers": {
    "ranger": "ranger",
    "mc": "mc",
    "nemo": "nemo",
    "dolphin": "dolphin",
    "thunar": "thunar"
  }
}
MAPPING_EOF
    
    print_success "Package mapping database created"
}

# Function to detect Debian package from file or command
detect_debian_package() {
    local input="$1"
    print_convert "Detecting Debian package from: $input"
    
    # Check if it's a .deb file
    if [[ $input == *.deb ]]; then
        if [ -f "$input" ]; then
            print_status "Detected .deb file: $input"
            extract_deb_info "$input"
        else
            print_error "Deb file not found: $input"
            return 1
        fi
    # Check if it's a package name
    elif [[ $input =~ ^[a-zA-Z0-9._-]+$ ]]; then
        print_status "Detected package name: $input"
        convert_package_name "$input"
    # Check if it's a command
    elif command_exists "$input"; then
        print_status "Detected command: $input"
        detect_package_from_command "$input"
    # Check if it's a file path
    elif [ -f "$input" ]; then
        print_status "Detected file: $input"
        detect_package_from_file "$input"
    else
        print_error "Unable to detect package type: $input"
        return 1
    fi
}

# Function to extract information from .deb file
extract_deb_info() {
    local deb_file="$1"
    print_convert "Extracting information from .deb file..."
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    
    # Extract deb file
    cd "$temp_dir"
    ar x "$deb_file"
    
    # Extract control.tar.gz
    if [ -f "control.tar.gz" ]; then
        tar -xzf control.tar.gz
    elif [ -f "control.tar.xz" ]; then
        tar -xJf control.tar.xz
    fi
    
    # Read package information
    if [ -f "control" ]; then
        local package_name=$(grep "^Package:" control | cut -d: -f2 | xargs)
        local dependencies=$(grep "^Depends:" control | cut -d: -f2 | xargs)
        
        print_success "Package: $package_name"
        print_status "Dependencies: $dependencies"
        
        # Convert package and dependencies
        convert_package_name "$package_name"
        
        # Convert dependencies
        if [ -n "$dependencies" ]; then
            IFS=',' read -ra deps <<< "$dependencies"
            for dep in "${deps[@]}"; do
                dep=$(echo "$dep" | sed 's/[()|]//g' | xargs)
                if [ -n "$dep" ]; then
                    convert_package_name "$dep"
                fi
            done
        fi
    fi
    
    # Clean up
    cd - > /dev/null
    rm -rf "$temp_dir"
}

# Function to convert Debian package name to Arch
convert_package_name() {
    local debian_package="$1"
    print_convert "Converting Debian package: $debian_package"
    
    # Load mapping database
    local mapping_file="/opt/swordofkings/mappings/debian-to-arch.json"
    
    # Search for package in mapping
    local arch_package=$(jq -r ".[] | to_entries[] | select(.key == \"$debian_package\") | .value" "$mapping_file" 2>/dev/null)
    
    if [ -n "$arch_package" ] && [ "$arch_package" != "null" ]; then
        print_success "Found Arch equivalent: $arch_package"
        install_arch_package "$arch_package"
    else
        print_warning "No direct mapping found for: $debian_package"
        suggest_alternatives "$debian_package"
    fi
}

# Function to detect package from command
detect_package_from_command() {
    local command="$1"
    print_convert "Detecting package from command: $command"
    
    # Common command to package mappings
    case $command in
        "nginx") convert_package_name "nginx" ;;
        "apache2") convert_package_name "apache2" ;;
        "mysql") convert_package_name "mysql-client" ;;
        "python3") convert_package_name "python3" ;;
        "node") convert_package_name "nodejs" ;;
        "npm") convert_package_name "npm" ;;
        "php") convert_package_name "php" ;;
        "java") convert_package_name "java-runtime" ;;
        "javac") convert_package_name "java-compiler" ;;
        "go") convert_package_name "golang" ;;
        "rustc") convert_package_name "rustc" ;;
        "cargo") convert_package_name "cargo" ;;
        "git") convert_package_name "git" ;;
        "docker") convert_package_name "docker.io" ;;
        "htop") convert_package_name "htop" ;;
        "nmap") convert_package_name "nmap" ;;
        "vim") convert_package_name "vim" ;;
        "firefox") convert_package_name "firefox" ;;
        "vlc") convert_package_name "vlc" ;;
        *)
            print_warning "Unknown command: $command"
            suggest_alternatives "$command"
            ;;
    esac
}

# Function to detect package from file
detect_package_from_file() {
    local file="$1"
    print_convert "Detecting package from file: $file"
    
    # Check file type and suggest packages
    local file_type=$(file "$file" | cut -d: -f2)
    
    case $file_type in
        *"Python script"*)
            convert_package_name "python3" ;;
        *"Node.js"*)
            convert_package_name "nodejs" ;;
        *"PHP script"*)
            convert_package_name "php" ;;
        *"Java"*)
            convert_package_name "java-runtime" ;;
        *"Go"*)
            convert_package_name "golang" ;;
        *"Rust"*)
            convert_package_name "rustc" ;;
        *"ELF"*)
            print_status "Detected binary file - checking dependencies..."
            check_binary_dependencies "$file" ;;
        *)
            print_warning "Unknown file type: $file_type"
            ;;
    esac
}

# Function to check binary dependencies
check_binary_dependencies() {
    local binary="$1"
    print_convert "Checking binary dependencies: $binary"
    
    # Use ldd to check shared library dependencies
    if command_exists ldd; then
        local deps=$(ldd "$binary" 2>/dev/null | grep "=>" | awk '{print $1}' | sort -u)
        
        for dep in $deps; do
            case $dep in
                "libssl.so") convert_package_name "openssl" ;;
                "libcrypto.so") convert_package_name "openssl" ;;
                "libz.so") convert_package_name "zlib" ;;
                "libxml2.so") convert_package_name "libxml2" ;;
                "libcurl.so") convert_package_name "curl" ;;
                "libsqlite3.so") convert_package_name "sqlite" ;;
                "libmysqlclient.so") convert_package_name "mysql-client" ;;
                "libpq.so") convert_package_name "postgresql" ;;
                *)
                    print_status "Library dependency: $dep"
                    ;;
            esac
        done
    fi
}

# Function to suggest alternatives
suggest_alternatives() {
    local package="$1"
    print_convert "Suggesting alternatives for: $package"
    
    # Search for similar packages
    local suggestions=$(pacman -Ss "$package" 2>/dev/null | head -5)
    
    if [ -n "$suggestions" ]; then
        print_status "Similar packages found:"
        echo "$suggestions"
        
        read -p "Install one of these packages? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            read -p "Enter package name to install: " package_name
            if [ -n "$package_name" ]; then
                install_arch_package "$package_name"
            fi
        fi
    else
        print_warning "No similar packages found for: $package"
        print_status "You may need to install from AUR or build from source"
    fi
}

# Function to install Arch package
install_arch_package() {
    local package="$1"
    print_convert "Installing Arch package: $package"
    
    if package_installed "$package"; then
        print_warning "Package already installed: $package"
    else
        print_status "Installing $package..."
        if sudo pacman -S --noconfirm "$package"; then
            print_success "Successfully installed: $package"
        else
            print_error "Failed to install: $package"
            
            # Try AUR
            print_status "Trying AUR..."
            if command_exists yay; then
                if yay -S --noconfirm "$package"; then
                    print_success "Successfully installed from AUR: $package"
                else
                    print_error "Failed to install from AUR: $package"
                fi
            elif command_exists paru; then
                if paru -S --noconfirm "$package"; then
                    print_success "Successfully installed from AUR: $package"
                else
                    print_error "Failed to install from AUR: $package"
                fi
            else
                print_warning "No AUR helper found (yay/paru)"
                print_status "You can install manually: sudo pacman -S $package"
            fi
        fi
    fi
}

# Main installation function
main() {
    echo "=========================================="
    echo "    SwordofKings: Debian to Arch Converter"
    echo "    Automatic Package Detection & Conversion"
    echo "=========================================="
    echo ""
    
    # Check compatibility
    check_compatibility
    
    # Create package mapping database
    create_package_mapping
    
    echo ""
    echo "=========================================="
    print_success "SwordofKings installation completed!"
    echo "=========================================="
    echo ""
    echo "⚔️  SwordofKings Features:"
    echo "  • Automatic Debian package detection"
    echo "  • .deb file extraction and conversion"
    echo "  • Command-based package detection"
    echo "  • File-based package detection"
    echo "  • Comprehensive package mapping database"
    echo ""
    echo "🔧 Usage Examples:"
    echo "  • ./SwordofKings.sh package.deb        # Convert .deb file"
    echo "  • ./SwordofKings.sh nginx              # Convert package name"
    echo "  • ./SwordofKings.sh python3            # Convert command"
    echo "  • ./SwordofKings.sh app.py             # Convert file"
    echo ""
    echo "📋 Supported Conversions:"
    echo "  • Web servers (nginx, apache)"
    echo "  • Databases (mysql, postgresql)"
    echo "  • Languages (python, nodejs, php, java)"
    echo "  • Development tools (git, gcc, cmake)"
    echo "  • System tools (htop, rsync, curl)"
    echo "  • Security tools (ufw, fail2ban)"
    echo "  • Containers (docker, podman)"
    echo "  • And 100+ more packages!"
    echo ""
    echo "🚀 SwordofKings is ready to convert Debian packages to Arch!"
    echo ""
}

# Check if script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # If no arguments provided, run installation
    if [ $# -eq 0 ]; then
        main
    else
        # Run detection on provided input
        detect_debian_package "$1"
    fi
fi
