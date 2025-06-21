#!/bin/bash

# PK-Server: Transform Endeavor OS into the Perfect Server Operating System
# GUIless Mode • Automatic Dependencies • Server Management • Stability & Graphics

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

print_server() {
    echo -e "${PURPLE}[SERVER]${NC} $1"
}

print_stable() {
    echo -e "${CYAN}[STABLE]${NC} $1"
}

print_gui() {
    echo -e "${PURPLE}[GUI]${NC} $1"
}

# ASCII Art
PK_SERVER_LOGO="
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║  ██████╗ ██╗  ██╗    ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗  ║
    ║  ██╔══██╗██║ ██╔╝    ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗ ║
    ║  ██████╔╝█████╔╝     ███████╗███████╗██████╔╝██║   ██║█████╗  ██████╔╝ ║
    ║  ██╔═══╝ ██╔═██╗     ╚════██║╚════██║██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗ ║
    ║  ██║     ██║  ██╗    ███████║███████║██║  ██║ ╚████╔╝ ███████╗██║  ██║ ║
    ║  ╚═╝     ╚═╝  ╚═╝    ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝ ║
    ║                                                              ║
    ║              ENDEAVOR OS SERVER TRANSFORMATION              ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if package is installed
package_installed() {
    pacman -Q "$1" >/dev/null 2>&1
}

# Function to check if service is enabled
service_enabled() {
    systemctl is-enabled "$1" >/dev/null 2>&1
}

# Function to detect server hardware
detect_server_hardware() {
    print_server "Detecting server hardware..."
    
    # CPU info
    cpu_cores=$(nproc)
    cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
    
    # Memory info
    total_mem=$(free -h | grep Mem | awk '{print $2}')
    available_mem=$(free -h | grep Mem | awk '{print $7}')
    
    # Disk info
    disk_space=$(df -h / | awk 'NR==2 {print $4}')
    
    # Network interfaces
    network_interfaces=$(ip link show | grep -E "^[0-9]+:" | cut -d: -f2 | tr -d ' ')
    
    echo ""
    print_server "Server Hardware Summary:"
    echo "=============================="
    echo "CPU: $cpu_model ($cpu_cores cores)"
    echo "Memory: $total_mem total, $available_mem available"
    echo "Disk Space: $disk_space available"
    echo "Network Interfaces: $network_interfaces"
    echo ""
}

# Function to create server backup
create_server_backup() {
    print_stable "Creating server system backup..."
    
    # Create backup directory
    sudo mkdir -p /opt/pk-server-backup
    
    # Backup current system configuration
    sudo cp -r /etc/systemd /opt/pk-server-backup/systemd.backup 2>/dev/null || print_warning "Could not backup systemd"
    sudo cp -r /etc/network /opt/pk-server-backup/network.backup 2>/dev/null || print_warning "Could not backup network"
    sudo cp -r /etc/ssh /opt/pk-server-backup/ssh.backup 2>/dev/null || print_warning "Could not backup SSH"
    
    # Backup current packages
    pacman -Q > /opt/pk-server-backup/installed-packages.list
    
    # Backup current services
    systemctl list-unit-files --state=enabled > /opt/pk-server-backup/enabled-services.list
    
    print_success "Server backup completed at /opt/pk-server-backup/"
}

# Function to check system compatibility
check_server_compatibility() {
    print_stable "Checking server system compatibility..."
    
    # Check if we're on Arch/Endeavor OS
    if ! command_exists pacman; then
        print_error "This script is designed for Arch-based systems (Endeavor OS)"
        exit 1
    fi
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        exit 1
    fi
    
    # Check available disk space (need at least 5GB for server setup)
    available_space=$(df / | awk 'NR==2 {print $4}')
    if [ "$available_space" -lt 5242880 ]; then  # 5GB in KB
        print_error "Insufficient disk space. Need at least 5GB free."
        exit 1
    fi
    
    # Check if system is up to date
    print_status "Checking if system is up to date..."
    sudo pacman -Sy
    if [ "$(pacman -Qu | wc -l)" -gt 0 ]; then
        print_warning "System has pending updates. It's recommended to update first."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Please run: sudo pacman -Syu"
            exit 1
        fi
    fi
    
    print_success "Server compatibility check passed"
}

# Function to install package safely
install_package_safe() {
    local package=$1
    local description=$2
    
    if package_installed "$package"; then
        print_warning "$description ($package) is already installed"
    else
        print_status "Installing $description ($package)..."
        if sudo pacman -S --noconfirm "$package"; then
            print_success "$description installed successfully"
        else
            print_error "Failed to install $package"
            return 1
        fi
    fi
}

# Function to enable minimal GUI mode (instead of completely GUIless)
enable_minimal_gui_mode() {
    print_gui "Enabling minimal GUI server mode..."
    
    # Keep display manager but use minimal desktop
    if service_enabled "gdm"; then
        print_success "Keeping GDM display manager"
    elif service_enabled "lightdm"; then
        print_success "Keeping LightDM display manager"
    elif service_enabled "sddm"; then
        print_success "Keeping SDDM display manager"
    else
        # Install minimal display manager if none exists
        install_package_safe "lightdm" "LightDM Display Manager" || return 1
        sudo systemctl enable lightdm
        print_success "Installed and enabled LightDM"
    fi
    
    # Install minimal desktop environment (Openbox)
    install_package_safe "openbox" "Openbox Window Manager" || return 1
    install_package_safe "xorg-server" "X11 Server" || return 1
    install_package_safe "xorg-xinit" "X11 Init" || return 1
    
    # Install minimal GUI utilities
    install_package_safe "lxappearance" "GTK Theme Switcher" || print_warning "lxappearance not available"
    install_package_safe "obconf" "Openbox Configuration" || print_warning "obconf not available"
    
    # Remove heavy desktop environments but keep minimal ones
    print_status "Removing heavy desktop environments..."
    sudo pacman -Rns --noconfirm gnome gnome-extra kde-applications xfce4 xfce4-goodies 2>/dev/null || print_warning "Some heavy GUI packages not found"
    
    # Set default target to graphical (but with minimal GUI)
    sudo systemctl set-default graphical.target
    print_success "Set default target to graphical (minimal GUI)"
    
    # Create minimal Openbox configuration
    mkdir -p ~/.config/openbox
    cat << 'EOF' > ~/.config/openbox/autostart
# PK-Server Minimal GUI Autostart
# Start server dashboard in background
/usr/local/bin/pk-server-dashboard.sh &
EOF
    
    # Create Openbox menu
    cat << 'EOF' > ~/.config/openbox/menu.xml
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">
  <menu id="root-menu" label="PK-Server">
    <item label="Server Dashboard">
      <action name="Execute">
        <command>/usr/local/bin/pk-server-dashboard.sh</command>
      </action>
    </item>
    <item label="Terminal">
      <action name="Execute">
        <command>xterm</command>
      </action>
    </item>
    <item label="File Manager">
      <action name="Execute">
        <command>ranger</command>
      </action>
    </item>
    <item label="System Monitor">
      <action name="Execute">
        <command>htop</command>
      </action>
    </item>
    <separator />
    <item label="Reboot">
      <action name="Execute">
        <command>sudo reboot</command>
      </action>
    </item>
    <item label="Shutdown">
      <action name="Execute">
        <command>sudo shutdown -h now</command>
      </action>
    </item>
  </menu>
</openbox_menu>
EOF
    
    # Create .xinitrc for manual GUI start
    cat << 'EOF' > ~/.xinitrc
#!/bin/bash
# PK-Server Minimal GUI Startup

# Start Openbox
exec openbox-session
EOF
    
    chmod +x ~/.xinitrc
    
    print_success "Minimal GUI mode enabled - Minecraft and other GUI apps will work"
}

