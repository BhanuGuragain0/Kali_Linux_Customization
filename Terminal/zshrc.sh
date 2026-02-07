#!/usr/bin/env zsh
# ═══════════════════════════════════════════════════════════════════════════
# 🚀 Shadow@Bhanu Elite Terminal Environment v4.2.1 ULTIMATE HYBRID 🚀
# ═══════════════════════════════════════════════════════════════════════════
#
# Author: Bhanu Guragain (Shadow Junior)
# Version: 4.2.1
# Date: 2026-02-06
# Repository: https://github.com/BhanuGuragain0/Scripts

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 1: MASTER CONFIGURATION TOGGLES
# ═══════════════════════════════════════════════════════════════════════════

# === Core AI & Intelligence ===
typeset -g ENABLE_AI_ENGINE=true
typeset -g ENABLE_AI_NLC=true              # Natural language commands
typeset -g ENABLE_AI_PREDICTIONS=true      # Workflow predictions

# === Visuals & Effects ===
typeset -g ENABLE_MATRIX_ON_CLEAR=true     # Matrix rain effect
typeset -g ENABLE_GREETING_BANNER=true     # Startup banner
typeset -g ENABLE_NERD_FONTS=true          # Icon system

# === Security & Monitoring ===
typeset -g ENABLE_SECURITY_HUD=true        # Real-time threat monitoring
typeset -g ENABLE_INTRUSION_DETECTION=true # Active threat detection
typeset -g ENABLE_FILE_INTEGRITY=true      # Integrity checks

# === Operational Context ===
typeset -g ENABLE_OP_CONTEXT=true          # Target management
typeset -g ENABLE_THREAT_INTEL=true        # CVE fetching

# === NEW: Extended Operational Features ===
typeset -g ENABLE_CLOUD_MONITORING=true    # AWS/Azure/GCP/Docker/K8s
typeset -g ENABLE_ADVANCED_CPU=true        # Advanced CPU monitoring
typeset -g ENABLE_LIVE_DASHBOARD=true      # Live monitoring dashboard

# === Network & Privacy ===
typeset -g ENABLE_PUBLIC_IP_LOOKUP=false   # Disable in high-privacy envs

# === Performance ===
typeset -g ENABLE_ASYNC_LOADING=true       # Async plugin loading
typeset -g ENABLE_CACHE_SYSTEM=true        # Function result caching

# === Prompt ===
typeset -g ENABLE_STARSHIP=false           # Use Starship instead of Powerlevel10k

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 2: CORE ENVIRONMENT SETUP
# ═══════════════════════════════════════════════════════════════════════════

# Editor & Tools
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export BROWSER="firefox"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Terminal Configuration
export TERM="xterm-256color"
export COLORTERM="truecolor"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Zsh-specific directories
export ZSH_COMPCACHE_DIR="$XDG_CACHE_HOME/zsh/completion"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=100000
export SAVEHIST=100000
export LESSHISTFILE="-"

# Session tracking
export TERMINAL_SESSION_FILE="$XDG_STATE_HOME/zsh/session_tracker"

# Batch directory creation for efficiency
_zsh_create_directories() {
  local -a directories=(
    "$XDG_STATE_HOME/zsh"
    "$XDG_CACHE_HOME/zsh"
    "$ZSH_COMPCACHE_DIR"
  )

  local dir
  for dir in "${directories[@]}"; do
    [[ -d "$dir" ]] || mkdir -p "$dir"
  done
}
_zsh_create_directories

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 3: ZSH OPTIONS (PERFORMANCE + FEATURES)
# ═══════════════════════════════════════════════════════════════════════════

# Performance Optimizations
setopt NO_HASH_CMDS
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS
setopt PROMPT_SUBST
setopt TRANSIENT_RPROMPT
setopt COMBINING_CHARS
setopt MULTIBYTE

# History Management
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt HIST_BEEP

# Directory Navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS
setopt PUSHD_SILENT

# Completion System
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt PATH_DIRS
setopt AUTO_MENU
setopt AUTO_LIST
setopt AUTO_PARAM_SLASH
setopt COMPLETE_ALIASES
setopt GLOB_COMPLETE
setopt HASH_LIST_ALL
setopt MENU_COMPLETE

# Correction
setopt CORRECT
unsetopt CORRECT_ALL

# Globbing
setopt EXTENDED_GLOB
setopt NULL_GLOB
setopt NUMERIC_GLOB_SORT
setopt GLOB_DOTS

# Job Control
setopt LONG_LIST_JOBS
setopt AUTO_RESUME
setopt NOTIFY
setopt CHECK_JOBS
setopt HUP

# Input/Output
setopt ALIASES
setopt CLOBBER
setopt PRINT_EXIT_VALUE

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 4: MODULE SYSTEM (LAZY LOADING)
# ═══════════════════════════════════════════════════════════════════════════

# Optimized module loading with associative array for O(1) lookup
typeset -gA _ZSH_LOADED_MODULES

zsh_load_module() {
  local module="$1"
  [[ -n "${_ZSH_LOADED_MODULES[$module]}" ]] && return 0
  zmodload "$module" 2>/dev/null && _ZSH_LOADED_MODULES[$module]=1
}

# Load essential modules immediately
zsh_load_module zsh/datetime
zsh_load_module zsh/mathfunc

# Lazy-load expensive modules
autoload -Uz zmv

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 5: POWERLEVEL10K INSTANT PROMPT
# ═══════════════════════════════════════════════════════════════════════════

# Secure Powerlevel10k instant prompt loading
_zsh_load_p10k_prompt() {
  [[ "$ENABLE_STARSHIP" == "true" ]] && return 0

  local prompt_file="${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  [[ -r "$prompt_file" && -f "$prompt_file" ]] || return 1

  # Basic security validation
  if grep -q "p10k" "$prompt_file" 2>/dev/null; then
    typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
    source "$prompt_file"
  else
    echo "⚠️ Suspicious p10k prompt file detected" >&2
    return 1
  fi
}
_zsh_load_p10k_prompt

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 6: ZINIT PLUGIN MANAGER
# ═══════════════════════════════════════════════════════════════════════════

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"
if [[ "$ENABLE_STARSHIP" != true ]]; then
  zinit light romkatv/powerlevel10k
fi

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 7: LAZY-LOADED PLUGINS (ASYNC)
# ═══════════════════════════════════════════════════════════════════════════

_zsh_lazy_load_plugins() {
  [[ "$ENABLE_ASYNC_LOADING" != true ]] && return

  # Remove self from precmd to prevent re-execution
  precmd_functions=(${precmd_functions#_zsh_lazy_load_plugins})

  # Load completion first (blocking, required dependency)
  zinit ice lucid wait'0' \
    atload'zstyle ":completion:*" use-cache on; zstyle ":completion:*" cache-path "$ZSH_COMPCACHE_DIR"' \
    atinit'zicompinit; zicdreplay'
  zinit light zsh-users/zsh-completions

  # Load UI plugins with slight delay to prevent conflicts
  zinit ice lucid wait'0.1'
  zinit light zdharma-continuum/fast-syntax-highlighting

  # Load utility plugins last (lowest priority)
  zinit ice lucid wait'0.2'
  zinit light zsh-users/zsh-autosuggestions
  zinit ice lucid wait'0.2'; zinit light zsh-users/zsh-history-substring-search
  zinit ice lucid wait'0.2'; zinit light Aloxaf/fzf-tab
  zinit ice lucid wait'0.2'; zinit light MichaelAquilina/zsh-auto-notify
  zinit ice lucid wait'0.2'; zinit light MichaelAquilina/zsh-you-should-use
  zinit ice lucid wait'0.2'; zinit light agkozak/zsh-z
  zinit ice lucid wait'0.2'; zinit light hlissner/zsh-autopair
  zinit ice lucid wait'0.2'; zinit light ael-code/zsh-colored-man-pages
}

precmd_functions+=(_zsh_lazy_load_plugins)

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 8: COMPLETION SYSTEM (OPTIMIZED)
# ═══════════════════════════════════════════════════════════════════════════

autoload -Uz compinit
zcompdump_path="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
mkdir -p "$(dirname "$zcompdump_path")"

if [[ -n ${zcompdump_path}(#qN.mh+24) ]]; then
  compinit -d "${zcompdump_path}"
else
  compinit -C -d "${zcompdump_path}"
fi

# Completion styling
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' file-sort name
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*' format '%F{yellow}%d%f'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/completion"

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 9: COLOR SYSTEM (NERD FONTS + THEMES)
# ═══════════════════════════════════════════════════════════════════════════

typeset -ga ZSH_COLOR_PALETTE=(
  "38;2;0;255;255"      # Quantum Cyan
  "38;2;255;0;255"      # Neural Magenta
  "38;2;0;255;0"        # Matrix Green
  "38;2;255;0;0"        # Alert Red
  "38;2;255;165;0"      # Warning Orange
  "38;2;138;43;226"     # Elite Purple
  "38;2;0;191;255"      # Electric Blue
  "38;2;255;215;0"      # Champion Gold
  "38;2;255;255;0"      # Plasma Yellow
  "38;2;127;255;0"      # Laser Lime
)

typeset -gA ZSH_THEME_PROFILES=(
  [stealth]="38;2;20;20;30"
  [matrix]="38;2;0;255;0"
  [cyber]="38;2;0;255;255"
  [blood]="38;2;255;0;0"
  [purple]="38;2;138;43;226"
  [gold]="38;2;255;215;0"
)

typeset -g ZSH_ACTIVE_THEME="cyber"

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 10: NERD FONT ICON SYSTEM
# ═══════════════════════════════════════════════════════════════════════════

typeset -gA ZSH_ICONS=(
  [cpu]="⚙️"        [memory]="🧠"     [disk]="💾"        [network]="󰈀"
  [time]="⏱️"       [calendar]="📅"   [battery]="🔋"     [temperature]="🌡️"
  [shield]="🛡️"     [lock]="🔒"       [key]="🔑"         [warning]="⚠️"
  [alert]="🚨"      [check]="✅"      [error]="❌"       [success]="🟢"
  [git]=""        [branch]=""     [docker]="🐳"      [kubernetes]="󱃾"
  [python]="🐍"     [nodejs]=""    [rust]="🦀"        [go]="🐹"
  [java]="☕"       [cpp]="⚡"        [bash]="🐚"        [terminal]=""
  [folder]="📁"     [file]="📄"      [home]="🏠"        [root]="👑"
  [download]="⬇️"   [upload]="⬆️"
  [info]="ℹ️"       [question]="❓"  [loading]="⏳"     [done]="✅"
  [target]="🎯"     [exploit]="💥"   [pwned]="💀"       [recon]="🔍"
  [payload]="🚀"    [shell]="🐚"     [scan]="📡"        [project]="🧩"
)

icon() {
  [[ "$ENABLE_NERD_FONTS" != true ]] && return
  local name=$1
  echo -n "${ZSH_ICONS[$name]:-}"
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 10A: OPERATOR EXECUTION FRAMEWORK (EARLY INIT)
# ═══════════════════════════════════════════════════════════════════════════
# NOTE: This section is loaded early because _op_notify is used throughout
#       the config. Original Section 38 location preserved for reference.

# === OPERATOR NAMESPACE ===
typeset -gA _OP_CONFIG
_OP_CONFIG[exec_prefix]="🧠"
_OP_CONFIG[exec_tag]="[OP-EXEC]"
_OP_CONFIG[divider_char]="─"
_OP_CONFIG[divider_width]=64
_OP_CONFIG[show_command]=true
_OP_CONFIG[show_divider]=true
_OP_CONFIG[show_context]=true
_OP_CONFIG[show_output_separator]=true
_OP_CONFIG[output_separator_char]="━"
_OP_CONFIG[gradient_effects]=true
_OP_CONFIG[enhanced_errors]=true
_OP_CONFIG[session_tracking]=true

# === SHADOW SESSION STATE ===
typeset -gA SHADOW_SESSION_STATE
SHADOW_SESSION_STATE[start_time]=$(date +%s)
SHADOW_SESSION_STATE[command_count]=0
SHADOW_SESSION_STATE[error_count]=0
SHADOW_SESSION_STATE[last_activity]=$(date +%s)

# === TACTICAL ICON SYSTEM ===
typeset -gA SHADOW_ICONS=(
  [ai]="🧠"
  [processing]="⚙️"
  [analyzing]="🔍"
  [computing]="📊"
  [scanning]="📡"
  [elevated]="🛡️"
  [secure]="🔒"
  [vulnerable]="⚠️"
  [compromised]="🚨"
  [executing]="⚡"
  [success]="✅"
  [failure]="❌"
  [warning]="⚠️"
  [complete]="📡"
  [background]="🛰️"
  [critical]="💀"
  [active]="🟢"
  [inactive]="🔴"
  [pending]="🟡"
  [unknown]="⚪"
  [ai_exec]="🤖"
  [recon]="🔍"
  [dev]="💻"
  [cloud]="☁️"
  [version]="🌿"
)

# Semantic icon accessor
_icon() {
  local semantic="$1"
  local fallback="${2:-ℹ️}"
  echo "${SHADOW_ICONS[$semantic]:-$fallback}"
}

# === OPERATOR NOTIFICATION SYSTEM ===
_op_notify() {
  local type="$1"
  local message="$2"
  local context="${3:-${SHADOW_SESSION_STATE[current_context]:-shell}}"
  local timestamp=$(date '+%H:%M:%S')

  # Icon mapping with tactical significance
  local icon color_code
  case "$type" in
    success)
      icon="$(_icon success)"
      color_code="38;2;0;255;0"
      ;;
    warning)
      icon="$(_icon warning)"
      color_code="38;2;255;165;0"
      ;;
    failure)
      icon="$(_icon failure)"
      color_code="38;2;255;0;0"
      ;;
    elevated)
      icon="$(_icon elevated)"
      color_code="38;2;255;215;0"
      ;;
    background)
      icon="$(_icon background)"
      color_code="38;2;0;191;255"
      ;;
    critical)
      icon="$(_icon critical)"
      color_code="38;2;255;255;255"
      ;;
    *)
      icon="$(_icon processing)"
      color_code="38;2;150;150;150"
      ;;
  esac

  # Formatted tactical output
  printf "\033[%sm%s [%s] %s\033[0m %s\n" \
    "$color_code" \
    "$icon" \
    "$timestamp" \
    "${context:+[$context] }" \
    "$message"
}

# === ADVANCED EXECUTION HEADER RENDERER ===
_op_render_execution_header() {
  local full_command="$1"
  local timestamp=$(date '+%H:%M:%S')
  local working_dir="${PWD/#$HOME/\~}"
  local command_type="COMMAND"

  # Enhanced command type detection with more categories
  case "$full_command" in
    # PRIVILEGED OPERATIONS
    sudo*|doas*|pkexec*) command_type="ELEVATED COMMAND" ;;
    # SECURITY & RECONNAISSANCE
    nmap*|gobuster*|nikto*|masscan*|dirb*|dirsearch*|wfuzz*|hydra*|burp*|sqlmap*|metasploit*) command_type="SECURITY/RECON COMMAND" ;;
    # PROGRAMMING LANGUAGES
    python*|python3*|node*|npm*|yarn*|go*|java*|javac*|ruby*|gem*|perl*|php*|composer*|rust*|cargo*|c++|g++|gcc*|clang*) command_type="DEVELOPMENT COMMAND" ;;
    # CLOUD & DEVOPS
    docker*|kubectl*|helm*|terraform*|ansible*|puppet*|chef*|kops*|eksctl*|gcloud*|az*|aws*) command_type="CLOUD/DEVOPS COMMAND" ;;
    # VERSION CONTROL
    git*|svn*|hg*|bzr*|cvs*) command_type="VERSION CONTROL COMMAND" ;;
    # AI & MACHINE LEARNING
    ai*|chatgpt*|claude*|gemini*|bard*|copilot*|ollama*|huggingface*|tensorflow*|pytorch*|scikit*|pandas*|numpy*) command_type="AI/MACHINE LEARNING COMMAND" ;;
    # NETWORK & COMMUNICATIONS
    curl*|wget*|http*|ssh*|rsync*|scp*|sftp*|ftp*|telnet*|netcat*|nc*|nmap*|ping*|traceroute*|dig*|nslookup*|host*) command_type="NETWORK/COMMUNICATIONS COMMAND" ;;
    # TEXT EDITORS & IDES
    vim*|nvim*|vi*|emacs*|nano*|code*|subl*|atom*|vscode*|intellij*|pycharm*|webstorm*) command_type="TEXT EDITOR/IDE COMMAND" ;;
    # BUILD SYSTEMS & COMPILERS
    make*|cmake*|meson*|ninja*|bazel*|buck*|gradle*|maven*|ant*|webpack*|rollup*|vite*|parcel*) command_type="BUILD SYSTEMS COMMAND" ;;
    # PACKAGE MANAGERS
    apt*|apt-get*|dpkg*|yum*|dnf*|rpm*|pacman*|yaourt*|yay*|brew*|port*|pkg*|snap*|flatpak*|pip*|npm*|yarn*|gem*|cargo*) command_type="PACKAGE MANAGEMENT COMMAND" ;;
    # SYSTEM ADMINISTRATION
    systemctl*|service*|journalctl*|crontab*|top*|htop*|ps*|kill*|killall*|nice*|renice*|nohup*|screen*|tmux*) command_type="SYSTEM ADMINISTRATION COMMAND" ;;
    # FILE & DATA OPERATIONS
    find*|grep*|sed*|awk*|sort*|uniq*|cut*|tr*|wc*|head*|tail*|cat*|less*|more*|tar*|zip*|unzip*|gzip*|gunzip*) command_type="FILE/DATA OPERATIONS COMMAND" ;;
    # DATABASE OPERATIONS
    mysql*|postgresql*|psql*|sqlite*|mongo*|redis*|elasticsearch*|cassandra*|oracle*|sqlplus*) command_type="DATABASE OPERATIONS COMMAND" ;;
    # WEB DEVELOPMENT
    http-server*|node*|live-server*|webpack-dev-server*|vite*|next*|react-scripts*|angular-cli*) command_type="WEB DEVELOPMENT COMMAND" ;;
    # MONITORING & LOGGING
    tail*|less*|more*|journalctl*|dmesg*|syslog*|klog*|dmesg*|lsof*|netstat*|ss*|iotop*|iftop*|nethogs*) command_type="MONITORING/LOGGING COMMAND" ;;
    # MULTIMEDIA & GRAPHICS
    ffmpeg*|avconv*|convert*|identify*|display*|eog*|feh*|gimp*|inkscape*|blender*|kdenlive*|obs*) command_type="MULTIMEDIA/GRAPHICS COMMAND" ;;
    # VIRTUALIZATION & CONTAINERS
    virtualbox*|vbox*|vmware*|kvm*|qemu*|libvirt*|docker*|podman*|lxc*|lxd*) command_type="VIRTUALIZATION/CONTAINERS COMMAND" ;;
    # SECURITY TOOLS
    wireshark*|tcpdump*|tshark*|aircrack-ng*|hashcat*|john*|hydra*|metasploit*|burp*|sqlmap*) command_type="SECURITY TOOLS COMMAND" ;;
    # DOCUMENTATION & HELP
    man*|info*|help*|tldr*|cheat*|howdoi*|explainshell*) command_type="DOCUMENTATION/HELP COMMAND" ;;
    # NAVIGATION & SHELL OPERATIONS
    cd*|pwd*|ls*|la*|ll*|tree*|find*|which*|whereis*|type*|whatis*|apropos*) command_type="NAVIGATION/SHELL COMMAND" ;;
    # ARCHIVE & COMPRESSION
    tar*|zip*|unzip*|gzip*|gunzip*|bzip2*|bunzip2*|xz*|unxz*|7z*|p7zip*|rar*|unrar*) command_type="ARCHIVE/COMPRESSION COMMAND" ;;
    # PROCESS MANAGEMENT
    ps*|top*|htop*|kill*|killall*|nice*|renice*|jobs*|fg*|bg*|disown*|nohup*) command_type="PROCESS MANAGEMENT COMMAND" ;;
    # HARDWARE & SYSTEM INFO
    lscpu*|lsmem*|lsblk*|fdisk*|df*|du*|free*|uname*|lspci*|lsusb*|sensors*|acpi*|dmidecode*) command_type="HARDWARE/SYSTEM INFO COMMAND" ;;
    # NETWORK CONFIGURATION
    ip*|ifconfig*|route*|iptables*|ufw*|firewalld*|netplan*|nmcli*|iwconfig*|iwlist*) command_type="NETWORK CONFIGURATION COMMAND" ;;
    # DEVELOPMENT TOOLS
    git*|make*|cmake*|gcc*|g++||python*|node*|npm*|docker*|kubectl*|vim*|nvim*|code*|vscode*) command_type="DEVELOPMENT TOOLS COMMAND" ;;
    # FILE TRANSFER
    scp*|rsync*|sftp*|ftp*|wget*|curl*|aria2c*|rclone*|lftp*) command_type="FILE TRANSFER COMMAND" ;;
    # SYSTEM SERVICES
    systemctl*|service*|init*|rc*|upstart*|systemd*|cron*|crontab*) command_type="SYSTEM SERVICES COMMAND" ;;
    # SECURITY AUDITING
    auditd*|ausearch*|aureport*|fail2ban*|ufw*|iptables*|nftables*|selinux*) command_type="SECURITY AUDITING COMMAND" ;;
    # PERFORMANCE MONITORING
    perf*|strace*|ltrace*|valgrind*|gdb*|lldb*|time*|timeout*) command_type="PERFORMANCE MONITORING COMMAND" ;;
    # BACKUP & RECOVERY
    rsync*|tar*|dd*|clone*|backup*|restore*|dump*|import*|export*) command_type="BACKUP/RECOVERY COMMAND" ;;
    # SHELL SCRIPTING
    bash*|sh*|zsh*|fish*|ksh*|csh*|tcsh*|source*|exec*|eval*) command_type="SHELL SCRIPTING COMMAND" ;;
    # DEFAULT COMMAND
    *) command_type="COMMAND" ;;
  esac

  # Dynamic icon selection based on command type
  local cmd_icon
  case "$command_type" in
    "ELEVATED") cmd_icon="$(_icon elevated)" ;;
    "SECURITY/RECON") cmd_icon="$(_icon recon)" ;;
    "AI/MACHINE LEARNING") cmd_icon="$(_icon ai_exec)" ;;
    "NETWORK/COMMUNICATIONS") cmd_icon="$(_icon scanning)" ;;
    "TEXT EDITOR/IDE") cmd_icon="$(_icon processing)" ;;
    "BUILD SYSTEMS") cmd_icon="$(_icon computing)" ;;
    "SYSTEM ADMINISTRATION") cmd_icon="$(_icon secure)" ;;
    "FILE/DATA OPERATIONS") cmd_icon="$(_icon analyzing)" ;;
    "PACKAGE MANAGEMENT") cmd_icon="$(_icon processing)" ;;
    "DATABASE OPERATIONS") cmd_icon="$(_icon computing)" ;;
    "WEB DEVELOPMENT") cmd_icon="$(_icon processing)" ;;
    "MONITORING/LOGGING") cmd_icon="$(_icon analyzing)" ;;
    "MULTIMEDIA/GRAPHICS") cmd_icon="$(_icon processing)" ;;
    "VIRTUALIZATION/CONTAINERS") cmd_icon="$(_icon cloud)" ;;
    "SECURITY TOOLS") cmd_icon="$(_icon recon)" ;;
    "DOCUMENTATION/HELP") cmd_icon="$(_icon processing)" ;;
    "NAVIGATION/SHELL") cmd_icon="$(_icon executing)" ;;
    "ARCHIVE/COMPRESSION") cmd_icon="$(_icon processing)" ;;
    "PROCESS MANAGEMENT") cmd_icon="$(_icon secure)" ;;
    "HARDWARE/SYSTEM INFO") cmd_icon="$(_icon analyzing)" ;;
    "NETWORK CONFIGURATION") cmd_icon="$(_icon scanning)" ;;
    "DEVELOPMENT TOOLS") cmd_icon="$(_icon dev)" ;;
    "FILE TRANSFER") cmd_icon="$(_icon scanning)" ;;
    "SYSTEM SERVICES") cmd_icon="$(_icon secure)" ;;
    "SECURITY AUDITING") cmd_icon="$(_icon recon)" ;;
    "PERFORMANCE MONITORING") cmd_icon="$(_icon analyzing)" ;;
    "BACKUP/RECOVERY") cmd_icon="$(_icon processing)" ;;
    "SHELL SCRIPTING") cmd_icon="$(_icon executing)" ;;
  esac

  # Command execution header with tactical styling
  printf "\033[38;2;0;255;255m%s [%s] %s ➜ %s\033[0m\n" \
    "$(_icon ai)" \
    "$command_type" \
    "$timestamp" \
    "$full_command"

  # Clean separator
  if [[ "${_OP_CONFIG[show_divider]}" == "true" ]]; then
    printf "\033[38;2;60;60;60m"
    printf "%*s" "${_OP_CONFIG[divider_width]}" "" | tr ' ' "━"
    printf "\033[0m\n"
  fi
}

