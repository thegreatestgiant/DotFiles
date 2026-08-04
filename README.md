# ⚡️ Dotfiles (Unified Edition)

> My cross-platform development environment for **Arch Linux** and **Ubuntu**, managed with **GNU Stow**, encrypted with **Git-Crypt**, and componentized with **Submodules**.

[![Arch Linux](https://img.shields.io/badge/OS-Arch_Linux-1793D1?style=flat&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Ubuntu](https://img.shields.io/badge/OS-Ubuntu-E95420?style=flat&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
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

### 🔐 Security (Git-Crypt)

We use symmetric encryption for sensitive configuration.

* **Protected Files:** `.gitattributes` defines the filter (e.g., `gh` tokens).
* **Key Management:** The binary key is stored offline (Password Manager/USB).
* **Warning:** Do NOT `git add` secret files unless `git-crypt status` confirms they are encrypted.

## 🚀 Installation

### Option A: Interactive Setup (Full Install)

This method uses an interactive script powered by **Gum** to handle OS detection, package installation, decryption, and stowing. It officially supports **Arch Linux** and **Ubuntu/Debian**.

#### 1. Clone & Run

```bash
git clone --recurse-submodules https://github.com/thegreatestgiant/dotfiles.git ~/.files
cd ~/.files
chmod +x setup.sh
./setup.sh 
```

#### 2. Follow the Interactive Prompts

The script will automatically:
1. Detect your OS and install the necessary dependencies (via `pacman`/`yay` or `apt`).
2. Unlock your secrets (ensure `dotfiles_key.key` is present in `~/` or `~/Downloads/`).
3. Present an interactive menu to select exactly which components you want to stow.

*Note: If you have existing configuration files, the script will automatically back them up with a `.bak` extension before applying the new symlinks.*

### Option B: Manual Setup (Minimal/Server)

If you're on a server or just want a minimal terminal environment without the heavy GUI dependencies (like Hyprland), you can bypass the setup script.

#### 1. Clone

```bash
git clone --recurse-submodules https://github.com/thegreatestgiant/dotfiles.git ~/.files
cd ~/.files
```

#### 2. Unlock Secrets (Optional)

If you need access to your encrypted files (like your SSH config), unlock them now:

```bash
git-crypt unlock /path/to/your/dotfiles_key.key
```

#### 3. Manually Stow Components

Simply use GNU Stow for the specific packages you want:

```bash
# Example: Only stow terminal essentials
stow bash zsh nvim tmux starship
```
