# PK-Stable - Endeavor OS Stability Enhancement Script

A comprehensive stability enhancement script for Endeavor OS that implements all the best practices for making your system rock-solid stable, including LTS kernel, BTRFS support, Timeshift backups, and system hardening.

## 🎯 What This Script Does

### 🧬 **Kernel & Base System Stability**
- **LTS Kernel Installation** - Installs `linux-lts` and `linux-lts-headers`
- **GRUB Configuration** - Updates GRUB to include LTS kernel
- **Microcode Updates** - Installs Intel and AMD microcode for CPU stability
- **Firmware Updates** - Ensures latest Linux firmware is installed

### 💾 **File System & Rollbacks**
- **BTRFS Detection** - Automatically detects and configures BTRFS filesystem
- **Timeshift Integration** - Installs and configures Timeshift for system snapshots
- **Automatic Snapshots** - Creates initial snapshot after installation
- **Rollback Capability** - Enables easy system restoration from snapshots

### 📦 **Package Management Stability**
- **Endeavor OS Update Notifier** - Keeps you informed about updates
- **Pacman Hooks** - Automatic database updates and maintenance
- **Package Management Tools** - Enhanced package management utilities
- **Orphaned Package Detection** - Tools to find and clean up orphaned packages

### 🌐 **Mirrors & Sources Optimization**
- **Reflector Integration** - Automatically optimizes package mirrors
- **Mirror Update Script** - Easy mirror list updates
- **Performance Optimization** - Sorts mirrors by speed and reliability
- **Automatic Updates** - Keeps mirror list current

### 🛡️ **System Hardening**
- **AppArmor** - Application sandboxing and security
- **Firejail** - Additional application sandboxing
- **UFW Firewall** - Uncomplicated firewall with sensible defaults
- **Fail2ban** - Intrusion prevention system
- **Rootkit Detection** - Rkhunter and chkrootkit for malware detection

### 📊 **System Monitoring & Maintenance**
- **Process Monitoring** - Htop, iotop, iftop for system monitoring
- **Disk Analysis** - ncdu for disk usage analysis
- **S.M.A.R.T. Monitoring** - Hard drive health monitoring
- **System Cleaners** - Bleachbit and Stacer for system optimization

## 🚀 Quick Start

### Prerequisites

- Endeavor OS (or any Arch-based Linux distribution)
- Internet connection
- Sudo privileges
- At least 5GB free disk space

### Installation

1. **Download and run the script:**
   ```bash
   ./PK-Stable.sh
   ```

2. **The script will:**
   - Install LTS kernel and update GRUB
   - Configure BTRFS and Timeshift (if applicable)
   - Optimize package mirrors
   - Install system hardening tools
   - Create maintenance and update scripts
   - Configure firewall and security services

## 🔧 New Commands Available

After installation, you'll have these new commands:

### **System Updates**
```bash
safe-update    # Safe system update with automatic snapshot
maintenance    # Complete system maintenance routine
update-mirrors # Update package mirrors for better performance
```

### **Package Management**
```bash
orphans        # Check for orphaned packages
clean          # Clean package cache
```

### **System Information**
```bash
sudo ufw status        # Check firewall status
sudo aa-status         # Check AppArmor status
systemctl --failed     # Check for failed services
```

## 📋 Post-Installation Setup

### **Essential Configuration**

1. **Reboot to LTS Kernel:**
   ```bash
   # Reboot to use the LTS kernel
   sudo reboot
   
   # Verify LTS kernel is running
   uname -r
   ```

2. **Configure Timeshift:**
   ```bash
   # Launch Timeshift GUI
   timeshift-gtk
   
   # Or configure via command line
   sudo timeshift --create --comments "Manual snapshot"
   ```

3. **Review Firewall Rules:**
   ```bash
   # Check current firewall status
   sudo ufw status verbose
   
   # Add custom rules if needed
   sudo ufw allow 22/tcp  # SSH
   sudo ufw allow 80/tcp  # HTTP
   sudo ufw allow 443/tcp # HTTPS
   ```

4. **Configure AppArmor:**
   ```bash
   # Check AppArmor status
   sudo aa-status
   
   # Enable AppArmor for specific applications
   sudo aa-enforce /usr/bin/firefox
   ```