# === OPERATOR CONFIGURATION ===
operator_config() {
  local setting="$1"
  local value="$2"

  case "$setting" in
    exec_prefix) _OP_CONFIG[exec_prefix]="$value" ;;
    exec_tag)   _OP_CONFIG[exec_tag]="$value" ;;
    show_command)
      if [[ "$value" == true || "$value" == false ]]; then
        _OP_CONFIG[show_command]="$value"
      fi
      ;;
    show_divider)
      if [[ "$value" == true || "$value" == false ]]; then
        _OP_CONFIG[show_divider]="$value"
      fi
      ;;
    *)
      echo "Available settings: exec_prefix, exec_tag, show_command, show_divider"
      echo "Current config:"
      for key in "${(@k)_OP_CONFIG}"; do
        printf "  %s: %s\n" "$key" "${_OP_CONFIG[$key]}"
      done
      ;;
  esac
}

# === OPERATOR STATUS DISPLAY ===
operator_status() {
  echo "🧠 Operator Console Status"
  echo "═════════════════════════════"
  echo "Mode: $(whoami)@$(hostname)"
  echo "Shell: Zsh $ZSH_VERSION"
  echo "Session: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "Config: $(operator_config | wc -l) active settings"
  echo "Status: OPERATIONAL"
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 10B: SECURITY AUDIT LOGGING SYSTEM
# ═══════════════════════════════════════════════════════════════════════════

typeset -g SECURITY_AUDIT_LOG="$XDG_STATE_HOME/zsh/security_audit.log"
typeset -g COMMAND_AUDIT_LOG="$XDG_STATE_HOME/zsh/command_audit.log"

# Initialize audit logs
_init_audit_logs() {
  mkdir -p "$XDG_STATE_HOME/zsh"

  for log in "$SECURITY_AUDIT_LOG" "$COMMAND_AUDIT_LOG"; do
    if [[ ! -f "$log" ]]; then
      touch "$log"
      chmod 600 "$log"
      {
        echo "# Shadow Terminal Security Audit Log"
        echo "# Created: $(date -Iseconds)"
        echo "# User: $(whoami)"
        echo "# Host: $(hostname)"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
      } >> "$log"
    fi
  done
}

# Security event logger
_log_security_event() {
  local event_type="$1"
  local severity="$2"
  local message="$3"
  local details="${4:-}"

  local log_entry
  log_entry=$(cat <<EOF
[$(date -Iseconds)] SECURITY_EVENT
Type: $event_type
Severity: $severity
User: $(whoami)
PID: $$
PPID: $PPID
PWD: $PWD
Message: $message
Details: $details
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
)

  echo "$log_entry" >> "$SECURITY_AUDIT_LOG"

  # Alert on critical events
  if [[ "$severity" == "CRITICAL" ]]; then
    _op_notify "critical" "🚨 SECURITY: $message"
  fi
}

# Command audit logger
_log_command_execution() {
  local command="$1"
  local exit_code="${2:-0}"

  {
    echo "[$(date -Iseconds)] CMD_EXEC"
    echo "User: $(whoami)"
    echo "PWD: $PWD"
    echo "Command: $command"
    echo "Exit: $exit_code"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
  } >> "$COMMAND_AUDIT_LOG"
}

# Initialize on load
_init_audit_logs

# Log rotation function
rotate_audit_logs() {
  local max_size=$((10 * 1024 * 1024))  # 10MB

  for log in "$SECURITY_AUDIT_LOG" "$COMMAND_AUDIT_LOG"; do
    if [[ -f "$log" ]] && [[ $(stat -f%z "$log" 2>/dev/null || stat -c%s "$log" 2>/dev/null) -gt $max_size ]]; then
      local archive="${log}.$(date +%Y%m%d_%H%M%S).gz"
      gzip -c "$log" > "$archive"
      > "$log"  # Truncate
      echo "📦 Rotated: $archive"
    fi
  done
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 10C: RATE LIMITING SYSTEM
# ═══════════════════════════════════════════════════════════════════════════

typeset -gA _RATE_LIMIT_COUNTERS
typeset -gA _RATE_LIMIT_WINDOWS

# Check rate limit for function
# Usage: _check_rate_limit "function_name" max_calls window_seconds
_check_rate_limit() {
  local func_name="$1"
  local max_calls="${2:-10}"
  local window="${3:-60}"

  local current_time=$(date +%s)
  local counter_key="${func_name}_counter"
  local window_key="${func_name}_window_start"

  # Initialize if first call
  if [[ -z "${_RATE_LIMIT_WINDOWS[$window_key]}" ]]; then
    _RATE_LIMIT_WINDOWS[$window_key]=$current_time
    _RATE_LIMIT_COUNTERS[$counter_key]=0
  fi

  # Check if window expired
  local window_start=${_RATE_LIMIT_WINDOWS[$window_key]}
  local elapsed=$((current_time - window_start))

  if [[ $elapsed -ge $window ]]; then
    # Reset window
    _RATE_LIMIT_WINDOWS[$window_key]=$current_time
    _RATE_LIMIT_COUNTERS[$counter_key]=0
  fi

  # Check limit
  local current_count=${_RATE_LIMIT_COUNTERS[$counter_key]}

  if [[ $current_count -ge $max_calls ]]; then
    local remaining=$((window - elapsed))
    echo "🚨 Rate limit exceeded for $func_name"
    echo "   Limit: $max_calls calls per $window seconds"
    echo "   Wait: $remaining seconds"
    _log_security_event "RATE_LIMIT" "WARNING" "Rate limit hit: $func_name" "Count: $current_count, Window: $window"
    return 1
  fi

  # Increment counter
  _RATE_LIMIT_COUNTERS[$counter_key]=$((current_count + 1))
  return 0
}

# Apply rate limiting to sensitive functions
_apply_rate_limits() {
  # These will be applied in the actual functions
  :
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 10D: INPUT VALIDATION FRAMEWORK
# ═══════════════════════════════════════════════════════════════════════════

# Validate string input
# Usage: _validate_string "input" "pattern" "max_length"
_validate_string() {
  local input="$1"
  local pattern="${2:-^[a-zA-Z0-9_.-]+$}"
  local max_length="${3:-256}"

  # Length check
  if [[ ${#input} -gt $max_length ]]; then
    echo "❌ Input too long (max: $max_length)"
    return 1
  fi

  # Pattern match
  if [[ ! "$input" =~ $pattern ]]; then
    echo "❌ Invalid characters in input"
    return 1
  fi

  return 0
}

# Validate numeric input
_validate_number() {
  local input="$1"
  local min="${2:-0}"
  local max="${3:-2147483647}"

  if ! [[ "$input" =~ ^[0-9]+$ ]]; then
    echo "❌ Not a valid number: $input"
    return 1
  fi

  if [[ $input -lt $min ]] || [[ $input -gt $max ]]; then
    echo "❌ Number out of range ($min-$max): $input"
    return 1
  fi

  return 0
}

# Validate file path
_validate_path() {
  local path="$1"
  local must_exist="${2:-false}"

  # Check for path traversal
  if [[ "$path" == *".."* ]]; then
    echo "❌ Path traversal detected"
    _log_security_event "PATH_TRAVERSAL" "CRITICAL" "Attempt: $path"
    return 1
  fi

  # Check for absolute paths if not allowed
  if [[ "$path" == /* ]] && [[ "${3:-false}" != "allow_absolute" ]]; then
    echo "❌ Absolute paths not allowed"
    return 1
  fi

  # Check existence if required
  if [[ "$must_exist" == "true" ]] && [[ ! -e "$path" ]]; then
    echo "❌ Path does not exist: $path"
    return 1
  fi

  return 0
}

# Validate URL
_validate_url() {
  local url="$1"
  local require_https="${2:-false}"

  # Basic URL format check
  if [[ ! "$url" =~ ^https?:// ]]; then
    echo "❌ Invalid URL format"
    return 1
  fi

  # HTTPS requirement
  if [[ "$require_https" == "true" ]] && [[ ! "$url" =~ ^https:// ]]; then
    echo "❌ HTTPS required"
    return 1
  fi

  # Block internal IPs (SSRF protection)
  if [[ "$url" =~ (127\.|10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|169\.254\.|::1|localhost) ]]; then
    echo "❌ Internal/private IP addresses blocked"
    _log_security_event "SSRF_ATTEMPT" "CRITICAL" "Blocked URL: $url"
    return 1
  fi

  return 0
}

# Sanitize user input for safe display
_sanitize_output() {
  local input="$1"
  # Remove ANSI escape sequences
  echo "$input" | sed 's/\x1b\[[0-9;]*m//g'
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 11: CORE UTILITY FUNCTIONS
# ═════════════════════════════════════════════════════════════════════════════

# Secure sudo wrapper with validation
# Usage: secure_sudo "<command>"
# Security: Validates command against whitelist before execution
# Returns: Exit code of executed command or 1 for security violation
secure_sudo() {
  if [[ -z "$1" ]]; then
    echo "Usage: secure_sudo \"<command>\""
    return 1
  fi

  local cmd="$1"

  # Enhanced whitelist - add more commands as needed
  local -a allowed_commands=(
    "shutdown" "reboot" "systemctl" "modprobe" "umount"
    "wipefs" "mkfs.vfat" "mkfs.exfat" "mkfs.ntfs" "mkfs.ext4"
    "dmidecode" "lsblk" "fdisk" "parted"
    "apt" "apt-get" "dpkg" "dnf" "yum"
    "ufw" "iptables" "firewall-cmd"
  )

  # Parse command into array
  local -a cmd_array
  read -rA cmd_array <<< "$cmd"

  if [[ ${#cmd_array[@]} -eq 0 ]]; then
    _op_notify "failure" "Empty command"
    return 1
  fi

  local base_cmd="${cmd_array[1]}"

  # === CRITICAL SECURITY CHECKS ===

  # 1. Validate base command is whitelisted
  local allowed=false
  for allowed_cmd in "${allowed_commands[@]}"; do
    if [[ "$base_cmd" == "$allowed_cmd" ]]; then
      allowed=true
      break
    fi
  done

  if ! $allowed; then
    _op_notify "failure" "🚨 Command '$base_cmd' not in sudo whitelist"
    echo "Allowed commands: ${allowed_commands[*]}"
    return 1
  fi

  # 2. Check for dangerous characters in all arguments
  local arg
  for arg in "${cmd_array[@]}"; do
    # Check for shell metacharacters that could enable command injection
    if [[ "$arg" =~ [\;] ]] || \
       [[ "$arg" =~ [\|] ]] || \
       [[ "$arg" =~ [\&] ]] || \
       [[ "$arg" =~ [\`] ]] || \
       [[ "$arg" =~ [\$] ]] || \
       [[ "$arg" =~ [\(] ]] || \
       [[ "$arg" =~ [\)] ]] || \
       [[ "$arg" =~ [\<] ]] || \
       [[ "$arg" =~ [\>] ]]; then
        _op_notify "failure" "🚨 Dangerous character detected in: $arg"
        return 1
    fi
  done

  # 3. Prevent path traversal
  for arg in "${cmd_array[@]}"; do
    if [[ "$arg" == *".."* ]]; then
      _op_notify "failure" "🚨 Path traversal detected: $arg"
      return 1
    fi
  done

  # === EXECUTION ===
  _op_notify "elevated" "🔑 Requesting sudo for: ${cmd_array[*]}"

  # Execute with proper quoting
  sudo "${cmd_array[@]}"
  local exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    _op_notify "success" "✅ Privileged command completed"
  else
    _op_notify "failure" "❌ Command failed (exit: $exit_code)"
  fi

  return $exit_code
}

# Get threat level color code
# Usage: threat_color <level>
# Levels: 0=CRITICAL(red), 1=HIGH(orange), 2=MEDIUM(yellow), 3=LOW(green), 4=INFO(blue)
# Returns: ANSI color code string
threat_color() {
  local level=${1:-3}
  case $level in
    0) echo "38;2;255;0;0"     ;;
    1) echo "38;2;255;165;0"   ;;
    2) echo "38;2;255;255;0"   ;;
    3) echo "38;2;0;255;0"     ;;
    4) echo "38;2;0;191;255"   ;;
    *) echo "38;2;255;255;255" ;;
  esac
}

threat_level_to_text() {
  case $1 in
    0) echo "CRITICAL" ;;
    1) echo "HIGH" ;;
    2) echo "MEDIUM" ;;
    3) echo "LOW" ;;
    4) echo "INFO" ;;
    *) echo "UNKNOWN" ;;
  esac
}

random_color() {
  if [[ ${#ZSH_COLOR_PALETTE[@]} -eq 0 ]]; then
    echo "38;2;255;255;255"
    return
  fi
  echo "${ZSH_COLOR_PALETTE[$((RANDOM % ${#ZSH_COLOR_PALETTE[@]} + 1))]}"
}

gradient_text() {
  local text="$1"
  local len=${#text}

  if [[ $len -le 1 ]]; then
    local color=$(random_color)
    echo -e "\033[${color}m${text}\033[0m"
    return
  fi

  local output=""
  for ((i=0; i<len; i++)); do
    local char="${text:$i:1}"
    local r=$((255 - (i * 255 / (len - 1))))
    local g=$((i * 255 / (len - 1)))
    local b=$((127 + (i * 128 / (len - 1))))

    r=$(( r < 0 ? 0 : (r > 255 ? 255 : r) ))
    g=$(( g < 0 ? 0 : (g > 255 ? 255 : g) ))
    b=$(( b < 0 ? 0 : (b > 255 ? 255 : b) ))

    output+="\033[38;2;${r};${g};${b}m${char}\033[0m"
  done
  echo -e "$output"
}

format_bytes() {
  local bytes=${1:-0}
  local units=("B" "KB" "MB" "GB" "TB")
  local unit_index=0
  local size=$bytes

  while [[ $size -gt 1024 && $unit_index -lt 4 ]]; do
    size=$((size / 1024))
    unit_index=$((unit_index + 1))
  done

  echo "${size}${units[$unit_index]}"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

safe_system_call() {
  local cmd="$1"
  local timeout_duration=${2:-5}
  local fallback_value="${3:-N/A}"

  if command_exists timeout; then
    # Use eval to handle complex commands with arguments safe from splitting issues
    timeout "$timeout_duration" zsh -c "$cmd" 2>/dev/null || echo "$fallback_value"
  else
    eval "$cmd" 2>/dev/null || echo "$fallback_value"
  fi
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 12: ANIMATION SYSTEM
# ═══════════════════════════════════════════════════════════════════════════

loading_animation() {
  local message="${1:-⚡ Initializing Shadow Systems}"
  local duration=${2:-2.0}
  local callback_function="${3:-}"
  local style="${4:-matrix}"
  local show_eta="${5:-false}"

  local width=50
  local steps=100

  local duration_int=${duration%.*}
  local duration_frac=${duration#*.}
  [[ "$duration_frac" == "$duration" ]] && duration_frac=0
  local total_ms=$(( (duration_int * 1000) + (duration_frac * 100) ))
  local step_ms=$((total_ms / steps))
  [[ $step_ms -lt 10 ]] && step_ms=10

  local chars
  case "$style" in
    matrix)   chars="▓▒░▓▒░▓▒░" ;;
    wave)     chars="∿∾∽∼∽∾∿" ;;
    pulse)    chars="💀😈💀😈💀😈💀" ;;
    scan)     chars="▁▂▃▄▅▆▇█" ;;
    fire)     chars="🔥💥⚡✨" ;;
    *)        chars="⣾⣽⣻⢿⡿⣟⣯⣷" ;;
  esac

  local -a gradient=(
    "38;2;0;255;0"
    "38;2;0;220;0"
    "38;2;0;180;0"
    "38;2;0;140;0"
  )

  local msg_color="${gradient[0]}"
  echo -e "\033[${msg_color};1m$message\033[0m"

  local start_time=$(date +%s)

  for ((i=0; i<=steps; i++)); do
    local progress=$((i * 100 / steps))
    local filled=$((i * width / steps))
    local empty=$((width - filled))

    local color_idx=$((i * ${#gradient[@]} / steps))
    [[ $color_idx -ge ${#gradient[@]} ]] && color_idx=$((${#gradient[@]} - 1))
    local color="${gradient[$color_idx]}"

    local spinner_idx=$((i % ${#chars}))
    local spinner="${chars:$spinner_idx:1}"

    local eta_text=""
    if [[ "$show_eta" == "true" && $i -gt 5 ]]; then
      local elapsed=$(($(date +%s) - start_time))
      local rate=$((i > 0 ? i : 1))
      local remaining=$(( (steps - i) * elapsed / rate ))
      eta_text=" ETA: ${remaining}s"
    fi

    printf "\r\033[${color}m[$spinner] ["
    for ((j=0; j<filled; j++)); do
      local char_idx=$(( (j + i) % ${#chars} ))
      printf "${chars:$char_idx:1}"
    done
    for ((j=0; j<empty; j++)); do
      printf "░"
    done
    printf "] %3d%%%s\033[0m" "$progress" "$eta_text"

    if [[ -n "$callback_function" ]] && declare -f "$callback_function" >/dev/null 2>&1; then
      if [[ $((progress % 25)) -eq 0 ]] || [[ $progress -eq 100 ]]; then
        "$callback_function" "$progress" 2>/dev/null &
      fi
    fi

    sleep $(printf "0.%03d" $step_ms)
  done

  printf "\r\033[K"
  echo -e "\033[38;2;0;255;0m✅ Complete\033[0m"
}

# Multi-stage loading
loading_multi_stage() {
  local -a stages=("$@")
  local total_stages=${#stages[@]}

  for ((i=0; i<total_stages; i++)); do
    local stage_name="${stages[$i]}"
    local stage_duration=$((2 + RANDOM % 3))

    echo -e "\n\033[38;2;255;255;0m┏━━ Stage $((i+1))/$total_stages: $stage_name ━━┓\033[0m"
    loading_animation "$stage_name" "$stage_duration" "" "matrix" "true"
    sleep 0.5
  done

  echo -e "\n\033[38;2;0;255;0m🎯 All stages completed successfully!\033[0m"
}

# Background loading with PID tracking
loading_background() {
  local message="$1"
  local command="$2"
  local pid_file="/tmp/loading_$$.pid"

  {
    local i=0
    local chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    while kill -0 $$ 2>/dev/null; do
      local spinner="${chars:$((i % ${#chars})):1}"
      printf "\r\033[38;2;0;255;255m[$spinner] %s\033[0m" "$message"
      ((i++))
      sleep 0.1
    done
  } &
  local spinner_pid=$!
  echo $spinner_pid > "$pid_file"

  # Secure command execution with validation
  if [[ "$command" =~ ^[a-zA-Z0-9_[:space:]/-]+$ ]]; then
    # Additional validation against dangerous patterns
    local -a dangerous=('rm -rf' 'dd if=' ':(){:|:&};:' 'mkfs' 'wipefs')
    for pat in "${dangerous[@]}"; do
      if [[ "$command" == *"$pat"* ]]; then
        echo "🚨 Security: Dangerous command pattern detected: $pat"
        return 1
      fi
    done
    bash -c "$command"
  else
    echo "🚨 Security: Unsafe command detected"
    return 1
  fi
  local exit_code=$?

  kill $spinner_pid 2>/dev/null
  wait $spinner_pid 2>/dev/null
  rm -f "$pid_file"

  printf "\r\033[K"
  if [[ $exit_code -eq 0 ]]; then
    echo -e "\033[38;2;0;255;0m✅ $message - Success\033[0m"
  else
    echo -e "\033[38;2;255;0;0m❌ $message - Failed (code: $exit_code)\033[0m"
  fi

  return $exit_code
}

matrix_rain() {
  setopt localoptions localtraps ksharrays
  trap 'tput cnorm 2>/dev/null; stty echo 2>/dev/null; printf "\033[0m\033[?25h"' EXIT INT TERM

  local duration=${1:-5}
  local density=${2:-50}
  local theme=${3:-matrix}
  local charset=${4:-katakana}
  local show_fps=${5:-false}

  # === INPUT VALIDATION ===

  # Validate duration (1-300 seconds)
  if ! [[ "$duration" =~ ^[0-9]+$ ]] || [[ $duration -lt 1 ]] || [[ $duration -gt 300 ]]; then
    echo "⚠️ Invalid duration (must be 1-300): $duration"
    duration=5
  fi

  # Validate density (1-100)
  if ! [[ "$density" =~ ^[0-9]+$ ]] || [[ $density -lt 1 ]] || [[ $density -gt 100 ]]; then
    echo "⚠️ Invalid density (must be 1-100): $density"
    density=50
  fi

  # Validate theme (whitelist only)
  case "$theme" in
    matrix|cyber|blood|ice|fire) ;;
    *)
      echo "⚠️ Invalid theme. Using 'matrix'"
      theme="matrix"
      ;;
  esac

  # Validate charset (whitelist only)
  case "$charset" in
    katakana|binary|hex|ascii|dna) ;;
    *)
      echo "⚠️ Invalid charset. Using 'katakana'"
      charset="katakana"
      ;;
  esac

  # Validate show_fps (boolean only)
  if [[ "$show_fps" != "true" && "$show_fps" != "false" ]]; then
    show_fps="false"
  fi

  # Terminal capability check
  if ! command -v tput &>/dev/null; then
    echo "⚠️ Terminal not supported for matrix effect"
    return 1
  fi

  local width=$(tput cols 2>/dev/null)
  local height=$(tput lines 2>/dev/null)

  # Bounds checking with safe defaults
  width=${width:-80}
  height=${height:-24}

  # Enforce maximum dimensions to prevent DoS
  [[ $width -lt 10 ]] && width=10
  [[ $height -lt 10 ]] && height=10
  [[ $width -gt 300 ]] && width=300
  [[ $height -gt 100 ]] && height=100

  local chars
  case "$charset" in
    katakana) chars="ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝ日ｱｲｳ" ;;
    binary)   chars="01010101010101010101" ;;
    hex)      chars="0123456789ABCDEF" ;;
    ascii)    chars="!@#$%^&*()_+-=[]{}|;:,.<>?/~\`" ;;
    dna)      chars="ATCGATCGATCGATCG" ;;
    *)        chars="$charset" ;;
  esac
  local num_chars=${#chars}

  local -a colors
  case "$theme" in
    matrix)
      colors=("38;2;0;255;0" "38;2;0;220;0" "38;2;0;180;0" "38;2;0;140;0" "38;2;0;100;0" "38;2;0;60;0" "38;2;0;30;0")
      ;;
    cyber)
      colors=("38;2;0;255;255" "38;2;255;0;255" "38;2;0;191;255" "38;2;138;43;226" "38;2;75;0;130" "38;2;50;0;90")
      ;;
    blood)
      colors=("38;2;255;0;0" "38;2;220;0;0" "38;2;180;0;0" "38;2;140;0;0" "38;2;100;0;0" "38;2;60;0;0")
      ;;
    ice)
      colors=("38;2;173;216;230" "38;2;135;206;250" "38;2;100;149;237" "38;2;70;130;180" "38;2;25;25;112")
      ;;
    fire)
      colors=("38;2;255;255;0" "38;2;255;165;0" "38;2;255;69;0" "38;2;220;20;60" "38;2;139;0;0")
      ;;
    *)
      colors=("38;2;255;255;255")
      ;;
  esac
  local num_colors=${#colors[@]}

  declare -a columns lengths speeds intensities
  local active_columns=$((width * density / 100))
  [[ $active_columns -lt 1 ]] && active_columns=1

  for ((i=0; i<width; i++)); do
    if [[ $i -lt $active_columns ]]; then
      columns[$i]=$(( -(RANDOM % height) ))
      lengths[$i]=$((RANDOM % (height / 2) + height / 4))
      speeds[$i]=$((RANDOM % 3 + 1))
      intensities[$i]=$((RANDOM % 100))
    else
      columns[$i]=-9999
    fi
  done

  tput civis 2>/dev/null
  stty -echo 2>/dev/null
  printf "\033[2J\033[H\033[?25l"

  local frame_count=0
  local start_time=$(date +%s)
  local end_time=$((start_time + duration))
  local last_fps_time=$start_time
  local fps=0

  while [[ $(date +%s) -lt $end_time ]]; do
    local frame_buffer=""
    ((frame_count++))

    if [[ $((frame_count % 10)) -eq 0 ]]; then
      frame_buffer+="\033[2J"
    fi

    for ((i=0; i<width; i++)); do
      [[ ${columns[$i]} -eq -9999 ]] && continue

      local col_pos=${columns[$i]}
      local col_len=${lengths[$i]}
      local col_speed=${speeds[$i]}

      if [[ $((col_pos - col_len)) -lt height ]]; then
        for ((j=0; j<col_len; j++)); do
          local y_pos=$((col_pos - j))

          if [[ y_pos -ge 0 && y_pos -lt height ]]; then
            local color_idx=$(( (j * (num_colors - 1)) / col_len ))
            color_idx=$((color_idx >= num_colors ? num_colors - 1 : color_idx))

            local char_idx=$(( (y_pos + i + frame_count) % num_chars ))
            local brightness=$((intensities[i] > 50 ? 1 : 2))

            frame_buffer+="\033[$((y_pos + 1));$((i + 1))H\033[${brightness};${colors[$color_idx]}m${chars:$char_idx:1}"
          fi
        done

        if [[ col_pos -ge 0 && col_pos -lt height ]]; then
          local lead_char=$(( (col_pos + i + frame_count * 2) % num_chars ))
          frame_buffer+="\033[$((col_pos + 1));$((i + 1))H\033[1;${colors[0]}m${chars:$lead_char:1}"
        fi

        columns[$i]=$((col_pos + col_speed))

        if [[ $((col_pos - col_len)) -ge height ]]; then
          columns[$i]=$(( -(RANDOM % (height / 2)) ))
          lengths[$i]=$((RANDOM % (height / 2) + height / 4))
          speeds[$i]=$((RANDOM % 3 + 1))
          intensities[$i]=$((RANDOM % 100))
        fi
      fi
    done

    if [[ "$show_fps" == "true" ]]; then
      local current_time=$(date +%s)
      if [[ $((current_time - last_fps_time)) -gt 0 ]]; then
        fps=$frame_count
        last_fps_time=$current_time
        frame_count=0
      fi
      frame_buffer+="\033[1;1H\033[38;2;255;255;0m FPS: $fps \033[0m"
    fi

    printf "%b" "$frame_buffer\033[0m"
    sleep 0.04
  done

  tput cnorm 2>/dev/null
  stty echo 2>/dev/null
  printf "\033[2J\033[H\033[?25h\033[0m"
}

matrix() { matrix_rain "${1:-5}" "${2:-50}" "${3:-matrix}" "${4:-katakana}" "${5:-false}"; }
matrix_cyber() { matrix_rain "${1:-5}" 70 "cyber" "hex" "false"; }
matrix_blood() { matrix_rain "${1:-5}" 60 "blood" "binary" "false"; }
matrix_screensaver() {
  echo -e "\033[38;2;0;255;0m🔋 Neural Cascade Screensaver Activated\033[0m"
  matrix_rain "${1:-30}" 80 "matrix" "katakana" "true"
  echo -e "\033[38;2;0;255;0m✅ Screensaver Deactivated\033[0m"
}
matrix_benchmark() {
  echo "🔬 Matrix Benchmark Mode - Testing Performance..."
  local start=$(date +%s)
  matrix_rain 10 100 "matrix" "katakana" "true"
  local end=$(date +%s)
  echo "⏱️ Total time: $((end - start))s"
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 13: CPU MONITORING SYSTEM
# ═══════════════════════════════════════════════════════════════════════════

typeset -gA _ZSH_CPU_HISTORY=()
typeset -ga _ZSH_CPU_TIMESTAMPS=()
typeset -g _ZSH_CPU_MAX_HISTORY=100  # Limit history size

_zsh_init_cpu_monitor() {
  mkdir -p "$XDG_CACHE_HOME/zsh"
  _ZSH_CPU_HISTORY=()
  _ZSH_CPU_TIMESTAMPS=()
}

_zsh_cleanup_cpu_history() {
  # Keep only last N entries to prevent memory leaks
  local current_size=${#_ZSH_CPU_TIMESTAMPS[@]}
  if [[ $current_size -gt $_ZSH_CPU_MAX_HISTORY ]]; then
    local trim_count=$((current_size - _ZSH_CPU_MAX_HISTORY))
    _ZSH_CPU_TIMESTAMPS=("${_ZSH_CPU_TIMESTAMPS[@]:$trim_count}")
    # Clean history keys accordingly
    local -a keys_to_remove=("${_ZSH_CPU_TIMESTAMPS[@]:0:$trim_count}")
    for key in "${keys_to_remove[@]}"; do
      unset "_ZSH_CPU_HISTORY[$key]"
    done
  fi
}

_zsh_get_cpu_usage() {
  local mode="${1:-total}"
  local stat_file="$XDG_CACHE_HOME/zsh/cpu_last_stat"

  local -a last_stat
  if [[ -f "$stat_file" ]]; then
    last_stat=($(<"$stat_file"))
  else
    last_stat=(0 0 0 0 0 0 0 0)
  fi

  local -a current_stat
  if [[ "$mode" == "per-core" ]]; then
    current_stat=($(awk '/^cpu[0-9]+ / {print $2+$3+$4, $2+$3+$4+$5+$6+$7+$8}' /proc/stat 2>/dev/null))
  else
    current_stat=($(awk '/^cpu / {print $2+$3+$4+$6+$7+$8, $2+$3+$4+$5+$6+$7+$8, $2, $4, $5, $6, $7, $8}' /proc/stat 2>/dev/null))
  fi

  echo "${current_stat[@]}" > "$stat_file"

  if [[ "$mode" == "detailed" ]]; then
    local delta_total=$((current_stat[1] - last_stat[1]))
    if [[ $delta_total -gt 0 ]]; then
      local user_pct=$(( (current_stat[2] - last_stat[2]) * 100 / delta_total ))
      local system_pct=$(( (current_stat[3] - last_stat[3]) * 100 / delta_total ))
      local idle_pct=$(( (current_stat[4] - last_stat[4]) * 100 / delta_total ))
      local iowait_pct=$(( (current_stat[5] - last_stat[5]) * 100 / delta_total ))
      local irq_pct=$(( (current_stat[6] - last_stat[6]) * 100 / delta_total ))
      local softirq_pct=$(( (current_stat[7] - last_stat[7]) * 100 / delta_total ))

      echo "user:$user_pct system:$system_pct idle:$idle_pct iowait:$iowait_pct irq:$irq_pct softirq:$softirq_pct"
    else
      echo "user:0 system:0 idle:100 iowait:0 irq:0 softirq:0"
    fi
  elif [[ "$mode" == "per-core" ]]; then
    local num_cores=$((${#current_stat[@]} / 2))
    local core_usages=()

    for ((i=0; i<num_cores; i++)); do
      local idx=$((i * 2))
      local delta_total=$((current_stat[$((idx + 1))] - last_stat[$((idx + 1))]))
      local delta_busy=$((current_stat[$idx] - last_stat[$idx]))

      if [[ $delta_total -gt 0 ]]; then
        local core_usage=$((delta_busy * 100 / delta_total))
        core_usages+=("$core_usage")
      else
        core_usages+=("0")
      fi
    done

    echo "${core_usages[@]}"
  else
    local delta_total=$((current_stat[1] - last_stat[1]))
    local delta_busy=$((current_stat[0] - last_stat[0]))

    if [[ $delta_total -gt 0 ]]; then
      printf "%.1f" $(echo "$delta_busy $delta_total" | awk '{print 100 * $1 / $2}')
    else
      echo "0.0"
    fi
  fi
}

_zsh_get_cpu_temp() {
  local temp="N/A"

  # Try multiple temperature sources with fallbacks
  if command -v sensors &>/dev/null; then
    temp=$(sensors 2>/dev/null | awk '/^Core 0:/ {print $3}' | tr -d '+°C' | head -1)
  fi

  # Fallback to thermal zone
  if [[ "$temp" == "N/A" || -z "$temp" ]] && [[ -f /sys/class/thermal/thermal_zone0/temp ]]; then
    local raw_temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
    if [[ "$raw_temp" =~ ^[0-9]+$ ]]; then
      temp=$(( raw_temp / 1000 ))
    fi
  fi

  # Fallback to other thermal zones
  if [[ "$temp" == "N/A" ]]; then
    for zone in /sys/class/thermal/thermal_zone*/temp; do
      if [[ -f "$zone" ]]; then
        local raw_temp=$(cat "$zone" 2>/dev/null)
        if [[ "$raw_temp" =~ ^[0-9]+$ ]] && [[ $raw_temp -gt 1000 ]]; then
          temp=$(( raw_temp / 1000 ))
          break
        fi
      fi
    done
  fi

  echo "${temp:-N/A}"
}

_zsh_get_cpu_freq() {
  if [[ -f /proc/cpuinfo ]]; then
    awk '/^cpu MHz/ {sum+=$4; count++} END {if(count>0) printf "%.0f", sum/count}' /proc/cpuinfo
  else
    echo "N/A"
  fi
}

_zsh_generate_cpu_graph() {
  local -a history=("$@")
  local max_height=10
  local max_val=100
  local graph=""

  for val in "${history[@]}"; do
    local bar_height=$(( (val * max_height) / max_val ))
    [[ $bar_height -gt max_height ]] && bar_height=$max_height

    local color
    if [[ $val -gt 80 ]]; then
      color="38;2;255;0;0"
    elif [[ $val -gt 60 ]]; then
      color="38;2;255;165;0"
    elif [[ $val -gt 40 ]]; then
      color="38;2;255;255;0"
    else
      color="38;2;0;255;0"
    fi

    local bar=""
    for ((i=0; i<bar_height; i++)); do
      bar="█$bar"
    done

    printf "\033[${color}m%-10s\033[0m " "$bar"
  done
  echo
}

cpu_status() {
  if [[ "$ENABLE_ADVANCED_CPU" != true ]]; then
    echo "⚠️ Advanced CPU monitoring disabled. Enable ENABLE_ADVANCED_CPU in config."
    return 1
  fi

  echo -e "\033[38;2;0;255;255m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo -e "\033[38;2;255;255;0m          💀 NEURAL METRICS - CPU STATUS 💀\033[0m"
  echo -e "\033[38;2;0;255;255m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

  local total_usage=$(_zsh_get_cpu_usage "total")
  echo -e "\n\033[38;2;0;255;0m🔋 Total CPU Usage:\033[0m $total_usage%"

  echo -e "\n\033[38;2;0;255;0m⚡ Per-Core Usage:\033[0m"
  local -a core_usages=($(_zsh_get_cpu_usage "per-core"))
  for ((i=0; i<${#core_usages[@]}; i++)); do
    local usage=${core_usages[$i]}
    local bar=""
    local filled=$((usage / 5))

    for ((j=0; j<20; j++)); do
      if [[ $j -lt $filled ]]; then
        if [[ $usage -gt 80 ]]; then bar+="\033[38;2;255;0;0m█\033[0m"
        elif [[ $usage -gt 60 ]]; then bar+="\033[38;2;255;165;0m█\033[0m"
        else bar+="\033[38;2;0;255;0m█\033[0m"; fi
      else
        bar+="\033[38;2;50;50;50m░\033[0m"
      fi
    done

    printf "  Core %2d: [%b] %3d%%\n" "$i" "$bar" "$usage"
  done

  echo -e "\n\033[38;2;0;255;0m📊 Breakdown:\033[0m"
  local detailed=$(_zsh_get_cpu_usage "detailed")
  echo "$detailed" | tr ' ' '\n' | while IFS=: read key val; do
    printf "  %-10s %3d%%\n" "$key:" "$val"
  done

  local temp=$(_zsh_get_cpu_temp)
  if [[ "$temp" != "N/A" ]]; then
    local temp_color
    if [[ $temp -gt 80 ]]; then temp_color="38;2;255;0;0"
    elif [[ $temp -gt 70 ]]; then temp_color="38;2;255;165;0"
    else temp_color="38;2;0;255;0"; fi

    echo -e "\n\033[${temp_color}m🌡️ Temperature:\033[0m ${temp}°C"
  fi

  local freq=$(_zsh_get_cpu_freq)
  [[ "$freq" != "N/A" ]] && echo -e "\033[38;2;0;255;255m⚡ Frequency:\033[0m ${freq} MHz"

  echo -e "\n\033[38;2;255;255;0m🔥 Top CPU Consumers:\033[0m"
  ps aux --sort=-%cpu | awk 'NR>1 {printf "  %-20s %5.1f%%\n", $11, $3}' | head -5

  echo -e "\033[38;2;0;255;255m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
}

cpu_monitor_live() {
  if [[ "$ENABLE_ADVANCED_CPU" != true ]]; then
    echo "⚠️ Advanced CPU monitoring disabled. Enable ENABLE_ADVANCED_CPU in config."
    return 1
  fi

  local duration="${1:-30}"
  local sample_interval="${2:-1}"

  echo -e "\033[38;2;0;255;255m🔬 Live CPU Monitor - Press Ctrl+C to exit\033[0m\n"

  local -a history
  local end_time=$(($(date +%s) + duration))

  trap 'tput cnorm; echo -e "\n\033[38;2;0;255;0m✅ Monitor stopped\033[0m"; return' INT
  tput civis

  while [[ $(date +%s) -lt $end_time ]]; do
    local usage=$(_zsh_get_cpu_usage "total")
    history+=("${usage%.*}")

    [[ ${#history[@]} -gt 30 ]] && history=("${history[@]:1}")

    printf "\033[2J\033[H"
    echo -e "\033[38;2;255;255;0mCPU Usage History (last ${#history[@]} samples):\033[0m"
    _zsh_generate_cpu_graph "${history[@]}"
    echo -e "\n\033[38;2;0;255;0mCurrent: ${usage}%\033[0m"

    sleep $sample_interval
  done

  tput cnorm
  echo -e "\n\033[38;2;0;255;0m✅ Monitoring complete\033[0m"
}

alias cpu='_zsh_get_cpu_usage'
alias cpu-temp='_zsh_get_cpu_temp'
alias cpu-detailed='_zsh_get_cpu_usage detailed'
alias cpu-cores='_zsh_get_cpu_usage per-core'
alias cpu-live='cpu_monitor_live'
alias cpu-status='cpu_status'

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 14: CACHING SYSTEM
# ═══════════════════════════════════════════════════════════════════════════

_zsh_cache_file="$XDG_CACHE_HOME/zsh/zsh_cache.json"
_zsh_cache_ttl=60

get_cached() {
  [[ "$ENABLE_CACHE_SYSTEM" != true ]] && return 1

  local key="$1"
  local cache_file="$_zsh_cache_file"
  local lock_file="${cache_file}.lock"

  # Create cache directory if needed
  mkdir -p "$(dirname "$cache_file")"

  # Use simple file-based locking
  if [[ -f "$lock_file" ]]; then
    local lock_age=$(($(date +%s) - $(stat -c %Y "$lock_file" 2>/dev/null || echo 0)))
    if [[ $lock_age -gt 5 ]]; then
      rm -f "$lock_file"
    else
      return 1
    fi
  fi

  echo $$ > "$lock_file" || return 1

  # Read cache
  local expiry=$(jq -r ".${key}.expiry" "$cache_file" 2>/dev/null)
  local now=$(date +%s)

  # Cleanup lock
  rm -f "$lock_file"

  if [[ -n "$expiry" && "$expiry" != "null" && "$now" -lt "$expiry" ]]; then
    jq -r ".${key}.value" "$cache_file"
    return 0
  fi

  return 1
}

set_cached() {
  [[ "$ENABLE_CACHE_SYSTEM" != true ]] && return 1

  local key="$1"
  local value="$2"
  local expiry=$(($(date +%s) + _zsh_cache_ttl))

  local cache_file="$_zsh_cache_file"
  local lock_file="${cache_file}.lock"

  # Create cache directory with secure permissions
  local cache_dir=$(dirname "$cache_file")
  mkdir -p "$cache_dir"
  chmod 700 "$cache_dir"

  # Use simple file-based locking
  if [[ -f "$lock_file" ]]; then
    local lock_age=$(($(date +%s) - $(stat -c %Y "$lock_file" 2>/dev/null || echo 0)))
    if [[ $lock_age -gt 5 ]]; then
      rm -f "$lock_file"
    else
      return 1
    fi
  fi

  echo $$ > "$lock_file" || return 1

  # Critical section
  local temp_file=$(mktemp "$cache_dir/.cache.XXXXXX")
  chmod 600 "$temp_file"

  # Initialize if doesn't exist
  if [[ ! -f "$cache_file" ]]; then
    echo '{}' > "$cache_file"
    chmod 600 "$cache_file"
  fi

  # Update cache
  jq --arg key "$key" \
     --arg value "$value" \
     --argjson expiry "$expiry" \
     '.[$key] = {value: $value, expiry: $expiry}' \
     "$cache_file" > "$temp_file"

  # Atomic move
  mv "$temp_file" "$cache_file"
  chmod 600 "$cache_file"

  # Cleanup lock
  rm -f "$lock_file"
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 15: SYSTEM INFORMATION DISPLAY
# ═══════════════════════════════════════════════════════════════════════════

show_system_info() {
  local cached_info=$(get_cached "system_info")
  if [[ -n "$cached_info" ]]; then
    echo -e "$cached_info"
    return
  fi

  local output_buffer=""
  local primary_color="38;2;255;0;255"
  local secondary_color="38;2;0;255;255"
  local accent_color="38;2;255;255;0"
  local success_color="38;2;0;255;0"
  local warning_color="38;2;255;165;0"
  local danger_color="38;2;255;0;0"

  output_buffer+="\033[${primary_color}m"
  if command -v figlet &>/dev/null; then
    output_buffer+=$(echo "Shadow@Bhanu" | figlet -f slant 2>/dev/null)
  else
    output_buffer+=$(gradient_text "🚀 Shadow@Bhanu Elite Terminal 🚀")
  fi
  output_buffer+="\033[0m\n"

  output_buffer+="\033[${secondary_color}m╔═══════════════════════════════════════════════════════════════════════════════╗\033[0m\n"
  output_buffer+="\033[${secondary_color}m║\033[0m \033[${accent_color}m😈💀 This ain't a shell 😏 it's a weaponized AI brain 🤖 Are You Ready ?😎😈 \033[0m \033[${secondary_color}m║\033[0m\n"
  output_buffer+="\033[${secondary_color}m╠═══════════════════════════════════════════════════════════════════════════════╣\033[0m\n"

  local hostname=$(hostname 2>/dev/null || echo "UNKNOWN")
  local kernel=$(uname -r 2>/dev/null || echo "UNKNOWN")
  local os_info=$(lsb_release -d 2>/dev/null | cut -f2 || uname -o 2>/dev/null || echo "UNKNOWN")
  local arch=$(uname -m 2>/dev/null || echo "UNKNOWN")

  output_buffer+="\033[${secondary_color}m║\033[0m \033[${primary_color}m🌐 HOST:\033[0m $hostname \033[${accent_color}m⚡ KERNEL:\033[0m $kernel \033[${success_color}m🗄️ ARCH:\033[0m $arch\n"
  output_buffer+="\033[${secondary_color}m║\033[0m \033[${primary_color}m🖥️ OS:\033[0m $os_info\n"

  local uptime_info=$(uptime -p 2>/dev/null | sed 's/up //' || echo "UNKNOWN")
  local load_avg=$(uptime 2>/dev/null | awk -F'load average:' '{print $2}' | sed 's/^ *//' || echo "N/A")
  local current_time=$(date '+%H:%M:%S %Z' 2>/dev/null)
  local current_date=$(date '+%Y-%m-%d %A' 2>/dev/null)

  output_buffer+="\033[${secondary_color}m║\033[0m \033[${accent_color}m⏱️ UPTIME:\033[0m $uptime_info \033[${warning_color}m📊 LOAD:\033[0m $load_avg\n"
  output_buffer+="\033[${secondary_color}m║\033[0m \033[${success_color}m🕐 TIME:\033[0m $current_time \033[${primary_color}m📅 DATE:\033[0m $current_date\n"

  if command -v free &>/dev/null; then
    local memory_total=$(free -m 2>/dev/null | awk 'NR==2{print $2}')
    local memory_used=$(free -m 2>/dev/null | awk 'NR==2{print $3}')
    local memory_percent=$(free -m 2>/dev/null | awk 'NR==2{printf "%.0f", $3*100/$2}')
    local memory_bar=""

    for ((i=0; i<30; i++)); do
      if [[ $i -lt $((memory_percent*30/100)) ]]; then
        if [[ $memory_percent -gt 80 ]]; then
          memory_bar+="\033[${danger_color}m█\033[0m"
        elif [[ $memory_percent -gt 60 ]]; then
          memory_bar+="\033[${warning_color}m█\033[0m"
        else
          memory_bar+="\033[${success_color}m█\033[0m"
        fi
      else
        memory_bar+="\033[38;2;64;64;64m░\033[0m"
      fi
    done

    output_buffer+="\033[${secondary_color}m║\033[0m \033[${primary_color}m🧠 MEMORY:\033[0m ${memory_used}MB/${memory_total}MB (${memory_percent}%) $memory_bar\n"
  fi

  if command -v df &>/dev/null; then
    local disk_used=$(df -h / 2>/dev/null | awk 'NR==2{print $3}' || echo "N/A")
    local disk_total=$(df -h / 2>/dev/null | awk 'NR==2{print $2}' || echo "N/A")
    local disk_percent=$(df / 2>/dev/null | awk 'NR==2{print $5}' | sed 's/%//' || echo "0")
    local disk_bar=""

    for ((i=0; i<30; i++)); do
      if [[ $i -lt $((disk_percent*30/100)) ]]; then
        if [[ $disk_percent -gt 85 ]]; then
          disk_bar+="\033[${danger_color}m█\033[0m"
        elif [[ $disk_percent -gt 70 ]]; then
          disk_bar+="\033[${warning_color}m█\033[0m"
        else
          disk_bar+="\033[${success_color}m█\033[0m"
        fi
      else
        disk_bar+="\033[38;2;64;64;64m░\033[0m"
      fi
    done

    output_buffer+="\033[${secondary_color}m║\033[0m \033[${accent_color}m💾 STORAGE:\033[0m $disk_used/$disk_total (${disk_percent}%) $disk_bar\n"
  fi

  if command -v ip &>/dev/null; then
    local ip_addr=$(ip route get 8.8.8.8 2>/dev/null | grep -oP 'src \K\S+' || echo "N/A")
    local interface=$(ip route get 8.8.8.8 2>/dev/null | grep -oP 'dev \K\S+' || echo "N/A")
    local public_ip_line=""

    if [[ "$ENABLE_PUBLIC_IP_LOOKUP" == "true" ]]; then
      local public_ip=$(timeout 2 curl -s https://ipinfo.io/ip 2>/dev/null || echo "LOOKUP FAILED")
      public_ip_line=" \033[${primary_color}m🌍 PUBLIC:\033[0m $public_ip"
    fi

    output_buffer+="\033[${secondary_color}m║\033[0m \033[${success_color}m🌐 LOCAL:\033[0m $ip_addr \033[${warning_color}m📡 INTERFACE:\033[0m $interface$public_ip_line\n"
  fi

  if command -v lscpu &>/dev/null; then
    local cpu_info=$(lscpu 2>/dev/null | grep "Model name" | cut -d':' -f2 | sed 's/^ *//' | cut -c1-50 || echo "N/A")
    local cpu_cores=$(nproc 2>/dev/null || echo "N/A")
    local cpu_usage=$(_zsh_get_cpu_usage)
    local cpu_temp=""

    if command -v sensors &>/dev/null; then
      cpu_temp=$(sensors 2>/dev/null | grep -i 'core 0' | awk '{print $3}' | head -1 2>/dev/null || echo "")
      [[ -n "$cpu_temp" ]] && cpu_temp=" 🌡️$cpu_temp"
    fi

    output_buffer+="\033[${secondary_color}m║\033[0m \033[${accent_color}m⚙️ CPU:\033[0m $cpu_info (${cpu_cores} cores) ${cpu_usage}%$cpu_temp\n"
  fi

  local processes=$(ps aux 2>/dev/null | wc -l || echo "N/A")
  local users=$(who 2>/dev/null | wc -l || echo "N/A")
  local zombie_processes=$(ps aux 2>/dev/null | awk '$8 ~ /^Z/ { count++ } END { print count+0 }' || echo "0")

  output_buffer+="\033[${secondary_color}m║\033[0m \033[${success_color}m⚡ PROCESSES:\033[0m $processes \033[${primary_color}m👥 USERS:\033[0m $users \033[${danger_color}m🧟 ZOMBIES:\033[0m $zombie_processes\n"

  local failed_logins=$(lastb 2>/dev/null | wc -l || echo "0")
  local active_sessions=$(w -h 2>/dev/null | wc -l || echo "0")

  output_buffer+="\033[${secondary_color}m║\033[0m \033[${danger_color}m🔒 FAILED_LOGINS:\033[0m $failed_logins \033[${warning_color}m🔺 ACTIVE_SESSIONS:\033[0m $active_sessions\n"

  output_buffer+="\033[${secondary_color}m╚═══════════════════════════════════════════════════════════════════════════════╝\033[0m\n"

  set_cached "system_info" "$output_buffer"
  echo -e "$output_buffer"
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 16: GREETING SYSTEM
# ═══════════════════════════════════════════════════════════════════════════

time_based_greeting() {
  local hour=$(date +"%H")
  local greeting
  local -a options
  local color=$(random_color)

  local threat_level=3
  if [[ $hour -ge 0 && $hour -lt 6 ]]; then
    threat_level=1
  elif [[ $hour -ge 6 && $hour -lt 9 ]]; then
    threat_level=2
  elif [[ $hour -ge 18 && $hour -lt 24 ]]; then
    threat_level=2
  fi

  if [[ $hour -ge 5 && $hour -lt 12 ]]; then
    options=(
      "🌅 Morning, Shadow 😈 – AI swarm online, targets acquired 🎯"
      "🔥 Rise and dominate, Shadow 😈 – neural networks activated 🧠"
      "🌄 Dawn protocol initiated, Shadow 😈 – red team standing by 🚨"
      "☀️ Morning breach, Shadow 😈 – all systems green 🟢"
      "🛠️ Operations online, Shadow 😈 – ready to penetrate 💀"
    )
  elif [[ $hour -ge 12 && $hour -lt 17 ]]; then
    options=(
      "🌞 Afternoon ops, Shadow 😈 – targets in crosshairs 🎯"
      "💣 Midday strike, Shadow 😈 – cyber weapons hot 🔥"
      "⚙️ Systems peaked, Shadow 😈 – maximum efficiency 📊"
      "🔓 Vulnerabilities exposed, Shadow 😈 – exploit ready 💥"
      "💀 Afternoon hunt, Shadow 😈 – stealth mode engaged 👻"
    )
  elif [[ $hour -ge 17 && $hour -lt 21 ]]; then
    options=(
      "🌆 Evening infiltration, Shadow 😈 – darkness approaching 🌙"
      "⚡ Dusk operations, Shadow 😈 – time to strike 🗡️"
      "🌇 Shadow protocol, Shadow 😈 – moving unseen 👻"
      "🚨 Night ops prep, Shadow 😈 – going dark 🕶️"
      "🌌 Stealth mode, Shadow 😈 – hunt begins 🔍"
    )
  else
    options=(
      "🌙 Midnight ops, Shadow 😈 – silent running 🤫"
      "🌃 Night hunter, Shadow 😈 – invisible strike 👻"
      "💣 Zero dark thirty, Shadow 😈 – full stealth 🕶️"
      "🛡️ Insomniac ops, Shadow 😈 – always watching 👁️"
      "🕛 Late night breach, Shadow 😈 – systems never sleep 💀"
    )
  fi

  greeting="${options[$(( (RANDOM % ${#options[@]}) + 1 ))]}"

  local threat_color_code=$(threat_color $threat_level)
  echo -e "\033[${threat_color_code}m$greeting\033[0m"

  local threat_text=""
  case $threat_level in
    0) threat_text="🔴 CRITICAL" ;;
    1) threat_text="🟠 HIGH" ;;
    2) threat_text="🟡 MEDIUM" ;;
    3) threat_text="🟢 LOW" ;;
    4) threat_text="🔵 INFO" ;;
  esac

  echo -e "\033[$(random_color)m🎯 Threat Level: $threat_text | AI Red Team Status: ACTIVE 🚨\033[0m"

  local current_dir=$(basename "$PWD")
  local context_color=$(random_color)
  echo -e "\033[${context_color}m📍 Current AO: $current_dir | Ready for engagement 💀\033[0m"
  echo
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 17: ENHANCED CLEAR FUNCTION
# ═══════════════════════════════════════════════════════════════════════════

clear() {
  command clear

  if [[ "$ENABLE_MATRIX_ON_CLEAR" == true && $((RANDOM % 4)) -eq 0 ]]; then
    matrix_rain 1
  fi

  loading_animation "🔄 Reinitializing Shadow Systems..." 1.2 "" "pulse" "false"

  command clear

  show_system_info
  time_based_greeting

  if [[ -n "$WELCOME_DISPLAYED" ]]; then
    echo -e "\033[38;2;255;255;255m────────────────────────────────────────────────────────────────────────────────\033[0m"
  fi

  if command -v git &>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
    echo -e "\033[38;2;100;255;100m📁 $(pwd) \033[38;2;255;255;100m($(git branch --show-current 2>/dev/null || echo 'detached'))\033[0m"
  else
    echo -e "\033[38;2;100;255;100m📁 $(pwd)\033[0m"
  fi
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 18: PROCESS CLEANUP
# ═══════════════════════════════════════════════════════════════════════════

cleanup_processes() {
  local pid_file="$TERMINAL_SESSION_FILE.monitor.pid"

  if [[ -f "$pid_file" ]]; then
    local pid=$(cat "$pid_file" 2>/dev/null)

    if [[ -n "$pid" && "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null; then
      kill -TERM -"$pid" 2>/dev/null
      sleep 0.2
      kill -0 "$pid" 2>/dev/null && kill -KILL -"$pid" 2>/dev/null
    fi

    rm -f "$pid_file"
  fi

  jobs -p | xargs -r kill -TERM 2>/dev/null
  sleep 0.1
  jobs -p | xargs -r kill -KILL 2>/dev/null

  tput cnorm 2>/dev/null
  stty echo 2>/dev/null
  printf "\033[0m\033[?25h"
}

trap cleanup_processes EXIT INT TERM

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 19: KEYBINDINGS
# ═══════════════════════════════════════════════════════════════════════════

bindkey -e
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^H' backward-kill-word
bindkey '^[[3;5~' kill-word
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^I' expand-or-complete

_zsh_refresh_dashboard() {
  clear
  show_system_info
  zle reset-prompt
}
zle -N _zsh_refresh_dashboard
bindkey '^X^R' _zsh_refresh_dashboard

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 20: FZF INTEGRATION
# ═══════════════════════════════════════════════════════════════════════════

if command -v fzf &> /dev/null; then
  if [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh
  elif [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
    source /usr/share/fzf/completion.zsh
  fi

  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git 2>/dev/null || find . -type f -not -path "*/\.git/*"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git 2>/dev/null || find . -type d -not -path "*/\.git/*"'
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --multi --info=inline --color=bg+:#1e1e1e,bg:#0a0a0a,spinner:#f4a261,hl:#e76f51,fg:#ffffff,header:#e9c46a,info:#264653,pointer:#f4a261,marker:#e76f51,fg+:#ffffff,prompt:#e9c46a,hl+:#e76f51"
  export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {}' --preview-window=right:60%"
  export FZF_ALT_C_OPTS="--preview 'tree -C {} 2>/dev/null || ls -la {}' --preview-window=right:60%"
fi

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 21: PLUGIN CONFIGURATIONS
# ═══════════════════════════════════════════════════════════════════════════

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"
ZSH_AUTOSUGGEST_USE_ASYNC=true

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
ZSH_HIGHLIGHT_STYLES[default]=none
ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red,bold
ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[path]=underline
ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=cyan
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=cyan
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
ZSH_HIGHLIGHT_STYLES[arg0]=fg=green

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 22: SECURITY & OPERATIONAL CONTEXT
# ═══════════════════════════════════════════════════════════════════════════

INTEGRITY_BASELINE_FILE="$XDG_CONFIG_HOME/zsh/fs_integrity_baseline.sha256"

initialize_integrity_baseline() {
  [[ "$ENABLE_FILE_INTEGRITY" != true ]] && return

  echo "🔒 Creating file integrity baseline..."
  local files_to_check=(
    "/etc/passwd" "/etc/shadow" "/etc/group" "/etc/gshadow"
    "/etc/sudoers" "/etc/ssh/sshd_config"
    "/etc/pam.d/common-auth" "/etc/pam.d/common-password"
    "/etc/login.defs" "/etc/securetty"
    "/root/.ssh/authorized_keys"
  )

  mkdir -p "$(dirname "$INTEGRITY_BASELINE_FILE")"
  echo "# Zsh File Integrity Baseline - $(date)" > "$INTEGRITY_BASELINE_FILE"

  for file in "${files_to_check[@]}"; do
    [[ -r "$file" ]] && sha256sum "$file" >> "$INTEGRITY_BASELINE_FILE"
  done

  echo "✅ Baseline created at: $INTEGRITY_BASELINE_FILE"
}

check_fs_integrity() {
  [[ "$ENABLE_FILE_INTEGRITY" != true ]] && return

  if [[ ! -f "$INTEGRITY_BASELINE_FILE" ]]; then
    echo "⚠️ Baseline not found. Run 'sec-baseline' first."
    return 1
  fi

  echo "🔍 Checking file system integrity..."
  local has_warnings=false

  while IFS= read -r line; do
    echo "🚨 WARNING: Integrity check FAILED for: $(echo $line | cut -d':' -f1)"
    has_warnings=true
  done < <(sha256sum -c --quiet "$INTEGRITY_BASELINE_FILE" 2>/dev/null | grep 'FAILED')

  if ! $has_warnings; then
    echo "✅ All checked files are intact."
  fi
}

check_network_anomalies() {
  echo "📡 Checking for network anomalies..."

  if ! command -v ss &>/dev/null; then
    echo "⚠️ 'ss' command not found."
    return 1
  fi

  echo "\nUnusual Listening Ports:"
  ss -tlpn 2>/dev/null | awk 'NR>1 {print $4}' | grep -E ':[0-9]+$' | cut -d':' -f2 | sort -un | while read port; do
    if ! grep -qwE "^\w+\s+${port}/(tcp|udp)" /etc/services 2>/dev/null; then
      echo "  - Unusual port: $port"
    fi
  done

  echo "\nTop 10 Established Connections:"
  ss -tn 'state established' 2>/dev/null | awk 'NR>1 {print $5}' | cut -d':' -f1 | \
    grep -vE '^(127.0.0.1|::1)$' | sort | uniq -c | sort -nr | head -n 10
}

alias sec-baseline='initialize_integrity_baseline'
alias sec-check-fs='check_fs_integrity'
alias sec-check-net='check_network_anomalies'

export ZSH_OP_TARGET_IP=""
export ZSH_OP_TARGET_DOMAIN=""
export ZSH_OP_TARGET_DESC=""

set-target() {
  [[ "$ENABLE_OP_CONTEXT" != true ]] && return

  if [[ -z "$1" ]]; then
    echo "Usage: set-target <IP_ADDRESS> [DOMAIN] [DESCRIPTION]"
    echo "Example: set-target 10.10.11.15 kioptrix.com 'Vulnhub VM'"
    return 1
  fi

  export ZSH_OP_TARGET_IP="$1"
  export ZSH_OP_TARGET_DOMAIN="$2"
  export ZSH_OP_TARGET_DESC="$3"

  echo "🎯 Target set: IP=$ZSH_OP_TARGET_IP, Domain=$ZSH_OP_TARGET_DOMAIN"
}

clear-target() {
  [[ "$ENABLE_OP_CONTEXT" != true ]] && return

  export ZSH_OP_TARGET_IP=""
  export ZSH_OP_TARGET_DOMAIN=""
  export ZSH_OP_TARGET_DESC=""
  echo "🎯 Target cleared."
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 23: AI ENGINE
# ═══════════════════════════════════════════════════════════════════════════

ai() {
  [[ "$ENABLE_AI_ENGINE" != true || "$ENABLE_AI_NLC" != true ]] && return

  if [[ -z "$1" ]]; then
    echo "Usage: ai <your query in plain English>"
    echo "Example: ai scan all ports for the target"
    return 1
  fi

  local query="$@"
  local target_ip="${ZSH_OP_TARGET_IP:-127.0.0.1}"
  local target_domain="${ZSH_OP_TARGET_DOMAIN:-example.com}"
  local suggested_command

  case "$query" in
    *"scan all ports"*|*"full port scan"*)
      suggested_command="nmap -p- -T4 -v $target_ip"
      ;;
    *"scan for web servers"*|*"find http ports"*)
      suggested_command="nmap -p 80,443,8000,8080 --open -sV $target_ip"
      ;;
    *"find web directories"*|*"gobuster"*)
      suggested_command="gobuster dir -u http://$target_ip -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
      ;;
    *"check for web vulnerabilities"*|*"nikto"*)
      suggested_command="nikto -h http://$target_ip"
      ;;
    *"find subdomains"*)
      suggested_command="gobuster dns -d $target_domain -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt"
      ;;
    *"public ip"*)
      suggested_command="curl -s https://ipinfo.io/ip"
      ;;
    *"docker containers"*)
      suggested_command="docker ps"
      ;;
    *"network config"*)
      suggested_command="ip addr"
      ;;
    *)
      suggested_command="# AI: I'm not sure how to translate that yet."
      ;;
  esac

  echo -e "\n\033[38;2;0;255;255m🧠 AI-Suggested Command:\033[0m"
  echo -e "   \033[1;33m$suggested_command\033[0m"

  if [[ ! "$suggested_command" =~ "# AI:" ]]; then
    echo -n -e "\n\033[38;2;255;255;0m[E]xecute / [B]uffer (edit) / [C]ancel?\033[0m "
    read -r choice

    case "${choice:l}" in  # :l converts to lowercase
      e|execute)
  # === SECURITY HARDENING v2.0 ===

  # 1. Character whitelist validation
  if [[ ! "$suggested_command" =~ ^[a-zA-Z0-9_/.\ :,@-]+$ ]]; then
    _op_notify "failure" "🚨 Invalid characters detected in command"
    return 1
  fi

  # 2. Dangerous pattern blacklist
  local -a dangerous_patterns=(
    'rm -rf /'
    'rm -rf ~'
    'rm -rf *'
    'dd if='
    ':(){:|:&};:'
    'mkfs'
    'wipefs'
    '>/etc/'
    '>>/etc/'
    'chmod 777'
    'chmod -R 777'
    'chown -R'
    ';'
    '&&'
    '||'
    '`'
    '$('
    '|sudo'
  )

  for pattern in "${dangerous_patterns[@]}"; do
    if [[ "$suggested_command" == *"$pattern"* ]]; then
      _op_notify "failure" "🚨 Blocked dangerous pattern: $pattern"
      return 1
    fi
  done

  # 3. User confirmation with full command display
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "⚠️  COMMAND EXECUTION CONFIRMATION"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Command: $suggested_command"
  echo "Working Directory: $PWD"
  echo "User: $(whoami)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -n "Execute this command? Type 'YES' to confirm: "
  read -r confirm

  if [[ "$confirm" != "YES" ]]; then
    _op_notify "warning" "Command execution cancelled"
    return 0
  fi

  # 4. Audit logging
  local audit_log="$XDG_STATE_HOME/zsh/ai_command_audit.log"
  mkdir -p "$(dirname "$audit_log")"
  touch "$audit_log"
  chmod 600 "$audit_log"

  {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Timestamp: $(date -Iseconds)"
    echo "User: $(whoami)"
    echo "PWD: $PWD"
    echo "Query: $query"
    echo "Command: $suggested_command"
    echo "PID: $$"
  } >> "$audit_log"

  # 5. Execute in restricted subshell
  (
    # Resource limits
    ulimit -t 600      # 10 min CPU time
    ulimit -v 2097152  # 2GB virtual memory
    ulimit -f 10485760 # 10GB max file size
    ulimit -c 0        # No core dumps
    ulimit -n 1024     # Max 1024 open files

    # Execute with explicit word splitting
    set -f  # Disable globbing
    eval "$suggested_command"
  )

  local exit_code=$?

  # 6. Log execution result
  {
    echo "Exit Code: $exit_code"
    echo "Completed: $(date -Iseconds)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
  } >> "$audit_log"

  if [[ $exit_code -eq 0 ]]; then
    _op_notify "success" "Command completed successfully"
  else
    _op_notify "failure" "Command failed with exit code: $exit_code"
  fi

  return $exit_code
        ;;
      b|buffer)
        # Put in command buffer for editing (safest option)
        print -z "$suggested_command"
        echo "✓ Command placed in buffer. Press ↑ to edit and execute."
        ;;
      *)
        echo "✗ Command cancelled."
        return 0
        ;;
    esac
  fi
}

_ZSH_AI_HISTORY_FILE="$XDG_DATA_HOME/zsh/zsh_ai_history"

_zsh_log_command_to_history() {
  [[ "$ENABLE_AI_ENGINE" != true ]] && return
  [[ -z "$1" || "$1" == "suggest" ]] && return

  mkdir -p "$(dirname "$_ZSH_AI_HISTORY_FILE")"
  echo "$PWD|$1" >> "$_ZSH_AI_HISTORY_FILE"
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _zsh_log_command_to_history

suggest() {
  [[ "$ENABLE_AI_ENGINE" != true || "$ENABLE_AI_PREDICTIONS" != true ]] && return

  if [[ ! -f "$_ZSH_AI_HISTORY_FILE" ]]; then
    echo "No command history found yet."
    return
  fi

  echo -e "\033[38;2;0;255;255m🧠 AI Command Suggestions:\033[0m"

  local target_ip="${ZSH_OP_TARGET_IP:-127.0.0.1}"
  local target_domain="${ZSH_OP_TARGET_DOMAIN:-example.com}"
  local last_command=$(fc -ln -1 2>/dev/null)
  echo -e "\033[38;2;255;255;0m✨ Workflow Suggestions (last: '$last_command'):\033[0m"

  case "$last_command" in
    *nmap*)
      echo "  - gobuster dir -u http://${target_ip} -w <wordlist>"
      echo "  - nikto -h http://${target_ip}"
      echo "  - enum4linux -a ${target_ip}"
      ;;
    *gobuster*|*nikto*)
      echo "  - nmap -sC -sV -p<port> ${target_ip}"
      echo "  - searchsploit <service_name>"
      ;;
    *searchsploit*)
      echo "  - searchsploit -m <exploit_path>"
      echo "  - python -m http.server 80"
      ;;
    *git*)
      echo "  - git log --oneline --graph"
      echo "  - git status -sb"
      ;;
    *docker*)
      echo "  - docker exec -it <container> /bin/bash"
      echo "  - docker logs -f <container>"
      ;;
  esac

  echo -e "\n\033[38;2;255;255;0m📚 Most Frequent in This Directory:\033[0m"
  grep "^$PWD|" "$_ZSH_AI_HISTORY_FILE" 2>/dev/null | cut -d'|' -f2 | \
    sort | uniq -c | sort -nr | head -n 5 | awk '{ $1="  - "; print }'
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 24: CLOUD & CONTAINER OPERATIONS (RESTORED)
# ═══════════════════════════════════════════════════════════════════════════

docker_status() {
  if [[ "$ENABLE_CLOUD_MONITORING" != true ]]; then
    echo "⚠️ Cloud monitoring disabled. Enable ENABLE_CLOUD_MONITORING in config."
    return 1
  fi

  if command -v docker &>/dev/null; then
    echo -e "\033[38;2;0;255;255m🐳 Docker Container Status:\033[0m"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
  else
    echo "⚠️ Docker not installed"
  fi
}

kube_status() {
  if [[ "$ENABLE_CLOUD_MONITORING" != true ]]; then
    echo "⚠️ Cloud monitoring disabled. Enable ENABLE_CLOUD_MONITORING in config."
    return 1
  fi

  if command -v kubectl &>/dev/null; then
    echo -e "\033[38;2;0;255;255m☸️ Kubernetes Cluster Status:\033[0m"
    kubectl get nodes -o wide
    echo -e "\n\033[38;2;255;255;0mPods by Namespace:\033[0m"
    kubectl get pods --all-namespaces -o wide
  else
    echo "⚠️ kubectl not installed"
  fi
}

aws_status() {
  if [[ "$ENABLE_CLOUD_MONITORING" != true ]]; then
    echo "⚠️ Cloud monitoring disabled. Enable ENABLE_CLOUD_MONITORING in config."
    return 1
  fi

  if command -v aws &>/dev/null; then
    echo -e "\033[38;2;0;255;255m☁️ AWS EC2 Instances:\033[0m"
    aws ec2 describe-instances \
      --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
      --output table
  else
    echo "⚠️ AWS CLI not installed"
  fi
}

az_status() {
  if [[ "$ENABLE_CLOUD_MONITORING" != true ]]; then
    echo "⚠️ Cloud monitoring disabled. Enable ENABLE_CLOUD_MONITORING in config."
    return 1
  fi

  if command -v az &>/dev/null; then
    echo -e "\033[38;2;0;255;255m☁️ Azure Virtual Machines:\033[0m"
    az vm list --show-details --output table
  else
    echo "⚠️ Azure CLI not installed"
  fi
}

gcp_status() {
  if [[ "$ENABLE_CLOUD_MONITORING" != true ]]; then
    echo "⚠️ Cloud monitoring disabled. Enable ENABLE_CLOUD_MONITORING in config."
    return 1
  fi

  if command -v gcloud &>/dev/null; then
    echo -e "\033[38;2;0;255;255m☁️ GCP Compute Instances:\033[0m"
    gcloud compute instances list
  else
    echo "⚠️ gcloud not installed"
  fi
}

alias docker-stats='docker_status'
alias k8s='kube_status'
alias cloud-aws='aws_status'
alias cloud-azure='az_status'
alias cloud-gcp='gcp_status'

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 25: REDUNDANT - MERGED INTO SECTION 34
# (Legacy Threat Intelligence removed in favor of Advanced Module)


# ═══════════════════════════════════════════════════════════════════════════
# SECTION 26: REDUNDANT - MERGED INTO SECTION 35
# (Legacy Dashboard removed in favor of Advanced Module)


# ═══════════════════════════════════════════════════════════════════════════
# SECTION 27: GIT INTEGRATION
# ═══════════════════════════════════════════════════════════════════════════

alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add -p'
alias gb='git branch'
alias gbr='git branch -r'
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gcam='git commit -a -m'
alias gcb='git checkout -b'
alias gco='git checkout'
alias gd='git diff'
alias gdc='git diff --cached'
alias gf='git fetch'
alias gl='git pull'
alias gp='git push'
alias glog='git log --oneline --decorate --graph'
alias gs='git status -sb'

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 27B: CUSTOM UTILITIES (IMPORTED)
# ═══════════════════════════════════════════════════════════════════════════

_spinner() {
  local chars=("/" "-" "\\" "|")
  local i=0
  while (( i < 12 )); do
    printf "\r%s %s" "$1" "${chars[$(( (i % 4) + 1 ))]}"
    sleep 0.1
    ((i++))
  done
  printf "\r%b\n" "$2"
}

typeset -g ZSH_DEFAULT_VENV="${ZSH_DEFAULT_VENV:-$HOME/myenv2}"

venvon() {
  local venv_path="${1:-$ZSH_DEFAULT_VENV}"
  local activate_script="$venv_path/bin/activate"
  if [[ ! -f "$activate_script" ]]; then
    echo "❌ Python environment not found: $activate_script"
    return 1
  fi
  _spinner "Starting Python Environment" "\e[1;34mYour Python Environment is Starting..................\e[0m"
  source "$activate_script"
}

venvoff() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    _spinner "Terminating Python Environment" "\e[1;34mYour Python Environment is Terminated..................\e[0m"
    deactivate
  else
    echo -e "\e[1;31mNo Python environment is currently active.\e[0m"
  fi
}

disk() {
  local mode="full"

  case "$1" in
    -t|--top)   mode="top" ;;
    -q|--quick) mode="quick" ;;
  esac

  if ! command_exists df || ! command_exists lsblk; then
    echo "⚠️ 'df' and 'lsblk' are required for disk reporting."
    command df -h 2>/dev/null
    return 1
  fi

  # Quick mode
  if [[ "$mode" == "quick" ]]; then
    df -h
    return
  fi

  printf "\n\033[1;36m📦 Mounted Filesystems:\033[0m\n"
  df -h --output=source,size,used,avail,pcent,target | awk '
    NR==1 {printf "%-15s %-8s %-8s %-8s %-6s %s\n",$1,$2,$3,$4,$5,$6; next}
    $6=="/" || $6 ~ /^\/media/ {
      color=""
      if ($6=="/") color="\033[0;31m"
      else if ($1 ~ /nvme/) color="\033[0;34m"
      else if ($1 ~ /sd[a-z]/) color="\033[0;35m"
      sub("/media/[^/]+/","",$6)
      printf color "%-15s %-8s %-8s %-8s %-6s %s\033[0m\n",$1,$2,$3,$4,$5,$6
    }'

  printf "\n\033[1;36m💽 Physical Disks and Partitions:\033[0m\n"

  local -a disks_order=("nvme1n1" "nvme0n1" "sda")
  local -a detected_disks=()
  local disk

  for disk in "${disks_order[@]}"; do
    [[ -b "/dev/$disk" ]] && detected_disks+=("$disk")
  done

  if [[ ${#detected_disks[@]} -eq 0 ]]; then
    mapfile -t detected_disks < <(lsblk -dn -o NAME,TYPE | awk '$2=="disk"{print $1}')
  fi

  for disk in "${detected_disks[@]}"; do
    local size rota model color=""
    size=$(lsblk -dn -o SIZE -r "/dev/$disk")
    rota=$(lsblk -dn -o ROTA -r "/dev/$disk")
    model=$(lsblk -dn -o MODEL -r "/dev/$disk" | sed 's/\\x20/ /g')

    [[ "$model" == *Micron_3400* ]] && color="\033[0;31m"
    [[ "$model" == *Micron_2450* ]] && color="\033[0;34m"
    [[ "$model" == *TOSHIBA*     ]] && color="\033[0;35m"

    printf "${color}%s\033[0m\t%s\t%s\t%s\n" "$disk" "$size" "$rota" "$model"

    lsblk -ln -o NAME,SIZE,ROTA,MOUNTPOINT "/dev/$disk" |
    while read -r part psize prota mnt; do
      [[ -z "$mnt" || "$mnt" == "[SWAP]" ]] && continue

      local pcolor="$color"
      [[ "$mnt" == "/" ]] && pcolor="\033[0;31m"

      printf "  ${pcolor}%-10s %-8s %-6s %-25s\033[0m\n" \
        "$part" "$psize" "$prota" "$mnt"
    done
  done

  if [[ "$mode" == "top" ]]; then
    printf "\n\033[1;36m🔥 Top Disk Consumers (current directory):\033[0m\n"
    du -sh ./* 2>/dev/null | sort -hr | head -10
  fi
}

ram() {
  printf "\n\033[1;36m🧠 Memory Usage:\033[0m\n"
  free -h | awk '
    NR==1 {print}
    NR==2 {printf "\033[1;32mTotal:\033[0m %s  \033[1;33mUsed:\033[0m %s  \033[1;34mFree:\033[0m %s\n",$2,$3,$4}'

  if ! command_exists dmidecode; then
    echo "\n⚠️ dmidecode not available (run as root for DIMM details)"
    return
  fi

  printf "\n\033[1;36m📦 RAM Modules (DIMMs):\033[0m\n"

  sudo dmidecode -t memory |
  awk '
    /Memory Device/ {inblock=1; size=""; type=""; speed=""; locator=""; manu=""; part=""; next}
    inblock && /Size:/ && $2!="No" {size=$0}
    inblock && /Type:/ {type=$0}
    inblock && /Speed:/ && $2!="Configured" {speed=$0}
    inblock && /Locator:/ {locator=$0}
    inblock && /Manufacturer:/ {manu=$0}
    inblock && /Part Number:/ {part=$0}
    inblock && /^$/ {
      if (size!="") {
        print "\033[1;32m" size "\033[0m"
        print "\033[1;34m" type "\033[0m"
        print "\033[1;35m" speed "\033[0m"
        print "\033[1;36m" locator "\033[0m"
        print "\033[1;33m" manu "\033[0m"
        print "\033[1;31m" part "\033[0m\n"
      }
      inblock=0
    }'
}

turnoff() {
  if [[ -z "$1" ]]; then
    echo "Usage: turnoff <seconds|now>"
    return 1
  fi

  if [[ "$1" == "now" ]]; then
    echo "Your PC will shut down *now*..."
    sudo shutdown -h now
  else
    echo "Your PC will shut down in $1 seconds..."
    sleep "$1"
    sudo shutdown -h now
  fi
}

inet() {
  if ! command_exists ip; then
    echo "⚠️ 'ip' command not found."
    return 1
  fi

  echo "----IP Networks Available----"
  printf "Interface         IP_Address        Broadcast           Subnet_Mask        CIDR   Status\n"
  echo "-----------------------------------------------------------------------------------------"

  ip -4 -o addr show | awk '
    BEGIN {
      while (( "ls /sys/class/net" | getline iface ) > 0) {
        cmd = "cat /sys/class/net/" iface "/operstate"
        cmd | getline st
        close(cmd)
        status_table[iface] = (st ~ /up/ ? "UP" : "DOWN")
      }
      red = "\033[31m"; green = "\033[32m"; blue = "\033[34m"; reset = "\033[0m"
    }

    function cidr_to_mask(c,    mask, i, val) {
      mask = ""
      for (i = 0; i < 4; i++) {
        if (c >= 8) {
          mask = mask "255"
          c -= 8
        } else {
          val = 256 - 2^(8 - c)
          mask = mask val
          c = 0
        }
        if (i < 3) mask = mask "."
      }
      return mask
    }

    {
      split($4, a, "/")
      ipaddr = a[1]
      cidr = a[2]
      mask = cidr_to_mask(cidr)
      brd = "N/A"
      for (i = 1; i <= NF; i++) if ($i == "brd") brd = $(i + 1)
      iface = $2
      status = status_table[iface]

      ip_color = red
      brd_color = blue
      mask_color = green

      status_color = (status == "UP" ? red : blue)

      printf "%s%-17s%s %s%-17s%s %s%-20s%s %s%-18s%s %s%-4s%s %s%-6s%s\n",
        "", iface, "",
        ip_color, ipaddr, reset,
        brd_color, brd, reset,
        mask_color, mask, reset,
        red, cidr, reset,
        status_color, status, reset
    }'

  echo

  if [[ "$ENABLE_PUBLIC_IP_LOOKUP" != true ]]; then
    echo "Public IP lookup disabled. Set ENABLE_PUBLIC_IP_LOOKUP=true to enable."
    return 0
  fi

  if ! command_exists curl; then
    echo "⚠️ 'curl' is required for public IP lookups."
    return 1
  fi

  echo "----Public_IP----"
  local pub_ip4=$(safe_system_call "curl -4 -s ifconfig.me" 6 "N/A")
  local pub_ip6=$(safe_system_call "curl -6 -s ifconfig.me" 6 "N/A")
  [[ -n "$pub_ip4" ]] && echo "IPv4: $pub_ip4"
  [[ -n "$pub_ip6" ]] && echo "IPv6: $pub_ip6"

  echo
  echo

  echo "----Tor_Public_IP (via SOCKS)----"
  if ! command_exists torsocks; then
    echo "Tor: torsocks not installed."
    return 0
  fi

  local -a tor_services=(
    "https://ident.me"
    "https://ipinfo.io/ip"
    "https://api.ipify.org"
  )

  local tor_ip=""
  local svc
  for svc in "${tor_services[@]}"; do
    tor_ip=$(safe_system_call "torsocks curl -s --connect-timeout 8 $svc" 10 "")
    [[ -n "$tor_ip" ]] && break
  done

  if [[ -n "$tor_ip" ]]; then
    echo "Tor IPv4: $tor_ip"
  else
    echo "Tor: Tor has not started yet................"
  fi
}

toron() {
  if ! command_exists systemctl; then
    echo "⚠️ 'systemctl' not available."
    return 1
  fi

  sudo systemctl start tor && sudo systemctl enable tor
  sudo systemctl status tor --no-pager

  if command_exists torsocks && command_exists curl; then
    echo
    echo -n "Tor check: "
    torsocks curl -s https://check.torproject.org | tr -d "\n" | sed -n "s:.*<title>\(.*\)</title>.*:\1:p"
    echo
  fi
}

toroff() {
  if ! command_exists systemctl; then
    echo "⚠️ 'systemctl' not available."
    return 1
  fi

  sudo systemctl stop tor && sudo systemctl disable tor
  echo "Tor stopped and disabled."
}

camtog() {
  if ! command_exists lsmod || ! command_exists modprobe; then
    echo "⚠️ 'lsmod' and 'modprobe' are required."
    return 1
  fi

  if lsmod | grep -q '^uvcvideo'; then
    echo "🔴 Disabling webcam..."
    sudo modprobe -r uvcvideo
  else
    echo "🟢 Enabling webcam..."
    sudo modprobe uvcvideo
  fi
}

typeset -g ZSH_XCNG_PATH="${ZSH_XCNG_PATH:-$HOME/script/X_Change/x_change.sh}"
xcng() {
  if [[ -x "$ZSH_XCNG_PATH" ]]; then
    "$ZSH_XCNG_PATH"
  else
    echo "⚠️ X_Change script not found: $ZSH_XCNG_PATH"
    return 1
  fi
}

typeset -g ZSH_NCPD_PATH="${ZSH_NCPD_PATH:-$HOME/script/NCPD/NCPD.sh}"
ncpd() {
  if [[ -x "$ZSH_NCPD_PATH" ]]; then
    bash "$ZSH_NCPD_PATH"
  else
    echo "⚠️ NCPD script not found: $ZSH_NCPD_PATH"
    return 1
  fi
}

startkdeconnect() {
  if ! command_exists kdeconnectd || ! command_exists kdeconnect-app; then
    echo "⚠️ kdeconnectd/kdeconnect-app not installed."
    return 1
  fi

  kdeconnectd &
  sleep 1
  kdeconnect-app &
}

usbformat() {
  if ! command_exists lsblk || ! command_exists wipefs; then
    echo "⚠️ 'lsblk' and 'wipefs' are required."
    return 1
  fi

  echo "Available removable USB devices:"
  echo "--------------------------------"
  lsblk -o NAME,SIZE,MODEL,TRAN | awk 'NR==1 || $4 ~ /usb/' || {
    echo "No USB devices found."
    return 1
  }

  echo "Enter device name (example: sdb)"
  echo "Or press Q to quit"
  print -n "> "
  read DEV

  [[ "$DEV" =~ ^[Qq]$ ]] && { echo "Exited."; return 0; }

  # === ENHANCED VALIDATION ===

  # 1. Character validation (alphanumeric only)
  if [[ -z "$DEV" ]] || [[ ! "$DEV" =~ ^[a-zA-Z0-9]+$ ]]; then
    echo "❌ Invalid device name (alphanumeric only)"
    return 1
  fi

  # 2. Block system disks (sda, nvme0n1, mmcblk0)
  local -a forbidden_devices=(
    "sda" "sda1" "sda2" "sda3" "sda4" "sda5"
    "nvme0n1" "nvme0n1p1" "nvme0n1p2" "nvme0n1p3"
    "mmcblk0" "mmcblk0p1" "mmcblk0p2"
  )

  for forbidden in "${forbidden_devices[@]}"; do
    if [[ "$DEV" == "$forbidden" ]]; then
      echo "🚨 BLOCKED: $DEV is a system disk"
      return 1
    fi
  done

  # 3. Verify device exists
  if [[ ! -b "/dev/$DEV" ]]; then
    echo "❌ Block device not found: /dev/$DEV"
    return 1
  fi

  # 4. Check if device is removable
  local removable=$(cat "/sys/block/${DEV}/removable" 2>/dev/null || cat "/sys/block/${DEV%[0-9]}/removable" 2>/dev/null)

  if [[ "$removable" != "1" ]]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  WARNING: /dev/$DEV is NOT marked as removable"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "This may be a system disk!"
    echo ""
    echo "Type 'I UNDERSTAND THE RISKS' to continue"
    echo "Or Q to quit"
    print -n "> "
    read FORCE

    [[ "$FORCE" =~ ^[Qq]$ ]] && { echo "Exited."; return 0; }

    if [[ "$FORCE" != "I UNDERSTAND THE RISKS" ]]; then
      echo "❌ Aborted for safety"
      return 1
    fi
  fi

  # 5. Check if device is mounted
  if mount | grep -q "^/dev/$DEV"; then
    echo "⚠️  Device is currently mounted:"
    mount | grep "^/dev/$DEV"
    echo ""
    echo "Attempting to unmount..."
    sudo umount "/dev/${DEV}"* 2>/dev/null
    sleep 1

    if mount | grep -q "^/dev/$DEV"; then
      echo "❌ Failed to unmount device. Close any programs using it."
      return 1
    fi
  fi

  echo
  echo "Choose filesystem:"
  echo "1) FAT32  (Best compatibility)"
  echo "2) exFAT  (Large files, cross-platform)"
  echo "3) NTFS   (Windows-focused)"
  echo "4) ext4   (Linux only)"
  echo "Q) Quit"
  print -n "> "
  read FS

  [[ "$FS" =~ ^[Qq]$ ]] && { echo "Exited."; return 0; }

  local mkfs_cmd=()
  local fstype=""
  case "$FS" in
    1) fstype="vfat"; mkfs_cmd=(mkfs.vfat -F32) ;;
    2) fstype="exfat"; mkfs_cmd=(mkfs.exfat) ;;
    3) fstype="ntfs"; mkfs_cmd=(mkfs.ntfs -f) ;;
    4) fstype="ext4"; mkfs_cmd=(mkfs.ext4 -F) ;;
    *) echo "Invalid choice"; return 1 ;;
  esac

  if ! command_exists "${mkfs_cmd[1]}"; then
    echo "⚠️ Filesystem tool not found: ${mkfs_cmd[1]}"
    return 1
  fi

  echo
  echo "⚠  WARNING ⚠"
  echo "This will ERASE ALL DATA on /dev/$DEV"
  echo "Type YES to continue or Q to quit"
  print -n "> "
  read CONFIRM

  [[ "$CONFIRM" =~ ^[Qq]$ ]] && { echo "Exited."; return 0; }
  [[ "$CONFIRM" != "YES" ]] && { echo "Aborted."; return 1; }

  sudo umount "/dev/${DEV}"* 2>/dev/null
  sudo wipefs -a "/dev/$DEV"
  sudo "${mkfs_cmd[@]}" "/dev/$DEV"

  echo
  echo "USB /dev/$DEV formatted as $fstype successfully."
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 27C: SMART PRODUCTIVITY TOOLKIT
# ═══════════════════════════════════════════════════════════════════════════

typeset -g ZSH_PROJECTS_DIR="${ZSH_PROJECTS_DIR:-$HOME/Projects}"
typeset -g ZSH_DEFAULT_SERVER_PORT="${ZSH_DEFAULT_SERVER_PORT:-8000}"

mkcd() {
  if [[ -z "$1" ]]; then
    echo "Usage: mkcd <directory>"
    return 1
  fi

  mkdir -p -- "$1" || return 1
  cd -- "$1" || return 1
  echo "📁 Entered: $PWD"
}

up() {
  local count="${1:-1}"
  if ! [[ "$count" =~ ^[0-9]+$ ]]; then
    echo "Usage: up <levels>"
    return 1
  fi

  local path=""
  for ((i=0; i<count; i++)); do
    path+="../"
  done

  cd "$path" || return 1
}

croot() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -z "$root" ]]; then
    echo "⚠️ Not inside a git repository."
    return 1
  fi

  cd "$root" || return 1
  echo "🌿 Moved to git root: $root"
}

cproj() {
  local base="${1:-$ZSH_PROJECTS_DIR}"
  if [[ ! -d "$base" ]]; then
    echo "⚠️ Projects directory not found: $base"
    return 1
  fi

  local -a projects
  projects=("${base}"/*(/N))
  if (( ${#projects[@]} == 0 )); then
    echo "⚠️ No project directories found in: $base"
    return 1
  fi

  local selection=""
  if command_exists fzf; then
    selection=$(printf '%s\n' "${projects[@]}" | fzf --height 45% --layout=reverse --prompt="Project> " \
      --preview 'ls -la {} | head -200')
  else
    echo "⚠️ fzf not installed. Select a project:"
    select selection in "${projects[@]}"; do
      [[ -n "$selection" ]] && break
    done
  fi

  [[ -z "$selection" ]] && return 1
  cd "$selection" || return 1
  echo "🧩 Project loaded: $selection"
}

pathadd() {
  local dir="$1"
  if [[ -z "$dir" ]]; then
    echo "Usage: pathadd <dir>"
    return 1
  fi

  dir="${dir:A}"
  if [[ ! -d "$dir" ]]; then
    echo "⚠️ Directory not found: $dir"
    return 1
  fi

  path=("$dir" $path)
  typeset -U path
  export PATH
  echo "✅ Added to PATH: $dir"
}

pathrm() {
  local dir="$1"
  if [[ -z "$dir" ]]; then
    echo "Usage: pathrm <dir>"
    return 1
  fi

  dir="${dir:A}"
  path=(${path:#$dir})
  typeset -U path
  export PATH
  echo "🧹 Removed from PATH: $dir"
}

pathshow() {
  print -l $path
}

extract() {
  local archive="$1"

  if [[ -z "$archive" ]]; then
    echo "Usage: extract <archive>"
    return 1
  fi

  if [[ ! -f "$archive" ]]; then
    echo "❌ File not found: $archive"
    return 1
  fi

  # Create secure extraction directory
  local extract_dir="./extracted_$(date +%s)_$$"
  mkdir -p "$extract_dir" || {
    echo "❌ Failed to create extraction directory"
    return 1
  }

  # Make it absolute path
  extract_dir=$(cd "$extract_dir" && pwd)

  echo "🔍 Scanning archive for security issues..."

  case "$archive" in
    *.tar.bz2|*.tbz2|*.tar.gz|*.tgz|*.tar.xz|*.txz|*.tar.zst|*.tzst|*.tar)
      # Security check: scan for path traversal
      if tar -tf "$archive" 2>/dev/null | grep -q '\.\./'; then
        echo "🚨 SECURITY: Archive contains path traversal (../) - BLOCKED"
        rm -rf "$extract_dir"
        return 1
      fi

      # Security check: scan for absolute paths
      if tar -tf "$archive" 2>/dev/null | grep -q '^/'; then
        echo "🚨 SECURITY: Archive contains absolute paths - BLOCKED"
        rm -rf "$extract_dir"
        return 1
      fi

      # Security check: scan for suspicious filenames
      if tar -tf "$archive" 2>/dev/null | grep -qE '(\.\.|\$|\`|\||;|&)'; then
        echo "🚨 SECURITY: Archive contains suspicious filenames - BLOCKED"
        rm -rf "$extract_dir"
        return 1
      fi

      echo "✅ Security checks passed"

      # Extract based on compression
      case "$archive" in
        *.tar.bz2|*.tbz2)
          tar -xjf "$archive" -C "$extract_dir" --no-same-owner --no-same-permissions
          ;;
        *.tar.gz|*.tgz)
          tar -xzf "$archive" -C "$extract_dir" --no-same-owner --no-same-permissions
          ;;
        *.tar.xz|*.txz)
          tar -xJf "$archive" -C "$extract_dir" --no-same-owner --no-same-permissions
          ;;
        *.tar.zst|*.tzst)
          tar --zstd -xf "$archive" -C "$extract_dir" --no-same-owner --no-same-permissions 2>/dev/null || \
          tar -I zstd -xf "$archive" -C "$extract_dir" --no-same-owner --no-same-permissions
          ;;
        *.tar)
          tar -xf "$archive" -C "$extract_dir" --no-same-owner --no-same-permissions
          ;;
      esac
      ;;

    *.zip)
      if ! command_exists unzip; then
        echo "⚠️ 'unzip' required"
        rm -rf "$extract_dir"
        return 1
      fi

      # Security check for zip files
      if unzip -l "$archive" 2>/dev/null | grep -q '\.\./'; then
        echo "🚨 SECURITY: Archive contains path traversal - BLOCKED"
        rm -rf "$extract_dir"
        return 1
      fi

      unzip -q "$archive" -d "$extract_dir"
      ;;

    *.rar)
      if ! command_exists unrar; then
        echo "⚠️ 'unrar' required"
        rm -rf "$extract_dir"
        return 1
      fi
      unrar x "$archive" "$extract_dir/"
      ;;

    *.7z)
      if ! command_exists 7z; then
        echo "⚠️ '7z' required"
        rm -rf "$extract_dir"
        return 1
      fi
      7z x "$archive" -o"$extract_dir"
      ;;

    *.gz)
      if ! command_exists gunzip; then
        echo "⚠️ 'gunzip' required"
        rm -rf "$extract_dir"
        return 1
      fi
      cp "$archive" "$extract_dir/"
      gunzip "$extract_dir/$(basename "$archive")"
      ;;

    *.bz2)
      if ! command_exists bunzip2; then
        echo "⚠️ 'bunzip2' required"
        rm -rf "$extract_dir"
        return 1
      fi
      cp "$archive" "$extract_dir/"
      bunzip2 "$extract_dir/$(basename "$archive")"
      ;;

    *.xz)
      if ! command_exists unxz; then
        echo "⚠️ 'unxz' required"
        rm -rf "$extract_dir"
        return 1
      fi
      cp "$archive" "$extract_dir/"
      unxz "$extract_dir/$(basename "$archive")"
      ;;

    *)
      echo "❌ Unknown archive format: $archive"
      rm -rf "$extract_dir"
      return 1
      ;;
  esac

  local exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    echo "✅ Extracted to: $extract_dir"
    echo "📁 Contents:"
    ls -lah "$extract_dir"
  else
    echo "❌ Extraction failed"
    rm -rf "$extract_dir"
  fi

  return $exit_code
}

please() {
  local last_cmd
  last_cmd=$(fc -ln -1 2>/dev/null | sed 's/^[[:space:]]*//')

  if [[ -z "$last_cmd" ]]; then
    echo "⚠️ No previous command found"
    return 1
  fi

  # Dangerous pattern blacklist
  local -a dangerous=(
    'rm -rf /'
    'rm -rf ~'
    'rm -rf *'
    'rm -rf .'
    'dd if='
    'mkfs'
    'wipefs'
    'fdisk'
    '>/etc/'
    '>>/etc/'
    'chmod -R 777'
    'chown -R root'
    ':(){:|:&};:'
  )

  # Check blacklist
  for pattern in "${dangerous[@]}"; do
    if [[ "$last_cmd" == *"$pattern"* ]]; then
      echo "🚨 BLOCKED: Command contains dangerous pattern: $pattern"
      echo "Command: $last_cmd"
      return 1
    fi
  done

  # Display and confirm
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔐 SUDO EXECUTION REQUEST"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Command: $last_cmd"
  echo "User: $(whoami) → root"
  echo "PWD: $PWD"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -n "Type 'YES' to execute with sudo: "
  read -r confirm

  if [[ "$confirm" != "YES" ]]; then
    echo "❌ Cancelled"
    return 0
  fi

  # Audit log
  local audit_log="$XDG_STATE_HOME/zsh/sudo_audit.log"
  mkdir -p "$(dirname "$audit_log")"
  chmod 600 "$audit_log"

  {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Timestamp: $(date -Iseconds)"
    echo "User: $(whoami)"
    echo "PWD: $PWD"
    echo "Command: $last_cmd"
  } >> "$audit_log"

  # Execute with proper word splitting
  sudo sh -c "$last_cmd"
  local exit_code=$?

  {
    echo "Exit Code: $exit_code"
    echo "Completed: $(date -Iseconds)"
    echo ""
  } >> "$audit_log"

  return $exit_code
}

genpass() {
  local length="${1:-24}"
  if ! [[ "$length" =~ ^[0-9]+$ ]]; then
    echo "Usage: genpass <length>"
    return 1
  fi

  if command_exists openssl; then
    openssl rand -base64 64 | tr -d '\n' | head -c "$length"
  elif command_exists python3; then
    python3 - <<PY
import secrets
import string
import sys

length = int("$length")
alphabet = string.ascii_letters + string.digits + "!@#$%^&*()_+-={}[]"
print(''.join(secrets.choice(alphabet) for _ in range(length)))
PY
  else
    tr -dc 'A-Za-z0-9!@#$%^&*()_+-={}[]' < /dev/urandom | head -c "$length"
  fi
  echo
}

serve() {
  local port="${1:-$ZSH_DEFAULT_SERVER_PORT}"
  if ! [[ "$port" =~ ^[0-9]+$ ]]; then
    echo "Usage: serve [port]"
    return 1
  fi

  echo "🌐 Serving $PWD at http://localhost:$port"
  if command_exists python3; then
    python3 -m http.server "$port"
  elif command_exists python; then
    python -m SimpleHTTPServer "$port"
  elif command_exists php; then
    php -S "0.0.0.0:$port"
  else
    echo "⚠️ Install python3 or php to use serve."
    return 1
  fi
}

calc() {
  if [[ -z "$*" ]]; then
    echo "Usage: calc <expression>"
    return 1
  fi

  if command_exists python3; then
    ZSH_CALC_EXPR="$*" python3 - <<'PY'
import ast
import math
import operator
import os
import sys

expr = os.environ.get("ZSH_CALC_EXPR", "")

ALLOWED_NAMES = {k: getattr(math, k) for k in dir(math) if not k.startswith("_")}
OPERATORS = {
    ast.Add: operator.add,
    ast.Sub: operator.sub,
    ast.Mult: operator.mul,
    ast.Div: operator.truediv,
    ast.Pow: operator.pow,
    ast.Mod: operator.mod,
    ast.FloorDiv: operator.floordiv,
}
UNARY_OPERATORS = {
    ast.UAdd: operator.pos,
    ast.USub: operator.neg,
}

def eval_node(node):
    if isinstance(node, ast.Expression):
        return eval_node(node.body)
    if isinstance(node, ast.Constant) and isinstance(node.value, (int, float)):
        return node.value
    if isinstance(node, ast.BinOp) and type(node.op) in OPERATORS:
        return OPERATORS[type(node.op)](eval_node(node.left), eval_node(node.right))
    if isinstance(node, ast.UnaryOp) and type(node.op) in UNARY_OPERATORS:
        return UNARY_OPERATORS[type(node.op)](eval_node(node.operand))
    if isinstance(node, ast.Call):
        if not isinstance(node.func, ast.Name):
            raise ValueError("Only simple function calls are allowed")
        func = ALLOWED_NAMES.get(node.func.id)
        if func is None or not callable(func):
            raise ValueError(f"Unknown function: {node.func.id}")
        if node.keywords:
            raise ValueError("Keyword arguments are not supported")
        return func(*[eval_node(arg) for arg in node.args])
    if isinstance(node, ast.Name):
        value = ALLOWED_NAMES.get(node.id)
        if value is not None and not callable(value):
            return value
        raise ValueError(f"Unknown name: {node.id}")
    raise ValueError("Unsupported expression")

try:
    parsed = ast.parse(expr, mode="eval")
    result = eval_node(parsed)
except Exception as exc:
    print(f"calc error: {exc}", file=sys.stderr)
    sys.exit(1)
print(result)
PY
  elif command_exists bc; then
    echo "$*" | bc -l
  else
    echo "⚠️ Install python3 or bc to use calc."
    return 1
  fi
}

ff() {
  local query="$1"
  local -a cmd

  if command_exists fd; then
    if [[ -n "$query" ]]; then
      cmd=(fd --type f --hidden --follow --exclude .git "$query")
    else
      cmd=(fd --type f --hidden --follow --exclude .git .)
    fi
  else
    cmd=(find . -type f -not -path "*/.git/*")
    [[ -n "$query" ]] && cmd+=( -iname "*${query}*" )
  fi

  if command_exists fzf; then
    local selection
    selection=$("${cmd[@]}" 2>/dev/null | fzf --height 45% --layout=reverse --prompt="File> " \
      --preview 'bat --style=numbers --color=always --line-range :200 {} 2>/dev/null || sed -n "1,200p" {}')
    [[ -n "$selection" ]] && print -r -- "$selection"
  else
    "${cmd[@]}"
  fi
}

zsh_doctor() {
  local -a tools=(
    "git:Version control"
    "curl:HTTP client"
    "jq:JSON parsing"
    "fzf:Fuzzy finder"
    "fd:Fast file search"
    "rg:Ripgrep search"
    "bat:Syntax-aware cat"
    "eza:Modern ls"
    "fastfetch:System fetch"
    "figlet:Banner text"
    "tldr:Cheat sheets"
    "python3:Python runtime"
    "openssl:Crypto utilities"
    "tmux:Terminal multiplexer"
    "torsocks:Tor proxy wrapper"
  )

  local missing=0
  echo -e "\033[1;36m🩺 Zsh Doctor Report\033[0m"
  for tool in "${tools[@]}"; do
    local name="${tool%%:*}"
    local desc="${tool#*:}"
    if command_exists "$name"; then
      echo -e "  ✅ $name - $desc"
    else
      echo -e "  ❌ $name - $desc (missing)"
      ((missing++))
    fi
  done

  if (( missing == 0 )); then
    echo -e "\n\033[1;32mAll optional tools detected.\033[0m"
  else
    echo -e "\n\033[1;33mMissing: $missing optional tool(s).\033[0m"
  fi
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 28: ENHANCED ALIASES
# ═══════════════════════════════════════════════════════════════════════════

if command -v eza &> /dev/null; then
  alias ls='eza --icons --long --group-directories-first --git'
  alias ll='eza -la --icons --group-directories-first --git'
  alias la='eza -la --icons --group-directories-first'
  alias lt='eza --tree --level=2 --icons'
  alias l='eza -F --icons'
elif command -v exa &> /dev/null; then
  alias ls='exa --icons --long --group-directories-first --git'
  alias ll='exa -la --icons --group-directories-first --git'
  alias la='exa -la --icons --group-directories-first'
  alias lt='exa --tree --level=2 --icons'
  alias l='exa -F --icons'
else
  alias ls='ls --color=auto --group-directories-first'
  alias ll='ls -la'
  alias la='ls -la'
  alias l='ls -CF'
fi

alias apt='nocorrect apt'
alias update="sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean"
alias sysinfo="show_system_info"
alias netstat="ss -tuln"
alias ports="ss -tulpn"
alias process="ps aux | head -20"
alias memory="free -h && echo && ps aux --sort=-%mem | head -10"
alias kubectl='minikube kubectl --'
alias nvidia-run='__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias pathlist='pathshow'
alias proj='cproj'
alias doctor='zsh_doctor'

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 29: WELCOME SCREEN
# ═══════════════════════════════════════════════════════════════════════════

post_init_display() {
  if [[ -z "$WELCOME_DISPLAYED" ]]; then
    export WELCOME_DISPLAYED=1
    command clear

    if [[ "$ENABLE_GREETING_BANNER" == true ]]; then
      show_system_info
      time_based_greeting

      if command -v fastfetch &>/dev/null; then
        echo
        if [[ -f "$HOME/.config/fastfetch/config.jsonc" ]]; then
          fastfetch --config "$HOME/.config/fastfetch/config.jsonc"
        else
          fastfetch
        fi
      fi
    fi
  fi
}

add-zsh-hook precmd post_init_display

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 30: PATH CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════

export WORKON_HOME="$HOME/.virtualenvs"
export GOPATH="$HOME/go"
export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"

path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$GOPATH/bin"
  "$HOME/.cargo/bin"
  "$HOME/.local/share/npm/bin"
  "$PNPM_HOME"
  $path
)
typeset -U path
export PATH

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 31: SECURITY & PERMISSIONS
# ═══════════════════════════════════════════════════════════════════════════

ulimit -c 0
umask 022
alias chmod='command chmod'

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 32: POWERLEVEL10K CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════

if [[ "$ENABLE_STARSHIP" != true ]]; then
  [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
fi

if [[ "$ENABLE_STARSHIP" == true ]]; then
  export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship/kitty.toml}"
  if command_exists starship; then
    eval "$(starship init zsh)"
  else
    echo "⚠️ starship not installed. Disable ENABLE_STARSHIP or install starship."
  fi
fi

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 32B: COMMAND-NOT-FOUND
# ═══════════════════════════════════════════════════════════════════════════

if [[ -f /etc/zsh_command_not_found ]]; then
  source /etc/zsh_command_not_found
fi

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 33: LOCAL CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════

[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 34: ADVANCED THREAT INTELLIGENCE
# ═══════════════════════════════════════════════════════════════════════════

# Real-time threat intelligence monitoring (ENHANCED in v4.1)
# Usage: threat_intel [--update] [--critical] [--severity high|medium|low]
# Features: NVD API v2.0, CVSS filtering, exploit checking, portable date handling
threat_intel() {
  # Rate limit: 5 calls per 30 seconds
  _check_rate_limit "threat_intel" 5 30 || return 1

  local action="${1:-status}"
  local severity="${2:-high}"
  local cache_dir="$XDG_CACHE_HOME/zsh"

  mkdir -p "$cache_dir"

  case "$action" in
    --update|-u)
      echo "🔍 Updating threat intelligence feeds..."

      # === PORTABLE DATE CALCULATION ===
      local yesterday today
      if command -v python3 &>/dev/null; then
        # Works on ALL platforms (Linux, macOS, BSD)
        yesterday=$(python3 -c "from datetime import datetime, timedelta; print((datetime.now() - timedelta(1)).strftime('%Y-%m-%dT00:00:00.000'))")
        today=$(python3 -c "from datetime import datetime; print(datetime.now().strftime('%Y-%m-%dT23:59:59.999'))")
      else
        # Fallback for systems without Python (Linux only)
        yesterday=$(date -d '1 day ago' +%Y-%m-%dT00:00:00.000 2>/dev/null || date -v-1d +%Y-%m-%dT00:00:00.000 2>/dev/null)
        today=$(date +%Y-%m-%dT23:59:59.999)
      fi

      # === NVD API WITH KEY SUPPORT ===
      local nvd_url="https://services.nvd.nist.gov/rest/json/cves/2.0"
      nvd_url+="?lastModStartDate=${yesterday}&lastModEndDate=${today}"

      local curl_opts="-s --max-time 30"
      if [[ -n "$NVD_API_KEY" ]]; then
        curl_opts+=" -H 'apiKey: $NVD_API_KEY'"
        echo "  ℹ️  Using authenticated NVD API (higher rate limits)"
      else
        echo "  ⚠️  No NVD_API_KEY set (rate limited to 5 requests/30s)"
        echo "  💡 Get free key: https://nvd.nist.gov/developers/request-an-api-key"
      fi

      local cve_data=$(eval curl $curl_opts "\"$nvd_url\"" 2>/dev/null)

      if [[ -n "$cve_data" ]] && command -v jq &>/dev/null; then
        # === PARSE AND FILTER CVEs ===
        echo "$cve_data" | jq -r '
          .vulnerabilities[]? |
          select(.cve.metrics.cvssMetricV31 != null) |
          [
            .cve.id,
            (.cve.metrics.cvssMetricV31[0].cvssData.baseScore | tostring),
            .cve.metrics.cvssMetricV31[0].cvssData.baseSeverity,
            (.cve.descriptions[0].value[:150] + "...")
          ] | @tsv
        ' 2>/dev/null > "$cache_dir/latest_cves.tsv"

        local cve_count=$(wc -l < "$cache_dir/latest_cves.tsv" 2>/dev/null || echo 0)
        echo "✅ Downloaded $cve_count CVEs from last 24 hours"

      elif [[ -z "$(command -v jq)" ]]; then
        echo "⚠️  jq not installed. Install with: sudo apt install jq"
      else
        echo "⚠️  Failed to fetch CVE data from NVD"
      fi
      ;;

    --critical|-c)
      echo "🚨 CRITICAL Vulnerabilities (CVSS >= 9.0):"
      echo "═══════════════════════════════════════"

      if [[ -f "$cache_dir/latest_cves.tsv" ]]; then
        awk -F'\t' '$2 >= 9.0 {
          printf "  🔴 %-18s CVSS: %-4s (%s)\n     %s\n\n", $1, $2, $3, $4
        }' "$cache_dir/latest_cves.tsv"
      else
        echo "  ℹ️  No CVE data cached. Run: threat_intel --update"
      fi
      ;;

    --severity|-s)
      local min_score
      case "$severity" in
        critical) min_score=9.0 ;;
        high)     min_score=7.0 ;;
        medium)   min_score=4.0 ;;
        low)      min_score=0.1 ;;
        *)        min_score=7.0 ;;
      esac

      echo "📊 CVEs with severity >= ${severity} (CVSS >= ${min_score}):"

      if [[ -f "$cache_dir/latest_cves.tsv" ]]; then
        awk -F'\t' -v min="$min_score" '$2 >= min {
          printf "  %-18s CVSS: %-4s (%s)\n", $1, $2, $3
        }' "$cache_dir/latest_cves.tsv"
      else
        echo "  ℹ️  No CVE data cached. Run: threat_intel --update"
      fi
      ;;

    *)
      echo "📊 Current Threat Intelligence Status:"
      echo "────────────────────────────────────"

      # Show system vulnerability count
      if command_exists apt; then
        local pending_updates=$(apt list --upgradable 2>/dev/null | wc -l)
        echo "🔧 Pending security updates: $((pending_updates - 1))"
      fi

      # Show recent CVEs if available
      if [[ -f "$cache_dir/latest_cves.tsv" ]]; then
        local total_cves=$(wc -l < "$cache_dir/latest_cves.tsv")
        local critical_cves=$(awk -F'\t' '$2 >= 9.0' "$cache_dir/latest_cves.tsv" 2>/dev/null | wc -l)
        local high_cves=$(awk -F'\t' '$2 >= 7.0 && $2 < 9.0' "$cache_dir/latest_cves.tsv" 2>/dev/null | wc -l)

        echo "🚨 Cached CVEs: $total_cves total ($critical_cves critical, $high_cves high)"
        echo "   Top 3 by CVSS:"
        sort -t$'\t' -k2 -rn "$cache_dir/latest_cves.tsv" 2>/dev/null | head -3 | while IFS=$'\t' read cve score sev desc; do
          echo "   - $cve (CVSS: $score)"
        done
      else
        echo "🚨 No CVE cache. Run: threat_intel --update"
      fi

      # Network threat indicators
      echo "🌐 Network Status:"
      if command_exists ss; then
        local established_connections=$(ss -tn state established 2>/dev/null | wc -l)
        local listening_ports=$(ss -tln state listening 2>/dev/null | wc -l)
        echo "   Established connections: $established_connections"
        echo "   Listening ports: $listening_ports"
      fi
      ;;
  esac
}

