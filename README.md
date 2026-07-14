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
- **Waybar** — modular status bar (workspaces, tray, clock, audio, …)
- **Rofi** — app launcher, WiFi, Bluetooth — themed with matugen
- **Cava** — terminal audio visualizer with gradient colors
- **GTK3 + GTK4 + Qt5 + Qt6** — consistent theming
- **Neovim** — colorscheme generated from wallpaper
- **Firefox & Brave** — optional browser theming

## Quick install

```bash
git clone https://github.com/matrix-node/hyprland_dotfiles.git ~/hyprland_dotfiles
cd ~/hyprland_dotfiles
./install.sh
```

Fully automatic (default wallpaper, skip optional apps):

```bash
./install.sh --yes
```

Pick a bundled wallpaper by name:

```bash
./install.sh --yes --wallpaper nordwall3.jpg
```

### What the installer does

1. Installs official packages from `packages.txt` (bulk install, then per-package fallback)
2. Installs AUR packages from `packages-aur.txt` via `yay`/`paru` (installs `yay` if missing)
3. Optionally offers personal apps from `packages-optional.txt` (default: skip)
4. Symlinks configs into `~/.config/` (backs up existing files)
5. Copies bundled wallpapers → `~/Pictures/Wallpapers/`
6. Applies a default (or selected) wallpaper and runs matugen
7. Enables `hyprpolkitagent` / `hypridle` user services

**Failed packages are logged and skipped.** The rice still installs.

### Installer flags

| Flag | Description |
|---|---|
| `-y`, `--yes` | Non-interactive defaults |
| `--wallpaper PATH` | File under `wallpapers/` or absolute path |
| `--no-packages` | Skip pacman packages |
| `--no-aur` | Skip AUR packages |
| `--no-optional` | Skip optional package prompt |
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

### Core (`packages.txt`)

Hyprland stack, waybar, rofi, swaync, matugen, awww, terminals, pipewire, fonts, …

### AUR (`packages-aur.txt`)

`wlogout`, `waypaper-git`, `grimblast-git`, `bibata-cursor-theme`

### Optional (`packages-optional.txt`)

Browser, Spotify, VS Code, AnyDesk, … — **not required**.

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
├── packages.txt            # Official packages
├── packages-aur.txt        # AUR packages
├── packages-optional.txt   # Optional personal apps
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
