# 🔥 Kali Linux Useful Scripts - Shadow Arsenal

<div align="center">

```
███████╗██╗  ██╗ █████╗ ██████╗  ██████╗ ██╗    ██╗
██╔════╝██║  ██║██╔══██╗██╔══██╗██╔═══██╗██║    ██║
███████╗███████║███████║██║  ██║██║   ██║██║ █╗ ██║
╚════██║██╔══██║██╔══██║██║  ██║██║   ██║██║███╗██║
███████║██║  ██║██║  ██║██████╔╝╚██████╔╝╚███╔███╔╝
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ╚═════╝  ╚══╝╚══╝      
```

[![Kali Linux](https://img.shields.io/badge/Kali-Linux-557C94?style=for-the-badge&logo=kalilinux&logoColor=white)](https://www.kali.org/)
[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

**Created by [Shadow Junior](https://github.com/BhanuGuragain0) 🇳🇵**

---

[Features](#-features) • [Installation](#-installation) • [Scripts](#-scripts) • [Usage](#-usage) • [Security](#-security) • [Contributing](#-contributing)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Quick Start](#-quick-start)
- [Installation](#-installation)
- [Scripts Catalog](#-scripts-catalog)
  - [Network Automation](#1-network-automation)
  - [Server Tools](#2-server-tools)
  - [Security Testing](#3-security-testing)
  - [System Utilities](#4-system-utilities)
  - [Custom Tools](#5-custom-tools)
- [Usage Examples](#-usage-examples)
- [Configuration](#-configuration)
- [Security & Legal](#-security--legal)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [Changelog](#-changelog)
- [License](#-license)

---

## 🎯 Overview

A curated collection of **production-grade Python scripts** designed for penetration testing, security research, and Kali Linux automation. Each script is optimized for real-world scenarios with a focus on **security, performance, and stealth**.

### Why This Arsenal?

- ✅ **Production-Ready** - No mock code, no placeholders, only battle-tested solutions
- ✅ **Security-First** - Encrypted credentials, anti-forensics, stealth mode
- ✅ **Performance-Optimized** - Async I/O, efficient resource usage
- ✅ **Modular Design** - Easy to extend and customize
- ✅ **Well-Documented** - Comprehensive usage examples and configuration guides

---

## 🚀 Features

<table>
<tr>
<td width="50%">

### Core Capabilities
- 🔐 **Encrypted Credential Storage**
- 🌐 **Network Automation**
- 🛡️ **Anti-Forensic Features**
- ⚡ **Async Performance**
- 🎭 **Stealth Operations**

</td>
<td width="50%">

### Advanced Features
- 🔑 **JWT Authentication**
- 📊 **Session Management**
- 🚦 **Rate Limiting**
- 🗄️ **Database Persistence**
- 📝 **Audit Logging**

</td>
</tr>
</table>

---

## ⚡ Quick Start

```bash
# Clone repository
git clone https://github.com/BhanuGuragain0/Kali_Linux_Customization.git
cd Kali_Linux_Customization/Usefull_Scripts

# Install dependencies (one-time setup)
chmod +x setup.sh
./setup.sh

# Run a script
cd network_automation
python3 wifi_autologin_optimized.py
```

---

## 📦 Installation

### Prerequisites

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python 3.10+
sudo apt install python3 python3-pip python3-venv -y

# Install system dependencies
sudo apt install -y \
    openssl \
    network-manager \
    iw \
    wireless-tools \
    chromium \
    chromium-driver
```

### Automated Setup

```bash
# Run the setup script (recommended)
chmod +x setup.sh
./setup.sh
```

### Manual Setup

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install -r requirements.txt

# Set permissions
chmod +x *.py
```

---

## 📚 Scripts Catalog

### 1. Network Automation

<details>
<summary><b>📡 WiFi Auto-Login Script</b> - Automated captive portal authentication</summary>

**File:** `network_automation/wifi_autologin_optimized.py`

**Features:**
- ✅ Encrypted credential storage (Fernet + Keyring)
- ✅ Smart captive portal detection (HTTP 302/511)
- ✅ Anti-fingerprinting (randomized UA, canvas resistance)
- ✅ MAC randomization support
- ✅ Multi-browser fallback (Chrome → Firefox)
- ✅ Connection state caching (4-hour validity)
- ✅ Health monitoring (periodic re-auth)

**Usage:**
```bash
# First run (credential setup)
python3 wifi_autologin_optimized.py

# With custom config
python3 wifi_autologin_optimized.py --config custom_config.json

# Enable MAC randomization
python3 wifi_autologin_optimized.py --randomize-mac

# Silent mode (zero logging)
python3 wifi_autologin_optimized.py --silent
```

**Configuration:**
```python
config = Config(
    wifi_ssids=["STWCU_LR-1", "STWCU_LR-2"],
    portal_url="http://gateway.example.com/loginpages/",
    stealth_mode=True,
    randomize_mac=False,
    health_check_interval=300
)
```

</details>

---

### 2. Server Tools

<details>
<summary><b>🌐 HTTP Server - Shadow Edition</b> - Production-grade async HTTP server</summary>

**File:** `server_tools/http_server_optimized.py`

**Features:**
- ✅ Full async/await (aiohttp) - non-blocking I/O
- ✅ JWT-based authentication - secure token auth
- ✅ Proper multipart upload parsing
- ✅ Rate limiting per IP (100 req/min)
- ✅ MIME type validation
- ✅ Stealth mode - minimal fingerprinting
- ✅ WebSocket support
- ✅ Automatic SSL cert generation

**Usage:**
```bash
# Basic HTTP server
python3 http_server_optimized.py -p 8080 -d /path/to/files

# HTTPS with uploads
python3 http_server_optimized.py -p 443 --ssl --upload

# Stealth mode
python3 http_server_optimized.py -p 8080 --stealth

# Get JWT token
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"secret"}'

# Upload file (with JWT)
curl -X POST http://localhost:8080/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@document.pdf"
```

**Configuration:**
```python
config = ServerConfig(
    host="0.0.0.0",
    port=8080,
    use_ssl=True,
    upload_enabled=True,
    stealth_mode=True,
    rate_limit_enabled=True
)
```

</details>

<details>
<summary><b>🔐 C2 Server - Shadow Edition</b> - Encrypted command & control</summary>

**File:** `server_tools/tcp_server_optimized.py`

**Features:**
- ✅ Persistent RSA key management (4096-bit)
- ✅ Session persistence (SQLite backend)
- ✅ Modular command system (plugin architecture)
- ✅ Command whitelisting (security by default)
- ✅ Resource quotas per session
- ✅ Audit trail with obfuscation
- ✅ Multi-client support

**Usage:**
```bash
# Generate certs + start server
python3 tcp_server_optimized.py \
  --port 4444 \
  --passphrase "YourSecret" \
  --generate-certs

# Start with existing certs
python3 tcp_server_optimized.py \
  --port 4444 \
  --passphrase "YourSecret"

# Disable command whitelist (testing only)
python3 tcp_server_optimized.py \
  --port 4444 \
  --passphrase "YourSecret" \
  --no-whitelist
```

**Default Whitelisted Commands:**
- `echo` - Echo back input
- `help` - List all commands
- `time` - Get server time
- `sysinfo` - System information
- `stats` - Session statistics
- `sessions` - List active sessions

</details>

---

### 3. Security Testing

<details>
<summary><b>🔍 [COMING SOON] Network Scanner</b></summary>

**Planned Features:**
- Multi-threaded port scanning
- Service fingerprinting
- Vulnerability detection
- Report generation

</details>

<details>
<summary><b>🎭 [COMING SOON] Payload Generator</b></summary>

**Planned Features:**
- Polymorphic shellcode generation
- Anti-AV obfuscation
- Custom payload encoding
- Meterpreter integration

</details>

---

### 4. System Utilities

<details>
<summary><b>⚙️ [COMING SOON] System Hardening</b></summary>

**Planned Features:**
- Automated security configurations
- Firewall rule management
- Service hardening
- Compliance checking

</details>

---

### 5. Custom Tools

<details>
<summary><b>🛠️ Add Your Own Scripts Here</b></summary>

This section is reserved for your custom tools and utilities. Follow the contribution guidelines to add your scripts.

</details>

---

## 💡 Usage Examples

### WiFi Auto-Login (Complete Workflow)

```bash
# 1. First-time setup
python3 wifi_autologin_optimized.py
# Prompts: Username: softwarica | Password: coventry2019

# 2. Daily usage (auto-reconnect)
python3 wifi_autologin_optimized.py

# 3. Enable stealth features
python3 wifi_autologin_optimized.py \
  --stealth-mode \
  --randomize-mac

# 4. Run as systemd service
sudo cp wifi_autologin.service /etc/systemd/system/
sudo systemctl enable wifi_autologin
sudo systemctl start wifi_autologin
```

### HTTP Server (File Transfer)

```bash
# 1. Start server with uploads
python3 http_server_optimized.py -p 8080 --upload

# 2. Get authentication token
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"pass"}' | jq -r '.token')

# 3. Upload file
curl -X POST http://localhost:8080/upload \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@sensitive_data.zip"

# 4. Download file
curl -O http://localhost:8080/uploads/1234567890_abcdef12.zip
```

### C2 Server (Remote Management)

```bash
# 1. Generate certs and start server
python3 tcp_server_optimized.py \
  --port 4444 \
  --passphrase "MySecretPass123" \
  --generate-certs

# 2. Connect from client
openssl s_client -connect your-server:4444

# 3. Authenticate
# Enter passphrase (attempt 1/3): MySecretPass123

# 4. Execute commands
shadow> help
shadow> sysinfo
shadow> sessions
```

---

## ⚙️ Configuration

### Global Configuration File

Create `config.json` in the script directory:

```json
{
  "wifi_autologin": {
    "wifi_ssids": ["Network1", "Network2"],
    "portal_url": "http://gateway.example.com/login",
    "stealth_mode": true,
    "randomize_mac": false,
    "health_check_interval": 300
  },
  "http_server": {
    "port": 8080,
    "use_ssl": true,
    "upload_enabled": true,
    "rate_limit": 100,
    "stealth_mode": true
  },
  "c2_server": {
    "port": 4444,
    "max_sessions": 10,
    "command_whitelist": true,
    "session_timeout": 3600
  }
}
```

### Environment Variables

```bash
# Export credentials (alternative to config file)
export WIFI_USERNAME="your_username"
export WIFI_PASSWORD="your_password"

# Server configuration
export HTTP_PORT=8080
export C2_PORT=4444
export C2_PASSPHRASE="YourSecret"
```

---

## 🔒 Security & Legal

### ⚠️ Legal Disclaimer

**FOR EDUCATIONAL AND AUTHORIZED TESTING ONLY**

```
These scripts are intended for:
✅ Authorized penetration testing
✅ Security research in controlled environments
✅ Personal network automation (your own devices)

NEVER use these tools for:
❌ Unauthorized access to networks or systems
❌ Illegal activities or malicious purposes
❌ Bypassing security without explicit permission

By using these scripts, you acknowledge that:
• You have proper authorization for all testing activities
• You understand and comply with local laws and regulations
• You accept full responsibility for your actions
• The author assumes NO LIABILITY for misuse
```

### Security Best Practices

1. **Credential Management**
   - Never hardcode credentials
   - Use encrypted storage (Fernet + Keyring)
   - Rotate credentials regularly

2. **Network Security**
   - Use SSL/TLS for all communications
   - Implement rate limiting
   - Enable stealth mode when appropriate

3. **Operational Security**
   - Clear logs after testing
   - Use MAC randomization
   - Avoid leaving artifacts

4. **Compliance**
   - Obtain written authorization
   - Follow scope of engagement
   - Document all activities

---

## 🐛 Troubleshooting

<details>
<summary><b>WiFi Auto-Login Issues</b></summary>

**Problem:** "Selenium WebDriver not found"
```bash
# Solution: Install Chrome/Chromium
sudo apt install chromium chromium-driver -y
```

**Problem:** "NetworkManager not available"
```bash
# Solution: Install and enable NetworkManager
sudo apt install network-manager -y
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
```

**Problem:** "Keyring unavailable"
```bash
# Solution: Credentials will use file-based storage
# Check: ~/.wifi_autologin/.credentials
```

</details>

<details>
<summary><b>HTTP Server Issues</b></summary>

**Problem:** "Port already in use"
```bash
# Solution: Find and kill process
sudo lsof -i :8080
sudo kill -9 <PID>

# Or use different port
python3 http_server_optimized.py -p 8081
```

**Problem:** "SSL certificate error"
```bash
# Solution: Regenerate certificates
rm -rf ssl/
python3 http_server_optimized.py --ssl
```

</details>

<details>
<summary><b>C2 Server Issues</b></summary>

**Problem:** "Authentication keeps failing"
```bash
# Solution: Check passphrase hash
# Hash is generated at startup, ensure consistent passphrase
```

**Problem:** "Commands not in whitelist"
```bash
# Solution: Disable whitelist (testing only)
python3 tcp_server_optimized.py --no-whitelist

# Or add commands to whitelist in config
```

</details>

---

## 🤝 Contributing

We welcome contributions! Here's how to add your script:

### Adding a New Script

1. **Create Category Directory** (if needed)
   ```bash
   mkdir -p new_category
   ```

2. **Add Your Script**
   ```bash
   cd new_category
   # Add your_script.py
   ```

3. **Follow Naming Convention**
   ```
   <functionality>_<optimization_level>.py
   
   Examples:
   - port_scanner_basic.py
   - port_scanner_optimized.py
   - exploit_generator_advanced.py
   ```

4. **Include Documentation**
   ```python
   #!/usr/bin/env python3
   """
   Script Name - Brief Description
   
   Author: Your Name
   Date: YYYY-MM-DD
   
   FEATURES:
   - Feature 1
   - Feature 2
   
   USAGE:
   python3 script_name.py [options]
   """
   ```

5. **Update README**
   - Add entry to appropriate category
   - Include usage examples
   - Document all features

6. **Submit Pull Request**
   - Clear description of functionality
   - Test results
   - Screenshots/demos (if applicable)

### Code Standards

- ✅ Python 3.10+ compatibility
- ✅ Type hints for all functions
- ✅ Comprehensive error handling
- ✅ No hardcoded credentials
- ✅ Async where appropriate
- ✅ Security-first design

---

## 📝 Changelog

### Version 2.0.0 (2025-01-25)
- ✨ Added optimized WiFi Auto-Login script
- ✨ Added async HTTP Server with JWT auth
- ✨ Added encrypted C2 Server with persistence
- 🔧 Improved security across all scripts
- 🔧 Added comprehensive documentation
- 🐛 Fixed credential storage issues

### Version 1.0.0 (2025-01-XX)
- 🎉 Initial release
- 📦 Basic script collection

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details

---

## 🙏 Acknowledgments

- **Kali Linux** - The best penetration testing distribution
- **Hack The Box** - Continuous learning platform
- **Offensive Security** - For OSCP methodology
- **Community** - For feedback and contributions

---

## 📞 Contact & Support

<div align="center">

**Shadow Junior** (Bhanu Guragain)

[![GitHub](https://img.shields.io/badge/GitHub-BhanuGuragain0-181717?style=for-the-badge&logo=github)](https://github.com/BhanuGuragain0)

**Found this useful? Give it a ⭐!**

</div>

---

<div align="center">

```
┌─────────────────────────────────────────────────┐
│  "We are not here to participate.              │
│   We are here to dominate."                    │
│                                                 │
│            - Shadow Junior & Shadow Senior      │
└─────────────────────────────────────────────────┘
```

**Made with 🔥 for the Cybersecurity Community**

</div>