# Advanced system hardening (ENHANCED in v4.1)
# Usage: system_hardening [--fix|--audit|--rollback]
# Features: Automatic backups, idempotent operations, kernel hardening, SSH security
system_hardening() {
  local action="${1:-audit}"
  local backup_dir="$XDG_CACHE_HOME/zsh/hardening_backups"

  mkdir -p "$backup_dir"

  case "$action" in
    --fix)
      echo "🛡️  System Hardening - Creating backups..."

      # === BACKUP CRITICAL FILES ===
      local timestamp=$(date +%Y%m%d_%H%M%S)

      [[ -f /etc/security/limits.conf ]] && \
        sudo cp /etc/security/limits.conf "$backup_dir/limits.conf.$timestamp" 2>/dev/null

      [[ -f /etc/sysctl.conf ]] && \
        sudo cp /etc/sysctl.conf "$backup_dir/sysctl.conf.$timestamp" 2>/dev/null

      echo "✅ Backups created in: $backup_dir"

      # === 1. CORE DUMPS (IDEMPOTENT) ===
      if ! grep -q "^\* hard core 0" /etc/security/limits.conf 2>/dev/null; then
        echo "* hard core 0" | sudo tee -a /etc/security/limits.conf >/dev/null
        echo "✅ Core dumps disabled"
      else
        echo "ℹ️  Core dumps already disabled"
      fi

      # === 2. KERNEL HARDENING (IDEMPOTENT) ===
      echo "\n🔧 Applying kernel hardening parameters..."

      local -a sysctl_params=(
        "kernel.dmesg_restrict=1"
        "kernel.kptr_restrict=2"
        "net.ipv4.tcp_syncookies=1"
        "net.ipv4.conf.all.accept_redirects=0"
        "net.ipv4.conf.all.send_redirects=0"
        "net.ipv4.conf.all.accept_source_route=0"
        "net.ipv4.conf.all.log_martians=1"
        "net.ipv6.conf.all.accept_redirects=0"
        "fs.suid_dumpable=0"
      )

      for param in "${sysctl_params[@]}"; do
        local key="${param%%=*}"
        local value="${param#*=}"

        if ! grep -q "^${key}=" /etc/sysctl.conf 2>/dev/null; then
          echo "$param" | sudo tee -a /etc/sysctl.conf >/dev/null
          sudo sysctl -w "$param" >/dev/null 2>&1
          echo "  ✓ Set: $param"
        fi
      done

      sudo sysctl -p >/dev/null 2>&1

      # === 3. UMASK ===
      umask 077
      echo "\n✅ Umask set to 077 (owner-only)"

      echo "\n🎯 Hardening complete! Review backups in: $backup_dir"
      ;;

    --audit)
      echo "🔍 Security Hardening Audit"
      echo "═══════════════════════════"

      # === UMASK CHECK ===
      local current_umask=$(umask)
      if [[ "$current_umask" == "0077" ]]; then
        echo "✅ Umask: $current_umask (secure)"
      else
        echo "⚠️  Umask: $current_umask (recommend: 0077)"
      fi

      # === CORE DUMPS ===
      if grep -q "^\* hard core 0" /etc/security/limits.conf 2>/dev/null; then
        echo "✅ Core dumps: Disabled"
      else
        echo "⚠️  Core dumps: Not disabled"
      fi

      # === KERNEL PARAMETERS ===
      echo "\n🔐 Kernel Security Parameters:"
      local -a params=(
        "kernel.dmesg_restrict"
        "kernel.kptr_restrict"
        "net.ipv4.tcp_syncookies"
      )

      for param in "${params[@]}"; do
        local value=$(sysctl -n "$param" 2>/dev/null || echo "not set")
        printf "  %-30s = %s\n" "$param" "$value"
      done

      # === WORLD-WRITABLE FILES (SAMPLE) ===
      echo "\n📁 World-writable files (sample, excluding /tmp):"
      find /home /etc /usr/local -type f -perm -002 ! -path "/tmp/*" 2>/dev/null | \
        head -5 | sed 's/^/   /' || echo "   None found (or permission denied)"

      # === FIREWALL STATUS ===
      echo "\n🔥 Firewall Status:"
      if command -v ufw &>/dev/null; then
        sudo ufw status 2>/dev/null | head -1 || echo "  Unknown"
      elif command -v firewall-cmd &>/dev/null; then
        echo "  firewalld: $(sudo firewall-cmd --state 2>/dev/null || echo 'unknown')"
      else
        echo "  ⚠️  No firewall detected (ufw/firewalld)"
      fi

      # === FAILED LOGINS ===
      if [[ -r /var/log/auth.log ]]; then
        local failed=$(grep -c "Failed password" /var/log/auth.log 2>/dev/null || echo 0)
        echo "\n🚨 Failed login attempts: $failed"
      fi

      echo "\n💡 Run 'system_hardening --fix' to apply hardening"
      ;;

    --rollback)
      echo "🔄 Rollback System Hardening"
      echo "════════════════════════════"

      local latest_limits=$(ls -t "$backup_dir"/limits.conf.* 2>/dev/null | head -1)
      local latest_sysctl=$(ls -t "$backup_dir"/sysctl.conf.* 2>/dev/null | head -1)

      if [[ -z "$latest_limits" && -z "$latest_sysctl" ]]; then
        echo "⚠️  No backups found in $backup_dir"
        return 1
      fi

      echo "Found backups:"
      [[ -n "$latest_limits" ]] && echo "  - $(basename $latest_limits)"
      [[ -n "$latest_sysctl" ]] && echo "  - $(basename $latest_sysctl)"

      echo -n "\nProceed with rollback? [y/N] "
      read -r confirm

      if [[ "${confirm:l}" == "y" ]]; then
        [[ -n "$latest_limits" ]] && \
          sudo cp "$latest_limits" /etc/security/limits.conf && \
          echo "✅ Restored limits.conf"

        [[ -n "$latest_sysctl" ]] && \
          sudo cp "$latest_sysctl" /etc/sysctl.conf && \
          sudo sysctl -p >/dev/null 2>&1 && \
          echo "✅ Restored sysctl.conf"

        echo "\n🎯 Rollback complete!"
      else
        echo "Cancelled."
      fi
      ;;
  esac
}