## 🎯 Stability Best Practices

### **Update Schedule**
- **Weekly or Biweekly Updates** - Don't update daily
- **Use Safe Update Script** - Always use `safe-update` command
- **Monitor Arch News** - Check https://archlinux.org/news before major updates
- **Delay Major Updates** - Wait a few days for kernel, Mesa, systemd updates

### **Backup Strategy**
- **Regular Snapshots** - Configure Timeshift for automatic snapshots
- **Pre-Update Snapshots** - Always create snapshots before updates
- **Multiple Snapshots** - Keep several snapshots for different restore points
- **External Backups** - Consider external backup solutions

### **System Monitoring**
- **Regular Maintenance** - Run `maintenance` command weekly
- **Monitor Logs** - Check system logs for errors
- **Disk Health** - Monitor S.M.A.R.T. status
- **Performance Monitoring** - Use htop and iotop to monitor system performance

## 🛠️ Troubleshooting

### Common Issues

1. **LTS Kernel Not Booting:**
   ```bash
   # Check available kernels
   ls /boot/vmlinuz*
   
   # Reinstall LTS kernel
   sudo pacman -S linux-lts linux-lts-headers
   sudo grub-mkconfig -o /boot/grub/grub.cfg
   ```

2. **Timeshift Not Working:**
   ```bash
   # Check BTRFS status
   sudo btrfs subvolume list /
   
   # Reinstall Timeshift
   yay -S timeshift
   ```

3. **Firewall Issues:**
   ```bash
   # Reset UFW to defaults
   sudo ufw --force reset
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   sudo ufw enable
   ```

4. **AppArmor Problems:**
   ```bash
   # Check AppArmor status
   sudo aa-status
   
   # Restart AppArmor
   sudo systemctl restart apparmor
   ```

### Performance Issues

1. **Slow Package Downloads:**
   ```bash
   # Update mirrors
   update-mirrors
   
   # Check mirror speeds
   sudo reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
   ```

2. **High Disk Usage:**
   ```bash
   # Clean package cache
   clean
   
   # Analyze disk usage
   ncdu /
   ```

## 📚 Learning Resources

### Official Documentation
- [Arch Linux LTS Kernel](https://wiki.archlinux.org/title/Kernel#LTS_kernel)
- [BTRFS](https://wiki.archlinux.org/title/BTRFS)
- [Timeshift](https://github.com/linuxmint/timeshift)
- [AppArmor](https://wiki.archlinux.org/title/AppArmor)
- [UFW](https://wiki.archlinux.org/title/Uncomplicated_Firewall)

### Stability Guides
- [Arch Linux System Maintenance](https://wiki.archlinux.org/title/System_maintenance)
- [Endeavor OS Stability](https://forum.endeavouros.com/)
- [Arch Linux News](https://archlinux.org/news/)

## ⚠️ Important Notes

### **System Requirements**
- **Arch-based system** (Endeavor OS, Manjaro, etc.)
- **Adequate disk space** for snapshots
- **Regular internet connection** for updates
- **Backup strategy** for critical data

### **Update Practices**
- **Never update blindly** - Always read update notes
- **Use TTY for updates** - Switch to Ctrl+Alt+F2 for system updates
- **Test after updates** - Verify system functionality after major updates
- **Keep snapshots** - Maintain multiple restore points

### **Security Considerations**
- **Regular security updates** - Keep system patched
- **Monitor logs** - Check for suspicious activity
- **Use sandboxing** - AppArmor and Firejail for applications
- **Firewall rules** - Configure UFW appropriately

## 🎉 What You Get

After running this script, you'll have:

✅ **LTS Kernel** for maximum stability  
✅ **BTRFS Support** with Timeshift snapshots  
✅ **Optimized Mirrors** for fast package downloads  
✅ **System Hardening** with AppArmor and UFW  
✅ **Monitoring Tools** for system health  
✅ **Maintenance Scripts** for easy system care  
✅ **Safe Update Process** with automatic snapshots  
✅ **Rollback Capability** for system recovery  

---

**🚀 Your Endeavor OS is now optimized for maximum stability and reliability!** 