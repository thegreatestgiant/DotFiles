#!/bin/bash
set -e

# ----------------------------------------------------------------------
# ⚡️ Dotfiles Bootstrap Script (Unified Edition)
# ----------------------------------------------------------------------
export TZ="America/New_York"

DOTFILES_DIR="$HOME/.files"
REPO_URL="https://github.com/thegreatestgiant/dotfiles.git"
KEY_PATH="$HOME/dotfiles_key.key"

echo "🚀 Starting System Bootstrap..."

# 1. OS Detection
# ----------------------------------------------------------------------
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    OS_LIKE=$ID_LIKE
else
    echo "Could not detect OS. Exiting."
    exit 1
fi

is_arch() {
    [[ "$OS" == "arch" || "$OS_LIKE" == *"arch"* ]]
}

is_ubuntu() {
    [[ "$OS" == "ubuntu" || "$OS" == "debian" || "$OS_LIKE" == *"debian"* ]]
}

# 2. Package Installation & Dependencies
# ----------------------------------------------------------------------
if is_arch; then
    echo "Distro: Arch Linux / CachyOS"
    
    if ! command -v yay &>/dev/null; then
        echo "📦 Installing yay..."
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm
        cd ~
    fi

    echo "📦 Installing system packages..."
    sudo pacman -S --needed --noconfirm \
        git stow zsh base-devel unzip \
        ripgrep fd xclip python \
        nodejs npm eza \
        fzf lazygit neovim go \
        zoxide starship kitty \
        tmux git-crypt \
        jdk-openjdk jdk21-openjdk maven \
        rbw pinentry gum 

    # AUR packages
    yay -S --needed --noconfirm vivid