# Function to install server essentials
install_server_essentials() {
    print_server "Installing server essentials..."
    
    # System monitoring
    install_package_safe "htop" "System Monitor" || return 1
    install_package_safe "btop" "Advanced System Monitor" || return 1
    install_package_safe "iotop" "I/O Monitor" || return 1
    install_package_safe "nethogs" "Network Monitor" || return 1
    
    # File management
    install_package_safe "ranger" "Terminal File Manager" || return 1
    install_package_safe "mc" "Midnight Commander" || return 1
    install_package_safe "tree" "Directory Tree" || return 1
    
    # Network tools
    install_package_safe "nmap" "Network Scanner" || return 1
    install_package_safe "netcat" "Network Utility" || return 1
    install_package_safe "curl" "HTTP Client" || return 1
    install_package_safe "wget" "File Downloader" || return 1
    install_package_safe "rsync" "File Synchronization" || return 1
    
    # Text editors
    install_package_safe "vim" "Text Editor" || return 1
    install_package_safe "nano" "Simple Text Editor" || return 1
    install_package_safe "micro" "Modern Text Editor" || return 1
    
    # Terminal multiplexers
    install_package_safe "tmux" "Terminal Multiplexer" || return 1
    install_package_safe "screen" "Terminal Multiplexer" || return 1
    
    # System utilities
    install_package_safe "neofetch" "System Info" || return 1
    install_package_safe "inxi" "System Information" || return 1
    install_package_safe "lsof" "List Open Files" || return 1
    install_package_safe "strace" "System Call Tracer" || return 1
    
    print_success "Server essentials installed"
}

# Function to install web server stack
install_web_server_stack() {
    print_server "Installing web server stack..."
    
    # Web servers
    install_package_safe "nginx" "Nginx Web Server" || return 1
    install_package_safe "apache" "Apache Web Server" || return 1
    install_package_safe "lighttpd" "Lighttpd Web Server" || return 1
    
    # Database servers
    install_package_safe "mariadb" "MariaDB Database" || return 1
    install_package_safe "postgresql" "PostgreSQL Database" || return 1
    install_package_safe "redis" "Redis Cache" || return 1
    
    # PHP and Python
    install_package_safe "php" "PHP Runtime" || return 1
    install_package_safe "php-fpm" "PHP-FPM" || return 1
    install_package_safe "python" "Python Runtime" || return 1
    install_package_safe "python-pip" "Python Package Manager" || return 1
    
    # Node.js
    install_package_safe "nodejs" "Node.js Runtime" || return 1
    install_package_safe "npm" "Node.js Package Manager" || return 1
    
    print_success "Web server stack installed"
}

# Function to install development tools
install_development_tools() {
    print_server "Installing development tools..."
    
    # Version control
    install_package_safe "git" "Git Version Control" || return 1
    install_package_safe "subversion" "SVN Version Control" || return 1
    
    # Build tools
    install_package_safe "base-devel" "Base Development Tools" || return 1
    install_package_safe "cmake" "CMake Build System" || return 1
    install_package_safe "make" "Make Build System" || return 1
    
    # Programming languages
    install_package_safe "gcc" "GNU Compiler Collection" || return 1
    install_package_safe "clang" "LLVM Compiler" || return 1
    install_package_safe "go" "Go Programming Language" || return 1
    install_package_safe "rust" "Rust Programming Language" || return 1
    
    # Development utilities
    install_package_safe "valgrind" "Memory Debugger" || return 1
    install_package_safe "gdb" "GNU Debugger" || return 1
    install_package_safe "lldb" "LLVM Debugger" || return 1
    
    print_success "Development tools installed"
}

# Function to install security tools
install_security_tools() {
    print_server "Installing security tools..."
    
    # Firewall
    install_package_safe "ufw" "Uncomplicated Firewall" || return 1
    install_package_safe "iptables" "IP Tables" || return 1
    
    # Security monitoring
    install_package_safe "fail2ban" "Fail2Ban" || return 1
    install_package_safe "rkhunter" "Rootkit Hunter" || return 1
    install_package_safe "chkrootkit" "Rootkit Checker" || return 1
    
    # Network security
    install_package_safe "wireshark-cli" "Network Analyzer" || return 1
    install_package_safe "tcpdump" "Packet Analyzer" || return 1
    install_package_safe "nmap" "Network Scanner" || return 1
    
    # SSL/TLS tools
    install_package_safe "openssl" "SSL/TLS Toolkit" || return 1
    install_package_safe "certbot" "Let's Encrypt Client" || return 1
    
    print_success "Security tools installed"
}

