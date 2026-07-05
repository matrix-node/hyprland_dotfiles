# Installation

## Prerequisites

- **Arch Linux** (or Arch-based distro)
- An internet connection
- A user with `sudo` privileges

On a **fresh Arch install**, make sure you have:
```bash
sudo pacman -S --needed git base-devel
```

## Clone the repo

```bash
git clone https://github.com/matrix-node/hyprland_dotfiles.git ~/hyprland_dotfiles
cd ~/hyprland_dotfiles
```

## Run the installer

```bash
# Interactive mode (recommended for first run)
./install.sh

# Fully automatic
./install.sh --yes
```

### What the installer does

**Step 1** — Installs all official packages via pacman:
- Hyprland ecosystem (hyprland, hyprlock, hypridle, hyprpolkitagent)
- GTK/Qt theme tools (matugen, nwg-look, qt5ct, qt6ct)
- Terminals (ghostty, kitty)
- Utilities (neovim, btop, fastfetch, pipewire, waybar, rofi, cava, swaync)
- Fonts (JetBrains Mono Nerd Font, Nerd Font Symbols)

**Step 2** — Installs AUR packages via yay/paru:
- Browser (brave-origin-nightly-bin)
- GUI tools (waypaper-git, awww, quickshell)
- Extras (bibata-cursor-theme, wlogout, grimblast, rofi-wifi-menu-git)

**Step 3** — Symlinks all config files to `~/.config/` and home dotfiles to `~/`

**Step 4** — Enables user services (hyprpolkitagent, hypridle)

## After installation

```bash
reboot
```

Select **Hyprland** from your display manager.

## Setting up the wallpaper

The first time you log in, you'll need to set a wallpaper to trigger matugen color generation:

1. Press `Super + W` to open the wallpaper picker
2. Select an image
3. Colors will auto-apply across all apps

Or manually:
```bash
matugen-apply-colors ~/Pictures/Wallpapers/your-image.jpg
```

## Manual installation

If you prefer to install without the script:

```bash
# Official packages
sudo pacman -S --needed - < packages.txt

# AUR packages
yay -S --needed - < packages-aur.txt

# Symlink configs
for dir in config/*/; do
    ln -sf "$PWD/$dir" "$HOME/.config/$(basename $dir)"
done
ln -sf "$PWD/config/starship.toml" "$HOME/.config/starship.toml"
ln -sf "$PWD/home/.zshrc" "$HOME/.zshrc"
ln -sf "$PWD/home/.bashrc" "$HOME/.bashrc"

# Scripts
mkdir -p "$HOME/.local/bin"
for script in bin/*; do
    ln -sf "$PWD/$script" "$HOME/.local/bin/"
    chmod +x "$HOME/.local/bin/$(basename $script)"
done

# Enable services
systemctl --user enable --now hyprpolkitagent hypridle
```
