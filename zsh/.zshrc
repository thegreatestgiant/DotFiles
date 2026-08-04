export TERM=xterm-256color
### -------------------------------------------------------------------------
### 1. ZINIT INSTALLATION (Auto-installs if missing)
### -------------------------------------------------------------------------
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing \033[35mZinit\033[0m..."
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f" || \
        print -P "%F{160} The clone has failed.%f"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

### -------------------------------------------------------------------------
### 2. PLUGIN MANAGEMENT (Turbo Mode)
### -------------------------------------------------------------------------
# Load Powerlevel10k or Starship instantly
zinit ice depth=1
zinit light starship/starship

# Syntax Highlighting (Load after compinit)
zinit ice wait lucid atinit"zpcompinit; zpcdreplay"
zinit light zsh-users/zsh-syntax-highlighting

# Autosuggestions (Grey text completions)
zinit ice wait lucid atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

# FZF & Zoxide integration (Productivity)
zinit ice wait lucid
zinit light ajeetdsouza/zoxide

# Completions library
zinit ice wait lucid blockf
zinit light zsh-users/zsh-completions

# FZF-TAB (The upgrade: Replaces standard Tab menu with FZF)
# Needs to be loaded after compinit, but zinit handles that order generally.
zinit ice wait lucid
zinit light aloxaf/fzf-tab

# Sudo Plugin (Press Esc-Esc to add sudo)
zinit ice wait lucid
zinit snippet OMZP::sudo

# -- GIT POWER TOOLS --
# Forgit: Interactive git using FZF (ga, glo, gd)
zinit ice wait lucid
zinit light wfxr/forgit


### -------------------------------------------------------------------------
### 3. BASIC CONFIGURATION & HISTORY
### -------------------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
HISTDUP=erase

# Options
setopt EXTENDED_HISTORY          # Write timestamps to history
setopt SHARE_HISTORY             # Share history between terminals
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first when trimming history
setopt HIST_IGNORE_SPACE          
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt AUTO_CD                   # Type 'dir_name' to cd into it
setopt AUTO_PUSHD                # Push the old directory onto the stack on cd
setopt PUSHD_IGNORE_DUPS         # Do not store duplicates in the stack
setopt PUSHD_SILENT              # Do not print the directory stack on pushd or popd

### -------------------------------------------------------------------------
### 4. VI MODE & HYBRID KEYBINDINGS
### -------------------------------------------------------------------------
bindkey -v # Enable Vi Mode

# The Hybrid Setup: Restore standard shortcuts in Insert Mode
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^K' kill-line
bindkey -M viins '^U' backward-kill-line
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^Y' yank
bindkey -M viins '^R' history-incremental-search-backward
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char

# Fix Backspace in Command Mode
bindkey -M vicmd '^?' backward-delete-char
bindkey -M vicmd '^H' backward-delete-char

# EDIT IN NEOVIM
# Press 'v' in command mode (Esc first) to edit the current line in $EDITOR
autoload -z edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

### -------------------------------------------------------------------------
### 5. COMPLETION & PREVIEWS (Strict & Complete)
### -------------------------------------------------------------------------

# -- CONFIGURATION --
# 1. Colors
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# 2. MATCHER (Fixed: Kills the "Ghost" completions)
# Only two rules:
# 1. Case insensitive (a matches A)
# 2. Fix typos (Start matching at the beginning, don't search middle of word)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'

# 3. HIDDEN FILES (Fixed: Show BOTH normal and hidden files together)
# We list both patterns in ONE string so they are generated simultaneously.
zstyle ':completion:*' file-patterns '%p:globbed-files *(D):hidden-files'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:hidden-files' format ' %F{240}-- hidden files --%f'
zstyle ':completion:*:globbed-files' format ' %F{green}-- files --%f'

# 4. THE PREVIEWER
zstyle ':fzf-tab:complete:*:*' fzf-preview '
  if [ -d $realpath ]; then
    # Directory -> Show colorful eza tree
    eza -1 -a --color=always --icons --group-directories-first $realpath
  else
    # File -> Show colorful content
    if command -v bat> /dev/null; then
      bat --color=always --style=numbers --line-range=:500 $realpath
    else
      cat $realpath
    fi
  fi
'
zstyle ':fzf-tab:complete:*:*' fzf-flags --height=80% --preview-window=right:60%:wrap
zstyle ':fzf-tab:*' switch-group '<' '>'

### -------------------------------------------------------------------------
### MANUAL EMOJI WIDGET (Bypassing the broken plugin)
### -------------------------------------------------------------------------
# This function runs emoji-fzf directly. No plugin required.
function insert_emoji() {
  # check if tool exists
  if ! command -v emoji-fzf &> /dev/null; then
    echo "\nError: emoji-fzf not found. Check your PATH or install with 'pipx install emoji-fzf'"
    zle reset-prompt
    return 1
  fi

  # Run the selector
  local selected=$(emoji-fzf preview --prepend | fzf --height=40% --layout=reverse --border --preview-window=right:wrap)
  
  if [[ -n "$selected" ]]; then
    # Extract the emoji icon (First column)
    local icon=$(echo "$selected" | awk '{print $1}')
    LBUFFER+="$icon "
  fi
}

# Register the widget
zle -N insert_emoji

# Bind Keys
bindkey -M viins '^xe' insert_emoji  # Ctrl+x, then e (Insert Mode)
bindkey -M vicmd 'E' insert_emoji    # Shift+e (Normal Mode)

### -------------------------------------------------------------------------
### 6. LAZY LOADING (Speed Boosters)
### -------------------------------------------------------------------------

# Lazy Load NVM
# NVM is slow. This function defines 'nvm', 'node', 'npm' as dummy functions.
# The first time you run one, it unsets the dummies, loads NVM for real, and runs the command.
export NVM_DIR="$HOME/.nvm"
lazy_load_nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  "$@"
}
nvm() { lazy_load_nvm nvm "$@"; }
node() { lazy_load_nvm node "$@"; }
npm() { lazy_load_nvm npm "$@"; }
npx() { lazy_load_nvm npx "$@"; }

# --- Cross-Platform Java Setup ---
if [ -d "/usr/lib/jvm/default" ]; then
  export JAVA_HOME="/usr/lib/jvm/default" # Arch
elif [ -d "/usr/lib/jvm/default-java" ]; then
  export JAVA_HOME="/usr/lib/jvm/default-java" # Ubuntu
fi

### -------------------------------------------------------------------------
### 7. ALIASES & TOOLS
### -------------------------------------------------------------------------
# Load Zoxide and replace 'cd'
eval "$(zoxide init zsh --cmd cd)"

# Load FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ZMV (Mass rename tool)
autoload -U zmv

# Available themes: vivid themes (run this to see list)
export LS_COLORS="$(vivid generate snazzy)"

rationalise-dot() {
  if [[ $LBUFFER = *.. ]]; then
    LBUFFER+=/..
  else
    LBUFFER+=.
  fi
}
zle -N rationalise-dot
bindkey . rationalise-dot


# --icons: show icons
# --group-directories-first: folders on top
# --git: show git status symbols
alias v='wl-paste'

alias ls='eza --icons --group-directories-first --git'

alias ll='eza --icons --group-directories-first --git -la --header --time-style=long-iso'
alias la='eza --icons --group-directories-first --git -la --header --time-style=long-iso'
alias l='eza --icons --group-directories-first --git -labF --header'
alias lt='eza --icons -a --tree --level=2'
alias llt='eza --icons -a --tree --level=2 -l'

# General Aliases
alias ip='curl icanhazip.com'
alias grep='grep --color=auto'

# Cross-Platform Package Management (Arch/CachyOS vs Ubuntu/Debian)
if command -v paru &> /dev/null; then
    # Arch / CachyOS (paru)
    alias i='paru -S --noconfirm'
    alias r='paru -Rns'
    alias zupdate='paru -Syu'
    alias cleanup='paru -Scc'                                         
    alias orphans='sudo pacman -Rns $(pacman -Qtdq)'                  
    alias pin='paru -Slq | fzf --multi --preview "paru -Si {1}" | xargs -ro paru -S'
elif command -v apt-get &> /dev/null; then
    # Ubuntu / WSL (apt)
    alias i='sudo apt install -y'
    alias r='sudo apt remove -y'
    alias zupdate='sudo apt update && sudo apt upgrade -y'
    alias cleanup='sudo apt autoremove -y && sudo apt clean'
    alias orphans='sudo apt autoremove -y'
fi

alias W='wl-copy'

# NVIM as default editor
export EDITOR='nvim'
export SUDO_EDITOR='nvim'
export UV_LINK_MODE=copy
# Add custom path
# Add Node global binaries explicitly so they work without triggering NVM
export PATH="/usr/local/go/bin:$HOME/go/bin:/opt/nvim-linux-x86_64/bin:$HOME/.local/bin:$PATH"
  
# SSH Agent Bridge (Bitwarden/WSL) - DISABLED
# if [ -f "$HOME/.ssh/ssh-agent-bridge-bit.sh" ]; then
#     source "$HOME/.ssh/ssh-agent-bridge-bit.sh"
# fi

### -------------------------------------------------------------------------
### 8. PROMPT (Starship)
### -------------------------------------------------------------------------
eval "$(starship init zsh)"

### -------------------------------------------------------------------------
### 9. RBW (Lightning Fast Bitwarden CLI & SSH Agent)
### -------------------------------------------------------------------------
# Set the SSH agent socket to point to rbw's background agent
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/rbw/ssh-agent-socket"

# Function to initially set up rbw for self-hosted Bitwarden
function bw-setup() {
    echo "--- Setting up rbw for self-hosted Bitwarden ---"
    echo -n "Enter your self-hosted Bitwarden URL (e.g., https://vault.example.com): "
    read url
    if [[ -n "$url" ]]; then
        rbw config set base_url "$url"
    fi
    
    echo -n "Enter your Bitwarden email address: "
    read email
    if [[ -n "$email" ]]; then
        rbw config set email "$email"
    fi
    
    echo "✅ Configuration saved!"
    echo "Logging in to your vault... (You will need your Master Password)"
    rbw login
    
    # Also set the timeout so they don't have to worry about it
    rbw config set lock_timeout 315360000
    echo "✅ Lock timeout set to 10 years."
}

# Function to unlock the vault and set an infinite timeout
function bw-unlock() {
    # Set the timeout to 10 years so you never have to re-enter it
    rbw config set lock_timeout 315360000
    rbw unlock
}