alias threat='threat_intel'
alias harden='system_hardening'
alias harden-rollback='system_hardening --rollback'
alias vulns='threat_intel --severity high'
# Consolidated Aliases from System 4.0
alias cve='threat_intel'
alias threats='threat_intel'
# ═══════════════════════════════════════════════════════════════════════════
# SECTION 35: PERFORMANCE DASHBOARD
# ═══════════════════════════════════════════════════════════════════════════

# Real-time performance monitoring dashboard
# Usage: perf_dashboard [--refresh <seconds>] [--export <format>]
# Features: CPU, memory, disk, network metrics with historical tracking
perf_dashboard() {
  local refresh_interval="${1:-2}"
  local export_format="${2:-none}"
  local log_file="$XDG_CACHE_HOME/zsh/perf_log.csv"

  # Initialize CSV log if exporting
  if [[ "$export_format" == "csv" ]]; then
    echo "timestamp,cpu_usage,memory_usage,disk_usage,network_io" > "$log_file"
  fi

  echo "🚀 Shadow Performance Dashboard - Ctrl+C to exit"
  echo "═══════════════════════════════════════════════════"

  while true; do
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local cpu_usage=$(_zsh_get_cpu_usage "total")
    # Memory: (Total - Available) / Total * 100
    local memory_info=$(free -b 2>/dev/null | awk 'NR==2{printf "%.2f", ($2-$7)*100/$2}')
    local disk_usage=$(df -h / 2>/dev/null | awk 'NR==2{print $5}' | sed 's/%//')

    # Network I/O (simplified)
    local network_io="N/A"
    if [[ -f /proc/net/dev ]]; then
      network_io=$(awk 'NR>2 {rx+=$2; tx+=$10} END {printf "%.0f/%.0f", rx/1024/1024, tx/1024/1024}' /proc/net/dev)
    fi

    # Clear screen and display dashboard
    printf "\033[2J\033[H"
    echo "📊 Performance Metrics - $timestamp"
    echo "─────────────────────────────────────"
    printf "💻 CPU Usage:     %8s%%\n" "$cpu_usage"
    printf "🧠 Memory Usage:  %8s%%\n" "$memory_info"
    printf "💾 Disk Usage:    %8s%%\n" "$disk_usage"
    printf "🌐 Network I/O:   %8s MB (RX/TX)\n" "$network_io"

    # Visual indicators
    echo ""
    echo "📈 Resource Status:"

    # CPU bar
    local cpu_bar_length=$((cpu_usage / 2))
    printf "CPU: [%-50s] %3d%%\n" "$(printf "%*s" $cpu_bar_length | tr ' ' '█')" "$cpu_usage"

    # Memory bar
    local mem_bar_length=$((memory_info / 2))
    printf "MEM: [%-50s] %3.0f%%\n" "$(printf "%*s" $mem_bar_length | tr ' ' '█')" "$memory_info"

    # Disk bar
    local disk_bar_length=$((disk_usage / 2))
    printf "DSK: [%-50s] %3d%%\n" "$(printf "%*s" $disk_bar_length | tr ' ' '█')" "$disk_usage"

    # Log data if requested
    if [[ "$export_format" == "csv" ]]; then
      echo "$timestamp,$cpu_usage,$memory_info,$disk_usage,$network_io" >> "$log_file"
    fi

    sleep "$refresh_interval"
  done
}

