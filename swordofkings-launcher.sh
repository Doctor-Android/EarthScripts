#!/bin/bash
# SwordofKings Launcher

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_sword() {
    echo -e "${PURPLE}[SWORD]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "SwordofKings - Debian to Arch Package Converter"
    echo ""
    echo "Usage: swordofkings <input>"
    echo ""
    echo "Input types:"
    echo "  .deb file     - Extract and convert Debian package"
    echo "  package name  - Convert Debian package name to Arch"
    echo "  command       - Detect package from command"
    echo "  file path     - Detect package from file"
    echo ""
    echo "Examples:"
    echo "  swordofkings package.deb"
    echo "  swordofkings nginx"
    echo "  swordofkings python3"
    echo "  swordofkings app.py"
    echo "  swordofkings /usr/bin/mysql"
    echo ""
    echo "Options:"
    echo "  --help        - Show this help"
    echo "  --update      - Update package mappings"
    echo "  --list        - List all mappings"
    echo "  --install     - Install SwordofKings system-wide"
}

# Function to update mappings
update_mappings() {
    print_sword "Updating package mappings..."
    # This would download latest mappings from a repository
    print_success "Mappings updated"
}

# Function to list mappings
list_mappings() {
    print_sword "Listing package mappings..."
    if [ -f "/opt/swordofkings/mappings/debian-to-arch.json" ]; then
        jq -r '.[] | to_entries[] | "\(.key) -> \(.value)"' /opt/swordofkings/mappings/debian-to-arch.json | sort
    else
        echo "Mappings not found. Run --install first."
    fi
}

# Function to install system-wide
install_system_wide() {
    print_sword "Installing SwordofKings system-wide..."
    
    # Copy main script
    sudo cp SwordofKings.sh /usr/local/bin/swordofkings-core
    sudo chmod +x /usr/local/bin/swordofkings-core
    
    # Create launcher
    sudo tee /usr/local/bin/swordofkings > /dev/null << 'EOF'
#!/bin/bash
# SwordofKings System Launcher

# Source the core functions
source /usr/local/bin/swordofkings-core

# Check if script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # If no arguments provided, show usage
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi
    
    case "$1" in
        --help)
            show_usage
            ;;
        --update)
            update_mappings
            ;;
        --list)
            list_mappings
            ;;
        --install)
            install_system_wide
            ;;
        *)
            # Run detection on provided input
            detect_debian_package "$1"
            ;;
    esac
fi
EOF
    
    sudo chmod +x /usr/local/bin/swordofkings
    
    # Create aliases
    sudo tee /etc/profile.d/swordofkings-aliases.sh > /dev/null << 'EOF'
# SwordofKings Aliases
alias sword='swordofkings'
alias deb2arch='swordofkings'
alias convert-deb='swordofkings'
EOF
    
    print_success "SwordofKings installed system-wide"
    echo "You can now use: swordofkings, sword, deb2arch, or convert-deb"
}

# Main function
main() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi
    
    case "$1" in
        --help)
            show_usage
            ;;
        --update)
            update_mappings
            ;;
        --list)
            list_mappings
            ;;
        --install)
            install_system_wide
            ;;
        *)
            # Source the main script and call detect function
            source ./SwordofKings.sh
            detect_debian_package "$1"
            ;;
    esac
}

# Run main function
main "$@" 