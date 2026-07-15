# Matrix — Hyprland Dotfiles

A fully themed **Arch Linux** Hyprland rice powered by [matugen](https://github.com/InioX/matugen) for automatic Material You color generation.

![OS](https://img.shields.io/badge/OS-Arch_Linux-1793d1?style=flat-square)
![WM](https://img.shields.io/badge/WM-Hyprland-58E1FF?style=flat-square)
![Shell](https://img.shields.io/badge/Shell-Zsh-f1dfd8?style=flat-square)

![Preview](preview.png)

## Features

- **Material You theming** — colors auto-generate from your wallpaper via matugen
- **Bundled wallpapers** — installer ships defaults and applies one on setup
- **Resilient installer** — package failures never abort the whole install
- **Hyprlock** — blur lock screen with time, date, and keyboard layout
- **Wlogout** — glass-morphism logout menu with blurred background
- **Waybar** — modular status bar (workspaces, VPN, network, tray, clock, audio, …)
- **Rofi** — app launcher, WiFi, Bluetooth — themed with matugen
- **Cava** — terminal audio visualizer with gradient colors
- **GTK3 + GTK4 + Qt5 + Qt6** — consistent theming
- **Neovim** — colorscheme generated from wallpaper
## Quick install

One-liner (clone + install with defaults):

```bash
git clone https://github.com/matrix-node/hyprland_dotfiles.git ~/hyprland_dotfiles \
  && cd ~/hyprland_dotfiles && ./install.sh --yes
```

Interactive:

```bash
git clone https://github.com/matrix-node/hyprland_dotfiles.git ~/hyprland_dotfiles
cd ~/hyprland_dotfiles
./install.sh
```

Pick a bundled wallpaper by name:

```bash
./install.sh --yes --wallpaper nordwall3.jpg
```

### What the installer does

1. Installs official packages from `packages.txt` (bulk install, then per-package fallback)
2. Installs AUR packages from `packages-aur.txt` via `yay`/`paru` (installs `yay` if missing)
3. Symlinks configs into `~/.config/` (backs up existing files)
4. Copies bundled wallpapers → `~/Pictures/Wallpapers/`
5. Applies a default (or selected) wallpaper and runs matugen
6. Enables `hyprpolkitagent` / `hypridle` user services

Package lists only include what the rice needs to run — no personal apps (browsers, Spotify, VS Code, etc.).  
**Failed packages are logged and skipped.** Config deploy still continues.

### Installer flags

| Flag | Description |
|---|---|
| `-y`, `--yes` | Non-interactive defaults |
| `--wallpaper PATH` | File under `wallpapers/` or absolute path |
| `--no-packages` | Skip pacman packages |
| `--no-aur` | Skip AUR packages |
| `--no-wallpaper` | Skip wallpaper setup |
| `--copy` | Copy configs instead of symlinking |
| `--dry-run` | Show actions without changing the system |

## After install

```bash
reboot
```

Select **Hyprland** from your display manager.

- Change wallpaper: `Super + W` or `set-wallpaper`
- Colors update automatically via matugen

## Packages

Only rice-required packages are installed:

| File | Contents |
|---|---|
| `packages.txt` | Official: Hyprland, waybar, rofi, swaync, matugen, awww, kitty, ghostty, neovim, pipewire, fonts, … |
| `packages-aur.txt` | AUR: `wlogout`, `waypaper-git`, `grimblast-git`, `bibata-cursor-theme` |

Install your own browser, media apps, and IDEs separately.

## Keybindings

| Key | Action |
|---|---|
| `Super + Return` | Terminal (kitty) |
| `Super + D` | App launcher (rofi) |
| `Super + L` | Lock (hyprlock) |
| `Super + Shift + L` | Logout menu (wlogout) |
| `Super + Q` | Close window |
| `Super + F` / `E` | File manager |
| `Super + B` | Browser |
| `Super + W` | Wallpaper picker |
| `Super + C` | Code editor |
| `Super + S` | Scratchpad |
| `Super + V` | Toggle float |
| `Super + Alt + V` | Clipboard history |
| `Print` | Screenshot area |
| `Super + Shift + Print` | Screenshot output |

## Structure

```text
hyprland_dotfiles/
├── install.sh              # Matrix installer
├── packages.txt            # Official packages (rice only)
├── packages-aur.txt        # AUR packages (rice only)
├── wallpapers/             # Bundled wallpapers (default.jpg, …)
├── assets/                 # Avatar and static assets
├── config/                 # ~/.config/* trees
├── home/                   # .zshrc / .bashrc
├── bin/                    # ~/.local/bin helpers
├── browsers/               # Firefox / Brave extras
└── wiki/                   # Documentation
```

## Wallpapers

Bundled images live in `wallpapers/` and are copied to `~/Pictures/Wallpapers/` on install.

Default: **`default.jpg`**. Override:

```bash
./install.sh --yes --wallpaper cyberpunk.jpg
# or later:
matugen-apply-colors ~/Pictures/Wallpapers/mountain.jpg
```

## Manual install

```bash
sudo pacman -S --needed - < packages.txt
yay -S --needed - < packages-aur.txt

for dir in config/*/; do
  ln -sfn "$PWD/$dir" "$HOME/.config/$(basename "$dir")"
done
ln -sfn "$PWD/config/starship.toml" "$HOME/.config/starship.toml"
ln -sfn "$PWD/home/.zshrc" "$HOME/.zshrc"

mkdir -p "$HOME/.local/bin" "$HOME/Pictures/Wallpapers"
cp -n wallpapers/* "$HOME/Pictures/Wallpapers/" 2>/dev/null || true
for s in bin/*; do ln -sfn "$PWD/$s" "$HOME/.local/bin/"; chmod +x "$HOME/.local/bin/$(basename "$s")"; done

systemctl --user enable --now hyprpolkitagent hypridle
matugen-apply-colors ~/Pictures/Wallpapers/default.jpg
```

## Tips

- **GTK/Qt not themed?** Run `nwg-look`, or open `qt6ct`.
- **Hyprlock fails?** `systemctl --user status hyprpolkitagent`
- **Wlogout slow?** Run `generate-wlogout-blur` once after setting a wallpaper.
- **Colors stuck?** `matugen-apply-colors ~/Pictures/Wallpapers/your.jpg`
- **Install log:** `.install-logs/install-*.log` in the repo

## Credits

- [Hyprland](https://hyprland.org/)
- [Matugen](https://github.com/InioX/matugen)
- [Adi1090x](https://github.com/adi1090x/rofi) — rofi type-2 styles
- [ArtsyMacaw](https://github.com/ArtsyMacaw/wlogout) — wlogout

## License

MIT
