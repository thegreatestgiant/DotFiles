#!/bin/bash
set -e

# ----------------------------------------------------------------------
# ⚡️ Dotfiles Bootstrap Script (Dynamic Edition)
# ----------------------------------------------------------------------

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
    ln -s $(which fdfind) ~/.local/bin/fd
fi

# 3. Install Vivid (Latest from GitHub)
# ----------------------------------------------------------------------
if ! command -v vivid &>/dev/null; then
    echo "🎨 Installing Vivid (Latest)..."
    # Fetch latest tag name
    VIVID_TAG=$(curl -s "https://api.github.com/repos/sharkdp/vivid/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    # Download
    wget "https://github.com/sharkdp/vivid/releases/download/${VIVID_TAG}/vivid_${VIVID_TAG}_amd64.deb"
    sudo dpkg -i "vivid_${VIVID_TAG}_amd64.deb"
    rm "vivid_${VIVID_TAG}_amd64.deb"
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
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf nvim-linux64.tar.gz

    export PATH="$PATH:/opt/nvim-linux64/bin"
    if ! grep -q "/opt/nvim-linux64/bin" "$HOME/.bashrc"; then
        echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >>"$HOME/.bashrc"
    fi
    rm nvim-linux64.tar.gz
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

# Check if ignore file exists
if [ ! -f ".stow-local-ignore" ]; then
    echo "⚠️  WARNING: .stow-local-ignore not found!"
    echo "    Please create it to avoid stowing README/git files."
    exit 1
fi

# Backup conflicts
for file in ".bashrc" ".zshrc" ".config/nvim" ".config/tmux"; do
    if [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
        mv "$HOME/$file" "$HOME/$file.bak"
    fi
done

stow bash zsh nvim tmux starship git gh

# 8. Final Polish
# ----------------------------------------------------------------------
if ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh)
fi

echo "🎉 All Systems Go!"