# System resource optimizer
# Usage: optimize_system [--aggressive] [--safe]
optimize_system() {
  local mode="${1:-safe}"

  echo "⚡ System Optimization - Mode: $mode"
  echo "════════════════════════════════════"

  case "$mode" in
    --aggressive|-a)
      echo "🔥 Applying aggressive optimizations..."

      # Clear system caches
      if command_exists sync; then
        sync && echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null 2>&1
        echo "✅ System caches cleared"
      fi

      # Optimize swappiness
      echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf 2>/dev/null
      echo "✅ Swappiness optimized"

      # Disable unnecessary services
      local services=("bluetooth" "cups" "avahi-daemon")
      for service in "${services[@]}"; do
        if systemctl is-active "$service" >/dev/null 2>&1; then
          sudo systemctl stop "$service" 2>/dev/null
          sudo systemctl disable "$service" 2>/dev/null
          echo "✅ Disabled $service"
        fi
      done
      ;;
    --safe|-s)
      echo "🛡️ Applying safe optimizations..."

      # Clean package cache
      if command_exists apt; then
        sudo apt autoremove -y >/dev/null 2>&1
        sudo apt autoclean >/dev/null 2>&1
        echo "✅ Package cache cleaned"
      fi

      # Clean temporary files
      find /tmp -type f -atime +7 -delete 2>/dev/null
      echo "✅ Temporary files cleaned"

      # Optimize database files
      if command_exists updatedb; then
        updatedb >/dev/null 2>&1
        echo "✅ File database updated"
      fi
      ;;
  esac

  echo "🎯 Optimization complete!"
}

