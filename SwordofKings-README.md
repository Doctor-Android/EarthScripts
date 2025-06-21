# ⚔️ SwordofKings: Debian to Arch Package Converter

**SwordofKings** is a powerful tool that automatically detects Debian packages and dependencies, then converts them to their Arch Linux equivalents. It's designed to bridge the gap between Debian-based and Arch-based systems, making it easy to run Debian software on Endeavor OS, Manjaro, and other Arch-based distributions.

## 🚀 Features

### 🔍 **Automatic Detection**
- **`.deb` files** - Extract and analyze Debian packages
- **Package names** - Convert Debian package names to Arch
- **Commands** - Detect packages from executable commands
- **Files** - Analyze files and suggest required packages
- **Binary dependencies** - Check shared library requirements

### 🗂️ **Comprehensive Mapping Database**
- **100+ package mappings** covering all major categories
- **Web servers** (nginx, apache, lighttpd)
- **Databases** (mysql, postgresql, redis, mongodb)
- **Programming languages** (python, nodejs, php, java, go, rust)
- **Development tools** (git, gcc, cmake, build-essential)
- **System tools** (htop, rsync, curl, wget)
- **Security tools** (ufw, fail2ban, openssh)
- **Containers** (docker, podman)
- **GUI applications** (firefox, vlc, gimp)

### ⚡ **Batch Processing**
- **Requirements.txt** - Convert Python requirements
- **Package lists** - Process multiple packages at once
- **Directory scanning** - Convert all `.deb` files in a folder
- **Command line lists** - Convert packages from space-separated list

### 🛡️ **Smart Fallbacks**
- **AUR support** - Automatically try AUR if official repo fails
- **Alternative suggestions** - Find similar packages when exact match not found
- **Dependency resolution** - Handle complex package dependencies
- **Error recovery** - Graceful handling of installation failures

## 📦 Installation

### Quick Install
```bash
# Download and run the installer
curl -O https://raw.githubusercontent.com/your-repo/SwordofKings.sh
chmod +x SwordofKings.sh
./SwordofKings.sh
```

### Manual Install
```bash
# Clone the repository
git clone https://github.com/your-repo/SwordofKings.git
cd SwordofKings

# Make scripts executable
chmod +x SwordofKings.sh swordofkings-launcher.sh swordofkings-batch.sh

# Run installation
./SwordofKings.sh
```

## 🎯 Usage Examples

### Basic Usage
```bash
# Convert a Debian package name
swordofkings nginx

# Convert a .deb file
swordofkings package.deb

# Convert a command
swordofkings python3

# Convert a file
swordofkings app.py
```

### Batch Processing
```bash
# Convert Python requirements
swordofkings-batch.sh requirements requirements.txt

# Convert package list
swordofkings-batch.sh packages debian-packages.list

# Convert all .deb files in directory
swordofkings-batch.sh deb-dir /path/to/deb/files

# Convert from command line list
swordofkings-batch.sh cmd-list 'nginx python3 mysql-server'
```

### System-wide Installation
```bash
# Install system-wide with aliases
./swordofkings-launcher.sh --install

# Now you can use these commands anywhere:
swordofkings nginx
sword nginx
deb2arch nginx
convert-deb nginx
```

## 📋 Supported Package Categories

### 🌐 Web Servers & Services
| Debian Package | Arch Package | Description |
|----------------|--------------|-------------|
| `apache2` | `apache` | Apache HTTP Server |
| `nginx` | `nginx` | Nginx web server |
| `lighttpd` | `lighttpd` | Lightweight web server |
| `squid` | `squid` | Proxy server |

### 🗄️ Databases
| Debian Package | Arch Package | Description |
|----------------|--------------|-------------|
| `mysql-server` | `mariadb` | MySQL/MariaDB server |
| `mysql-client` | `mariadb-clients` | MySQL/MariaDB client |
| `postgresql` | `postgresql` | PostgreSQL database |
| `redis-server` | `redis` | Redis in-memory database |
| `mongodb` | `mongodb` | MongoDB NoSQL database |

### 💻 Programming Languages
| Debian Package | Arch Package | Description |
|----------------|--------------|-------------|
| `python3` | `python` | Python 3 interpreter |
| `python3-pip` | `python-pip` | Python package manager |
| `nodejs` | `nodejs` | Node.js JavaScript runtime |
| `npm` | `npm` | Node.js package manager |
| `php` | `php` | PHP scripting language |
| `openjdk-11-jdk` | `jdk-openjdk` | OpenJDK 11 development kit |
| `golang` | `go` | Go programming language |
| `rustc` | `rust` | Rust compiler |

