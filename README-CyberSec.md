# PK-CyberSec - Comprehensive Cybersecurity Tools Installation Script

A massive cybersecurity toolkit installation script for Endeavor OS that installs hundreds of security tools covering all aspects of cybersecurity, penetration testing, vulnerability assessment, and security architecture.

## 🎯 What This Script Installs

### 🔍 **Network Security & Reconnaissance**
- **Nmap** - Network discovery and security auditing
- **Masscan** - Fast port scanner
- **Wireshark** - Network protocol analyzer
- **Tcpdump** - Packet analyzer
- **Ettercap** - Network security tool for man-in-the-middle attacks
- **Aircrack-ng** - WiFi security suite
- **Kismet** - Wireless network detector
- **Reaver** - WPS attack tool
- **Enum4linux** - SMB enumeration
- **NBTscan** - NetBIOS scanner
- **SNMP tools** - Network management tools

### 🌐 **Web Application Security**
- **Nikto** - Web server scanner
- **Dirb/DirBuster** - Directory brute forcer
- **Gobuster** - Directory/subdomain scanner
- **Wfuzz** - Web application fuzzer
- **SQLMap** - SQL injection tool
- **WhatWeb** - Web application fingerprinter
- **WPScan** - WordPress security scanner
- **JoomScan** - Joomla security scanner
- **Burp Suite** - Web application security platform
- **OWASP ZAP** - Web security testing tool
- **MITM Proxy** - HTTP/HTTPS proxy
- **PenMW** - Mobile web penetration testing framework

### ⚔️ **Exploitation Frameworks**
- **Metasploit Framework** - Penetration testing platform
- **Social Engineering Toolkit (SET)** - Social engineering attacks
- **BeEF** - Browser exploitation framework

### 🔐 **Password Attacks & Cracking**
- **John the Ripper** - Password cracker
- **Hashcat** - Advanced password recovery
- **Hydra** - Network login cracker
- **Medusa** - Parallel login cracker
- **Crunch** - Wordlist generator
- **CeWL** - Custom wordlist generator
- **Wordlists** - Password dictionaries

### 📶 **Wireless Security**
- **Wifite** - Automated WiFi attack tool
- **Fern WiFi Cracker** - GUI WiFi security tool
- **Wifiphisher** - WiFi security testing
- **Airgeddon** - WiFi security toolkit
- **Fluxion** - WiFi security tool

### 🔍 **Forensics & Digital Investigation**
- **Volatility** - Memory forensics framework
- **Autopsy** - Digital forensics platform
- **Sleuth Kit** - Digital forensics toolkit
- **TestDisk** - Data recovery tool
- **PhotoRec** - File recovery tool
- **Foremost** - Data recovery tool
- **Scalpel** - File recovery tool
- **Xplico** - Network forensics
- **NetworkMiner** - Network forensics

### 🦠 **Malware Analysis**
- **PEfile** - PE file analysis
- **YARA** - Pattern matching
- **Strings** - Binary analysis
- **Hexdump** - Binary analysis
- **Objdump** - Object file analysis
- **Readelf** - ELF file analysis
- **Cuckoo Sandbox** - Malware analysis
- **Joe Sandbox** - Malware analysis

### 🔧 **Reverse Engineering**
- **Radare2** - Reverse engineering framework
- **Ghidra** - Software reverse engineering
- **IDA Free** - Disassembler
- **x64dbg** - Debugger
- **OllyDbg** - Debugger
- **WinDbg** - Debugger

### 🔒 **Steganography & Cryptography**
- **Steghide** - Steganography tool
- **StegSolve** - Steganography tool
- **Binwalk** - Firmware analysis
- **ExifTool** - Metadata reader
- **OpenSSL** - Cryptography toolkit
- **GPG** - Encryption tool
- **Ccrypt** - File encryption
- **Bcrypt** - File encryption

### 🍯 **Honeypots & Traps**
- **Honeyd** - Honeypot daemon
- **Dionaea** - Honeypot
- **Cowrie** - SSH honeypot
- **Kippo** - SSH honeypot
- **Glastopf** - Web honeypot
- **Thug** - Low-interaction honeyclient

### 🌐 **Network Tricks & Advanced Tools**
- **Arptables** - ARP filtering
- **Ebtables** - Ethernet bridge filtering
- **Iptables** - Packet filtering
- **Nftables** - Packet filtering
- **Conntrack tools** - Connection tracking
- **Ipset** - IP set management
- **Iftop** - Network monitor
- **Htop** - Process monitor
- **Iotop** - I/O monitor
- **Nethogs** - Network monitor
- **Bandwhich** - Bandwidth monitor

### 🔍 **Additional Security Tools**
- **Maltego** - OSINT tool
- **Recon-ng** - Reconnaissance framework
- **TheHarvester** - OSINT tool
- **SpiderFoot** - OSINT automation
- **OpenVAS** - Vulnerability scanner
- **Nessus** - Vulnerability scanner
- **Qualys** - Vulnerability scanner
- **Trivy** - Container security scanner
- **Clair** - Container security scanner
- **Anchore** - Container security

### 🛠️ **Custom Tools & Scripts**
- **NmapAutomator** - Nmap automation script
- **PEASS** - Privilege escalation scripts
- **LinEnum** - Linux enumeration script
- **Discover** - Custom enumeration script

### 🐍 **Python Security Tools**
- **Requests** - HTTP library
- **BeautifulSoup** - Web scraping
- **Paramiko** - SSH library
- **Scapy** - Packet manipulation
- **Impacket** - Network protocols
- **Pwntools** - CTF framework
- **ROPgadget** - ROP gadget finder
- **Angr** - Binary analysis
- **Unicorn** - CPU emulator
- **Keystone** - Assembler framework
- **Capstone** - Disassembly framework
- **YARA-Python** - Pattern matching
- **PyInstaller** - Python packager

## 🚀 Quick Start

### Prerequisites

- Endeavor OS (or any Arch-based Linux distribution)
- Internet connection
- Sudo privileges
- At least 10GB free disk space (recommended 20GB+)

### Installation

1. **Download and run the script:**
   ```bash
   ./PK-CyberSec.sh
   ```

2. **The script will:**
   - Update your system packages
   - Install yay (AUR helper) if not present
   - Add Black Arch repository
   - Install hundreds of security tools
   - Configure environment variables
   - Set up aliases for common tools

## ⚠️ Legal and Ethical Considerations

### Authorized Use Only
- **These tools are for authorized security testing only**
- **Always obtain proper written permission before testing**
- **Respect privacy and data protection laws**
- **Follow responsible disclosure practices**

### Best Practices
- Use isolated environments for testing
- Document all testing activities
- Report findings responsibly
- Keep tools updated for security

## 📚 Learning Resources

### Official Documentation
- [Kali Linux Tools](https://tools.kali.org/)
- [Black Arch Tools](https://blackarch.org/tools.html)
- [Metasploit Documentation](https://docs.rapid7.com/metasploit/)
- [OWASP ZAP](https://www.zaproxy.org/docs/)

### Training Platforms
- [TryHackMe](https://tryhackme.com/)
- [HackTheBox](https://www.hackthebox.com/)
- [VulnHub](https://www.vulnhub.com/)
- [OverTheWire](https://overthewire.org/)

## ⚠️ Disclaimer

The authors are not responsible for any misuse of these tools. Users must ensure they have proper authorization before using these tools for security testing. Always follow ethical hacking principles and respect privacy rights.

---

**🔒 Remember: With great power comes great responsibility. Use these tools ethically and legally!**
