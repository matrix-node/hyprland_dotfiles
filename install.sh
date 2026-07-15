#!/usr/bin/env bash
# ============================================================
#  Matrix — Hyprland Dotfiles Installer
# ============================================================
#  Public-ready Arch Linux + Hyprland setup.
#  A single package failure never aborts the whole install.
# ============================================================

# Intentionally NOT using `set -e` — resilience over pedantry.
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${REPO_DIR}/.install-logs"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="${LOG_DIR}/install-${TIMESTAMP}.log"
SUDO_KEEPALIVE_PID=""

AUTOYES=false
SKIP_PACKAGES=false
SKIP_AUR=false
SKIP_WALLPAPER=false
DRY_RUN=false
WALLPAPER_ARG=""
COPY_MODE=false   # false = symlink configs (default), true = copy

FAILED_PKGS=()
SKIPPED_PKGS=()
INSTALLED_PKGS=()
WARNINGS=()

# ---------- colors ----------
if [[ -t 1 ]]; then
    RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'
    CYAN=$'\033[0;36m'; BOLD=$'\033[1m'; DIM=$'\033[2m'; NC=$'\033[0m'
else
    RED=""; GREEN=""; YELLOW=""; CYAN=""; BOLD=""; DIM=""; NC=""
fi

info()  { echo -e "${CYAN}[INFO]${NC}  $*" | tee -a "$LOG_FILE"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*" | tee -a "$LOG_FILE"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*" | tee -a "$LOG_FILE"; WARNINGS+=("$*"); }
err()   { echo -e "${RED}[ERR]${NC}   $*" | tee -a "$LOG_FILE"; }
step()  { echo -e "\n${BOLD}${CYAN}==>${NC}${BOLD} $*${NC}" | tee -a "$LOG_FILE"; }
dim()   { echo -e "${DIM}$*${NC}" | tee -a "$LOG_FILE"; }

cleanup() {
    if [[ -n "${SUDO_KEEPALIVE_PID:-}" ]]; then
        kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    fi
}
trap cleanup EXIT

# ---------- helpers ----------
usage() {
    cat <<EOF
${BOLD}Matrix Hyprland Dotfiles Installer${NC}

Usage: ./install.sh [options]

Options:
  -y, --yes              Non-interactive (accept defaults)
  --wallpaper PATH       Wallpaper to apply (name under wallpapers/ or absolute path)
  --no-packages          Skip pacman package installation
  --no-aur               Skip AUR packages
  --no-wallpaper         Skip wallpaper setup
  --copy                 Copy configs instead of symlinking
  --dry-run              Show what would happen, change nothing
  -h, --help             Show this help

Examples:
  ./install.sh
  ./install.sh --yes
  ./install.sh --yes --wallpaper nordwall3.jpg
  ./install.sh --yes --no-aur --wallpaper default.jpg
EOF
}

confirm() {
    local prompt="$1"
    local default="${2:-Y}"
    if $AUTOYES; then return 0; fi
    local hint="[Y/n]"
    [[ "$default" =~ ^[Nn] ]] && hint="[y/N]"
    echo -en "${YELLOW}?${NC} ${prompt} ${hint} "
    read -r resp || resp=""
    if [[ -z "$resp" ]]; then
        [[ "$default" =~ ^[Yy] ]]
        return
    fi
    [[ "$resp" =~ ^[Yy] ]]
}

have() { command -v "$1" &>/dev/null; }

is_installed() {
    pacman -Q "$1" &>/dev/null
}

pkg_in_repos() {
    # True if package exists in official sync DBs (or is already installed)
    local pkg="$1"
    is_installed "$pkg" && return 0
    pacman -Si "$pkg" &>/dev/null
}

ensure_log() {
    mkdir -p "$LOG_DIR" 2>/dev/null || true
    : >> "$LOG_FILE" 2>/dev/null || LOG_FILE="/tmp/matrix-install-${TIMESTAMP}.log"
    : >> "$LOG_FILE"
}

# ---------- parse args ----------
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -y|--yes) AUTOYES=true; shift ;;
            --wallpaper)
                if [[ $# -lt 2 || "$2" == -* ]]; then
                    err "--wallpaper requires a path/name"
                    exit 1
                fi
                WALLPAPER_ARG="$2"
                shift 2
                ;;
            --no-packages) SKIP_PACKAGES=true; shift ;;
            --no-aur) SKIP_AUR=true; shift ;;
            --no-wallpaper) SKIP_WALLPAPER=true; shift ;;
            --copy) COPY_MODE=true; shift ;;
            --dry-run) DRY_RUN=true; shift ;;
            -h|--help) usage; exit 0 ;;
            *) err "Unknown option: $1"; usage; exit 1 ;;
        esac
    done
}