alias perf='perf_dashboard'
alias opt='optimize_system --safe'
alias opt-aggressive='optimize_system --aggressive'
# Consolidated Aliases from System 4.0
alias dashboard='perf_dashboard'
alias live='perf_dashboard'

. "$HOME/.local/share/../bin/env"

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 36: CONFIGURATION VERSION CONTROL (NEW in v4.1)
# ═══════════════════════════════════════════════════════════════════════════

# Manage .zshrc versions/backups
# Usage: zshrc_version [init|save|restore|history|diff]
zshrc_version() {
  local action="${1:-history}"
  local backup_dir="$XDG_STATE_HOME/zsh/config_versions"
  local current_config="${HOME}/.zshrc"

  mkdir -p "$backup_dir"

  case "$action" in
    init)
      if [[ ! -d "$backup_dir/.git" ]]; then
        if command -v git &>/dev/null; then
          git init "$backup_dir" >/dev/null
          echo "✅ Config version control initialized in $backup_dir"
        else
          echo "⚠️  Git not found. Please install git first."
        fi
      else
        echo "ℹ️  Already initialized"
      fi
      ;;
    save)
      local msg="${2:-Auto-save $(date '+%Y-%m-%d %H:%M')}"
      if [[ ! -d "$backup_dir/.git" ]]; then
        zshrc_version init
      fi
      cp "$current_config" "$backup_dir/zshrc"
      git -C "$backup_dir" add zshrc
      git -C "$backup_dir" commit -m "$msg" >/dev/null && echo "✅ Config saved: $msg" || echo "ℹ️  No changes to save"
      ;;
    restore)
      local commit="${2:-HEAD~1}"
      if [[ ! -d "$backup_dir/.git" ]]; then
        echo "⚠️  No version history found."
        return 1
      fi
      git -C "$backup_dir" show "$commit":zshrc > "$current_config"
      echo "✅ Restored config from $commit"
      echo "ℹ️  Run 'source ~/.zshrc' to apply"
      ;;
    history)
      if [[ -d "$backup_dir/.git" ]]; then
        git -C "$backup_dir" log --oneline -n 10 2>/dev/null
      else
        echo "ℹ️  No history yet. Run 'zshrc_version init'"
      fi
      ;;
    diff)
      if [[ -d "$backup_dir/.git" ]]; then
        git -C "$backup_dir" diff HEAD -- zshrc 2>/dev/null
      fi
      ;;
    *)
      echo "Usage: zshrc_version <init|save|restore|history|diff>"
      ;;
  esac
}

