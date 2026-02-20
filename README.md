# ⚡️ Dotfiles

> My personal development environment, managed with **GNU Stow**,
> encrypted with **Git-Crypt**, and componentized with **Submodules**.

[![Gitmoji](https://img.shields.io/badge/gitmoji-%20😜%20😍-FFDD67.svg)](https://gitmoji.dev)

## 🏗 Architecture

This repository is hidden in `~/.files` to keep the home directory clean.
Stow generates symlinks relative to the parent (`~`).

### 📦 Components

| 🔧 Tool | 📂 Path | 📝 Description |
| :--- | :--- | :--- |
| **Neovim** | `.config/nvim` | Submodule pointing to my [Nvim Config](https://github.com/thegreatestgiant/NeoVim-Config) |
| **Tmux** | `.config/tmux` | Terminal multiplexer with TPM submodule |
| **Zsh** | `.zshrc` | Shell configuration |
| **Bash** | `.bashrc` | Shell configuration fallback |
| **Starship** | `.config/starship.toml` | Cross-shell prompt |
| **Hyprland** | `.config/hypr` | Window Manager, Waybar, Wlogout, & SwayNC config |
| **Kitty** | `.config/kitty` | Terminal emulator configuration |
| **Git** | `.gitconfig` | Version control settings |
| **SSH** | `.ssh/config` | SSH Config (Encrypted) |
| **GitHub** | `.config/gh` | REMOVED GH CLI config (Encrypted) REMOVED |

### 🔐 Security (Git-Crypt)

We use symmetric encryption for sensitive configuration.

* **Protected Files:** `.gitattributes` defines the filter (e.g., `gh` tokens).
* **Key Management:** The binary key is stored offline (Password Manager/USB).
* **Warning:** Do NOT `git add` secret files unless `git-crypt status` confirms they are encrypted.

## 🚀 Installation

### Option A: Automatic (Recommended)

This repo includes a `setup.sh` script that installs dependencies (Nvim, Zsh, FZF, etc.), handles encryption keys, and stows your config.

#### 1. **Clone & Run:**

```bash
git clone --recurse-submodules https://github.com/thegreatestgiant/dotfiles.git ~/.files
cd ~/.files
chmod +x setup.sh
./setup.sh 
```

#### 2. **Unlock Secrets**

Ensure you have your dotfiles_key.key in your home folder or Downloads, and the script will automatically unlock it.

### Option B: Manual

#### 1. Clone

```bash
git clone --recurse-submodules https://github.com/thegreatestgiant/dotfiles.git ~/.files
cd ~/.files
```

#### 2. Unlock Secrets

Place your dotfiles_key.key in a secure location (e.g. ~/Downloads/) and run:

```Bash
git-crypt unlock ~/Downloads/dotfiles_key.key
```

#### 3. Stow Packages

Use Stow to link your packages:

stow bash zsh nvim tmux starship git ssh

# Desktop only — uncomment on machines with Hyprland
# NOTE: wallust-generated files (colors-rofi.rasi, colors-waybar.css,
#       wallust-hyprland.conf etc.) won't exist until first wallpaper change.
#       This is expected — they are gitignored on purpose.
# NOTE: if ~/Pictures/wallpapers is a symlink, WallpaperSelect.sh requires
#       find -L to resolve it — see WallpaperSelect.sh line ~115.
# stow hypr kitty rclone