# ---------- banner ----------
banner() {
    cat <<'EOF'

    ███╗   ███╗ █████╗ ████████╗██████╗ ██╗██╗  ██╗
    ████╗ ████║██╔══██╗╚══██╔══╝██╔══██╗██║╚██╗██╔╝
    ██╔████╔██║███████║   ██║   ██████╔╝██║ ╚███╔╝
    ██║╚██╔╝██║██╔══██║   ██║   ██╔══██╗██║ ██╔██╗
    ██║ ╚═╝ ██║██║  ██║   ██║   ██║  ██║██║██╔╝ ██╗
    ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝
           Hyprland Dotfiles Installer
EOF
    echo -e "  ${DIM}Repo: ${REPO_DIR}${NC}"
    echo -e "  ${DIM}Log:  ${LOG_FILE}${NC}"
    echo ""
}

# ---------- system checks ----------
check_system() {
    step "System checks"

    if [[ "$(id -u)" -eq 0 ]]; then
        err "Do not run this installer as root. Run as your normal user (sudo is used when needed)."
        exit 1
    fi

    if ! have pacman; then
        err "This installer targets Arch Linux (pacman not found)."
        err "On other distros: install packages from packages.txt manually, then re-run with --no-packages --no-aur"
        exit 1
    fi
    ok "Arch Linux (pacman) detected"

    if ! have sudo; then
        err "sudo is required."
        exit 1
    fi

    if ! $DRY_RUN; then
        if ! sudo -v; then
            err "sudo authentication failed."
            exit 1
        fi
        ( while true; do sudo -n true; sleep 50; done ) 2>/dev/null &
        SUDO_KEEPALIVE_PID=$!
    fi

    if ! have git; then
        warn "git not found — installing base tools..."
        $DRY_RUN || sudo pacman -Sy --needed --noconfirm git base-devel 2>&1 | tee -a "$LOG_FILE" || true
    fi

    # Useful XDG dirs so bookmarks / screenshots never point nowhere
    mkdir -p \
        "$HOME/Downloads" "$HOME/Documents" "$HOME/Pictures" \
        "$HOME/Pictures/Screenshots" "$HOME/Pictures/Wallpapers" \
        "$HOME/Music" "$HOME/Videos" \
        "$HOME/.local/bin" "$HOME/.cache" \
        2>/dev/null || true

    ok "System checks passed"
}

# ---------- package helpers ----------
read_pkg_list() {
    local file="$1"
    [[ -f "$file" ]] || return 0
    grep -vE '^\s*(#|$)' "$file" | sed 's/\s*#.*//' | tr -d '\r' | awk 'NF'
}

install_pacman_pkg() {
    local pkg="$1"
    if is_installed "$pkg"; then
        dim "  already installed: $pkg"
        INSTALLED_PKGS+=("$pkg")
        return 0
    fi
    if $DRY_RUN; then
        info "  [dry-run] would install: $pkg"
        return 0
    fi
    if ! pkg_in_repos "$pkg"; then
        warn "  not found in repos (skipped): $pkg"
        SKIPPED_PKGS+=("$pkg")
        return 1
    fi
    if sudo pacman -S --needed --noconfirm "$pkg" >>"$LOG_FILE" 2>&1; then
        ok "  installed: $pkg"
        INSTALLED_PKGS+=("$pkg")
        return 0
    fi
    warn "  failed (pacman): $pkg — continuing"
    FAILED_PKGS+=("$pkg")
    return 1
}

install_aur_pkg() {
    local pkg="$1"
    local helper="$2"
    if is_installed "$pkg"; then
        dim "  already installed: $pkg"
        INSTALLED_PKGS+=("$pkg")
        return 0
    fi
    if $DRY_RUN; then
        info "  [dry-run] would install (AUR): $pkg"
        return 0
    fi
    if "$helper" -S --needed --noconfirm "$pkg" >>"$LOG_FILE" 2>&1; then
        ok "  installed (AUR): $pkg"
        INSTALLED_PKGS+=("$pkg")
        return 0
    fi
    # Fallback: package may have migrated to official repos
    if sudo pacman -S --needed --noconfirm "$pkg" >>"$LOG_FILE" 2>&1; then
        ok "  installed (official fallback): $pkg"
        INSTALLED_PKGS+=("$pkg")
        return 0
    fi
    warn "  failed (AUR): $pkg — continuing (optional component)"
    FAILED_PKGS+=("$pkg")
    return 1
}

