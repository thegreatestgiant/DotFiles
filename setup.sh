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

# 2. Install Gum & Ask What to Install
# ----------------------------------------------------------------------
if is_arch; then
    if ! command -v gum &>/dev/null; then
        echo "📦 Installing gum..."
        sudo pacman -Sy --needed --noconfirm gum
    fi
    DEFAULT_SELECTED="bash,zsh,nvim,tmux,starship,git,ssh,rclone,hypr,kitty"
elif is_ubuntu; then
    if ! command -v gum &>/dev/null; then
        echo "📦 Installing gum..."
        sudo apt update
        sudo apt install -y curl gpg
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg --yes
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null
        sudo apt update
        sudo apt install -y gum
    fi
    DEFAULT_SELECTED="bash,zsh,nvim,tmux,starship,git,ssh,rclone"
else
    echo "Unsupported OS."
    exit 1
fi

echo "🔗 Selecting configs to stow and dependencies to install..."

if [ "$CI" = "true" ]; then
    echo "CI environment detected. Using default selection: $DEFAULT_SELECTED"
    STOW_APPS=$(echo "$DEFAULT_SELECTED" | tr ',' '\n')
else
    STOW_APPS=$(gum choose --no-limit \
        --selected "$DEFAULT_SELECTED" \
        --header "Select which dotfiles/components to install (Space to select, Enter to confirm)" \
        bash zsh nvim tmux starship git ssh rclone hypr kitty)
fi

if [ -z "$STOW_APPS" ]; then
    echo "No apps selected. Exiting."
    exit 0
fi

mapfile -t APPS_ARRAY <<< "$STOW_APPS"

wants() {
    local app=$1
    for a in "${APPS_ARRAY[@]}"; do
        if [[ "$a" == "$app" ]]; then
            return 0
        fi
    done
    return 1
}

# 3. Package Installation & Dependencies
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

    # Base packages
    ARCH_PKGS=(git stow base-devel unzip wget curl)
    
    wants zsh && ARCH_PKGS+=(zsh eza zoxide)
    wants nvim && ARCH_PKGS+=(neovim ripgrep fd xclip python nodejs npm fzf lazygit go)
    wants tmux && ARCH_PKGS+=(tmux)
    wants starship && ARCH_PKGS+=(starship)
    wants hypr && ARCH_PKGS+=(kitty)
    wants kitty && ARCH_PKGS+=(kitty)
    wants git && ARCH_PKGS+=(git-crypt rbw pinentry)
    wants nvim && ARCH_PKGS+=(jdk-openjdk jdk21-openjdk maven)

    echo "📦 Installing system packages..."
    sudo pacman -S --needed --noconfirm "${ARCH_PKGS[@]}"

    if wants hypr; then
        yay -S --needed --noconfirm vivid
    fi