# Function to create server dashboard
create_server_dashboard() {
    print_server "Creating server dashboard..."
    
    # Create dashboard script
    cat << 'EOF' | sudo tee /usr/local/bin/pk-server-dashboard.sh
#!/bin/bash

# PK-Server Dashboard
# Endeavor OS Server Management Interface

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# ASCII Art
PK_SERVER_LOGO="
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║  ██████╗ ██╗  ██╗    ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗  ║
    ║  ██╔══██╗██║ ██╔╝    ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗ ║
    ║  ██████╔╝█████╔╝     ███████╗███████╗██████╔╝██║   ██║█████╗  ██████╔╝ ║
    ║  ██╔═══╝ ██╔═██╗     ╚════██║╚════██║██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗ ║
    ║  ██║     ██║  ██╗    ███████║███████║██║  ██║ ╚████╔╝ ███████╗██║  ██║ ║
    ║  ╚═╝     ╚═╝  ╚═╝    ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝ ║
    ║                                                              ║
    ║              ENDEAVOR OS SERVER DASHBOARD                   ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
"

# Function to show system info
show_system_info() {
    clear
    echo -e "${BLUE}System Information${NC}"
    echo "----------------------------------------"
    neofetch
    echo "----------------------------------------"
    read -p "Press Enter to continue..."
}

# Function to show server services
show_server_services() {
    clear
    echo -e "${GREEN}Server Services Status${NC}"
    echo "----------------------------------------"
    
    services=("nginx" "apache" "mariadb" "postgresql" "redis" "fail2ban" "ufw")
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            echo -e "✓ $service: ${GREEN}Running${NC}"
        else
            echo -e "✗ $service: ${RED}Stopped${NC}"
        fi
    done
    
    echo "----------------------------------------"
    read -p "Press Enter to continue..."
}

# Function to launch server tools
launch_server_tools() {
    while true; do
        clear
        echo -e "${GREEN}Server Tools${NC}"
        echo "----------------------------------------"
        echo "1) System Monitoring (htop)"
        echo "2) Network Monitor (nethogs)"
        echo "3) File Manager (ranger)"
        echo "4) Network Scanner (nmap)"
        echo "5) Database Management"
        echo "6) Web Server Management"
        echo "7) Security Tools"
        echo "8) Return to Main Menu"
        echo "----------------------------------------"
        read -p "Select an option: " choice

        case $choice in
            1) htop ;;
            2) sudo nethogs ;;
            3) ranger ;;
            4) nmap -sP 192.168.1.0/24 ;;
            5) launch_database_tools ;;
            6) launch_web_server_tools ;;
            7) launch_security_tools ;;
            8) break ;;
        esac
    done
}

# Function to launch database tools
launch_database_tools() {
    clear
    echo -e "${YELLOW}Database Management${NC}"
    echo "----------------------------------------"
    echo "1) MariaDB Console"
    echo "2) PostgreSQL Console"
    echo "3) Redis CLI"
    echo "4) Return"
    read -p "Select option: " db_choice
    case $db_choice in
        1) sudo mysql -u root -p ;;
        2) sudo -u postgres psql ;;
        3) redis-cli ;;
        4) return ;;
    esac
}

# Function to launch web server tools
launch_web_server_tools() {
    clear
    echo -e "${YELLOW}Web Server Management${NC}"
    echo "----------------------------------------"
    echo "1) Nginx Status"
    echo "2) Apache Status"
    echo "3) Restart Nginx"
    echo "4) Restart Apache"
    echo "5) Return"
    read -p "Select option: " web_choice
    case $web_choice in
        1) sudo systemctl status nginx ;;
        2) sudo systemctl status apache ;;
        3) sudo systemctl restart nginx ;;
        4) sudo systemctl restart apache ;;
        5) return ;;
    esac
}

# Function to launch security tools
launch_security_tools() {
    clear
    echo -e "${YELLOW}Security Tools${NC}"
    echo "----------------------------------------"
    echo "1) UFW Status"
    echo "2) Fail2Ban Status"
    echo "3) Rootkit Check"
    echo "4) Return"
    read -p "Select option: " sec_choice
    case $sec_choice in
        1) sudo ufw status ;;
        2) sudo fail2ban-client status ;;
        3) sudo rkhunter --check ;;
        4) return ;;
    esac
}

# Function to manage server programs
manage_server_programs() {
    while true; do
        clear
        echo -e "${GREEN}Server Program Management${NC}"
        echo "----------------------------------------"
        echo "1) Install Web Server"
        echo "2) Install Database"
        echo "3) Install Development Tools"
        echo "4) Install Security Tools"
        echo "5) Auto-install Dependencies"
        echo "6) Install Minecraft Launcher"
        echo "7) Return to Main Menu"
        echo "----------------------------------------"
        read -p "Select an option: " choice

        case $choice in
            1) install_web_server ;;
            2) install_database ;;
            3) install_dev_tools ;;
            4) install_security_tools ;;
            5) auto_install_dependencies ;;
            6) install_minecraft ;;
            7) break ;;
        esac
    done
}

# Function to install web server
install_web_server() {
    echo -e "${YELLOW}Installing Web Server...${NC}"
    sudo pacman -S --noconfirm nginx apache php php-fpm
    sudo systemctl enable nginx
    sudo systemctl start nginx
    echo -e "${GREEN}Web server installed and started!${NC}"
    sleep 2
}

# Function to install database
install_database() {
    echo -e "${YELLOW}Installing Database...${NC}"
    sudo pacman -S --noconfirm mariadb postgresql redis
    sudo systemctl enable mariadb
    sudo systemctl start mariadb
    echo -e "${GREEN}Database installed and started!${NC}"
    sleep 2
}

# Function to install dev tools
install_dev_tools() {
    echo -e "${YELLOW}Installing Development Tools...${NC}"
    sudo pacman -S --noconfirm base-devel git cmake gcc clang go rust
    echo -e "${GREEN}Development tools installed!${NC}"
    sleep 2
}

# Function to install security tools
install_security_tools() {
    echo -e "${YELLOW}Installing Security Tools...${NC}"
    sudo pacman -S --noconfirm ufw fail2ban rkhunter wireshark-cli
    sudo systemctl enable ufw
    sudo systemctl enable fail2ban
    echo -e "${GREEN}Security tools installed!${NC}"
    sleep 2
}