batch_install_pacman() {
    local file="$1"
    local label="$2"
    step "$label"

    local pkgs=()
    mapfile -t pkgs < <(read_pkg_list "$file")
    if [[ ${#pkgs[@]} -eq 0 ]]; then
        warn "No packages listed in $(basename "$file")"
        return 0
    fi

    local missing=()
    local unknown=()
    for pkg in "${pkgs[@]}"; do
        if is_installed "$pkg"; then
            dim "  already installed: $pkg"
            INSTALLED_PKGS+=("$pkg")
        elif pkg_in_repos "$pkg"; then
            missing+=("$pkg")
        else
            warn "  unknown package (will skip): $pkg"
            unknown+=("$pkg")
            SKIPPED_PKGS+=("$pkg")
        fi
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        ok "All known packages already installed"
        return 0
    fi

    info "Installing ${#missing[@]} package(s)..."
    if $DRY_RUN; then
        for p in "${missing[@]}"; do info "  [dry-run] $p"; done
        return 0
    fi

    # Sync DB once
    if ! sudo pacman -Sy --noconfirm >>"$LOG_FILE" 2>&1; then
        warn "pacman -Sy had issues (continuing with existing DBs)"
    fi

    # Fast path: bulk install
    if sudo pacman -S --needed --noconfirm "${missing[@]}" >>"$LOG_FILE" 2>&1; then
        for p in "${missing[@]}"; do
            INSTALLED_PKGS+=("$p")
        done
        ok "Bulk install succeeded (${#missing[@]} packages)"
        return 0
    fi

    warn "Bulk install had failures — retrying package-by-package (safe mode)"
    for p in "${missing[@]}"; do
        install_pacman_pkg "$p" || true
    done
}

ensure_aur_helper() {
    # Sets global AUR_HELPER; returns 0 if available.
    AUR_HELPER=""
    for h in yay paru; do
        if have "$h"; then
            AUR_HELPER="$h"
            ok "AUR helper: $AUR_HELPER"
            return 0
        fi
    done

    warn "No AUR helper found"
    if ! confirm "Install yay (AUR helper)?" "Y"; then
        warn "Skipping AUR packages"
        return 1
    fi

    if $DRY_RUN; then
        info "[dry-run] would install yay"
        AUR_HELPER="yay"
        return 0
    fi

    sudo pacman -S --needed --noconfirm git base-devel >>"$LOG_FILE" 2>&1 || true
    local tmp
    tmp="$(mktemp -d)"
    local ok_clone=false
    if git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin" >>"$LOG_FILE" 2>&1; then
        ok_clone=true
        (
            cd "$tmp/yay-bin" || exit 1
            makepkg -si --noconfirm
        ) >>"$LOG_FILE" 2>&1 || true
    elif git clone --depth 1 https://aur.archlinux.org/yay.git "$tmp/yay" >>"$LOG_FILE" 2>&1; then
        ok_clone=true
        (
            cd "$tmp/yay" || exit 1
            makepkg -si --noconfirm
        ) >>"$LOG_FILE" 2>&1 || true
    fi
    rm -rf "$tmp"
    $ok_clone || warn "Could not clone yay from AUR"

    if have yay; then
        AUR_HELPER="yay"
        ok "yay installed"
        return 0
    fi
    warn "Could not install yay — AUR packages will be skipped"
    return 1
}

install_aur_list() {
    local file="$1"
    local label="$2"
    step "$label"

    AUR_HELPER=""
    ensure_aur_helper || true
    local helper="${AUR_HELPER:-}"

    if [[ -z "$helper" ]]; then
        warn "No AUR helper — skipping $(basename "$file")"
        while IFS= read -r p; do SKIPPED_PKGS+=("$p"); done < <(read_pkg_list "$file")
        return 0
    fi
    ok "Using AUR helper: $helper"

    local pkgs=()
    mapfile -t pkgs < <(read_pkg_list "$file")
    if [[ ${#pkgs[@]} -eq 0 ]]; then
        warn "No AUR packages listed"
        return 0
    fi

    local missing=()
    for pkg in "${pkgs[@]}"; do
        if is_installed "$pkg"; then
            dim "  already installed: $pkg"
            INSTALLED_PKGS+=("$pkg")
        else
            missing+=("$pkg")
        fi
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        ok "All AUR packages already installed"
        return 0
    fi

    if $DRY_RUN; then
        for p in "${missing[@]}"; do info "  [dry-run] AUR $p"; done
        return 0
    fi

    # Fast path: bulk AUR install
    info "Installing ${#missing[@]} AUR package(s)..."
    if "$helper" -S --needed --noconfirm "${missing[@]}" >>"$LOG_FILE" 2>&1; then
        for p in "${missing[@]}"; do INSTALLED_PKGS+=("$p"); done
        ok "Bulk AUR install succeeded"
        return 0
    fi

    warn "Bulk AUR install had failures — retrying package-by-package"
    for p in "${missing[@]}"; do
        install_aur_pkg "$p" "$helper" || true
    done
}

# ---------- config deploy ----------
backup_path() {
    local path="$1"
    if [[ -e "$path" || -L "$path" ]]; then
        # Already points at our repo? leave it (symlink update is fine)
        if [[ -L "$path" ]]; then
            local target
            target="$(readlink -f "$path" 2>/dev/null || true)"
            if [[ -n "$target" && "$target" == "$REPO_DIR"* ]]; then
                return 0
            fi
        fi
        local bak="${path}.bak.${TIMESTAMP}"
        if $DRY_RUN; then
            info "  [dry-run] backup $path → $bak"
            return 0
        fi
        mv "$path" "$bak" 2>/dev/null || {
            warn "  could not backup $path — trying overwrite"
            rm -rf "$path" 2>/dev/null || true
        }
        dim "  backed up → $bak"
    fi
}

deploy_link_or_copy() {
    local src="$1"
    local dst="$2"
    local mode="${3:-link}"

    if [[ ! -e "$src" ]]; then
        warn "Source missing, skip: $src"
        return 0
    fi

    if $DRY_RUN; then
        info "  [dry-run] $mode $dst ← $src"
        return 0
    fi

    mkdir -p "$(dirname "$dst")"
    backup_path "$dst"

    case "$mode" in
        copy|copy-subst)
            if [[ -d "$src" ]]; then
                mkdir -p "$dst"
                cp -a "$src"/. "$dst"/
            else
                cp -a "$src" "$dst"
            fi
            if [[ "$mode" == "copy-subst" && -f "$dst" ]]; then
                sed -i "s|@HOME@|${HOME}|g; s|/home/matrix|${HOME}|g" "$dst" 2>/dev/null || true
            fi
            ;;
        *)
            ln -sfn "$src" "$dst"
            ;;
    esac
    ok "  ${mode}: $dst"
}

make_tree_executable() {
    local root="$1"
    [[ -d "$root" ]] || return 0
    # Shell scripts and common helpers
    find "$root" -type f \( -name '*.sh' -o -name '*-menu' -o -name '*-status.sh' -o -name '*-viz.sh' \) \
        -exec chmod +x {} + 2>/dev/null || true
    # Files with shebang
    while IFS= read -r -d '' f; do
        if head -n1 "$f" 2>/dev/null | grep -q '^#!'; then
            chmod +x "$f" 2>/dev/null || true
        fi
    done < <(find "$root" -type f -print0 2>/dev/null)
}

deploy_configs() {
    step "Deploying configuration"

    local mode="link"
    $COPY_MODE && mode="copy"

    if ! confirm "Deploy configs to ~/.config and home? (existing files backed up)" "Y"; then
        warn "Skipping config deploy"
        return 0
    fi

    # Ensure scripts are executable in the repo before linking
    make_tree_executable "$REPO_DIR/bin"
    make_tree_executable "$REPO_DIR/config/waybar/scripts"
    make_tree_executable "$REPO_DIR/config/hypr/scripts"
    make_tree_executable "$REPO_DIR/config/wlogout"
    make_tree_executable "$REPO_DIR/config/rofi"

    local config_dirs=(
        hypr wlogout waybar rofi cava gtk-3.0 gtk-4.0 qt5ct qt6ct
        matugen waypaper kitty ghostty btop swaync nvim fastfetch
        autostart environment.d
    )

    for dir in "${config_dirs[@]}"; do
        [[ -e "$REPO_DIR/config/$dir" ]] || continue
        deploy_link_or_copy "$REPO_DIR/config/$dir" "$HOME/.config/$dir" "$mode"
    done

    if [[ -f "$REPO_DIR/config/starship.toml" ]]; then
        deploy_link_or_copy "$REPO_DIR/config/starship.toml" "$HOME/.config/starship.toml" "$mode"
    fi

    personalize_gtk3

    # Home shell configs
    [[ -f "$REPO_DIR/home/.zshrc" ]] && deploy_link_or_copy "$REPO_DIR/home/.zshrc" "$HOME/.zshrc" "$mode"
    [[ -f "$REPO_DIR/home/.bashrc" ]] && deploy_link_or_copy "$REPO_DIR/home/.bashrc" "$HOME/.bashrc" "$mode"

    # Scripts → ~/.local/bin
    mkdir -p "$HOME/.local/bin"
    if [[ -d "$REPO_DIR/bin" ]]; then
        for script in "$REPO_DIR"/bin/*; do
            [[ -e "$script" ]] || continue
            local name
            name="$(basename "$script")"
            deploy_link_or_copy "$script" "$HOME/.local/bin/$name" "$mode"
            $DRY_RUN || chmod +x "$HOME/.local/bin/$name" 2>/dev/null || true
        done
    fi

    # Avatar for hyprlock (~/.face)
    if [[ -f "$REPO_DIR/assets/avatar.png" ]]; then
        if [[ ! -f "$HOME/.face" ]] || confirm "Install default lock-screen avatar to ~/.face?" "Y"; then
            if ! $DRY_RUN; then
                cp -f "$REPO_DIR/assets/avatar.png" "$HOME/.face" 2>/dev/null || true
                ok "  installed ~/.face avatar"
            fi
        fi
    fi

    # Ensure matugen output dirs exist so first paint is not broken
    mkdir -p \
        "$HOME/.config/waybar/tokens" \
        "$HOME/.config/swaync/tokens" \
        "$HOME/.config/nvim/lua/generated" \
        "$HOME/.config/qt5ct/colors" \
        "$HOME/.config/qt6ct/colors" \
        "$HOME/.config/hypr" \
        "$HOME/.config/cava" \
        "$HOME/Pictures/Screenshots" \
        2>/dev/null || true

    # Seed token CSS if missing (waybar still starts before first matugen run)
    if [[ -d "$REPO_DIR/config/waybar/tokens" ]]; then
        for f in "$REPO_DIR"/config/waybar/tokens/*; do
            [[ -f "$f" ]] || continue
            local base
            base="$(basename "$f")"
            if [[ ! -e "$HOME/.config/waybar/tokens/$base" ]]; then
                $DRY_RUN || cp -n "$f" "$HOME/.config/waybar/tokens/$base" 2>/dev/null || true
            fi
        done
    fi

    patch_firefox_template
    patch_qt_paths

    if have systemctl; then
        systemctl --user import-environment PATH 2>/dev/null || true
    fi

    ok "Configs deployed"
}

personalize_gtk3() {
    local src="$REPO_DIR/config/gtk-3.0"
    local dst="$HOME/.config/gtk-3.0"
    [[ -d "$src" ]] || return 0

    if $DRY_RUN; then
        info "  [dry-run] copy gtk-3.0 with personalized bookmarks"
        return 0
    fi

    local tmp
    tmp="$(mktemp -d)"
    cp -a "$src"/. "$tmp/" 2>/dev/null || true
    if [[ -f "$tmp/bookmarks" ]]; then
        sed -i "s|@HOME@|${HOME}|g; s|/home/matrix|${HOME}|g" "$tmp/bookmarks"
    else
        {
            echo "file://${HOME}/Downloads Downloads"
            echo "file://${HOME}/Documents Documents"
            echo "file://${HOME}/Pictures Pictures"
            echo "file://${HOME}/Music Music"
            echo "file://${HOME}/Videos Videos"
        } > "$tmp/bookmarks"
    fi

    backup_path "$dst"
    mkdir -p "$dst"
    cp -a "$tmp"/. "$dst/"
    rm -rf "$tmp"
    ok "  copy: ~/.config/gtk-3.0 (personalized bookmarks)"
}

patch_qt_paths() {
    $DRY_RUN && return 0
    for f in "$HOME/.config/qt5ct/qt5ct.conf" "$HOME/.config/qt6ct/qt6ct.conf"; do
        if [[ -f "$f" ]]; then
            if grep -qE 'color_scheme_path=(~/|/home/matrix)' "$f" 2>/dev/null; then
                local real
                real="$(readlink -f "$f" 2>/dev/null || echo "$f")"
                sed -i "s|color_scheme_path=.*/.config/qt|color_scheme_path=${HOME}/.config/qt|g" "$real" 2>/dev/null || true
                sed -i "s|color_scheme_path=~/.config/qt|color_scheme_path=${HOME}/.config/qt|g" "$real" 2>/dev/null || true
            fi
        fi
    done
}

patch_firefox_template() {
    $DRY_RUN && return 0
    local profiles_ini="$HOME/.mozilla/firefox/profiles.ini"
    local matugen_cfg="$HOME/.config/matugen/config.toml"
    [[ -f "$matugen_cfg" ]] || matugen_cfg="$REPO_DIR/config/matugen/config.toml"
    [[ -f "$matugen_cfg" ]] || return 0

    local profile_dir=""
    if [[ -f "$profiles_ini" ]]; then
        profile_dir="$(awk -F= '
            /^\[Profile/ { in_p=1; path=""; def=0 }
            in_p && /^Path=/ { path=$2 }
            in_p && /^Default=1/ { def=1 }
            in_p && /^$/ {
                if (def && path != "") { print path; exit }
            }
            END { if (path != "" && def) print path }
        ' "$profiles_ini")"
        if [[ -z "$profile_dir" ]]; then
            profile_dir="$(awk -F= '/^Path=/ {print $2; exit}' "$profiles_ini")"
        fi
    fi

    if [[ -n "$profile_dir" ]]; then
        local chrome_dir="$HOME/.mozilla/firefox/${profile_dir}/chrome"
        mkdir -p "$chrome_dir"
        local out_path="${chrome_dir}/userChrome.css"
        local real_cfg
        real_cfg="$(readlink -f "$matugen_cfg" 2>/dev/null || echo "$matugen_cfg")"
        if grep -q 'templates.firefox' "$real_cfg" 2>/dev/null; then
            sed -i "s|^output_path = \".*firefox.*userChrome.css\"|output_path = \"${out_path}\"|" "$real_cfg" 2>/dev/null || true
        fi
        if [[ -f "$REPO_DIR/browsers/firefox-user.js" ]]; then
            cp -f "$REPO_DIR/browsers/firefox-user.js" "$HOME/.mozilla/firefox/${profile_dir}/user.js" 2>/dev/null || true
        fi
        ok "  Firefox profile linked for matugen: $profile_dir"
    else
        dim "  No Firefox profile found — browser theming skipped until Firefox is run once"
    fi
}

# ---------- wallpapers ----------
list_repo_wallpapers() {
    find "$REPO_DIR/wallpapers" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        2>/dev/null | sort
}

resolve_wallpaper() {
    local arg="${1:-}"
    if [[ -z "$arg" ]]; then
        if [[ -f "$REPO_DIR/wallpapers/default.jpg" ]]; then
            echo "$REPO_DIR/wallpapers/default.jpg"
            return 0
        fi
        local first
        first="$(list_repo_wallpapers | head -n1)"
        echo "${first:-}"
        return 0
    fi
    if [[ -f "$arg" ]]; then
        echo "$arg"
        return 0
    fi
    if [[ -f "$REPO_DIR/wallpapers/$arg" ]]; then
        echo "$REPO_DIR/wallpapers/$arg"
        return 0
    fi
    if [[ -f "$HOME/Pictures/Wallpapers/$arg" ]]; then
        echo "$HOME/Pictures/Wallpapers/$arg"
        return 0
    fi
    warn "Wallpaper not found: $arg — falling back to default"
    resolve_wallpaper ""
}

install_wallpapers() {
    step "Wallpapers"

    if $SKIP_WALLPAPER; then
        warn "Skipping wallpaper setup (--no-wallpaper)"
        return 0
    fi

    local dest="$HOME/Pictures/Wallpapers"
    mkdir -p "$dest"

    local count
    count="$(list_repo_wallpapers | wc -l | tr -d ' ')"
    if [[ "$count" -eq 0 ]]; then
        warn "No wallpapers bundled in repo/wallpapers/"
        return 0
    fi

    info "Copying $count wallpaper(s) → $dest"
    if ! $DRY_RUN; then
        while IFS= read -r img; do
            local base
            base="$(basename "$img")"
            if [[ ! -f "$dest/$base" ]]; then
                cp -n "$img" "$dest/$base" 2>/dev/null || cp "$img" "$dest/$base" 2>/dev/null || true
            fi
        done < <(list_repo_wallpapers)
        ok "Wallpapers installed to $dest"
    fi

    local chosen=""
    if [[ -n "$WALLPAPER_ARG" ]]; then
        chosen="$(resolve_wallpaper "$WALLPAPER_ARG")"
    elif $AUTOYES; then
        chosen="$(resolve_wallpaper "")"
    else
        echo ""
        echo -e "${BOLD}Available wallpapers:${NC}"
        local i=1
        local files=()
        while IFS= read -r img; do
            files+=("$img")
            printf "  %2d) %s\n" "$i" "$(basename "$img")"
            i=$((i + 1))
        done < <(list_repo_wallpapers)
        echo "   0) Keep / skip applying now"
        echo -en "${YELLOW}?${NC} Select wallpaper number [default: default.jpg]: "
        read -r pick || pick=""
        if [[ -z "$pick" ]]; then
            chosen="$(resolve_wallpaper "default.jpg")"
        elif [[ "$pick" == "0" ]]; then
            chosen=""
        elif [[ "$pick" =~ ^[0-9]+$ ]] && (( pick >= 1 && pick <= ${#files[@]} )); then
            chosen="${files[$((pick - 1))]}"
        else
            warn "Invalid selection — using default.jpg"
            chosen="$(resolve_wallpaper "default.jpg")"
        fi
    fi

    if [[ -z "$chosen" || ! -f "$chosen" ]]; then
        warn "No wallpaper selected"
        return 0
    fi

    local dest_file="$dest/$(basename "$chosen")"
    if [[ ! -f "$dest_file" ]] && ! $DRY_RUN; then
        cp "$chosen" "$dest_file" 2>/dev/null || true
    fi
    [[ -f "$dest_file" ]] && chosen="$dest_file"

    info "Applying wallpaper: $(basename "$chosen")"
    if $DRY_RUN; then
        info "[dry-run] would apply $chosen"
        return 0
    fi

    mkdir -p "$HOME/.cache"
    echo "$chosen" > "$HOME/.cache/current-wallpaper"

    # waypaper config
    local wp_cfg="$HOME/.config/waypaper/config.ini"
    if [[ -f "$wp_cfg" ]]; then
        local real_wp
        real_wp="$(readlink -f "$wp_cfg" 2>/dev/null || echo "$wp_cfg")"
        if grep -q '^wallpaper' "$real_wp" 2>/dev/null; then
            if have python3; then
                python3 - "$real_wp" "$chosen" <<'PY' 2>/dev/null || true
import sys, re
path, wallpaper = sys.argv[1], sys.argv[2]
with open(path) as f:
    text = f.read()
text2, n = re.subn(r'(?m)^(wallpaper\s*=\s*).*$', r'\1' + wallpaper, text, count=1)
if n:
    with open(path, 'w') as f:
        f.write(text2)
PY
            else
                sed -i "0,/^wallpaper.*/s|^wallpaper.*|wallpaper = ${chosen}|" "$real_wp" 2>/dev/null || true
            fi
        fi
    fi

    # Colors
    if [[ -x "$HOME/.local/bin/matugen-apply-colors" ]]; then
        "$HOME/.local/bin/matugen-apply-colors" "$chosen" >>"$LOG_FILE" 2>&1 || true
        ok "Matugen colors generated from $(basename "$chosen")"
    elif have matugen; then
        local cfg="$HOME/.config/matugen/config.toml"
        [[ -f "$cfg" ]] || cfg="$REPO_DIR/config/matugen/config.toml"
        if [[ -f "$cfg" ]]; then
            matugen image -c "$cfg" "$chosen" -m dark --type scheme-tonal-spot --prefer lightness --continue-on-error >>"$LOG_FILE" 2>&1 || true
            ok "Matugen colors generated from $(basename "$chosen")"
        else
            warn "matugen config missing — colors will generate on first wallpaper change"
        fi
    else
        warn "matugen not available yet — colors will generate on first wallpaper change"
    fi

    # Live wallpaper if session running
    if have awww && [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        awww-daemon >/dev/null 2>&1 &
        sleep 0.2
        awww img "$chosen" >>"$LOG_FILE" 2>&1 || true
    fi

    ok "Default wallpaper set: $chosen"
}

# ---------- services ----------
setup_services() {
    step "Services"

    if $DRY_RUN; then
        info "[dry-run] would enable NetworkManager, bluetooth, hyprpolkitagent, hypridle, power-profiles-daemon"
        return 0
    fi

    # System services (best-effort — never abort)
    if have systemctl; then
        if is_installed networkmanager || is_installed NetworkManager; then
            sudo systemctl enable --now NetworkManager.service >>"$LOG_FILE" 2>&1 \
                && ok "NetworkManager enabled" \
                || warn "Could not enable NetworkManager (may need manual setup)"
        fi
        if is_installed bluez; then
            sudo systemctl enable --now bluetooth.service >>"$LOG_FILE" 2>&1 \
                && ok "Bluetooth enabled" \
                || warn "Could not enable bluetooth.service"
        fi
        if is_installed power-profiles-daemon; then
            sudo systemctl enable --now power-profiles-daemon.service >>"$LOG_FILE" 2>&1 \
                && ok "power-profiles-daemon enabled" \
                || dim "power-profiles-daemon not enabled (optional)"
        fi
    fi

    if ! confirm "Enable hyprpolkitagent & hypridle user services?" "Y"; then
        warn "Skipping user services"
        return 0
    fi

    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user enable --now hyprpolkitagent.service 2>>"$LOG_FILE" \
        && ok "hyprpolkitagent enabled" \
        || warn "hyprpolkitagent service not available yet (started from Hyprland autostart)"
    systemctl --user enable --now hypridle.service 2>>"$LOG_FILE" \
        && ok "hypridle enabled" \
        || warn "hypridle service not available yet (ok if started from Hyprland autostart)"
}

# ---------- shell ----------
setup_shell() {
    step "Shell"

    if ! have zsh; then
        warn "zsh not installed — skip default shell change"
        return 0
    fi

    local zsh_path
    zsh_path="$(command -v zsh)"
    if [[ "${SHELL:-}" == "$zsh_path" ]]; then
        ok "Default shell already zsh"
        return 0
    fi

    if confirm "Set zsh as default shell?" "Y"; then
        if $DRY_RUN; then
            info "[dry-run] chsh -s $zsh_path"
        else
            if chsh -s "$zsh_path" 2>>"$LOG_FILE"; then
                ok "Default shell set to zsh (re-login required)"
            else
                warn "chsh failed — run manually: chsh -s $zsh_path"
            fi
        fi
    fi
}

# ---------- health check ----------
health_check() {
    step "Health check"
    local critical_ok=true
    local optional_missing=()

    for cmd in hyprland waybar; do
        if have "$cmd"; then
            ok "  $cmd present"
        else
            warn "  missing critical command: $cmd"
            critical_ok=false
        fi
    done

    for cmd in kitty rofi swaync matugen awww hyprlock hypridle; do
        if have "$cmd"; then
            dim "  optional ok: $cmd"
        else
            optional_missing+=("$cmd")
        fi
    done

    if [[ ${#optional_missing[@]} -gt 0 ]]; then
        warn "Optional tools not on PATH: ${optional_missing[*]}"
        warn "Configs still work; install missing pieces later or re-run the installer."
    fi

    if [[ -f "$HOME/.cache/current-wallpaper" ]]; then
        ok "  wallpaper cache set"
    else
        dim "  no wallpaper cache (skipped or --no-wallpaper)"
    fi

    if [[ -L "$HOME/.config/hypr" || -d "$HOME/.config/hypr" ]]; then
        ok "  hypr config present"
    else
        warn "  hypr config missing — re-run without skipping deploy"
        critical_ok=false
    fi

    $critical_ok && ok "Core health check passed" || warn "Some critical pieces are missing — see log"
}

# ---------- summary ----------
print_summary() {
    step "Installation summary"
    echo ""
    echo -e "${GREEN}${BOLD}  Matrix dotfiles install finished.${NC}"
    echo ""
    echo -e "  Log file: ${DIM}${LOG_FILE}${NC}"

    if [[ ${#FAILED_PKGS[@]} -gt 0 ]]; then
        echo ""
        echo -e "  ${YELLOW}Packages that need attention:${NC}"
        printf '    - %s\n' "$(printf '%s\n' "${FAILED_PKGS[@]}" | sort -u)"
        echo ""
        echo -e "  ${DIM}Re-run install later, or install manually. See the log for details.${NC}"
        echo -e "  ${DIM}Core configs still deploy even if some packages failed.${NC}"
    fi

    if [[ ${#SKIPPED_PKGS[@]} -gt 0 ]]; then
        echo ""
        echo -e "  ${YELLOW}Skipped (not in repos / no AUR helper):${NC}"
        printf '    - %s\n' "$(printf '%s\n' "${SKIPPED_PKGS[@]}" | sort -u)"
    fi

    if [[ ${#WARNINGS[@]} -gt 0 ]]; then
        echo ""
        echo -e "  ${YELLOW}Warnings: ${#WARNINGS[@]}${NC} (see log for details)"
    fi

    echo ""
    echo -e "${BOLD}  Next steps:${NC}"
    echo "    1. Log out and back in (or reboot)"
    echo "    2. Select Hyprland from your display manager"
    echo "    3. Press Super+W to change wallpaper (colors auto-update)"
    echo "    4. Install a browser of your choice if you do not have one yet"
    echo ""
    local wp
    wp="$(cat "$HOME/.cache/current-wallpaper" 2>/dev/null || true)"
    if [[ -n "$wp" ]]; then
        echo -e "  Wallpaper: ${CYAN}$(basename "$wp")${NC}"
    fi
    echo ""
}

# ---------- main ----------
main() {
    parse_args "$@"
    ensure_log
    banner

    if ! $AUTOYES; then
        echo -e "This will install the ${BOLD}Matrix${NC} Hyprland rice on Arch Linux."
        echo "Existing configs are backed up with a .bak.<timestamp> suffix."
        echo "Package failures are logged and skipped — the install continues."
        echo ""
        if ! confirm "Continue?" "Y"; then
            info "Aborted by user."
            exit 0
        fi
    fi

    check_system

    if ! $SKIP_PACKAGES; then
        if confirm "Install official packages (pacman)?" "Y"; then
            batch_install_pacman "$REPO_DIR/packages.txt" "Official packages"
        else
            warn "Skipping official packages"
        fi
    else
        info "Skipping packages (--no-packages)"
    fi

    if ! $SKIP_AUR; then
        if confirm "Install AUR packages (wlogout, waypaper, grimblast, cursor)?" "Y"; then
            install_aur_list "$REPO_DIR/packages-aur.txt" "AUR packages"
        else
            warn "Skipping AUR packages"
        fi
    fi

    deploy_configs
    install_wallpapers
    setup_services
    setup_shell
    health_check
    print_summary
}

main "$@"
