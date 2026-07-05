#!/usr/bin/env bash
# ============================================================
# Hyprland Dotfiles — Bootstrap Installer
# ============================================================
# This script will:
#   1. Install required packages (official + AUR)
#   2. Symlink config files to ~/.config/
#   3. Symlink scripts to ~/.local/bin/
#   4. Set up wallpaper pipeline
#   5. Enable necessary systemd user services
#
# Usage:
#   ./install.sh              # interactive (asks before each step)
#   ./install.sh --yes        # non-interactive, full auto
# ============================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
AUTOYES=false

# ---------------------------------------
# Parse flags
# ---------------------------------------
for arg in "$@"; do
    case "$arg" in
        --yes|-y) AUTOYES=true ;;
    esac
done

# ---------------------------------------
# Colors for output
# ---------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

# ---------------------------------------
# Step 0: Detect OS
# ---------------------------------------
info "Detecting system..."
if ! command -v pacman &>/dev/null; then
    err "This installer is for Arch Linux only (pacman not found)."
    exit 1
fi
ok "Arch Linux detected."

# ---------------------------------------
# Step 1: Install official packages
# ---------------------------------------
echo ""
info "Step 1/4 — Installing official packages..."
if confirm "Install required packages via pacman?"; then
    sudo pacman -S --needed --noconfirm - < "$REPO_DIR/packages.txt"
    ok "Official packages installed."
else
    warn "Skipping package installation."
fi

# ---------------------------------------
# Step 2: Install AUR packages
# ---------------------------------------
echo ""
info "Step 2/4 — Installing AUR packages..."

# Detect AUR helper
AUR_HELPER=""
for helper in yay paru; do
    if command -v "$helper" &>/dev/null; then
        AUR_HELPER="$helper"
        break
    fi
done

if [ -z "$AUR_HELPER" ]; then
    warn "No AUR helper found (yay/paru). Installing yay first..."
    if confirm "Install yay (AUR helper)?"; then
        sudo pacman -S --needed --noconfirm git base-devel
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
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
        $AUR_HELPER -S --needed --noconfirm - < "$REPO_DIR/packages-aur.txt"
        ok "AUR packages installed."
    else
        warn "Skipping AUR package installation."
    fi
fi

# ---------------------------------------
# Step 3: Symlink config files
# ---------------------------------------
echo ""
info "Step 3/4 — Symlinking config files..."

link_config() {
    local src="$REPO_DIR/config/$1"
    local dst="$HOME/.config/$1"
    if [ ! -e "$src" ]; then
        warn "Source not found: $src — skipping"
        return
    fi
    # Remove existing file/link if present
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
    # Config dirs
    for dir in hypr wlogout waybar rofi cava gtk-3.0 gtk-4.0 qt5ct qt6ct \
               matugen waypaper kitty ghostty btop swaync nvim fastfetch autostart pipewire; do
        link_config "$dir"
    done
    # Individual config files
    link_config "starship.toml"

    # Home dotfiles
    link_home ".zshrc"
    link_home ".bashrc"

    # Scripts
    mkdir -p "$HOME/.local/bin"
    for script in "$REPO_DIR"/bin/*; do
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

# ---------------------------------------
# Step 4: Post-install setup
# ---------------------------------------
echo ""
info "Step 4/4 — Post-install setup..."

# Create wallpaper cache dir
mkdir -p /tmp/wlogout

# Enable user services
if confirm "Enable and start polkit agent & hypridle user services?"; then
    systemctl --user enable --now hyprpolkitagent 2>/dev/null || true
    systemctl --user enable --now hypridle 2>/dev/null || true
    ok "User services enabled."
fi

# Set wallpaper if current-wallpaper exists
if [ -f "$HOME/.cache/current-wallpaper" ]; then
    if confirm "Restore last wallpaper?"; then
        "$HOME/.local/bin/restore-wallpaper" 2>/dev/null || true
        ok "Wallpaper restored."
    fi
fi

# Remind about zsh
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo ""
    warn "Your current shell is $SHELL."
    warn "To set zsh as default:  chsh -s /usr/bin/zsh"
fi

# ---------------------------------------
# Done
# ---------------------------------------
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Hyprland dotfiles installed successfully! ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "  Next steps:"
echo "    1. Log out and back in (or reboot)"
echo "    2. Select 'Hyprland' from your display manager"
echo "    3. Once in Hyprland, run:  matugen-apply-colors /path/to/wallpaper"
echo ""
echo "  Keybinds:"
echo "    Super + Return       → Terminal"
echo "    Super + D            → App launcher (rofi)"
echo "    Super + L            → Lock screen (hyprlock)"
echo "    Super + Shift + L    → Logout menu (wlogout)"
echo "    Super + Q            → Close window"
echo ""
