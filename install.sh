#!/usr/bin/env bash
# ============================================================
# Hyprland Dotfiles — Bootstrap Installer
# ============================================================
# This script will:
#   1. Prompt the user to choose an installer (ML4W, End-4, Matrix-Node)
#   2. Install required packages safely (official + AUR)
#   3. Symlink config files and scripts
#   4. Enable necessary systemd user services
#   5. Handle fallbacks gracefully
# ============================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
AUTOYES=false

for arg in "$@"; do
    case "$arg" in
        --yes|-y) AUTOYES=true ;;
    esac
done

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
err()   { echo -e "${RED}[ERR]${NC}   $*"; }

confirm() {
    if $AUTOYES; then return 0; fi
    echo -en "${YELLOW}?${NC} $* [Y/n] "
    read -r resp
    [[ -z "$resp" || "$resp" =~ ^[Yy] ]]
}

info "Detecting system..."
if ! command -v pacman &>/dev/null; then
    err "This installer is for Arch Linux only (pacman not found)."
    exit 1
fi
ok "Arch Linux detected."

echo ""
echo -e "${CYAN}Please select the dotfiles profile you want to install:${NC}"
echo "  1) ML4W (MyLinuxForWork) Dotfiles"
echo "  2) End-4 (dots-hyprland) Dotfiles"
echo "  3) Matrix-Node Dotfiles (Current folder fallback)"
echo ""
if $AUTOYES; then
    CHOICE=3
else
    read -p "Enter choice [1-3] (Default: 3): " CHOICE
    CHOICE=${CHOICE:-3}
fi

install_ml4w() {
    info "Installing ML4W Dotfiles..."
    if ! command -v git &>/dev/null || ! command -v make &>/dev/null; then
        sudo pacman -Sy --needed --noconfirm git make || return 1
    fi
    rm -rf ~/.local/share/ml4w-dotfiles-installer
    git clone https://github.com/mylinuxforwork/ml4w-dotfiles-installer.git ~/.local/share/ml4w-dotfiles-installer || return 1
    cd ~/.local/share/ml4w-dotfiles-installer
    make install || return 1
    if command -v ml4w-dotfiles-installer &>/dev/null; then
        ml4w-dotfiles-installer
    elif [ -f "$HOME/.local/bin/ml4w-dotfiles-installer" ]; then
        "$HOME/.local/bin/ml4w-dotfiles-installer"
    else
        err "ml4w-dotfiles-installer executable not found."
        return 1
    fi
    return 0
}

install_end4() {
    info "Installing End-4 Dotfiles..."
    if ! command -v git &>/dev/null; then
        sudo pacman -Sy --needed --noconfirm git || return 1
    fi
    rm -rf ~/dots-hyprland
    git clone https://github.com/end-4/dots-hyprland ~/dots-hyprland || return 1
    cd ~/dots-hyprland
    if [ -f "./setup" ]; then
        ./setup install
    elif [ -f "./install.sh" ]; then
        ./install.sh
    else
        err "Installer script not found for end-4"
        return 1
    fi
    return 0
}

