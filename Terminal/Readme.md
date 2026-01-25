# Shadow@Bhanu Elite Terminal (Kali Linux Customization)

Production-grade Zsh/Bash terminal environment for **authorized** security work. Fast startup, AI-powered suggestions, advanced monitoring, and a clean, modular layout.

> **Ethical Use Notice**
> This project is intended **only** for authorized security testing, education, and defensive research. You are responsible for complying with all applicable laws and obtaining explicit permission before running any offensive security tooling.

---

## ✨ Highlights
- **Zsh 5.8+** setup with Powerlevel10k + Zinit for fast startup.
- **AI-style helpers** for workflow suggestions and automation.
- **Security posture**: file integrity checks, network anomaly signals, safe defaults.
- **Modern CLI tooling**: eza, ripgrep, fd, fzf, bat, delta, btop.
- **Optional Bash support** for users who still rely on `bash`.

---

## 📦 Quick Install (Recommended)

```bash
# From the repo root
cd Terminal
chmod +x kali_customize.sh

# Zsh-only install
./kali_customize.sh

# Optional: install Bash config too
./kali_customize.sh --install-bash

# Reload shell
exec zsh
```

---

## 🧰 Manual Install

```bash
# 1) Install dependencies
sudo apt update && sudo apt install -y \
  zsh git curl wget \
  eza ripgrep fd-find bat \
  fzf jq fastfetch \
  figlet toilet \
  inotify-tools \
  python3-pip \
  btop delta

# 2) Install Zinit
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

# 3) Install Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${XDG_DATA_HOME:-$HOME/.local/share}/powerlevel10k"

# 4) Install Nerd Fonts (icons)
mkdir -p ~/.local/share/fonts && cd ~/.local/share/fonts
for font in Regular Bold Italic "Bold Italic"; do
  curl -fLo "MesloLGS NF ${font}.ttf" \
    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20${font// /%20}.ttf"
done
fc-cache -fv

# 5) Deploy configuration
cp Zsh.sh ~/.config/zsh/.zshrc
ln -sf ~/.config/zsh/.zshrc ~/.zshrc

# Optional: Bash configuration
cp bashrc.sh ~/.bashrc

# 6) Configure Powerlevel10k
p10k configure
```

---

## 🧭 Usage Quick Reference

```bash
sysinfo              # System dashboard
live-dashboard       # Live monitoring dashboard
ai <query>           # Natural language command helper
suggest              # Context-aware suggestions
set-target <ip>      # Set pentest target
sec-baseline         # File integrity baseline
```

---

## 🗂️ Files

- **`Zsh.sh`**: Main Zsh configuration.
- **`bashrc.sh`**: Bash configuration (optional install).
- **`kali_customize.sh`**: Installer (supports `--install-bash`).
- **`custumize.md`**: Extended documentation and troubleshooting.

---

## ⚙️ Key Toggles

These live near the top of `Zsh.sh`:

```zsh
ENABLE_AI_ENGINE=true
ENABLE_MATRIX_ON_CLEAR=true
ENABLE_GREETING_BANNER=true
ENABLE_THREAT_INTEL=true
ENABLE_CLOUD_MONITORING=true
ENABLE_PUBLIC_IP_LOOKUP=false
```

---

## 🧪 Health Check

```bash
zsh --version
which eza bat fd rg fzf
```

---

## 📄 License

MIT License.

---

## 📞 Support

- Issues: https://github.com/BhanuGuragain0/Kali_Linux_Customization/issues
- Discussions: https://github.com/BhanuGuragain0/Kali_Linux_Customization/discussions

---

**Made with 💀 by Shadow@Bhanu**
