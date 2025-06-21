# PK-Gaming - Comprehensive Gaming Tools Installation Script

A massive gaming toolkit installation script for Endeavor OS that installs everything you need for gaming, from modern PC games to retro emulation, including all the tools you requested and much more.

## 🎮 What This Script Installs

### 🏪 **Gaming Platforms & Stores**
- **Steam** - The largest PC gaming platform
- **Heroic Games Launcher** - Epic Games Store client
- **Minigalaxy** - GOG Galaxy client
- **Itch.io Client** - Indie game platform
- **Humble Bundle** - Game bundle client

### 🪟 **Windows Gaming Compatibility**
- **Wine** - Windows compatibility layer
- **Bottles** - Modern Windows application manager
- **Lutris** - Game manager and launcher
- **Proton GE** - Enhanced Steam compatibility
- **DXVK/VKD3D** - DirectX to Vulkan layers
- **Winetricks** - Wine configuration tool
- **PlayOnLinux** - Wine manager

### 🎯 **Specific Games & Launchers**
- **Bolt** - RuneScape launcher (as requested)
- **RuneLite** - Enhanced RuneScape client
- **Minecraft Launcher** - Official Minecraft launcher
- **MultiMC** - Advanced Minecraft launcher
- **Prism Launcher** - Modern Minecraft launcher
- **Grapejuice** - Roblox client
- **League of Legends** - LoL client
- **Java Runtimes** - For Minecraft and Java games
- **OpenMW** - Morrowind game engine reimplementation

### 🕹️ **Retro Gaming & Emulation**
- **RetroArch** - Universal emulation frontend (as requested)
- **Dolphin** - GameCube/Wii emulator
- **PCSX2** - PlayStation 2 emulator
- **RPCS3** - PlayStation 3 emulator
- **Citra** - Nintendo 3DS emulator
- **Yuzu** - Nintendo Switch emulator
- **Ryujinx** - Nintendo Switch emulator
- **Cemu** - Wii U emulator
- **Mupen64Plus** - N64 emulator
- **Mednafen** - Multi-system emulator
- **FCEUX** - NES emulator
- **Snes9x** - SNES emulator
- **gPSP** - GBA emulator
- **DeSmuME** - NDS emulator
- **PPSSPP** - PSP emulator
- **DuckStation** - PlayStation emulator
- **Flycast** - Dreamcast emulator
- **MAME** - Arcade emulator
- **FinalBurn Alpha** - Arcade emulator

### ⚡ **Gaming Utilities & Tools**
- **MangoHud** - Performance overlay (FPS, temps, etc.)
- **GameMode** - Performance optimizer
- **AntiMicroX** - Controller mapping
- **JSTest-GTK** - Joystick testing
- **SDL2** - Game input libraries
- **PulseAudio** - Audio system
- **Vulkan Tools** - Graphics API tools

### 🎨 **Game Development Tools**
- **Godot** - Free game engine
- **Godot 4** - Latest Godot version
- **Unity Hub** - Unity game engine
- **Unreal Engine** - Professional game engine
- **Blender** - 3D modeling and animation
- **GIMP** - Image editing
- **Inkscape** - Vector graphics
- **Audacity** - Audio editing
- **Krita** - Digital painting

### 💬 **Gaming Community Tools**
- **Discord** - Gaming chat platform
- **TeamSpeak 3** - Voice chat
- **Mumble** - Voice chat
- **OBS Studio** - Streaming software

### 🔧 **Game Modding Tools**
- **7-Zip** - Archive manager
- **HexEdit** - Hex editor
- **Bless** - Hex editor

### 🚀 **Additional Gaming Tools**
- **Legendary** - Epic Games launcher
- **GOG Downloader** - GOG game downloader
- **VkBasalt** - Post-processing effects
- **Ludusavi** - Game save backup tool

## 🚀 Quick Start

### Prerequisites

- Endeavor OS (or any Arch-based Linux distribution)
- Internet connection
- Sudo privileges
- At least 15GB free disk space (recommended 30GB+)
- Graphics drivers installed

### Installation

1. **Download and run the script:**
   ```bash
   ./PK-Gaming.sh
   ```

2. **The script will:**
   - Update your system packages
   - Install yay (AUR helper) if not present
   - Enable multilib repository for 32-bit games
   - Install hundreds of gaming tools
   - Configure gaming environment
   - Set up performance optimizers

## 🎯 Key Features

### **Complete Gaming Ecosystem**
- **Modern Gaming**: Steam, Epic, GOG, and more
- **Retro Gaming**: Full emulation suite with RetroArch
- **Windows Games**: Wine, Bottles, Lutris for compatibility
- **Performance**: GameMode and MangoHud for optimization
- **Development**: Game engines and creative tools

### **Smart Installation**
- Checks for existing installations
- Installs from official repos, AUR, and multilib
- Enables necessary repositories automatically
- Configures gaming environment

### **Performance Optimization**
- GameMode for automatic performance tuning
- MangoHud for real-time performance monitoring
- DXVK/VKD3D for better Windows game performance
- Optimized audio and input configurations

## 🔧 Post-Installation Setup

### Essential Configuration

1. **Steam Setup:**
   ```bash
   # Launch Steam and log in
   steam
   
   # Enable Steam Play for Windows games
   # Go to Steam Settings > Steam Play
   ```

2. **Wine Configuration:**
   ```bash
   # Configure Wine
   winecfg
   
   # Install additional components
   winetricks corefonts vcrun2019
   ```