install_matrix_node() {
    cd "$REPO_DIR"
    echo ""
    info "Step 1/4 — Installing official packages..."
    if confirm "Install required packages via pacman?"; then
        for pkg in $(grep -v "^#" "$REPO_DIR/packages.txt" | grep -v "^$"); do
            sudo pacman -S --needed --noconfirm "$pkg" || warn "Failed to install official package: $pkg"
        done
        ok "Official packages installed."
    else
        warn "Skipping package installation."
    fi

    echo ""
    info "Step 2/4 — Installing AUR packages..."
    AUR_HELPER=""
    for helper in yay paru; do
        if command -v "$helper" &>/dev/null; then
            AUR_HELPER="$helper"
            break
        fi
    done

    if [ -z "$AUR_HELPER" ]; then
        warn "No AUR helper found. Installing yay..."
        if confirm "Install yay (AUR helper)?"; then
            sudo pacman -Sy --needed --noconfirm git base-devel
            rm -rf /tmp/yay
            git clone https://aur.archlinux.org/yay.git /tmp/yay
            cd /tmp/yay
            makepkg -si --noconfirm
            cd "$REPO_DIR"
            AUR_HELPER="yay"
            ok "yay installed."
        else
            warn "Skipping AUR packages (no AUR helper)."
        fi
    fi

    if [ -n "$AUR_HELPER" ]; then
        if confirm "Install AUR packages via $AUR_HELPER?"; then
            for pkg in $(grep -v "^#" "$REPO_DIR/packages-aur.txt" | grep -v "^$"); do
                $AUR_HELPER -S --needed --noconfirm "$pkg" || warn "Failed to install AUR package: $pkg"
            done
            ok "AUR packages installed."
        else
            warn "Skipping AUR package installation."
        fi
    fi

    echo ""
    info "Step 3/4 — Symlinking config files..."
    link_config() {
        local src="$REPO_DIR/config/$1"
        local dst="$HOME/.config/$1"
        if [ ! -e "$src" ]; then
            warn "Source not found: $src — skipping"
            return
        fi
        if [ -L "$dst" ] || [ -f "$dst" ] || [ -d "$dst" ]; then
            rm -rf "$dst"
        fi
        mkdir -p "$(dirname "$dst")"
        ln -sf "$src" "$dst"
        ok "Linked  $dst  →  $src"
    }

    link_home() {
        local src="$REPO_DIR/home/$1"
        local dst="$HOME/$1"
        if [ ! -e "$src" ]; then
            warn "Source not found: $src — skipping"
            return
        fi
        if [ -L "$dst" ] || [ -f "$dst" ]; then
            rm -f "$dst"
        fi
        ln -sf "$src" "$dst"
        ok "Linked  $dst  →  $src"
    }

    if confirm "Symlink all config files? (existing files will be replaced)"; then
        for dir in hypr wlogout waybar rofi cava gtk-3.0 gtk-4.0 qt5ct qt6ct \
                   matugen waypaper kitty ghostty btop swaync nvim fastfetch autostart pipewire; do
            link_config "$dir"
        done
        link_config "starship.toml"
        link_home ".zshrc"
        link_home ".bashrc"

        mkdir -p "$HOME/.local/bin"
        for script in "$REPO_DIR"/bin/*; do
            [ -e "$script" ] || continue
            local_script="$HOME/.local/bin/$(basename "$script")"
            if [ -L "$local_script" ] || [ -f "$local_script" ]; then
                rm -f "$local_script"
            fi
            ln -sf "$script" "$local_script"
            chmod +x "$local_script"
            ok "Linked  $local_script"
        done
        ok "All config files linked."
    else
        warn "Skipping symlinks."
    fi

    echo ""
    info "Step 4/4 — Post-install setup..."
    mkdir -p /tmp/wlogout

    if confirm "Enable and start polkit agent & hypridle user services?"; then
        systemctl --user daemon-reload || true
        systemctl --user enable --now hyprpolkitagent.service 2>/dev/null || true
        systemctl --user enable --now hypridle.service 2>/dev/null || true
        ok "User services enabled."
    fi

    if [ -f "$HOME/.cache/current-wallpaper" ]; then
        if confirm "Restore last wallpaper?"; then
            "$HOME/.local/bin/restore-wallpaper" 2>/dev/null || true
            ok "Wallpaper restored."
        fi
    fi

    if [ "$SHELL" != "/usr/bin/zsh" ]; then
        echo ""
        warn "Your current shell is $SHELL."
        warn "To set zsh as default:  chsh -s /usr/bin/zsh"
    fi

    echo ""
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}  Matrix-Node dotfiles installed successfully! ${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo ""
    echo "  Next steps:"
    echo "    1. Log out and back in (or reboot)"
    echo "    2. Select 'Hyprland' from your display manager"
    echo "    3. Once in Hyprland, run:  matugen-apply-colors /path/to/wallpaper"
    echo ""
}

case "$CHOICE" in
    1)
        if ! install_ml4w; then
            err "ML4W installation failed."
            if confirm "Fallback to Matrix-Node dotfiles?"; then
                install_matrix_node
            fi
        fi
        ;;
    2)
        if ! install_end4; then
            err "End-4 installation failed."
            if confirm "Fallback to Matrix-Node dotfiles?"; then
                install_matrix_node
            fi
        fi
        ;;
    3|*)
        install_matrix_node
        ;;
esac
