#!/bin/bash
set -e

# ----------------------------------------------------------------------
# ⚡️ Dotfiles Bootstrap Script (Dynamic Edition)
# ----------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
export TZ="America/New_York"
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ >/etc/timezone

DOTFILES_DIR="$HOME/.files"
REPO_URL="https://github.com/thegreatestgiant/dotfiles.git"
KEY_PATH="$HOME/dotfiles_key.key"

echo "🚀 Starting System Bootstrap..."

# 1. Prepare Apt Repositories
# ----------------------------------------------------------------------
echo "🔑 Setting up repositories..."
sudo apt update
sudo apt install -y wget gpg curl

# Add Eza Repo (Dynamic fetch not possible for apt source, using stable)
if ! command -v eza &>/dev/null; then
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg --yes
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
fi

# Add GitHub CLI Repo
if ! command -v gh &>/dev/null; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
fi

sudo apt update

# 2. Install Packages
# ----------------------------------------------------------------------
echo "📦 Installing system packages..."
sudo apt install -y git stow zsh build-essential unzip \
    ripgrep fd-find xclip python3-venv \
    nodejs npm gh eza

# 'fd' fix for Ubuntu
if ! command -v fd &>/dev/null; then
    mkdir -p ~/.local/bin
    # Added -f to force overwrite if it already exists
    ln -sf $(which fdfind) ~/.local/bin/fd
fi

# 3. Install Vivid (Latest from GitHub)
# ----------------------------------------------------------------------
if ! command -v vivid &>/dev/null; then
    echo "🎨 Installing Vivid (Latest)..."
    # Fetch latest tag name (e.g., v0.10.1)
    VIVID_TAG=$(curl -s "https://api.github.com/repos/sharkdp/vivid/releases/latest" | grep -Po '"tag_name": "\K[^"]*')

    # Strip the 'v' prefix for the Debian filename (results in 0.10.1)
    VIVID_VERSION="${VIVID_TAG#v}"

    # Download using the tag for the URL, and the stripped version for the file
    wget "https://github.com/sharkdp/vivid/releases/download/${VIVID_TAG}/vivid_${VIVID_VERSION}_amd64.deb"
    sudo dpkg -i "vivid_${VIVID_VERSION}_amd64.deb"
    rm "vivid_${VIVID_VERSION}_amd64.deb"
fi

# 4. Install FZF & Lazygit (Latest)
# ----------------------------------------------------------------------
if [ ! -d "$HOME/.fzf" ]; then
    echo "🔍 Installing FZF..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
fi

if ! command -v lazygit &>/dev/null; then
    echo "💤 Installing Lazygit (Latest)..."
    LG_TAG=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LG_TAG}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit.tar.gz lazygit
fi

# 5. Install Neovim (Latest Stable)
# ----------------------------------------------------------------------
if ! command -v nvim &>/dev/null; then
    echo "📝 Installing Neovim..."

    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim-linux-x86_64
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

    # Add to PATH (updating the folder name)
    export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
    if ! grep -q "/opt/nvim-linux-x86_64/bin" "$HOME/.bashrc"; then
        echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >>"$HOME/.bashrc"
    fi

    rm nvim-linux-x86_64.tar.gz
fi

# 5.1 Install Latest Golang
# ----------------------------------------------------------------------
if ! command -v go &>/dev/null; then
    echo "🐹 Installing Latest Golang..."
    # Scrape the official website for the latest version tag (e.g., go1.24.0)
    GO_VERSION=$(curl -sL https://go.dev/dl/ | grep -oP 'go[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)

    # Download and extract to /usr/local
    wget "https://dl.google.com/go/${GO_VERSION}.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "${GO_VERSION}.linux-amd64.tar.gz"
    rm "${GO_VERSION}.linux-amd64.tar.gz"
    rm -rf "${HOME}/go"

    # Add to PATH temporarily for this script
    export PATH="$PATH:/usr/local/go/bin"

    # NOTE: Your zsh/.zshrc already has /usr/local/go/bin in the PATH, so it will work on reboot!
fi

# 6. Clone & Unlock
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

# 7. Stow
# ----------------------------------------------------------------------
echo "🔗 Stowing..."

# Backup conflicts
for file in ".bashrc" ".zshrc" ".config/nvim" ".config/tmux"; do
    if [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
        mv "$HOME/$file" "$HOME/$file.bak"
    fi
done

stow bash zsh nvim tmux starship git gh ssh

# 7.5 Install Zoxide (Latest via Script)
# ----------------------------------------------------------------------
if ! command -v zoxide &>/dev/null; then
    echo "📂 Installing Zoxide..."
    curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

    # FIX: Move Zoxide to a globally accessible path
    sudo mv ~/.local/bin/zoxide /usr/local/bin/
fi

# 8. Final Polish
# ----------------------------------------------------------------------
if ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh)
fi

chmod 600 "$HOME/.ssh/id_ed25519" 2>/dev/null || true

# FIX 3: Added clear instructions instead of forcing a shell change
echo "🎉 All Systems Go!"
echo "👉 Please restart your terminal or run 'zsh' to load your new environment."