# Function to install Minecraft
install_minecraft() {
    echo -e "${YELLOW}Installing Minecraft Launcher...${NC}"
    sudo pacman -S --noconfirm minecraft-launcher
    echo -e "${GREEN}Minecraft launcher installed!${NC}"
    echo -e "${CYAN}You can now run: minecraft-launcher${NC}"
    sleep 2
}

# Function to auto-install dependencies
auto_install_dependencies() {
    echo -e "${YELLOW}Auto-installing dependencies for common server programs...${NC}"
    
    # Common dependencies
    sudo pacman -S --noconfirm base-devel git cmake make gcc clang
    
    # Web development dependencies
    sudo pacman -S --noconfirm nodejs npm python python-pip php
    
    # Database dependencies
    sudo pacman -S --noconfirm mariadb postgresql redis
    
    # Security dependencies
    sudo pacman -S --noconfirm ufw fail2ban openssl
    
    echo -e "${GREEN}Dependencies installed!${NC}"
    sleep 2
}

# Main menu loop
while true; do
    clear
    echo -e "${PK_SERVER_LOGO}"
    echo -e "${GREEN}PK-Server Dashboard${NC}"
    echo "----------------------------------------"
    echo "1) System Information"
    echo "2) Server Services Status"
    echo "3) Launch Server Tools"
    echo "4) Manage Server Programs"
    echo "5) Network Configuration (nmtui)"
    echo "6) System Update"
    echo "7) Launch Minecraft"
    echo "8) Reboot System"
    echo "9) Shutdown System"
    echo "0) Exit to Shell"
    echo "----------------------------------------"
    read -p "Select an option: " choice

    case $choice in
        1) show_system_info ;;
        2) show_server_services ;;
        3) launch_server_tools ;;
        4) manage_server_programs ;;
        5)
            clear
            echo -e "${YELLOW}Launching nmtui for network configuration...${NC}"
            sleep 1
            nmtui
            ;;
        6)
            echo -e "${YELLOW}Updating system...${NC}"
            sudo pacman -Syu --noconfirm
            echo -e "${GREEN}System updated!${NC}"
            sleep 2
            ;;
        7)
            echo -e "${YELLOW}Launching Minecraft...${NC}"
            minecraft-launcher &
            ;;
        8)
            echo -e "${YELLOW}Rebooting system...${NC}"
            sleep 2
            sudo reboot
            ;;
        9)
            echo -e "${YELLOW}Shutting down system...${NC}"
            sleep 2
            sudo shutdown -h now
            ;;
        0)
            echo -e "${YELLOW}Exiting to shell...${NC}"
            sleep 1
            exit 0
            ;;
    esac
done
EOF
    
    # Make dashboard executable
    sudo chmod +x /usr/local/bin/pk-server-dashboard.sh
    
    # Create desktop shortcut for dashboard
    mkdir -p ~/Desktop
    cat << 'EOF' > ~/Desktop/PK-Server-Dashboard.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=PK-Server Dashboard
Comment=Server Management Dashboard
Exec=/usr/local/bin/pk-server-dashboard.sh
Icon=terminal
Terminal=true
Categories=System;
EOF
    
    chmod +x ~/Desktop/PK-Server-Dashboard.desktop
    
    print_success "Server dashboard created and enabled"
}

# Function to configure server services
configure_server_services() {
    print_server "Configuring server services..."
    
    # Configure UFW firewall
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw allow 80/tcp  # HTTP
    sudo ufw allow 443/tcp # HTTPS
    sudo ufw allow 22/tcp  # SSH
    sudo ufw --force enable
    
    # Configure fail2ban
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban
    
    # Configure MariaDB
    sudo systemctl enable mariadb
    sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
    
    # Configure PostgreSQL
    sudo systemctl enable postgresql
    sudo -u postgres initdb -D /var/lib/postgres/data
    
    # Configure Redis
    sudo systemctl enable redis
    sudo systemctl start redis
    
    # Configure Nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
    
    print_success "Server services configured"
}

# Function to create server aliases
create_server_aliases() {
    print_server "Creating server aliases..."
    
    # Create aliases file
    cat << 'EOF' | sudo tee /etc/profile.d/pk-server-aliases.sh
# PK-Server Aliases
alias server-status='systemctl status'
alias server-start='sudo systemctl start'
alias server-stop='sudo systemctl stop'
alias server-restart='sudo systemctl restart'
alias server-enable='sudo systemctl enable'
alias server-disable='sudo systemctl disable'

alias web-status='systemctl status nginx apache'
alias web-restart='sudo systemctl restart nginx apache'

alias db-status='systemctl status mariadb postgresql redis'
alias db-restart='sudo systemctl restart mariadb postgresql redis'

alias sec-status='sudo ufw status && sudo fail2ban-client status'

alias server-update='sudo pacman -Syu'
alias server-clean='sudo pacman -Sc'

alias server-dashboard='/usr/local/bin/pk-server-dashboard.sh'
alias server-info='neofetch'

# Quick access to common directories
alias web-dir='cd /srv/http'
alias log-dir='cd /var/log'
alias config-dir='cd /etc'
EOF
    
    print_success "Server aliases created"
}

# Function to integrate PK-Stable features
integrate_pk_stable() {
    print_stable "Integrating PK-Stable features..."
    
    # Install LTS kernel
    install_package_safe "linux-lts" "LTS Kernel" || print_warning "LTS kernel not available"
    
    # Install system monitoring tools
    install_package_safe "iotop" "I/O Monitor" || return 1
    install_package_safe "smartmontools" "SMART Monitoring" || return 1
    
    # Install system hardening tools
    install_package_safe "apparmor" "AppArmor" || return 1
    install_package_safe "firejail" "Firejail" || return 1
    
    # Configure system hardening
    sudo systemctl enable apparmor
    
    # Create maintenance script
    cat << 'EOF' | sudo tee /usr/local/bin/pk-server-maintenance.sh
#!/bin/bash
# PK-Server Maintenance Script

echo "=== PK-Server Maintenance ==="
echo ""

# Update system
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Clean package cache
echo "Cleaning package cache..."
sudo pacman -Sc --noconfirm

# Check disk space
echo "Checking disk space..."
df -h

# Check system logs
echo "Checking system logs..."
journalctl --since "1 day ago" --no-pager | tail -20

# Check service status
echo "Checking critical services..."
systemctl status nginx mariadb postgresql redis fail2ban ufw --no-pager

echo ""
echo "Maintenance completed!"
EOF
    
    sudo chmod +x /usr/local/bin/pk-server-maintenance.sh
    
    print_success "PK-Stable features integrated"
}