3. **Bottles Setup:**
   ```bash
   # Launch Bottles
   bottles
   
   # Create new bottles for Windows applications
   ```

4. **RetroArch Configuration:**
   ```bash
   # Launch RetroArch
   retroarch
   
   # Download cores for your favorite systems
   # Add ROM directories
   ```

5. **GameMode Setup:**
   ```bash
   # Enable GameMode service
   sudo systemctl enable --now gamemoded
   
   # Test GameMode
   gamemoderun glxgears
   ```

### Performance Monitoring

1. **MangoHud Setup:**
   ```bash
   # Enable MangoHud for all games
   export MANGOHUD=1
   
   # Or run specific games with MangoHud
   mangohud steam
   ```

2. **Performance Testing:**
   ```bash
   # Test Vulkan
   vulkaninfo
   
   # Test OpenGL
   glxinfo | grep "OpenGL version"
   ```

## 🎮 Gaming Tips

### **Steam Gaming**
- Enable Steam Play for Windows games
- Use Proton GE for better compatibility
- Configure controller support in Steam settings

### **Retro Gaming**
- RetroArch supports most retro systems
- Download cores for your favorite platforms
- Organize ROMs in dedicated directories
- Use shaders for authentic retro look

### **Windows Games**
- Bottles is great for modern Windows applications
- Lutris manages game installations automatically
- Use DXVK for better DirectX performance
- Configure Wine prefixes for different games
- **OpenMW** is a great way to play Morrowind on Linux

### **Performance Optimization**
- GameMode automatically optimizes system for gaming
- MangoHud shows FPS, temperatures, and system info
- Use VkBasalt for post-processing effects
- Configure graphics drivers for gaming

## 🛠️ Troubleshooting

### Common Issues

1. **Steam Won't Launch:**
   ```bash
   # Install Steam native runtime
   sudo pacman -S steam-native-runtime
   
   # Clear Steam cache
   rm -rf ~/.steam/steam/appcache
   ```

2. **Wine Games Not Working:**
   ```bash
   # Update Wine
   sudo pacman -Syu wine
   
   # Reconfigure Wine
   winecfg
   ```

3. **Performance Issues:**
   ```bash
   # Check if GameMode is running
   systemctl status gamemoded
   
   # Enable GameMode for specific game
   gamemoderun ./game
   ```

4. **Controller Not Working:**
   ```bash
   # Test controller
   jstest-gtk
   
   # Install additional controller drivers
   sudo pacman -S xboxdrv
   ```

### Graphics Issues

1. **Vulkan Not Working:**
   ```bash
   # Install Vulkan drivers
   sudo pacman -S vulkan-icd-loader
   
   # For NVIDIA
   sudo pacman -S nvidia-utils
   
   # For AMD
   sudo pacman -S vulkan-radeon
   ```

2. **OpenGL Issues:**
   ```bash
   # Install Mesa drivers
   sudo pacman -S mesa
   
   # Check OpenGL support
   glxinfo | grep "OpenGL"
   ```

## 📚 Learning Resources

### Official Documentation
- [Steam Linux](https://developer.valvesoftware.com/wiki/Steam_under_Linux)
- [WineHQ](https://wiki.winehq.org/)
- [Lutris](https://lutris.net/)
- [RetroArch](https://docs.libretro.com/)
- [GameMode](https://github.com/FeralInteractive/gamemode)

### Gaming Communities
- [GamingOnLinux](https://www.gamingonlinux.com/)
- [ProtonDB](https://www.protondb.com/)
- [Lutris.net](https://lutris.net/)
- [WineHQ AppDB](https://appdb.winehq.org/)

### Performance Guides
- [Arch Gaming](https://wiki.archlinux.org/title/Gaming)
- [Linux Gaming Performance](https://github.com/ilovecookieee/GamingOnLinux)
- [MangoHud Configuration](https://github.com/flightlessmango/MangoHud)

## ⚠️ Important Notes

### Legal Considerations
- **Only use ROMs you own legally**
- **Respect game developers and publishers**
- **Follow platform terms of service**
- **Use emulation for preservation and fair use**

### Performance Expectations
- **Windows games may have varying compatibility**
- **Some games may require additional configuration**
- **Performance depends on your hardware**
- **Keep graphics drivers updated**

### System Requirements
- **Modern CPU and GPU recommended**
- **8GB+ RAM for gaming**
- **SSD storage for better loading times**
- **Good internet connection for game downloads**

## 🎉 What You Get

After running this script, you'll have:

✅ **Complete gaming ecosystem** with all major platforms  
✅ **Full retro emulation suite** with RetroArch  
✅ **Windows game compatibility** with Wine and Bottles  
✅ **Performance optimization tools** with GameMode and MangoHud  
✅ **Game development tools** with Godot and Unity  
✅ **Streaming and community tools** with Discord and OBS  
✅ **Modding and utility tools** for game customization  

---

**🎮 Ready to game on Linux? Your comprehensive gaming setup is complete!**

### 🎯 Key Applications Installed:
    echo "  • Steam Gaming Platform"
    echo "  • Bottles Windows Emulator"
    echo "  • Lutris Game Manager"
    echo "  • RetroArch Emulation Frontend"
    echo "  • Bolt RuneScape Launcher"
    echo "  • Minecraft Launchers"
    echo "  • OpenMW (Morrowind Engine)"
    echo "  • Heroic Games Launcher (Epic)"
    echo "  • Wine & DXVK"
    echo "  • GameMode Performance Optimizer"
    echo "  • MangoHud Performance Overlay"
    echo ""
