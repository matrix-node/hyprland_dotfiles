# Installation

## Prerequisites

- **Arch Linux** (or Arch-based distro with `pacman`)
- Internet connection
- A normal user with `sudo` privileges (do **not** run the installer as root)

On a fresh Arch install:

```bash
sudo pacman -S --needed git base-devel
```

## Clone

```bash
git clone https://github.com/matrix-node/hyprland_dotfiles.git ~/hyprland_dotfiles
cd ~/hyprland_dotfiles
```

## Run the Matrix installer

```bash
# Interactive (recommended first run)
./install.sh

# Fully automatic
./install.sh --yes

# Automatic + chosen wallpaper
./install.sh --yes --wallpaper nordwall3.jpg

# Preview without changing the system
./install.sh --dry-run --yes
```

### What it does

| Step | Action | Failure behavior |
|---|---|---|
| 1 | Official packages (`packages.txt`) | Bulk install, then retry each package; failures logged |
| 2 | AUR packages (`packages-aur.txt`) | Installs `yay` if needed; each failure skipped |
| 3 | Optional packages | Offered separately (default: no) |
| 4 | Config deploy | Backs up existing files as `*.bak.<timestamp>` |
| 5 | Wallpapers | Copies `wallpapers/` → `~/Pictures/Wallpapers/`, applies default |
| 6 | Services | Enables `hyprpolkitagent` / `hypridle` when available |

The installer **never aborts the whole run** because one package failed.

### Useful flags

```text
-y, --yes           Non-interactive
--wallpaper PATH    Bundled name or absolute path
--no-packages       Skip pacman
--no-aur            Skip AUR
--no-optional       Skip optional prompt
--no-wallpaper      Skip wallpaper setup
--copy              Copy configs instead of symlinks
--dry-run           No changes
```

Logs are written to `.install-logs/install-*.log`.

## After installation

```bash
reboot
```

Select **Hyprland** from your display manager.

On first login the default wallpaper should already be set. Change it anytime with `Super + W`.

## Wallpaper setup

Bundled wallpapers ship in the repo under `wallpapers/`. The installer copies them to:

```text
~/Pictures/Wallpapers/
```

Default image: **`default.jpg`**.

Manual apply:

```bash
matugen-apply-colors ~/Pictures/Wallpapers/cyberpunk.jpg
```

## Manual installation

```bash
sudo pacman -S --needed - < packages.txt
yay -S --needed - < packages-aur.txt

for dir in config/*/; do
  ln -sfn "$PWD/$dir" "$HOME/.config/$(basename "$dir")"
done
ln -sfn "$PWD/config/starship.toml" "$HOME/.config/starship.toml"
ln -sfn "$PWD/home/.zshrc" "$HOME/.zshrc"
ln -sfn "$PWD/home/.bashrc" "$HOME/.bashrc"

mkdir -p "$HOME/.local/bin" "$HOME/Pictures/Wallpapers"
cp -n wallpapers/* "$HOME/Pictures/Wallpapers/" 2>/dev/null || true
for script in bin/*; do
  ln -sfn "$PWD/$script" "$HOME/.local/bin/"
  chmod +x "$HOME/.local/bin/$(basename "$script")"
done

systemctl --user enable --now hyprpolkitagent hypridle
matugen-apply-colors ~/Pictures/Wallpapers/default.jpg
```

## Updating

```bash
cd ~/hyprland_dotfiles
git pull
./install.sh --yes --no-packages   # re-link configs only, or omit flag to refresh packages
```