# Function to integrate PK-Graphics features
integrate_pk_graphics() {
    print_stable "Integrating PK-Graphics features..."
    
    # Install graphics drivers for server rendering
    install_package_safe "mesa" "Mesa Graphics" || return 1
    install_package_safe "mesa-utils" "Mesa Utilities" || return 1
    install_package_safe "vulkan-tools" "Vulkan Tools" || return 1
    
    # Install GPU monitoring
    install_package_safe "nvtop" "GPU Monitor" || print_warning "nvtop not available"
    
    # Install graphics libraries for server applications
    install_package_safe "cairo" "Cairo Graphics" || return 1
    install_package_safe "pango" "Pango Text Layout" || return 1
    install_package_safe "gdk-pixbuf2" "GDK Pixbuf" || return 1
    
    print_success "PK-Graphics features integrated"
}

# Function to create rollback script
create_rollback_script() {
    print_stable "Creating rollback script..."
    
    cat << 'EOF' | sudo tee /opt/pk-server-backup/rollback.sh
#!/bin/bash
# PK-Server Rollback Script

echo "=== PK-Server Rollback ==="
echo ""

# Restore systemd configuration
if [ -d /opt/pk-server-backup/systemd.backup ]; then
    echo "Restoring systemd configuration..."
    sudo cp -r /opt/pk-server-backup/systemd.backup/* /etc/systemd/
fi

# Restore network configuration
if [ -d /opt/pk-server-backup/network.backup ]; then
    echo "Restoring network configuration..."
    sudo cp -r /opt/pk-server-backup/network.backup/* /etc/network/
fi

# Restore SSH configuration
if [ -d /opt/pk-server-backup/ssh.backup ]; then
    echo "Restoring SSH configuration..."
    sudo cp -r /opt/pk-server-backup/ssh.backup/* /etc/ssh/
fi

# Disable server services
echo "Disabling server services..."
sudo systemctl disable nginx apache mariadb postgresql redis fail2ban ufw

# Remove server packages
echo "Removing server packages..."
sudo pacman -Rns --noconfirm nginx apache mariadb postgresql redis fail2ban ufw rkhunter wireshark-cli

# Re-enable display manager
echo "Re-enabling display manager..."
sudo systemctl enable gdm 2>/dev/null || sudo systemctl enable lightdm 2>/dev/null || sudo systemctl enable sddm 2>/dev/null

# Set default target back to graphical
sudo systemctl set-default graphical.target

# Remove server dashboard
echo "Removing server dashboard..."
sudo rm -f /usr/local/bin/pk-server-dashboard.sh
sudo rm -f /etc/systemd/system/pk-server-autologin.service

echo ""
echo "Rollback completed. Please reboot your system."
echo "Your system will return to normal Endeavor OS mode."
EOF
    
    sudo chmod +x /opt/pk-server-backup/rollback.sh
    print_success "Rollback script created at /opt/pk-server-backup/rollback.sh"
}

# Function to auto-install dependencies for server programs
auto_install_server_dependencies() {
    local program=$1
    print_server "Auto-installing dependencies for: $program"
    
    case $program in
        # Web servers
        "nginx"|"apache"|"httpd")
            print_status "Installing web server dependencies..."
            sudo pacman -S --noconfirm nginx apache php php-fpm python python-pip nodejs npm
            sudo systemctl enable nginx
            sudo systemctl start nginx
            print_success "Web server dependencies installed"
            ;;
        
        # Databases
        "mysql"|"mariadb"|"postgres"|"postgresql"|"redis-server"|"redis")
            print_status "Installing database dependencies..."
            sudo pacman -S --noconfirm mariadb postgresql redis
            sudo systemctl enable mariadb postgresql redis
            sudo systemctl start mariadb postgresql redis
            print_success "Database dependencies installed"
            ;;
        
        # Development servers
        "node"|"npm"|"yarn"|"pnpm")
            print_status "Installing Node.js dependencies..."
            sudo pacman -S --noconfirm nodejs npm yarn
            print_success "Node.js dependencies installed"
            ;;
        
        "python"|"python3"|"pip"|"pip3"|"django"|"flask")
            print_status "Installing Python dependencies..."
            sudo pacman -S --noconfirm python python-pip python-virtualenv
            print_success "Python dependencies installed"
            ;;
        
        "php"|"composer")
            print_status "Installing PHP dependencies..."
            sudo pacman -S --noconfirm php php-fpm composer
            print_success "PHP dependencies installed"
            ;;
        
        "java"|"javac"|"mvn"|"gradle")
            print_status "Installing Java dependencies..."
            sudo pacman -S --noconfirm jre-openjdk jdk-openjdk maven gradle
            print_success "Java dependencies installed"
            ;;
        
        "go"|"golang")
            print_status "Installing Go dependencies..."
            sudo pacman -S --noconfirm go
            print_success "Go dependencies installed"
            ;;
        
        "rust"|"cargo")
            print_status "Installing Rust dependencies..."
            sudo pacman -S --noconfirm rust
            print_success "Rust dependencies installed"
            ;;
        
        # Git servers
        "git"|"gitea"|"gogs")
            print_status "Installing Git server dependencies..."
            sudo pacman -S --noconfirm git
            print_success "Git dependencies installed"
            ;;
        
        # Monitoring servers
        "prometheus"|"grafana"|"zabbix")
            print_status "Installing monitoring dependencies..."
            sudo pacman -S --noconfirm prometheus grafana
            print_success "Monitoring dependencies installed"
            ;;
        
        # Mail servers
        "postfix"|"dovecot"|"exim")
            print_status "Installing mail server dependencies..."
            sudo pacman -S --noconfirm postfix dovecot
            print_success "Mail server dependencies installed"
            ;;
        
        # VPN servers
        "openvpn"|"wireguard")
            print_status "Installing VPN dependencies..."
            sudo pacman -S --noconfirm openvpn wireguard-tools
            print_success "VPN dependencies installed"
            ;;
        
        # Game servers
        "minecraft"|"steam"|"steamcmd")
            print_status "Installing game server dependencies..."
            sudo pacman -S --noconfirm jre-openjdk steam
            print_success "Game server dependencies installed"
            ;;
        
        # File servers
        "samba"|"nfs"|"ftp")
            print_status "Installing file server dependencies..."
            sudo pacman -S --noconfirm samba nfs-utils vsftpd
            print_success "File server dependencies installed"
            ;;
        
        # DNS servers
        "bind"|"dnsmasq")
            print_status "Installing DNS server dependencies..."
            sudo pacman -S --noconfirm bind dnsmasq
            print_success "DNS server dependencies installed"
            ;;
        
        # DHCP servers
        "dhcpd"|"isc-dhcp")
            print_status "Installing DHCP server dependencies..."
            sudo pacman -S --noconfirm dhcp
            print_success "DHCP server dependencies installed"
            ;;
        
        # Proxy servers
        "squid"|"nginx-proxy")
            print_status "Installing proxy server dependencies..."
            sudo pacman -S --noconfirm squid nginx
            print_success "Proxy server dependencies installed"
            ;;
        
        # Container servers
        "docker"|"podman"|"kubernetes")
            print_status "Installing container dependencies..."
            sudo pacman -S --noconfirm docker podman kubectl
            sudo systemctl enable docker
            sudo systemctl start docker
            print_success "Container dependencies installed"
            ;;
        
        # Load balancers
        "haproxy"|"nginx-lb")
            print_status "Installing load balancer dependencies..."
            sudo pacman -S --noconfirm haproxy nginx
            print_success "Load balancer dependencies installed"
            ;;
        
        # Cache servers
        "memcached"|"varnish")
            print_status "Installing cache server dependencies..."
            sudo pacman -S --noconfirm memcached varnish
            print_success "Cache server dependencies installed"
            ;;
        
        # Message queues
        "rabbitmq"|"apache-kafka"|"redis-queue")
            print_status "Installing message queue dependencies..."
            sudo pacman -S --noconfirm rabbitmq redis
            print_success "Message queue dependencies installed"
            ;;
        
        # Search servers
        "elasticsearch"|"solr")
            print_status "Installing search server dependencies..."
            sudo pacman -S --noconfirm elasticsearch
            print_success "Search server dependencies installed"
            ;;
        
        # Backup servers
        "rsync"|"bacula"|"borg")
            print_status "Installing backup server dependencies..."
            sudo pacman -S --noconfirm rsync borg
            print_success "Backup server dependencies installed"
            ;;
        
        # Security servers
        "fail2ban"|"snort"|"suricata")
            print_status "Installing security server dependencies..."
            sudo pacman -S --noconfirm fail2ban snort suricata
            print_success "Security server dependencies installed"
            ;;
        
        *)
            print_warning "Unknown server program: $program"
            print_status "Installing common server dependencies..."
            sudo pacman -S --noconfirm base-devel git cmake make gcc clang
            print_success "Common dependencies installed"
            ;;
    esac
}

# Function to create dependency wrapper scripts
create_dependency_wrappers() {
    print_server "Creating dependency wrapper scripts..."
    
    # Create wrapper directory
    sudo mkdir -p /usr/local/bin/pk-server-wrappers
    
    # Create wrapper for common server programs
    local server_programs=(
        "nginx:nginx"
        "apache:apache"
        "httpd:apache"
        "mysql:mariadb"
        "mariadb:mariadb"
        "postgres:postgresql"
        "postgresql:postgresql"
        "redis:redis"
        "node:nodejs"
        "npm:nodejs"
        "python:python"
        "python3:python"
        "php:php"
        "java:java"
        "javac:java"
        "go:go"
        "rust:rust"
        "cargo:rust"
        "git:git"
        "docker:docker"
        "podman:podman"
        "haproxy:haproxy"
        "memcached:memcached"
        "rsync:rsync"
        "fail2ban:fail2ban"
    )
    
    for program_info in "${server_programs[@]}"; do
        IFS=':' read -r program_name package_name <<< "$program_info"
        
        # Create wrapper script
        cat << EOF | sudo tee "/usr/local/bin/pk-server-wrappers/$program_name"
#!/bin/bash
# PK-Server Dependency Wrapper for $program_name

# Check if program is installed
if ! command -v $program_name >/dev/null 2>&1; then
    echo "PK-Server: Installing dependencies for $program_name..."
    /usr/local/bin/pk-server-auto-deps.sh $program_name
fi

# Run the original program
exec $program_name "\$@"
EOF
        
        sudo chmod +x "/usr/local/bin/pk-server-wrappers/$program_name"
    done
    
    # Create the main auto-dependency script
    cat << 'EOF' | sudo tee /usr/local/bin/pk-server-auto-deps.sh
#!/bin/bash
# PK-Server Auto-Dependency Installer

# Source the dependency function
source /usr/local/bin/pk-server-deps.sh

# Call the auto-install function
auto_install_server_dependencies "$1"
EOF
    
    # Create the dependency functions file
    cat << 'EOF' | sudo tee /usr/local/bin/pk-server-deps.sh
#!/bin/bash
# PK-Server Dependency Functions

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_server() {
    echo -e "${PURPLE}[SERVER]${NC} $1"
}

# Function to auto-install dependencies for server programs
auto_install_server_dependencies() {
    local program=$1
    print_server "Auto-installing dependencies for: $program"
    
    case $program in
        # Web servers
        "nginx"|"apache"|"httpd")
            print_status "Installing web server dependencies..."
            sudo pacman -S --noconfirm nginx apache php php-fpm python python-pip nodejs npm
            sudo systemctl enable nginx
            sudo systemctl start nginx
            print_success "Web server dependencies installed"
            ;;
        
        # Databases
        "mysql"|"mariadb"|"postgres"|"postgresql"|"redis-server"|"redis")
            print_status "Installing database dependencies..."
            sudo pacman -S --noconfirm mariadb postgresql redis
            sudo systemctl enable mariadb postgresql redis
            sudo systemctl start mariadb postgresql redis
            print_success "Database dependencies installed"
            ;;
        
        # Development servers
        "node"|"npm"|"yarn")
            print_status "Installing Node.js dependencies..."
            sudo pacman -S --noconfirm nodejs npm yarn
            print_success "Node.js dependencies installed"
            ;;
        
        "python"|"python3"|"django"|"flask")
            print_status "Installing Python dependencies..."
            sudo pacman -S --noconfirm python python-pip python-virtualenv
            ;;
        
        "php"|"composer")
            print_status "Installing PHP dependencies..."
            sudo pacman -S --noconfirm php php-fpm composer
            ;;
        
        "java"|"javac"|"mvn")
            print_status "Installing Java dependencies..."
            sudo pacman -S --noconfirm jre-openjdk jdk-openjdk maven
            ;;
        
        "go"|"golang")
            print_status "Installing Go dependencies..."
            sudo pacman -S --noconfirm go
            ;;
        
        "rust"|"cargo")
            print_status "Installing Rust dependencies..."
            sudo pacman -S --noconfirm rust
            ;;
        
        # Container servers
        "docker"|"podman")
            print_status "Installing container dependencies..."
            sudo pacman -S --noconfirm docker podman
            sudo systemctl enable docker
            sudo systemctl start docker
            ;;
        
        # Game servers
        "minecraft"|"steam"|"steamcmd")
            print_status "Installing game server dependencies..."
            sudo pacman -S --noconfirm jre-openjdk steam
            ;;
        
        # File servers
        "samba"|"nfs"|"ftp")
            print_status "Installing file server dependencies..."
            sudo pacman -S --noconfirm samba nfs-utils vsftpd
            ;;
        
        # Unknown - install common dependencies
        *)
            print_status "Unknown server type - installing common dependencies..."
            sudo pacman -S --noconfirm base-devel git cmake make gcc clang
            ;;
    esac
}
EOF
    
    sudo chmod +x /usr/local/bin/pk-server-auto-deps.sh
    sudo chmod +x /usr/local/bin/pk-server-deps.sh
    
    # Add wrapper directory to PATH
    echo 'export PATH="/usr/local/bin/pk-server-wrappers:$PATH"' | sudo tee -a /etc/profile.d/pk-server-wrappers.sh
    
    print_success "Dependency wrapper scripts created"
}

# Function to create smart server launcher
create_smart_server_launcher() {
    print_server "Creating smart server launcher..."
    
    cat << 'EOF' | sudo tee /usr/local/bin/pk-server-launch.sh
#!/bin/bash
# PK-Server Smart Launcher
# Automatically installs dependencies and launches server programs

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_server() {
    echo -e "${PURPLE}[SERVER]${NC} $1"
}

# Function to detect server type and install dependencies
detect_and_install_deps() {
    local program=$1
    local args="$2"
    
    print_server "Detecting server type for: $program"
    
    case $program in
        # Web servers
        "nginx"|"apache"|"httpd")
            print_status "Detected web server - installing dependencies..."
            sudo pacman -S --noconfirm nginx apache php php-fpm python python-pip nodejs npm
            sudo systemctl enable nginx
            sudo systemctl start nginx
            ;;
        
        # Databases
        "mysql"|"mariadb"|"postgres"|"postgresql"|"redis-server"|"redis")
            print_status "Detected database server - installing dependencies..."
            sudo pacman -S --noconfirm mariadb postgresql redis
            sudo systemctl enable mariadb postgresql redis
            sudo systemctl start mariadb postgresql redis
            ;;
        
        # Development servers
        "node"|"npm"|"yarn")
            print_status "Detected Node.js server - installing dependencies..."
            sudo pacman -S --noconfirm nodejs npm yarn
            ;;
        
        "python"|"python3"|"django"|"flask")
            print_status "Detected Python server - installing dependencies..."
            sudo pacman -S --noconfirm python python-pip python-virtualenv
            ;;
        
        "php"|"composer")
            print_status "Detected PHP server - installing dependencies..."
            sudo pacman -S --noconfirm php php-fpm composer
            ;;
        
        "java"|"javac"|"mvn")
            print_status "Detected Java server - installing dependencies..."
            sudo pacman -S --noconfirm jre-openjdk jdk-openjdk maven
            ;;
        
        "go"|"golang")
            print_status "Detected Go server - installing dependencies..."
            sudo pacman -S --noconfirm go
            ;;
        
        "rust"|"cargo")
            print_status "Detected Rust server - installing dependencies..."
            sudo pacman -S --noconfirm rust
            ;;
        
        # Container servers
        "docker"|"podman")
            print_status "Detected container server - installing dependencies..."
            sudo pacman -S --noconfirm docker podman
            sudo systemctl enable docker
            sudo systemctl start docker
            ;;
        
        # Game servers
        "minecraft"|"steam"|"steamcmd")
            print_status "Detected game server - installing dependencies..."
            sudo pacman -S --noconfirm jre-openjdk steam
            ;;
        
        # File servers
        "samba"|"nfs"|"ftp")
            print_status "Detected file server - installing dependencies..."
            sudo pacman -S --noconfirm samba nfs-utils vsftpd
            ;;
        
        # Unknown - install common dependencies
        *)
            print_status "Unknown server type - installing common dependencies..."
            sudo pacman -S --noconfirm base-devel git cmake make gcc clang
            ;;
    esac
    
    print_success "Dependencies installed for $program"
}

# Main launcher function
launch_server() {
    local program=$1
    shift
    local args="$@"
    
    print_server "Launching server: $program"
    
    # Check if program exists
    if ! command -v "$program" >/dev/null 2>&1; then
        print_status "Program not found, installing dependencies..."
        detect_and_install_deps "$program" "$args"
    fi
    
    # Launch the server
    print_success "Starting $program..."
    exec "$program" $args
}

# Show usage if no arguments
if [ $# -eq 0 ]; then
    echo "PK-Server Smart Launcher"
    echo "Usage: pk-server-launch.sh <server_program> [arguments]"
    echo ""
    echo "Examples:"
    echo "  pk-server-launch.sh nginx"
    echo "  pk-server-launch.sh mysql"
    echo "  pk-server-launch.sh node app.js"
    echo "  pk-server-launch.sh python manage.py runserver"
    echo "  pk-server-launch.sh java -jar server.jar"
    echo "  pk-server-launch.sh minecraft"
    exit 1
fi

# Launch the server
launch_server "$@"
EOF
    
    sudo chmod +x /usr/local/bin/pk-server-launch.sh
    
    # Create aliases for common server programs
    cat << 'EOF' | sudo tee /etc/profile.d/pk-server-launcher.sh
# PK-Server Launcher Aliases
alias server-nginx='pk-server-launch.sh nginx'
alias server-apache='pk-server-launch.sh apache'
alias server-mysql='pk-server-launch.sh mysql'
alias server-postgres='pk-server-launch.sh postgres'
alias server-redis='pk-server-launch.sh redis'
alias server-node='pk-server-launch.sh node'
alias server-python='pk-server-launch.sh python'
alias server-php='pk-server-launch.sh php'
alias server-java='pk-server-launch.sh java'
alias server-go='pk-server-launch.sh go'
alias server-rust='pk-server-launch.sh cargo'
alias server-docker='pk-server-launch.sh docker'
alias server-minecraft='pk-server-launch.sh minecraft'
alias server-samba='pk-server-launch.sh samba'
alias server-ftp='pk-server-launch.sh vsftpd'
EOF
    
    print_success "Smart server launcher created"
}

# Main installation function
main() {
    echo -e "${PK_SERVER_LOGO}"
    echo ""
    echo "=========================================="
    echo "    PK-Server: Endeavor OS Transformation"
    echo "    Minimal GUI • Server Management • Stability"
    echo "=========================================="
    echo ""
    
    # Check compatibility first
    check_server_compatibility
    
    # Detect server hardware
    detect_server_hardware
    
    # Create backup before making changes
    create_server_backup
    
    # Create rollback script
    create_rollback_script
    
    echo ""
    print_server "Starting PK-Server transformation..."
    echo ""
    
    # Update system first
    print_status "Updating system packages..."
    sudo pacman -Syu --noconfirm
    print_success "System updated"
    
    # Enable minimal GUI mode
    enable_minimal_gui_mode
    
    # Install server components
    install_server_essentials
    install_web_server_stack
    install_development_tools
    install_security_tools
    
    # Integrate PK features
    integrate_pk_stable
    integrate_pk_graphics
    
    # Configure server services
    configure_server_services
    
    # Create server dashboard
    create_server_dashboard
    
    # Create server aliases
    create_server_aliases
    
    # Create dependency wrappers
    create_dependency_wrappers
    
    # Create smart server launcher
    create_smart_server_launcher
    
    # Clean up
    print_status "Cleaning up package cache..."
    sudo pacman -Sc --noconfirm
    print_success "Package cache cleaned"
    
    echo ""
    echo "=========================================="
    print_success "PK-Server transformation completed!"
    echo "=========================================="
    echo ""
    echo "🎯 Server Features Installed:"
    echo "  • Minimal GUI mode (Openbox + LightDM)"
    echo "  • Web server stack (Nginx, Apache, PHP, Python)"
    echo "  • Database servers (MariaDB, PostgreSQL, Redis)"
    echo "  • Development tools (Git, GCC, Node.js, Rust)"
    echo "  • Security tools (UFW, Fail2ban, Rkhunter)"
    echo "  • System monitoring (htop, btop, iotop)"
    echo "  • Terminal dashboard with server management"
    echo "  • Minecraft and GUI app support"
    echo "  • Automatic dependency installation"
    echo ""
    echo "🔧 Server Management:"
    echo "  • Dashboard: /usr/local/bin/pk-server-dashboard.sh"
    echo "  • Desktop Shortcut: ~/Desktop/PK-Server-Dashboard.desktop"
    echo "  • Maintenance: /usr/local/bin/pk-server-maintenance.sh"
    echo "  • Server aliases for quick commands"
    echo ""
    echo "🚀 Automatic Dependency Installation:"
    echo "  • Smart Launcher: pk-server-launch.sh <server_program>"
    echo "  • Auto-installs dependencies when running server programs"
    echo "  • Supports 50+ server types (web, database, game, etc.)"
    echo "  • Quick aliases: server-nginx, server-mysql, server-minecraft"
    echo ""
    echo "📋 Server Program Examples:"
    echo "  • pk-server-launch.sh nginx          # Web server"
    echo "  • pk-server-launch.sh mysql          # Database"
    echo "  • pk-server-launch.sh node app.js    # Node.js app"
    echo "  • pk-server-launch.sh minecraft      # Game server"
    echo "  • pk-server-launch.sh docker         # Container server"
    echo "  • pk-server-launch.sh python app.py  # Python server"
    echo ""
    echo "🎮 Gaming Support:"
    echo "  • Minecraft launcher support"
    echo "  • Minimal GUI for gaming applications"
    echo "  • Graphics drivers installed"
    echo "  • Java runtime available"
    echo ""
    echo "🛡️  Security Features:"
    echo "  • UFW firewall configured"
    echo "  • Fail2ban intrusion prevention"
    echo "  • Rootkit detection"
    echo "  • System hardening (AppArmor, Firejail)"
    echo ""
    echo "🔄 Update Protection:"
    echo "  • System backup at /opt/pk-server-backup/"
    echo "  • Rollback script: sudo /opt/pk-server-backup/rollback.sh"
    echo "  • Safe update process"
    echo "  • Service monitoring"
    echo ""
    echo "⚠️  Important Notes:"
    echo "  • REBOOT YOUR SYSTEM for all changes to take effect"
    echo "  • System will boot to minimal GUI (Openbox)"
    echo "  • Server dashboard available via desktop shortcut"
    echo "  • Server services are auto-started"
    echo "  • Minecraft and other GUI apps will work"
    echo "  • Dependencies auto-install when running server programs"
    echo ""
    echo "🚀 Your Endeavor OS is now transformed into the perfect server OS with automatic dependencies!"
    echo ""
}

# Run main function
main "$@" 