elif is_ubuntu; then
    echo "Distro: Ubuntu / Debian"
    export DEBIAN_FRONTEND=noninteractive
    sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ | sudo tee /etc/timezone >/dev/null

    echo "🔑 Setting up repositories..."
    sudo apt update
    sudo apt install -y wget gpg curl

    # Add Eza Repo
    if ! command -v eza &>/dev/null; then
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg --yes
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
    fi

    # Add Charm Repo for Gum
    if ! command -v gum &>/dev/null; then
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg --yes
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null
    fi

    sudo apt update

    echo "📦 Installing system packages..."
    sudo apt install -y git stow zsh build-essential unzip ripgrep fd-find xclip python3-venv nodejs npm eza ncurses-term pinentry-tty gum wtype rofimoji cargo liblz4-dev libdav1d-dev pkg-config wayland-protocols libwayland-dev

    # 'fd' fix for Ubuntu
    if ! command -v fd &>/dev/null; then
        mkdir -p ~/.local/bin
        ln -sf $(which fdfind) ~/.local/bin/fd
    fi

    # Install Vivid
    if ! command -v vivid &>/dev/null; then
        echo "🎨 Installing Vivid (Latest)..."
        VIVID_TAG=$(curl -s "https://api.github.com/repos/sharkdp/vivid/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
        VIVID_VERSION="${VIVID_TAG#v}"
        wget "https://github.com/sharkdp/vivid/releases/download/${VIVID_TAG}/vivid_${VIVID_VERSION}_amd64.deb" -O vivid.deb
        sudo dpkg -i vivid.deb
        rm vivid.deb
    fi

    # Install FZF
    if [ ! -d "$HOME/.fzf" ]; then
        echo "🔍 Installing FZF..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
    fi

    # Install awww (Wallpaper daemon)
    if ! command -v awww &>/dev/null; then
        echo "🖼️ Installing awww (Wallpaper daemon)..."
        cargo install --git https://codeberg.org/LGFae/awww.git awww
        cargo install --git https://codeberg.org/LGFae/awww.git awww-daemon
        cargo install --git https://codeberg.org/LGFae/awww.git awww-clear
        mkdir -p ~/.local/bin
        ln -sf ~/.cargo/bin/awww ~/.local/bin/awww
        ln -sf ~/.cargo/bin/awww-daemon ~/.local/bin/awww-daemon
        ln -sf ~/.cargo/bin/awww-clear ~/.local/bin/awww-clear
    fi

    # Install Lazygit
    if ! command -v lazygit &>/dev/null; then
        echo "💤 Installing Lazygit (Latest)..."
        LG_TAG=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LG_TAG}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit.tar.gz lazygit
    fi

    # Install Neovim
    if ! command -v nvim &>/dev/null; then
        echo "📝 Installing Neovim..."
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
        sudo rm -rf /opt/nvim-linux-x86_64
        sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
        export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
        rm nvim-linux-x86_64.tar.gz
    fi

    # Install Golang
    if ! command -v go &>/dev/null; then
        echo "🐹 Installing Latest Golang..."
        GO_VERSION=$(curl -sL https://go.dev/dl/ | grep -oP 'go[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
        wget "https://dl.google.com/go/${GO_VERSION}.linux-amd64.tar.gz" -O go.tar.gz
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf go.tar.gz
        rm go.tar.gz
        rm -rf "${HOME}/go"
        export PATH="$PATH:/usr/local/go/bin"
    fi

    # Install rbw
    if ! command -v rbw &>/dev/null; then
        echo "🔐 Installing rbw (Latest)..."
        RBW_TAG=$(curl -s "https://api.github.com/repos/doy/rbw/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
        wget -qO rbw.deb "https://git.tozt.net/rbw/releases/deb/rbw_${RBW_TAG}_amd64.deb"
        sudo dpkg -i rbw.deb
        rm rbw.deb
    fi

    # Install Zoxide
    if ! command -v zoxide &>/dev/null; then
        echo "📂 Installing Zoxide..."
        curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
        sudo mv ~/.local/bin/zoxide /usr/local/bin/
    fi

    # Install Starship
    if ! command -v starship &>/dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
else
    echo "Unsupported OS."
    exit 1
fi

# 3. Clone & Unlock
# ----------------------------------------------------------------------
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "📥 Cloning dotfiles..."
    git clone --recurse-submodules "$REPO_URL" "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"

if [ -d ".git-crypt" ] && [ -f "$KEY_PATH" ]; then
    echo "🔐 Unlocking secrets..."
    git-crypt unlock "$KEY_PATH"
fi

# 4. Interactive Stow via Gum
# ----------------------------------------------------------------------
echo "🔗 Selecting configs to stow..."

# Pre-select based on OS
if is_arch; then
    DEFAULT_SELECTED="bash,zsh,nvim,tmux,starship,git,ssh,rclone,hypr,kitty"
else
    DEFAULT_SELECTED="bash,zsh,nvim,tmux,starship,git,ssh,rclone"
fi

if [ "$CI" = "true" ]; then
    echo "CI environment detected. Using default selection: $DEFAULT_SELECTED"
    STOW_APPS=$(echo "$DEFAULT_SELECTED" | tr ',' '\n')
else
    STOW_APPS=$(gum choose --no-limit \
        --selected "$DEFAULT_SELECTED" \
        --header "Select which dotfiles to stow (Space to select, Enter to confirm)" \
        bash zsh nvim tmux starship git ssh rclone hypr kitty)
fi

if [ -z "$STOW_APPS" ]; then
    echo "No apps selected. Skipping stow."
else
    # Convert newline-separated list to array
    mapfile -t APPS_ARRAY <<< "$STOW_APPS"
    
    # Backup conflicts
    for app in "${APPS_ARRAY[@]}"; do
        case $app in
            bash) file=".bashrc" ;;
            zsh) file=".zshrc" ;;
            nvim) file=".config/nvim" ;;
            tmux) file=".config/tmux" ;;
            starship) file=".config/starship.toml" ;;
            hypr) file=".config/hypr" ;;
            kitty) file=".config/kitty" ;;
            ssh) file=".ssh" ;;
            rclone) file=".config/rclone" ;;
            git) file=".gitconfig" ;;
            *) file="" ;;
        esac
        
        if [ -n "$file" ] && [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
            echo "  Backing up $file → $file.bak"
            mv "$HOME/$file" "$HOME/$file.bak"
        fi
    done
    
    echo "Stowing: ${APPS_ARRAY[*]}"
    stow "${APPS_ARRAY[@]}"
fi

# 5. Final Polish
# ----------------------------------------------------------------------
# Install systemd user services
echo "⚙️ Installing systemd user services..."
mkdir -p "$HOME/.config/systemd/user/"
find . -maxdepth 1 -name "*.service" -exec cp {} "$HOME/.config/systemd/user/" \;
systemctl --user daemon-reload 2>/dev/null || true

# Set default shell to zsh
if [ "$SHELL" != "$(which zsh)" ] && [ "$CI" != "true" ]; then
    chsh -s $(which zsh)
fi

echo ""
echo "🎉 All Systems Go!"
echo "👉 Please restart your terminal or run 'zsh' to load your new environment."
