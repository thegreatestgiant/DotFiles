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

# SSH Agent (Lazy load ssh-agent)
zinit ice wait lucid
zinit snippet OMZP::ssh-agent

# Sudo Plugin (Press Esc-Esc to add sudo)
zinit ice wait lucid
zinit snippet OMZP::sudo

# -- GIT POWER TOOLS --
# Forgit: Interactive git using FZF (ga, glo, gd)
zinit ice wait lucid
zinit light wfxr/forgit

# -- EMOJI PLUGIN --
# 1. Disable default bind
export EMOJI_FZF_NO_BIND=1

# 2. Load Synchronously (Remove 'wait' to ensure function exists)
zinit light pschmitt/emoji-fzf.zsh

# 3. Bind Keys (Now safe to do directly)
bindkey -M viins '^xe' emoji-fzf
bindkey -M vicmd 'E' emoji-fzf

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
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
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
# Load completions
zinit ice wait lucid blockf
zinit light zsh-users/zsh-completions

# Load FZF-TAB
zinit ice wait lucid
zinit light aloxaf/fzf-tab

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
    if command -v batcat > /dev/null; then
      batcat --color=always --style=numbers --line-range=:500 $realpath
    elif command -v bat > /dev/null; then
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

# Lazy Load SDKMAN
# Similar concept for SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
lazy_load_sdkman() {
  unset -f sdk java javac mvn gradle
  [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
  "$@"
}
# Define the triggers
sdk() { lazy_load_sdkman sdk "$@"; }
java() { lazy_load_sdkman java "$@"; }
javac() { lazy_load_sdkman javac "$@"; }
mvn() { lazy_load_sdkman mvn "$@"; }
gradle() { lazy_load_sdkman gradle "$@"; }

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
alias ls='eza --icons --group-directories-first --git'

alias ll='eza --icons --group-directories-first --git -la --header --time-style=long-iso'
alias la='eza --icons --group-directories-first --git -la --header --time-style=long-iso'
alias l='eza --icons --group-directories-first --git -labF --header'
alias lt='eza --icons -a --tree --level=2'
alias llt='eza --icons -a --tree --level=2 -l'

# General Aliases
alias i='sudo apt install -y'
alias ip='curl icanhazip.com'
alias zupdate='sudo apt update && sudo apt upgrade -y'
alias grep='grep --color=auto'

# NVIM as default editor
export EDITOR='nvim'
export SUDO_EDITOR='nvim'

# Classpath (Ported)
export CLASSPATH=$CLASSPATH:"/home/sean/Intro To Comp Sci/":"/home/sean/Intro To Comp Sci/edu.yu.cs.intro.hw6ShiurStats/src/main/java/"

# Add custom path
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

### -------------------------------------------------------------------------
### 8. PROMPT (Starship)
### -------------------------------------------------------------------------
eval "$(starship init zsh)"
