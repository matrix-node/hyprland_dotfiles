# Hyprland Dotfiles — matrix-node

A fully themed Arch Linux Hyprland rice powered by [matugen](https://github.com/InioX/matugen) for automatic Material You color generation.

![OS](https://img.shields.io/badge/OS-Arch_Linux-1793d1?style=flat-square)
![Shell](https://img.shields.io/badge/Shell-Zsh-f1dfd8?style=flat-square)

![Preview](preview.png)

## Features

- **Material You theming** — colors auto-generate from your wallpaper via matugen
- **Hyprlock** — blur lock screen with time, date, and keyboard layout indicator
- **Wlogout** — glass-morphism logout menu with SVG icons and blurred background
- **Waybar** — status bar with workspaces, system tray, clock, and more
- **Rofi** — app launcher, WiFi menu, and Bluetooth selector all themed with matugen
- **Cava** — terminal audio visualizer with gradient colors
- **GTK4 + GTK3 + Qt5 + Qt6** — all themed consistently
- **Neovim** — custom colorscheme generated from wallpaper
- **Firefox & Brave** — themed browser chrome via userChrome.css and GTK integration

## Quick Install

### 1. Clone the repo

```bash
git clone https://github.com/matrix-node/hyprland_dotfiles.git ~/hyprland_dotfiles
cd ~/hyprland_dotfiles
```

### 2. Run the installer

```bash
./install.sh          # interactive (choose between ML4W, End-4, or Matrix-Node)
./install.sh --yes    # fully automatic (defaults to Matrix-Node fallback)
```

The new installer provides options for different popular dotfile setups:
1. **ML4W (MyLinuxForWork)** - Automatically clones and runs the ML4W dotfiles installer.
2. **End-4 (dots-hyprland)** - Automatically clones and runs the end-4 dots-hyprland setup script.
3. **Matrix-Node Dotfiles** - Installs the custom setup in this repository.

*Note: If the ML4W or End-4 installers fail, the script will gracefully prompt you to fall back to the Matrix-Node dotfiles.*

The Matrix-Node installation will:
- Install all required packages (pacman + AUR) safely
- Symlink config files to `~/.config/`
- Set up wallpaper pipeline scripts
- Enable necessary systemd services

### 3. Reboot

```bash
reboot
```

Select **Hyprland** from your display manager.

## What gets installed

### Official packages

`hyprland` `hyprlock` `hypridle` `waybar` `rofi` `matugen` `swaync` `kitty` `ghostty` `neovim` `btop` `fastfetch` `starship` `pipewire` `wireplumber` `ttf-jetbrains-mono-nerd` `ttf-nerd-fonts-symbols`

### AUR packages

`bibata-cursor-theme` `brave-origin-nightly-bin` `waypaper-git` `awww` `quickshell` `wlogout` `rofi-wifi-menu-git` `grimblast` `ttf-nerd-fonts-meta`

## Changing the wallpaper

1. Press `Super + W` or run `set-wallpaper`
2. Pick an image in the waypaper GUI
3. Colors auto-apply across all apps via matugen

Or manually:
```bash
matugen-apply-colors ~/Pictures/Wallpapers/your-image.jpg
```

## Keybindings

| Key | Action |
|---|---|
| `Super + Return` | Open terminal (ghostty) |
| `Super + D` | App launcher (rofi) |
| `Super + L` | Lock screen (hyprlock) |
| `Super + Shift + L` | Logout menu (wlogout) |
| `Super + Q` | Close focused window |
| `Super + F` | File manager (nautilus) |
| `Super + B` | Browser (brave) |
| `Super + R` | Launch waybar scripts |
| `Super + W` | Change wallpaper |
| `Super + C` | Code editor (VS Code) |
| `Super + S` | Scratchpad toggle |
| `Super + V` | Toggle window float |
| `Super + Shift + V` | Clipboard history |
| `Print` | Screenshot area |
| `Super + Print` | Screenshot output |

## Structure

```
hyprland_dotfiles/
├── install.sh            # Bootstrap installer
├── packages.txt          # Official packages
├── packages-aur.txt      # AUR packages
├── preview.png           # Screenshot
├── config/
│   ├── hypr/             # Hyprland, hyprlock, hypridle configs
│   ├── wlogout/          # Logout menu
│   ├── waybar/           # Status bar
│   ├── rofi/             # App launcher and menus
│   ├── cava/             # Audio visualizer
│   ├── gtk-3.0/          # GTK3 theme
│   ├── gtk-4.0/          # GTK4 theme
│   ├── qt5ct/            # Qt5 appearance
│   ├── qt6ct/            # Qt6 appearance
│   ├── matugen/          # Matugen templates and config
│   ├── waypaper/         # Wallpaper manager
│   ├── kitty/            # Kitty terminal
│   ├── ghostty/          # Ghostty terminal
│   ├── btop/             # System monitor
│   ├── swaync/           # Notifications
│   ├── nvim/             # Neovim config
│   ├── fastfetch/        # System fetch
│   ├── starship.toml     # Prompt
│   └── autostart/        # Desktop autostart
├── home/
│   ├── .zshrc            # Zsh config
│   └── .bashrc           # Bash fallback
├── bin/                  # ~/.local/bin scripts
│   ├── matugen-apply-colors
│   ├── generate-wlogout-blur
│   ├── restore-wallpaper
│   └── set-wallpaper
└── browsers/
    ├── firefox-user.js
    ├── firefox-userChrome.css
    ├── firefox-userContent.css
    └── brave-flags.conf
```

## Manual setup (without installer)

```bash
# Install packages
sudo pacman -S --needed - < packages.txt
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

## Tips

- **GTK/Qt apps not themed?** Run `nwg-look` to apply the GTK theme, or check `qt6ct` for Qt settings.
- **Hyprlock not working?** Make sure `hyprpolkitagent` is running: `systemctl --user status hyprpolkitagent`
- **Wlogout slow?** The blurred wallpaper is pre-generated by matugen. Run `generate-wlogout-blur` manually if it's missing.
- **Colors not updating?** After changing wallpaper, run `matugen-apply-colors ~/wallpaper.jpg` or use the waypaper GUI.

## Wallpapers

Place your wallpapers in `~/Pictures/Wallpapers/`. The `waypaper` config points there by default.

## Credits

- [Hyprland](https://hyprland.org/)
- [Matugen](https://github.com/InioX/matugen)
- [Adi1090x](https://github.com/adi1090x/rofi) — rofi type-2 style base
- [ArtsyMacaw](https://github.com/ArtsyMacaw/wlogout) — wlogout

## License

MIT