elif is_ubuntu; then
    echo "Distro: Ubuntu / Debian"
    export DEBIAN_FRONTEND=noninteractive
    sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ | sudo tee /etc/timezone >/dev/null

    # Add Eza Repo if zsh requested
    if wants zsh && ! command -v eza &>/dev/null; then
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg --yes
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
        sudo apt update
    fi

    # Base packages
    UBUNTU_PKGS=(git stow build-essential unzip wget curl)
    
    wants zsh && UBUNTU_PKGS+=(zsh eza)
    wants nvim && UBUNTU_PKGS+=(ripgrep fd-find xclip python3-venv nodejs npm)
    wants tmux && UBUNTU_PKGS+=(tmux ncurses-term)
    wants git && UBUNTU_PKGS+=(pinentry-tty)
    wants hypr && UBUNTU_PKGS+=(wtype liblz4-dev libdav1d-dev pkg-config wayland-protocols libwayland-dev)
    
    echo "📦 Installing system packages..."
    sudo apt install -y "${UBUNTU_PKGS[@]}"

    # 'fd' fix for Ubuntu
    if wants nvim && ! command -v fd &>/dev/null; then
        mkdir -p ~/.local/bin
        ln -sf $(which fdfind) ~/.local/bin/fd
    fi

    # Install Vivid
    if ( wants hypr || wants bash || wants zsh ) && ! command -v vivid &>/dev/null; then
        echo "🎨 Installing Vivid (Latest)..."
        VIVID_TAG=$(curl -s "https://api.github.com/repos/sharkdp/vivid/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
        VIVID_VERSION="${VIVID_TAG#v}"
        wget "https://github.com/sharkdp/vivid/releases/download/${VIVID_TAG}/vivid_${VIVID_VERSION}_amd64.deb" -O vivid.deb
        sudo dpkg -i vivid.deb
        rm vivid.deb
    fi

    # Install FZF
    if wants nvim && [ ! -d "$HOME/.fzf" ]; then
        echo "🔍 Installing FZF..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
    fi

    # Install awww (Wallpaper daemon)
    if wants hypr && ! command -v awww &>/dev/null; then
        echo "🖼️ Installing awww (Wallpaper daemon)..."
        
        # Install latest Rust via rustup
        if ! command -v cargo &>/dev/null; then
            echo "🦀 Installing Rust (rustup)..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
        fi

        rm -rf /tmp/awww_install
        git clone https://codeberg.org/LGFae/awww.git /tmp/awww_install
        sed -i 's/rustix::stdio::stdout()/unsafe { rustix::stdio::stdout() }/g' /tmp/awww_install/daemon/src/cli.rs
        sed -i 's/rustix::stdio::stderr()/unsafe { rustix::stdio::stderr() }/g' /tmp/awww_install/daemon/src/main.rs
        cargo install --path /tmp/awww_install/client
        cargo install --path /tmp/awww_install/daemon
        cargo install --path /tmp/awww_install/client --bin awww-clear || true
        mkdir -p ~/.local/bin
        ln -sf ~/.cargo/bin/awww ~/.local/bin/awww
        ln -sf ~/.cargo/bin/awww-daemon ~/.local/bin/awww-daemon
        ln -sf ~/.cargo/bin/awww-clear ~/.local/bin/awww-clear
    fi

    # Install Lazygit
    if wants nvim && ! command -v lazygit &>/dev/null; then
        echo "💤 Installing Lazygit (Latest)..."
        LG_TAG=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LG_TAG}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit.tar.gz lazygit
    fi

    # Install Neovim
    if wants nvim && ! command -v nvim &>/dev/null; then
        echo "📝 Installing Neovim..."
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
        sudo rm -rf /opt/nvim-linux-x86_64
        sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
        export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
        rm nvim-linux-x86_64.tar.gz
    fi

    # Install Golang
    if wants nvim && ! command -v go &>/dev/null; then
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
    if wants git && ! command -v rbw &>/dev/null; then
        echo "🔐 Installing rbw (Latest)..."
        RBW_TAG=$(curl -s "https://api.github.com/repos/doy/rbw/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
        wget -qO rbw.deb "https://git.tozt.net/rbw/releases/deb/rbw_${RBW_TAG}_amd64.deb"
        sudo dpkg -i rbw.deb
        rm rbw.deb
    fi

    # Install Zoxide
    if wants zsh && ! command -v zoxide &>/dev/null; then
        echo "📂 Installing Zoxide..."
        curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
        sudo mv ~/.local/bin/zoxide /usr/local/bin/ || echo "Failed to move zoxide to /usr/local/bin/"
    fi

    # Install Starship
    if wants starship && ! command -v starship &>/dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
fi

# 4. Clone & Unlock
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

# 5. Stow
# ----------------------------------------------------------------------
echo "🔗 Stowing configs..."
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

# 6. Final Polish
# ----------------------------------------------------------------------
# Install systemd user services
echo "⚙️ Installing systemd user services..."
mkdir -p "$HOME/.config/systemd/user/"
find . -maxdepth 1 -name "*.service" -exec cp {} "$HOME/.config/systemd/user/" \;
systemctl --user daemon-reload 2>/dev/null || true

# Set default shell to zsh
if wants zsh && [ "$SHELL" != "$(which zsh)" ] && [ "$CI" != "true" ]; then
    chsh -s $(which zsh)
fi

echo ""
echo "🎉 All Systems Go!"
echo "👉 Please restart your terminal or run 'zsh' to load your new environment."