### 🛠️ Development Tools
| Debian Package | Arch Package | Description |
|----------------|--------------|-------------|
| `build-essential` | `base-devel` | Essential build tools |
| `gcc` | `gcc` | GNU C compiler |
| `make` | `make` | Build automation tool |
| `cmake` | `cmake` | Cross-platform build system |
| `git` | `git` | Distributed version control |

### 🔧 System Tools
| Debian Package | Arch Package | Description |
|----------------|--------------|-------------|
| `htop` | `htop` | Interactive process viewer |
| `rsync` | `rsync` | File synchronization tool |
| `curl` | `curl` | Command line HTTP client |
| `wget` | `wget` | Web download utility |
| `tree` | `tree` | Directory listing utility |

### 🔒 Security Tools
| Debian Package | Arch Package | Description |
|----------------|--------------|-------------|
| `ufw` | `ufw` | Uncomplicated firewall |
| `fail2ban` | `fail2ban` | Intrusion prevention |
| `openssh-server` | `openssh` | SSH server |
| `nmap` | `nmap` | Network scanner |

### 🐳 Containers & Virtualization
| Debian Package | Arch Package | Description |
|----------------|--------------|-------------|
| `docker.io` | `docker` | Docker container platform |
| `docker-compose` | `docker-compose` | Docker orchestration |
| `podman` | `podman` | Pod manager |

## 🔧 Advanced Features

### Package Mapping Database
SwordofKings maintains a comprehensive JSON database of Debian to Arch package mappings:

```json
{
  "web_servers": {
    "apache2": "apache",
    "nginx": "nginx"
  },
  "databases": {
    "mysql-server": "mariadb",
    "postgresql": "postgresql"
  }
}
```

### Smart Dependency Resolution
When converting `.deb` files, SwordofKings:
1. Extracts package information using `ar` and `tar`
2. Reads the `control` file for dependencies
3. Converts each dependency recursively
4. Handles complex dependency relationships

### Binary Analysis
For binary files, SwordofKings:
1. Uses `file` command to detect file type
2. Uses `ldd` to check shared library dependencies
3. Maps common libraries to their packages
4. Suggests appropriate packages based on file type

### AUR Integration
When official packages fail, SwordofKings:
1. Automatically tries AUR helpers (yay, paru)
2. Provides fallback installation methods
3. Suggests manual installation commands

## 🎮 Gaming Support

SwordofKings includes special support for gaming packages:

```bash
# Convert gaming dependencies
swordofkings openjdk-11-jre  # For Minecraft servers
swordofkings wine            # For Windows games
swordofkings steam           # Steam client
```

## 🚨 Troubleshooting

### Common Issues

**"No direct mapping found"**
- SwordofKings will suggest similar packages
- You can manually choose from suggestions
- Check AUR for alternative packages

**"Failed to install from AUR"**
- Install an AUR helper: `sudo pacman -S yay`
- Or use: `sudo pacman -S paru`

**"Package already installed"**
- This is normal - SwordofKings checks existing packages
- No action needed

### Debug Mode
```bash
# Enable verbose output
DEBUG=1 swordofkings nginx
```

### Manual Package Installation
```bash
# If automatic conversion fails
sudo pacman -S package-name
# or
yay -S package-name
```

## 🤝 Contributing

### Adding New Package Mappings
Edit `/opt/swordofkings/mappings/debian-to-arch.json`:

```json
{
  "new_category": {
    "debian-package": "arch-package"
  }
}
```

### Reporting Issues
1. Check if the package exists in Arch repositories
2. Verify the package name is correct
3. Test with manual installation first
4. Report with detailed error messages

## 📄 License

SwordofKings is released under the MIT License. See LICENSE file for details.

## 🙏 Acknowledgments

- **Arch Linux** community for package availability
- **AUR** maintainers for additional packages
- **Debian** project for package standardization
- **Endeavor OS** team for the excellent distribution

## 🔗 Links

- **GitHub**: https://github.com/your-repo/SwordofKings
- **Issues**: https://github.com/your-repo/SwordofKings/issues
- **Wiki**: https://github.com/your-repo/SwordofKings/wiki

---

**⚔️ SwordofKings: Converting Debian packages to Arch with the power of a thousand swords! ⚔️** 