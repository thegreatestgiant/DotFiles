#!/bin/bash
set -e

# ----------------------------------------------------------------------
# ⚡ Dotfiles Bootstrap Script (CachyOS/Arch Edition)
# ----------------------------------------------------------------------
export TZ="America/New_York"

DOTFILES_DIR="$HOME/.files"
KEY_PATH="$HOME/dotfiles_key.key"

echo "🚀 Starting System Bootstrap..."

# 1. Install yay (AUR helper) if not present
# ----------------------------------------------------------------------
if ! command -v yay &>/dev/null; then
    echo "📦 Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd ~
fi

# 2. Install Packages
# ----------------------------------------------------------------------
echo "📦 Installing system packages..."
sudo pacman -S --needed --noconfirm \
    git stow zsh base-devel unzip \
    ripgrep fd xclip python \
    nodejs npm eza \
    fzf lazygit neovim go \
    zoxide starship kitty \
    tmux git-crypt \
    jdk-openjdk jdk21-openjdk maven \
    rbw pinentry 

# AUR packages (vivid not in main repos)
yay -S --needed --noconfirm vivid

# 3. Unlock git-crypt secrets if key exists
# ----------------------------------------------------------------------
cd "$DOTFILES_DIR"

if [ -d ".git-crypt" ] && [ -f "$KEY_PATH" ]; then
    echo "🔐 Unlocking secrets..."
    git-crypt unlock "$KEY_PATH"
fi

# 4. Stow
# ----------------------------------------------------------------------
echo "🔗 Stowing..."

# Backup any existing non-symlink configs
for file in ".bashrc" ".zshrc" ".config/nvim" ".config/tmux" ".config/hypr" ".config/kitty" ".config/starship.toml"; do
    if [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
        echo "  Backing up $file → $file.bak"
        mv "$HOME/$file" "$HOME/$file.bak"
    fi
done

stow bash zsh nvim tmux starship git ssh hypr kitty rclone

# Install systemd user services
echo "⚙️ Installing systemd user services..."
mkdir -p "$HOME/.config/systemd/user/"
find . -maxdepth 1 -name "*.service" -exec cp {} "$HOME/.config/systemd/user/" \;
systemctl --user daemon-reload 2>/dev/null || true

# 5. Set default shell to zsh
# ----------------------------------------------------------------------
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
fi

echo ""
echo "🎉 All Systems Go!"
echo "👉 Restart your terminal or run 'zsh' to load your new environment."