alias zshrc-save='zshrc_version save'
alias zshrc-log='zshrc_version history'
alias zshrc-diff='zshrc_version diff'

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 37: PROCESS BASELINE MONITORING (NEW in v4.1)
# ═══════════════════════════════════════════════════════════════════════════

# Monitor process list for anomalies
# Usage: process_monitor [--baseline|--diff|--suspicious]
process_monitor() {
  local action="${1:-diff}"
  local baseline_file="$XDG_STATE_HOME/zsh/process_baseline.txt"

  mkdir -p "$(dirname "$baseline_file")"

  case "$action" in
    --baseline)
      ps -eo comm,cmd --sort=comm | grep -v "ps -eo" > "$baseline_file"
      echo "✅ Process baseline created ($(wc -l < "$baseline_file") processes)"
      ;;
    --diff)
      if [[ ! -f "$baseline_file" ]]; then
        echo "⚠️  No baseline found. Run: process_monitor --baseline"
        return 1
      fi

      echo "🔍 New processes since baseline:"
      # Simple diff
      if command -v comm &>/dev/null; then
        ps -eo comm,cmd --sort=comm | grep -v "ps -eo" | comm -23 - "$baseline_file" | sed 's/^/   + /'
      else
        ps -eo comm,cmd --sort=comm | grep -v "ps -eo" | grep -vFx -f "$baseline_file" | sed 's/^/   + /'
      fi
      ;;
    --suspicious)
      echo "🕵️  Checking for suspicious process names..."
      ps -eo pid,user,comm,cmd | grep -E "nc |netcat|ncat|bash -i|sh -i|python.*pty|perl.*pty|ruby.*tcpsocket" | \
        grep -v "grep" | sed 's/^/   ⚠️  /' || echo "   None found"
      ;;
    *)
      echo "Usage: process_monitor [--baseline|--diff|--suspicious]"
      ;;
  esac
}

