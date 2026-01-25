
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# The following block is surrounded by two delimiters.
# These delimiters must not be modified. Thanks.
# START KALI CONFIG VARIABLES
PROMPT_ALTERNATIVE=twoline
NEWLINE_BEFORE_PROMPT=yes
# STOP KALI CONFIG VARIABLES

if [ "$color_prompt" = yes ]; then
    # override default virtualenv indicator in prompt
    VIRTUAL_ENV_DISABLE_PROMPT=1

    prompt_color='\[\033[;32m\]'
    info_color='\[\033[1;34m\]'
    prompt_symbol=㉿
    if [ "$EUID" -eq 0 ]; then # Change prompt colors for root user
        prompt_color='\[\033[;94m\]'
        info_color='\[\033[1;31m\]'
        # Skull emoji for root terminal
        #prompt_symbol=💀
    fi
    case "$PROMPT_ALTERNATIVE" in
        twoline)
            PS1=$prompt_color'┌──${debian_chroot:+($debian_chroot)──}${VIRTUAL_ENV:+(\[\033[0;1m\]$(basename $VIRTUAL_ENV)'$prompt_color')}('$info_color'\u'$prompt_symbol'\h'$prompt_color')-[\[\033[0;1m\]\w'$prompt_color']\n'$prompt_color'└─'$info_color'\$\[\033[0m\] ';;
        oneline)
            PS1='${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV)) }${debian_chroot:+($debian_chroot)}'$info_color'\u@\h\[\033[00m\]:'$prompt_color'\[\033[01m\]\w\[\033[00m\]\$ ';;
        backtrack)
            PS1='${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV)) }${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ ';;
    esac
    unset prompt_color
    unset info_color
    unset prompt_symbol
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|Eterm|aterm|kterm|gnome*|alacritty)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

[ "$NEWLINE_BEFORE_PROMPT" = yes ] && PROMPT_COMMAND="PROMPT_COMMAND=echo"

# enable color support of ls, less and man, and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:" # fix ls color for folders with 777 permissions

    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'

    export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
    export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
    export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
    export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
    export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
    export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
    export LESS_TERMCAP_ue=$'\E[0m'        # reset underline
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 99: SHADOW@BHANU BASH ENHANCEMENTS
# ═══════════════════════════════════════════════════════════════════════════

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

ENABLE_SHADOW_PROMPT=${ENABLE_SHADOW_PROMPT:-true}
ENABLE_STARTUP_BANNER=${ENABLE_STARTUP_BANNER:-true}
ENABLE_FASTFETCH=${ENABLE_FASTFETCH:-true}
SHADOW_BANNER_TEXT=${SHADOW_BANNER_TEXT:-"Shadow@Bhanu"}
SHADOW_PROMPT_TEXT=${SHADOW_PROMPT_TEXT:-"Shadow@Bhanu"}

if command_exists eza; then
  alias ls='eza --icons --long --group-directories-first --git'
  alias ll='eza -la --icons --group-directories-first --git'
  alias la='eza -la --icons --group-directories-first'
  alias lt='eza --tree --level=2 --icons'
  alias l='eza -F --icons'
elif command_exists exa; then
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

if command_exists rg; then
  alias grep='rg --color=auto'
fi

if command_exists fd; then
  alias find='fd'
fi

if command_exists apt; then
  alias update="sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean"
fi

[[ -f "$HOME/Scripts/wifi_auto_login.py" ]] && alias setup="python3 ~/Scripts/wifi_auto_login.py"
[[ -f "$HOME/Scripts/server.sh" ]] && alias server="bash /home/bhanu/Scripts/server.sh"

random_color() {
  local -a colors=(31 32 33 34 35 36 37)
  echo "${colors[RANDOM % ${#colors[@]}]}"
}

typewriter_effect() {
  local text="$1"
  local delay="${2:-0.03}"
  local i
  for ((i=0; i<${#text}; i++)); do
    printf "%s" "${text:$i:1}"
    sleep "$delay"
  done
}

shadow_banner() {
  local text="${1:-$SHADOW_BANNER_TEXT}"
  local color
  color=$(random_color)
  if command_exists figlet; then
    printf "\033[%sm" "$color"
    figlet -f slant "$text"
    printf "\033[0m"
  else
    printf "\033[%sm%s\033[0m\n" "$color" "$text"
  fi
}

if [[ "$ENABLE_STARTUP_BANNER" == "true" ]]; then
  shadow_banner
fi

clear() {
  command clear
  [[ "$ENABLE_STARTUP_BANNER" == "true" ]] && shadow_banner
}

if [[ "$ENABLE_SHADOW_PROMPT" == "true" ]]; then
  if [[ $EUID -eq 0 ]]; then
    PS1="\[\e[1;31m\]${SHADOW_PROMPT_TEXT}\[\e[0m\]:\[\e[1;33m\]\w\[\e[0m\]# "
  else
    PS1="\[\e[1;32m\]${SHADOW_PROMPT_TEXT}\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ "
  fi
fi

export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

if [[ "$ENABLE_FASTFETCH" == "true" ]] && command_exists fastfetch; then
  fastfetch
fi

man() {
  if command_exists tldr; then
    if [[ -z "$1" ]]; then
      if command_exists fzf; then
        local cmd
        cmd=$(tldr --list | fzf --preview 'tldr {}' --height 80% --border --reverse)
        [[ -n "$cmd" ]] && tldr "$cmd"
      else
        tldr --list
      fi
    else
      if tldr "$1" &>/dev/null; then
        tldr "$1"
      else
        command man "$1"
      fi
    fi
  else
    command man "$@"
  fi
}

path_add() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  case ":$PATH:" in
    *":$dir:"*) return 0 ;;
  esac
  PATH="$PATH:$dir"
}

if [[ -f "$HOME/.cargo/env" ]]; then
  . "$HOME/.cargo/env"
fi
path_add "$HOME/Downloads/010editor"
export GOPATH="${GOPATH:-$HOME/go}"
path_add "$GOPATH/bin"
export PATH

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 100: LOCAL OVERRIDES
# ═══════════════════════════════════════════════════════════════════════════

[[ -f "$HOME/.bashrc.local" ]] && . "$HOME/.bashrc.local"

# End of configuration
