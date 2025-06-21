#!/bin/bash
# SwordofKings Batch Converter

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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_sword() {
    echo -e "${PURPLE}[SWORD]${NC} $1"
}

# Function to convert requirements.txt
convert_requirements() {
    local file="$1"
    print_sword "Converting Python requirements: $file"
    
    if [ -f "$file" ]; then
        while IFS= read -r line; do
            # Skip comments and empty lines
            [[ $line =~ ^[[:space:]]*# ]] && continue
            [[ -z $line ]] && continue
            
            # Extract package name
            local package=$(echo "$line" | cut -d'=' -f1 | cut -d'>' -f1 | cut -d'<' -f1 | cut -d'!' -f1 | xargs)
            
            if [ -n "$package" ]; then
                print_status "Converting: $package"
                source ./SwordofKings.sh
                detect_debian_package "$package"
            fi
        done < "$file"
    else
        print_error "Requirements file not found: $file"
    fi
}

# Function to convert package.list
convert_package_list() {
    local file="$1"
    print_sword "Converting package list: $file"
    
    if [ -f "$file" ]; then
        while IFS= read -r line; do
            # Skip comments and empty lines
            [[ $line =~ ^[[:space:]]*# ]] && continue
            [[ -z $line ]] && continue
            
            local package=$(echo "$line" | xargs)
            
            if [ -n "$package" ]; then
                print_status "Converting: $package"
                source ./SwordofKings.sh
                detect_debian_package "$package"
            fi
        done < "$file"
    else
        print_error "Package list not found: $file"
    fi
}

# Function to convert all .deb files in directory
convert_deb_directory() {
    local directory="$1"
    print_sword "Converting .deb files in: $directory"
    
    if [ -d "$directory" ]; then
        for deb_file in "$directory"/*.deb; do
            if [ -f "$deb_file" ]; then
                print_status "Converting: $deb_file"
                source ./SwordofKings.sh
                detect_debian_package "$deb_file"
            fi
        done
    else
        print_error "Directory not found: $directory"
    fi
}

# Function to convert from command line list
convert_package_list_cmd() {
    local packages="$1"
    print_sword "Converting packages from command line: $packages"
    
    IFS=' ' read -ra package_array <<< "$packages"
    for package in "${package_array[@]}"; do
        if [ -n "$package" ]; then
            print_status "Converting: $package"
            source ./SwordofKings.sh
            detect_debian_package "$package"
        fi
    done
}

# Function to create sample files
create_samples() {
    print_sword "Creating sample files..."
    
    # Create sample requirements.txt
    cat > sample-requirements.txt << 'EOF'
# Sample Python requirements.txt
flask==2.0.1
requests>=2.25.0
numpy<1.22.0
pandas
matplotlib
EOF
    
    # Create sample package list
    cat > sample-packages.list << 'EOF'
# Sample Debian package list
nginx
python3
mysql-server
docker.io
htop
vim
firefox
vlc
EOF
    
    print_success "Sample files created:"
    echo "  • sample-requirements.txt"
    echo "  • sample-packages.list"
}

# Show usage
show_usage() {
    echo "SwordofKings Batch Converter"
    echo ""
    echo "Usage: swordofkings-batch.sh <type> <file/directory/packages>"
    echo ""
    echo "Types:"
    echo "  requirements  - Convert Python requirements.txt"
    echo "  packages      - Convert package list file"
    echo "  deb-dir       - Convert all .deb files in directory"
    echo "  cmd-list      - Convert packages from command line list"
    echo "  samples       - Create sample files"
    echo ""
    echo "Examples:"
    echo "  swordofkings-batch.sh requirements requirements.txt"
    echo "  swordofkings-batch.sh packages debian-packages.list"
    echo "  swordofkings-batch.sh deb-dir /path/to/deb/files"
    echo "  swordofkings-batch.sh cmd-list 'nginx python3 mysql-server'"
    echo "  swordofkings-batch.sh samples"
    echo ""
    echo "Sample files:"
    echo "  • requirements.txt - Python package requirements"
    echo "  • packages.list    - Debian package names (one per line)"
    echo "  • deb-dir/         - Directory containing .deb files"
}

# Main function
if [ $# -lt 1 ]; then
    show_usage
    exit 1
fi

case "$1" in
    requirements)
        if [ $# -lt 2 ]; then
            print_error "Please provide requirements file path"
            exit 1
        fi
        convert_requirements "$2"
        ;;
    packages)
        if [ $# -lt 2 ]; then
            print_error "Please provide package list file path"
            exit 1
        fi
        convert_package_list "$2"
        ;;
    deb-dir)
        if [ $# -lt 2 ]; then
            print_error "Please provide directory path"
            exit 1
        fi
        convert_deb_directory "$2"
        ;;
    cmd-list)
        if [ $# -lt 2 ]; then
            print_error "Please provide package list"
            exit 1
        fi
        convert_package_list_cmd "$2"
        ;;
    samples)
        create_samples
        ;;
    --help|-h)
        show_usage
        ;;
    *)
        print_error "Unknown type: $1"
        show_usage
        exit 1
        ;;
esac 