alias procmon='process_monitor'
alias procmon-baseline='process_monitor --baseline'

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 38: OPERATOR EXECUTION HOOKS (v4.2)
# ═══════════════════════════════════════════════════════════════════════════
# NOTE: Core functions (_op_notify, operator_status, operator_config,
#       _op_render_execution_header) moved to Section 10A for early init.
#       Only hooks remain here as they should be registered after all plugins.

# === PROFESSIONAL HOOK MANAGEMENT SYSTEM ===
typeset -gA _SHADOW_HOOKS_REGISTERED

_shadow_register_hook() {
  local hook_type="$1"
  local hook_function="$2"
  local priority="${3:-50}"  # 0-100, lower = higher priority

  local hook_key="${hook_type}_${hook_function}"

  # Prevent duplicate registration
  [[ -n "${_SHADOW_HOOKS_REGISTERED[$hook_key]}" ]] && return 0

  # Remove existing hook to prevent conflicts
  add-zsh-hook -d "$hook_type" "$hook_function" 2>/dev/null

  # Register with priority management
  case "$hook_type" in
    precmd)
      # Order: cleanup → display → operator
      case "$priority" in
        [0-9])   add-zsh-hook precmd "$hook_function" ;;  # Highest priority
        [1-4][0-9]) add-zsh-hook precmd "$hook_function" ;;  # High priority
        [5-7][0-9]) add-zsh-hook precmd "$hook_function" ;;  # Medium priority
        *)       add-zsh-hook precmd "$hook_function" ;;  # Low priority
      esac
      ;;
    preexec)
      add-zsh-hook preexec "$hook_function"
      ;;
  esac

  _SHADOW_HOOKS_REGISTERED[$hook_key]=1
}

# === ENHANCED PREEXEC HOOK WITH OUTPUT CAPTURE ===
_op_preexec() {
  local full_command="$1"

  # Update session state
  typeset -g SHADOW_SESSION_COMMAND_COUNT=${SHADOW_SESSION_COMMAND_COUNT:-0}
  (( SHADOW_SESSION_COMMAND_COUNT++ ))

  # Skip only truly noise commands (not ls, cd, pwd which users want to see)
  case "$full_command" in
    clear|cls|history|jobs|fg|bg) return ;;
    *\[\[*\]\]*) return ;;  # Skip bracketed paste
    *) ;;
  esac

  # Set flag for output separation in precmd
  typeset -g _OP_COMMAND_EXECUTED=true

  # Render execution header
  _op_render_execution_header "$full_command"
}

# === ADVANCED PRECMD HOOK WITH ENHANCED OUTPUT SEPARATION ===
_op_precmd() {
    local exit_code="$?"

    # Update session state
    [[ $exit_code -ne 0 ]] && typeset -g SHADOW_SESSION_ERROR_COUNT=${SHADOW_SESSION_ERROR_COUNT:-0} && (( SHADOW_SESSION_ERROR_COUNT++ ))

    # Show advanced output separator with status
    if [[ -n "${_OP_COMMAND_EXECUTED}" ]]; then
        _op_show_output_separator "$exit_code"
        unset _OP_COMMAND_EXECUTED
    fi

    # Enhanced error reporting with context and suggestions
    if [[ $exit_code -ne 0 ]]; then
        # Determine error type and styling
        local error_type="ERROR"
        local error_color="38;2;255;100;0"
        local error_icon="$(_icon failure)"
        local gradient_style="flame"

        [[ $exit_code -gt 128 ]] && error_type="SIGNAL" && error_color="38;2;255;0;0" && error_icon="$(_icon critical)" && gradient_style="critical"
        [[ $exit_code -eq 2 ]] && error_type="PERMISSION" && error_color="38;2;255;165;0" && gradient_style="warning"
        [[ $exit_code -eq 127 ]] && error_type="NOT_FOUND" && error_color="38;2;255;200;0" && gradient_style="warning"

        # Simple gradient border function without animation
        _draw_gradient_border() {
            local width=$1
            local style="$2"

            # Left cap (white)
            printf "\033[38;2;255;255;255m─"

            for ((i=1; i<width-1; i++)); do
                # Simple static gradient based on position
                local progress=$((i * 100 / (width - 1)))

                # Different gradient styles based on error type
                case "$style" in
                    "critical")
                        # Deep red gradient
                        local r=$((255 - progress / 4))
                        local g=$((50 - progress / 8))
                        local b=$((50 - progress / 8))
                        ;;
                    "warning")
                        # Orange-yellow gradient
                        local r=255
                        local g=$((200 - progress / 5))
                        local b=$((50 + progress / 10))
                        ;;
                    "flame"|*)
                        # Default flame gradient
                        local r=$((255 - progress / 6))
                        local g=$((140 - progress / 10))
                        local b=0
                        ;;
                esac

                printf "\033[38;2;%d;%d;%dm─" "$r" "$g" "$b"
            done

            # Right cap (white)
            printf "\033[38;2;255;255;255m─"
        }

        # Enhanced error messages with more context
        local msg1="$error_icon [$error_type] Command failed with $([[ $exit_code -gt 128 ]] && echo "signal" || echo "exit code"): $exit_code"
        local msg2=""
        local msg3=""
        local msg4=""

        # Comprehensive error hints with actionable solutions
        case $exit_code in
            127)
                msg2="💡 Command not found - check PATH or spelling"
                msg3="🔧 Try: 'which <command>' or 'command -v <command>'"
                msg4="📦 Install with: apt install <command> | brew install <command>"
                ;;
            126)
                msg2="💡 Command not executable - check permissions"
                msg3="🔧 Try: 'chmod +x <file>' to make executable"
                msg4="🔍 Check file type with: 'file <filename>'"
                ;;
            130)
                msg2="💡 Script terminated with Ctrl+C"
                msg3="⚡ Operation was interrupted by user"
                msg4="🔄 Use 'fg' to resume background jobs"
                ;;
            2)
                msg2="💡 File not found or permission denied"
                msg3="🔍 Check file paths and verify existence"
                msg4="🔐 Try 'sudo' if administrative access needed"
                ;;
            125)
                msg2="💡 Command failed or operation not permitted"
                msg3="🔐 Check permissions and try with sudo if needed"
                msg4="📋 Verify command syntax and arguments"
                ;;
            1)
                msg2="💡 General error - command completed with issues"
                msg3="📋 Check command output for specific error details"
                msg4="🔍 Review command syntax and parameters"
                ;;
            130)
                msg2="💡 Script terminated with Ctrl+C"
                msg3="⚡ Operation was interrupted by user"
                msg4="🔄 Use 'fg' to resume background jobs"
                ;;
            137)
                msg2="💡 Process terminated (SIGKILL)"
                msg3="⚡ Process was forcefully terminated"
                msg4="🔍 Check system resources or process limits"
                ;;
            *)
                msg2="💡 Exit code $exit_code - unusual termination"
                msg3="📚 Check command documentation for this exit code"
                msg4="🔍 Search online: 'exit code $exit_code <command>'"
                ;;
        esac

        # Calculate max width (strip ANSI codes for accurate length)
        local max_width=0
        local msg1_len=${#msg1}
        local msg2_len=${#msg2}
        local msg3_len=${#msg3}
        local msg4_len=${#msg4}

        [[ $msg1_len -gt $max_width ]] && max_width=$msg1_len
        [[ $msg2_len -gt $max_width ]] && max_width=$msg2_len
        [[ $msg3_len -gt $max_width ]] && max_width=$msg3_len
        [[ $msg4_len -gt $max_width ]] && max_width=$msg4_len

        # Add padding (6 for "│   " and "   │")
        local box_width=$((max_width + 6))

        printf "\n"

        # Top border with enhanced gradient
        printf "\033[38;2;255;255;255m┌"
        _draw_gradient_border $box_width "$gradient_style"
        printf "┐\033[0m\n"

        # Message 1 - Primary error info
        printf "\033[38;2;255;255;255m│   \033[%sm%s" "$error_color" "$msg1"
        printf "%*s\033[38;2;255;255;255m   │\033[0m\n" $((max_width - msg1_len)) ""

        # Message 2 - Primary hint
        if [[ -n "$msg2" ]]; then
            printf "\033[38;2;255;255;255m│   \033[38;2;255;255;100m%s" "$msg2"
            printf "%*s\033[38;2;255;255;255m   │\033[0m\n" $((max_width - msg2_len)) ""
        fi

        # Message 3 - Secondary hint
        if [[ -n "$msg3" ]]; then
            printf "\033[38;2;255;255;255m│   \033[38;2;200;200;255m%s" "$msg3"
            printf "%*s\033[38;2;255;255;255m   │\033[0m\n" $((max_width - msg3_len)) ""
        fi

        # Message 4 - Additional suggestion
        if [[ -n "$msg4" ]]; then
            printf "\033[38;2;255;255;255m│   \033[38;2;150;150;255m%s" "$msg4"
            printf "%*s\033[38;2;255;255;255m   │\033[0m\n" $((max_width - msg4_len)) ""
        fi

        # Bottom border with matching gradient
        printf "\033[38;2;255;255;255m└"
        _draw_gradient_border $box_width "$gradient_style"
        printf "┘\033[0m\n"

        printf "\n"
    fi

    # Clean formatting
    printf "\033[0m"
}

# === OUTPUT SEPARATION HELPER ===
_op_show_output_separator() {
  if [[ "${_OP_CONFIG[show_output_separator]}" == "true" ]]; then
    printf "\033[38;2;100;100;100m"
    printf "%*s" "${_OP_CONFIG[divider_width]}" "" | tr ' ' "${_OP_CONFIG[output_separator_char]}"
    printf "\033[0m\n"
  fi
}

# === HOOK SYSTEM INITIALIZATION ===
_shadow_init_hooks() {
  # Register core hooks with proper priority
  _shadow_register_hook precmd _op_precmd 10    # High priority
  _shadow_register_hook precmd post_init_display 50      # Medium priority
  _shadow_register_hook preexec _op_preexec 10   # High priority
}

# Initialize hook system
_shadow_init_hooks
