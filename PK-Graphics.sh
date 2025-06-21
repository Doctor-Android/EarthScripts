#!/bin/bash

# Universal Graphics Driver Installation Script
# Supports Intel, NVIDIA, AMD, and other graphics cards
# SAFE & STABLE VERSION with UPDATE PROTECTION

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

print_safe() {
    echo -e "${PURPLE}[SAFETY]${NC} $1"
}

print_stable() {
    echo -e "${CYAN}[STABLE]${NC} $1"
}

print_gpu() {
    echo -e "${PURPLE}[GPU]${NC} $1"
}

print_update() {
    echo -e "${CYAN}[UPDATE]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if package is installed
package_installed() {
    dpkg -l "$1" >/dev/null 2>&1
}

# Function to check kernel compatibility
check_kernel_compatibility() {
    print_update "Checking kernel compatibility..."
    
    current_kernel=$(uname -r)
    print_status "Current kernel: $current_kernel"
    
    # Check if running LTS kernel
    if [[ $current_kernel == *"lts"* ]]; then
        print_success "LTS kernel detected - good for stability"
    else
        print_warning "Non-LTS kernel detected - consider switching to LTS for stability"
    fi
    
    # Check kernel headers
    if package_installed "linux-headers-$(uname -r)"; then
        print_success "Kernel headers installed"
    else
        print_warning "Kernel headers not installed - installing for driver compatibility"
        sudo apt install -y "linux-headers-$(uname -r)"
    fi
    
    # Check for kernel modules
    if [ -d "/lib/modules/$(uname -r)" ]; then
        print_success "Kernel modules directory exists"
    else
        print_error "Kernel modules directory missing - this may cause driver issues"
        return 1
    fi
}

# Function to check package dependencies
check_package_dependencies() {
    print_update "Checking package dependencies..."
    
    # Check for essential packages
    local essential_packages=("build-essential" "dkms" "linux-headers-generic" "firmware-linux")
    
    for package in "${essential_packages[@]}"; do
        if ! package_installed "$package"; then
            print_status "Installing essential package: $package"
            sudo apt install -y "$package"
        fi
    done
    
    # Check for broken packages
    if sudo apt-get check 2>&1 | grep -q "broken"; then
        print_error "Broken packages detected - fixing..."
        sudo apt --fix-broken install -y
    fi
    
    print_success "Package dependencies verified"
}

# Function to create update protection
create_update_protection() {
    print_update "Creating update protection mechanisms..."
    
    # Create update protection directory
    sudo mkdir -p /opt/graphics-driver-backup/update-protection
    
    # Create package hold script
    cat << 'EOF' | sudo tee /opt/graphics-driver-backup/update-protection/hold-graphics-packages.sh
#!/bin/bash
# Hold Graphics Packages Script - Prevents breaking updates

echo "Holding graphics packages to prevent breaking updates..."

# Hold NVIDIA packages
sudo apt-mark hold nvidia-driver-* nvidia-settings nvidia-prime nvidia-modprobe

# Hold Intel packages
sudo apt-mark hold intel-media-va-driver intel-gpu-tool i965-va-driver intel-media-driver

# Hold AMD packages
sudo apt-mark hold libdrm-amdgpu1 libdrm-radeon1 radeontop firmware-amd-graphics

# Hold Mesa packages
sudo apt-mark hold mesa-utils mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers

# Hold Vulkan packages
sudo apt-mark hold vulkan-tools vulkan-validationlayers vulkan-utils

echo "Graphics packages are now held - they won't be updated automatically"
echo "To update them manually, run: sudo /opt/graphics-driver-backup/update-protection/unhold-graphics-packages.sh"
EOF
    
    # Create unhold script
    cat << 'EOF' | sudo tee /opt/graphics-driver-backup/update-protection/unhold-graphics-packages.sh
#!/bin/bash
# Unhold Graphics Packages Script - Allows manual updates

echo "Unholding graphics packages for manual updates..."

# Unhold NVIDIA packages
sudo apt-mark unhold nvidia-driver-* nvidia-settings nvidia-prime nvidia-modprobe

# Unhold Intel packages
sudo apt-mark unhold intel-media-va-driver intel-gpu-tool i965-va-driver intel-media-driver

# Unhold AMD packages
sudo apt-mark unhold libdrm-amdgpu1 libdrm-radeon1 radeontop firmware-amd-graphics

# Unhold Mesa packages
sudo apt-mark unhold mesa-utils mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers

# Unhold Vulkan packages
sudo apt-mark unhold vulkan-tools vulkan-validationlayers vulkan-utils

echo "Graphics packages are now unheld - you can update them manually"
echo "Remember to test after updating!"
EOF
    
    # Create safe update script
    cat << 'EOF' | sudo tee /opt/graphics-driver-backup/update-protection/safe-update.sh
#!/bin/bash
# Safe Update Script - Updates system while protecting graphics drivers

echo "=== Safe System Update ==="
echo ""

# Create snapshot before update
echo "Creating system snapshot..."
sudo timeshift --create --comments "Before safe update $(date)"

# Update system packages (excluding held graphics packages)
echo "Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Check for kernel updates
if sudo apt list --upgradable | grep -q "linux-image"; then
    echo "Kernel update detected - this may require graphics driver reinstallation"
    echo "Please reboot after update and run graphics driver verification"
fi

# Check graphics drivers after update
echo "Verifying graphics drivers..."
if command -v glxinfo >/dev/null 2>&1; then
    if glxinfo | grep -q "OpenGL version"; then
        echo "✓ OpenGL is working"
    else
        echo "✗ OpenGL test failed - graphics drivers may need attention"
    fi
fi

if command -v vulkaninfo >/dev/null 2>&1; then
    if vulkaninfo | grep -q "Vulkan Version"; then
        echo "✓ Vulkan is working"
    else
        echo "✗ Vulkan test failed - graphics drivers may need attention"
    fi
fi

echo ""
echo "Safe update completed!"
echo "If graphics issues occur, run: sudo /opt/graphics-driver-backup/rollback.sh"
EOF
    
    # Create graphics driver verification script
    cat << 'EOF' | sudo tee /opt/graphics-driver-backup/update-protection/verify-graphics.sh
#!/bin/bash
# Graphics Driver Verification Script

echo "=== Graphics Driver Verification ==="
echo ""

# Check OpenGL
echo "Testing OpenGL..."
if command -v glxinfo >/dev/null 2>&1; then
    if glxinfo | grep -q "OpenGL version"; then
        echo "✓ OpenGL: $(glxinfo | grep 'OpenGL version' | head -1)"
    else
        echo "✗ OpenGL test failed"
    fi
else
    echo "✗ glxinfo not found"
fi

# Check Vulkan
echo "Testing Vulkan..."
if command -v vulkaninfo >/dev/null 2>&1; then
    if vulkaninfo | grep -q "Vulkan Version"; then
        echo "✓ Vulkan: $(vulkaninfo | grep 'Vulkan Version' | head -1)"
    else
        echo "✗ Vulkan test failed"
    fi
else
    echo "✗ vulkaninfo not found"
fi

# Check NVIDIA
if command -v nvidia-smi >/dev/null 2>&1; then
    echo "Testing NVIDIA..."
    if nvidia-smi >/dev/null 2>&1; then
        echo "✓ NVIDIA drivers working"
        nvidia-smi --query-gpu=name --format=csv,noheader,nounits
    else
        echo "✗ NVIDIA drivers not working"
    fi
fi

# Check AMD
if command -v radeontop >/dev/null 2>&1; then
    echo "Testing AMD..."
    if timeout 3s radeontop -d - -l 1 >/dev/null 2>&1; then
        echo "✓ AMD drivers working"
    else
        echo "✗ AMD drivers not working"
    fi
fi

# Check Intel
if command -v intel_gpu_top >/dev/null 2>&1; then
    echo "Testing Intel..."
    if timeout 3s intel_gpu_top -J >/dev/null 2>&1; then
        echo "✓ Intel drivers working"
    else
        echo "✗ Intel drivers not working"
    fi
fi

echo ""
echo "Verification completed!"
EOF
    
    # Make scripts executable
    sudo chmod +x /opt/graphics-driver-backup/update-protection/*.sh
    
    # Apply package holds
    sudo /opt/graphics-driver-backup/update-protection/hold-graphics-packages.sh
    
    print_success "Update protection mechanisms created"
}

# Function to detect graphics cards
detect_graphics() {
    print_gpu "Detecting graphics hardware..."
    
    # Initialize arrays
    declare -a intel_gpus=()
    declare -a nvidia_gpus=()
    declare -a amd_gpus=()
    declare -a other_gpus=()
    
    # Use lspci to detect graphics cards
    if command_exists lspci; then
        while IFS= read -r line; do
            if [[ $line =~ "VGA compatible controller" ]] || [[ $line =~ "3D controller" ]]; then
                if [[ $line =~ "Intel" ]]; then
                    intel_gpus+=("$line")
                elif [[ $line =~ "NVIDIA" ]]; then
                    nvidia_gpus+=("$line")
                elif [[ $line =~ "AMD" ]] || [[ $line =~ "ATI" ]]; then
                    amd_gpus+=("$line")
                else
                    other_gpus+=("$line")
                fi
            fi
        done < <(lspci | grep -i "vga\|3d")
    fi
    
    # Display detected graphics cards
    echo ""
    print_gpu "Detected Graphics Cards:"
    echo "=========================="
    
    if [ ${#intel_gpus[@]} -gt 0 ]; then
        print_gpu "Intel Graphics:"
        for gpu in "${intel_gpus[@]}"; do
            echo "  • $gpu"
        done
    fi
    
    if [ ${#nvidia_gpus[@]} -gt 0 ]; then
        print_gpu "NVIDIA Graphics:"
        for gpu in "${nvidia_gpus[@]}"; do
            echo "  • $gpu"
        done
    fi
    
    if [ ${#amd_gpus[@]} -gt 0 ]; then
        print_gpu "AMD Graphics:"
        for gpu in "${amd_gpus[@]}"; do
            echo "  • $gpu"
        done
    fi
    
    if [ ${#other_gpus[@]} -gt 0 ]; then
        print_gpu "Other Graphics:"
        for gpu in "${other_gpus[@]}"; do
            echo "  • $gpu"
        done
    fi
    
    if [ ${#intel_gpus[@]} -eq 0 ] && [ ${#nvidia_gpus[@]} -eq 0 ] && [ ${#amd_gpus[@]} -eq 0 ] && [ ${#other_gpus[@]} -eq 0 ]; then
        print_warning "No graphics cards detected via lspci"
        print_status "Trying alternative detection methods..."
        
        # Try alternative detection
        if [ -f /sys/class/drm/card0/device/vendor ]; then
            vendor=$(cat /sys/class/drm/card0/device/vendor)
            if [[ $vendor == "0x8086" ]]; then
                intel_gpus+=("Intel Graphics (detected via sysfs)")
            elif [[ $vendor == "0x10de" ]]; then
                nvidia_gpus+=("NVIDIA Graphics (detected via sysfs)")
            elif [[ $vendor == "0x1002" ]]; then
                amd_gpus+=("AMD Graphics (detected via sysfs)")
            fi
        fi
    fi
    
    echo ""
}

# Function to create backup
create_backup() {
    print_safe "Creating system backup before installation..."
    
    # Create backup directory
    sudo mkdir -p /opt/graphics-driver-backup
    
    # Backup current graphics configuration
    if [ -f /etc/X11/xorg.conf ]; then
        sudo cp /etc/X11/xorg.conf /opt/graphics-driver-backup/xorg.conf.backup
        print_success "X11 configuration backed up"
    fi
    
    # Backup current graphics packages list
    dpkg -l | grep -i mesa > /opt/graphics-driver-backup/mesa-packages.list
    dpkg -l | grep -i intel > /opt/graphics-driver-backup/intel-packages.list
    dpkg -l | grep -i nvidia > /opt/graphics-driver-backup/nvidia-packages.list
    dpkg -l | grep -i amd > /opt/graphics-driver-backup/amd-packages.list
    print_success "Package lists backed up"
    
    # Backup current graphics modules
    if [ -d /etc/modprobe.d/ ]; then
        sudo cp -r /etc/modprobe.d/ /opt/graphics-driver-backup/modprobe.backup
        print_success "Kernel modules configuration backed up"
    fi
    
    # Backup current graphics drivers
    if [ -d /usr/lib/x86_64-linux-gnu/dri/ ]; then
        sudo cp -r /usr/lib/x86_64-linux-gnu/dri/ /opt/graphics-driver-backup/dri.backup
        print_success "DRI drivers backed up"
    fi
    
    # Backup current kernel modules
    sudo cp -r /lib/modules/$(uname -r) /opt/graphics-driver-backup/kernel-modules.backup 2>/dev/null || print_warning "Could not backup kernel modules"
    
    print_success "System backup completed at /opt/graphics-driver-backup/"
}

# Function to check system compatibility
check_compatibility() {
    print_stable "Checking system compatibility..."
    
    # Check if we're on Ubuntu/Debian
    if ! command_exists apt; then
        print_error "This script is designed for Ubuntu/Debian systems"
        exit 1
    fi
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        exit 1
    fi
    
    # Check available disk space (need at least 4GB for all drivers and protection)
    available_space=$(df / | awk 'NR==2 {print $4}')
    if [ "$available_space" -lt 4194304 ]; then  # 4GB in KB
        print_error "Insufficient disk space. Need at least 4GB free."
        exit 1
    fi
    
    # Check kernel compatibility
    check_kernel_compatibility
    
    # Check package dependencies
    check_package_dependencies
    
    # Check if system is up to date
    print_status "Checking if system is up to date..."
    sudo apt update
    if [ "$(apt list --upgradable 2>/dev/null | wc -l)" -gt 1 ]; then
        print_warning "System has pending updates. It's recommended to update first."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Please run: sudo apt update && sudo apt upgrade"
            exit 1
        fi
    fi
    
    print_success "System compatibility check passed"
}

# Function to install package safely
install_package_safe() {
    local package=$1
    local description=$2
    
    if package_installed "$package"; then
        print_warning "$description ($package) is already installed"
    else
        print_status "Installing $description ($package)..."
        if sudo apt install -y "$package"; then
            print_success "$description installed successfully"
        else
            print_error "Failed to install $package"
            return 1
        fi
    fi
}

# Function to install Intel drivers
install_intel_drivers() {
    print_gpu "Installing Intel graphics drivers..."
    
    # Basic Mesa drivers
    install_package_safe "mesa-utils" "Mesa Utilities" || return 1
    install_package_safe "mesa-va-drivers" "Mesa VA Drivers" || return 1
    install_package_safe "mesa-vdpau-drivers" "Mesa VDPAU Drivers" || return 1
    
    # Intel specific drivers
    install_package_safe "intel-microcode" "Intel Microcode" || return 1
    install_package_safe "intel-media-va-driver" "Intel Media VA Driver" || return 1
    install_package_safe "intel-gpu-tool" "Intel GPU Tool" || return 1
    install_package_safe "i965-va-driver" "Intel 965 VA Driver" || return 1
    install_package_safe "intel-media-driver" "Intel Media Driver" || return 1
    
    # Intel compute runtime
    install_package_safe "intel-opencl-icd" "Intel OpenCL ICD" || print_warning "Intel OpenCL failed to install"
    install_package_safe "intel-level-zero-gpu" "Intel Level Zero GPU" || print_warning "Intel Level Zero failed to install"
    
    print_success "Intel drivers installed successfully"
}

# Function to install NVIDIA drivers
install_nvidia_drivers() {
    print_gpu "Installing NVIDIA graphics drivers..."
    
    # Add NVIDIA repository
    print_status "Adding NVIDIA repository..."
    sudo add-apt-repository ppa:graphics-drivers/ppa -y
    sudo apt update
    
    # Install NVIDIA drivers (latest stable)
    install_package_safe "nvidia-driver-535" "NVIDIA Driver 535" || install_package_safe "nvidia-driver-525" "NVIDIA Driver 525" || install_package_safe "nvidia-driver-470" "NVIDIA Driver 470"
    
    # Install NVIDIA utilities
    install_package_safe "nvidia-settings" "NVIDIA Settings" || return 1
    install_package_safe "nvidia-prime" "NVIDIA Prime" || return 1
    install_package_safe "nvidia-modprobe" "NVIDIA Modprobe" || return 1
    
    # Install CUDA support (optional)
    install_package_safe "nvidia-cuda-toolkit" "NVIDIA CUDA Toolkit" || print_warning "CUDA toolkit failed to install"
    
    # Install OpenCL support
    install_package_safe "nvidia-opencl-icd" "NVIDIA OpenCL ICD" || print_warning "NVIDIA OpenCL failed to install"
    
    print_success "NVIDIA drivers installed successfully"
}

# Function to install AMD drivers
install_amd_drivers() {
    print_gpu "Installing AMD graphics drivers..."
    
    # Add AMD repository
    print_status "Adding AMD repository..."
    sudo add-apt-repository ppa:oibaf/graphics-drivers -y
    sudo apt update
    
    # Install AMD drivers
    install_package_safe "mesa-va-drivers" "Mesa VA Drivers" || return 1
    install_package_safe "mesa-vdpau-drivers" "Mesa VDPAU Drivers" || return 1
    install_package_safe "libdrm-amdgpu1" "AMD DRM Library" || return 1
    install_package_safe "libdrm-radeon1" "Radeon DRM Library" || return 1
    
    # Install AMD utilities
    install_package_safe "radeontop" "Radeon Top" || return 1
    install_package_safe "rocm-opencl-runtime" "AMD ROCm OpenCL" || print_warning "AMD ROCm failed to install"
    
    # Install AMD firmware
    install_package_safe "firmware-amd-graphics" "AMD Graphics Firmware" || print_warning "AMD firmware failed to install"
    
    print_success "AMD drivers installed successfully"
}

# Function to install universal graphics support
install_universal_support() {
    print_stable "Installing universal graphics support..."
    
    # Vulkan support
    install_package_safe "libvulkan1" "Vulkan Library" || return 1
    install_package_safe "vulkan-tools" "Vulkan Tools" || return 1
    install_package_safe "vulkan-validationlayers" "Vulkan Validation Layers" || return 1
    install_package_safe "mesa-vulkan-drivers" "Mesa Vulkan Drivers" || return 1
    install_package_safe "vulkan-utils" "Vulkan Utilities" || return 1
    
    # Testing tools
    install_package_safe "glmark2" "Graphics Benchmark" || return 1
    install_package_safe "glxgears" "OpenGL Test Tool" || return 1
    install_package_safe "glxinfo" "OpenGL Info Tool" || return 1
    
    # Monitoring tools
    install_package_safe "radeontop" "GPU Monitoring Tool" || print_warning "RadeonTop failed to install"
    install_package_safe "nvtop" "NVIDIA/AMD GPU Monitor" || print_warning "nvtop failed to install"
    
    # Gaming performance tools
    install_package_safe "gamemode" "GameMode Performance Tool" || return 1
    install_package_safe "gamemoded" "GameMode Daemon" || return 1
    
    # 32-bit libraries for gaming compatibility
    install_package_safe "lib32-mesa" "32-bit Mesa Libraries" || print_warning "32-bit Mesa libraries failed to install"
    install_package_safe "lib32-mesa-vulkan-drivers" "32-bit Vulkan Drivers" || print_warning "32-bit Vulkan drivers failed to install"
    
    print_success "Universal graphics support installed"
}

# Function to test graphics after installation
test_graphics() {
    print_stable "Testing graphics installation..."
    
    # Test OpenGL
    if command_exists glxinfo; then
        print_status "Testing OpenGL..."
        if glxinfo | grep -q "OpenGL version"; then
            print_success "OpenGL is working"
            glxinfo | grep "OpenGL version" | head -1
        else
            print_warning "OpenGL test failed"
        fi
    fi
    
    # Test Vulkan
    if command_exists vulkaninfo; then
        print_status "Testing Vulkan..."
        if vulkaninfo | grep -q "Vulkan Version"; then
            print_success "Vulkan is working"
            vulkaninfo | grep "Vulkan Version" | head -1
        else
            print_warning "Vulkan test failed"
        fi
    fi
    
    # Test basic OpenGL
    if command_exists glxgears; then
        print_status "Testing basic OpenGL (glxgears)..."
        timeout 5s glxgears > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            print_success "Basic OpenGL test passed"
        else
            print_warning "Basic OpenGL test failed"
        fi
    fi
    
    # Test GPU monitoring
    if command_exists nvidia-smi; then
        print_status "Testing NVIDIA GPU monitoring..."
        nvidia-smi --query-gpu=name --format=csv,noheader,nounits
    fi
    
    if command_exists radeontop; then
        print_status "Testing AMD GPU monitoring..."
        timeout 3s radeontop -d - -l 1 > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            print_success "AMD GPU monitoring working"
        fi
    fi
}

# Function to create rollback script
create_rollback_script() {
    print_safe "Creating rollback script..."
    
    cat << 'EOF' | sudo tee /opt/graphics-driver-backup/rollback.sh
#!/bin/bash
# Universal Graphics Driver Rollback Script

echo "=== Universal Graphics Driver Rollback ==="
echo ""

# Restore X11 configuration
if [ -f /opt/graphics-driver-backup/xorg.conf.backup ]; then
    echo "Restoring X11 configuration..."
    sudo cp /opt/graphics-driver-backup/xorg.conf.backup /etc/X11/xorg.conf
fi

# Restore kernel modules configuration
if [ -d /opt/graphics-driver-backup/modprobe.backup ]; then
    echo "Restoring kernel modules configuration..."
    sudo cp -r /opt/graphics-driver-backup/modprobe.backup/* /etc/modprobe.d/
fi

# Restore DRI drivers
if [ -d /opt/graphics-driver-backup/dri.backup ]; then
    echo "Restoring DRI drivers..."
    sudo cp -r /opt/graphics-driver-backup/dri.backup/* /usr/lib/x86_64-linux-gnu/dri/
fi

# Restore kernel modules
if [ -d /opt/graphics-driver-backup/kernel-modules.backup ]; then
    echo "Restoring kernel modules..."
    sudo cp -r /opt/graphics-driver-backup/kernel-modules.backup/* /lib/modules/$(uname -r)/
fi

# Remove NVIDIA drivers
echo "Removing NVIDIA drivers..."
sudo apt remove -y nvidia-driver-* nvidia-settings nvidia-prime nvidia-modprobe nvidia-cuda-toolkit nvidia-opencl-icd

# Remove AMD drivers
echo "Removing AMD drivers..."
sudo apt remove -y libdrm-amdgpu1 libdrm-radeon1 radeontop rocm-opencl-runtime firmware-amd-graphics

# Remove Intel drivers
echo "Removing Intel drivers..."
sudo apt remove -y intel-media-va-driver intel-gpu-tool i965-va-driver intel-media-driver intel-opencl-icd intel-level-zero-gpu

# Remove universal packages
echo "Removing universal graphics packages..."
sudo apt remove -y mesa-utils mesa-va-drivers mesa-vdpau-drivers vulkan-tools vulkan-validationlayers mesa-vulkan-drivers vulkan-utils glmark2 glxgears glxinfo gamemode gamemoded lib32-mesa lib32-mesa-vulkan-drivers

# Clean up
sudo apt autoremove -y
sudo apt autoclean

# Remove repositories
echo "Removing added repositories..."
sudo add-apt-repository --remove ppa:graphics-drivers/ppa -y
sudo add-apt-repository --remove ppa:oibaf/graphics-drivers -y

# Unhold packages
echo "Unholding graphics packages..."
sudo apt-mark unhold nvidia-driver-* nvidia-settings nvidia-prime nvidia-modprobe
sudo apt-mark unhold intel-media-va-driver intel-gpu-tool i965-va-driver intel-media-driver
sudo apt-mark unhold libdrm-amdgpu1 libdrm-radeon1 radeontop firmware-amd-graphics
sudo apt-mark unhold mesa-utils mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers
sudo apt-mark unhold vulkan-tools vulkan-validationlayers vulkan-utils

echo ""
echo "Rollback completed. Please reboot your system."
echo "If you still have issues, you may need to reinstall your original graphics drivers."
EOF
    
    sudo chmod +x /opt/graphics-driver-backup/rollback.sh
    print_success "Rollback script created at /opt/graphics-driver-backup/rollback.sh"
}

# Main installation function
main() {
    echo "=========================================="
    echo "    Universal Graphics Driver Setup"
    echo "    Intel • NVIDIA • AMD • Universal"
    echo "    SAFE & STABLE VERSION with UPDATE PROTECTION"
    echo "=========================================="
    echo ""
    
    # Check compatibility first
    check_compatibility
    
    # Detect graphics cards
    detect_graphics
    
    # Create backup before making changes
    create_backup
    
    # Create rollback script
    create_rollback_script
    
    # Create update protection
    create_update_protection
    
    echo ""
    print_stable "Starting SAFE universal graphics driver installation..."
    echo ""
    
    # Update system first (safely)
    print_status "Updating system packages safely..."
    sudo apt update
    if [ "$(apt list --upgradable 2>/dev/null | wc -l)" -gt 1 ]; then
        print_status "Installing system updates..."
        sudo apt upgrade -y
    fi
    print_success "System updated"
    
    # Install drivers based on detected hardware
    if [ ${#intel_gpus[@]} -gt 0 ]; then
        install_intel_drivers
    fi
    
    if [ ${#nvidia_gpus[@]} -gt 0 ]; then
        install_nvidia_drivers
    fi
    
    if [ ${#amd_gpus[@]} -gt 0 ]; then
        install_amd_drivers
    fi
    
    # Always install universal support
    install_universal_support
    
    # Clean up safely
    print_status "Cleaning up package cache safely..."
    sudo apt autoremove -y
    sudo apt autoclean
    print_success "Package cache cleaned"
    
    # Test graphics installation
    test_graphics
    
    echo ""
    echo "=========================================="
    print_success "SAFE & STABLE universal graphics driver installation completed!"
    echo "=========================================="
    echo ""
    echo "🎮 Graphics Features Installed:"
    echo "  • Universal Mesa OpenGL drivers (stable)"
    echo "  • Universal Vulkan support (stable)"
    echo "  • Hardware-specific drivers (Intel/NVIDIA/AMD)"
    echo "  • Gaming performance tools (GameMode)"
    echo "  • Graphics testing utilities"
    echo "  • GPU monitoring tools"
    echo "  • 32-bit libraries for compatibility"
    echo ""
    echo "🔧 Testing Commands:"
    echo "  • glxinfo | grep 'OpenGL version'    # Test OpenGL"
    echo "  • vulkaninfo | grep 'Vulkan Version' # Test Vulkan"
    echo "  • glmark2                            # Graphics benchmark"
    echo "  • glxgears                           # Simple OpenGL test"
    echo "  • nvidia-smi                         # NVIDIA GPU info"
    echo "  • radeontop                          # AMD GPU monitoring"
    echo "  • nvtop                              # Universal GPU monitor"
    echo ""
    echo "🎯 Gaming Performance:"
    echo "  • GameMode is installed for better gaming performance"
    echo "  • Run games with: gamemoderun ./game"
    echo "  • 32-bit libraries installed for compatibility"
    echo "  • Vulkan support for modern games"
    echo ""
    echo "🛡️  Safety Features:"
    echo "  • System backup created at /opt/graphics-driver-backup/"
    echo "  • Rollback script available: sudo /opt/graphics-driver-backup/rollback.sh"
    echo "  • Error checking and safe installation process"
    echo "  • Compatibility verification before installation"
    echo "  • Hardware detection and specific driver installation"
    echo ""
    echo "🔄 Update Protection:"
    echo "  • Graphics packages are HELD to prevent breaking updates"
    echo "  • Safe update script: sudo /opt/graphics-driver-backup/update-protection/safe-update.sh"
    echo "  • Graphics verification: sudo /opt/graphics-driver-backup/update-protection/verify-graphics.sh"
    echo "  • Unhold packages: sudo /opt/graphics-driver-backup/update-protection/unhold-graphics-packages.sh"
    echo "  • Hold packages: sudo /opt/graphics-driver-backup/update-protection/hold-graphics-packages.sh"
    echo ""
    echo "⚠️  Important Notes:"
    echo "  • REBOOT YOUR SYSTEM for all changes to take effect"
    echo "  • Your graphics cards should work optimally now"
    echo "  • Graphics packages are protected from breaking updates"
    echo "  • Use safe-update.sh for system updates"
    echo "  • Multiple GPU setups are supported"
    echo "  • Universal drivers work with any graphics card"
    echo ""
    echo "🚀 Your graphics system is now safely and stably configured with update protection!"
    echo ""
}

# Run main function
main "$@" 