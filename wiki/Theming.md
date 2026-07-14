# Theming System

This rice uses **matugen** (Material You color generation) to create a consistent color palette from your wallpaper. Every component reads from this palette.

## How it works

```
Change wallpaper
      ↓
Waypaper calls matugen-apply-colors
      ↓
Matugen generates colors from the image
      ↓
Templates are rendered with the new palette
      ↓
Post-hooks reload all apps
```

## The pipeline

### 1. Wallpaper selection

Press `Super + W` to launch **waypaper**, a GUI wallpaper manager. It supports:
- Local image files
- Multiple monitors
- Slideshow mode
- Transition effects (via swww)

### 2. Color generation

When you select a wallpaper, waypaper runs the `post_command`:

```bash
~/.local/bin/matugen-apply-colors $wallpaper
```

This script:
1. Saves the wallpaper path to `~/.cache/current-wallpaper`
2. Runs `matugen image` with the `scheme-tonal-spot` variant (dark mode)
3. Renders all templates defined in `~/.config/matugen/config.toml`
4. Fires post_hooks to reload apps

### 3. Template rendering

Matugen fills in `{{ colors.primary.default.hex }}` style placeholders in each template file and writes the result to the corresponding output path.

The config.toml defines:

| Template | Output | Auto-reload |
|---|---|---|
| hyprland-colors.lua | `~/.config/hypr/colors.lua` | `hyprctl reload` |
| hyprlock-colors.conf | `~/.config/hypr/hyprlock-colors.conf` | — |
| waybar-colors.css | `~/.config/waybar/tokens/colors.css` | `pkill -SIGUSR2 waybar` |
| wlogout-colors.css | `~/.config/wlogout/colors.css` | `generate-wlogout-blur` |
| rofi-colors.rasi | `~/.config/rofi/colors.rasi` | — |
| gtk-css.css | `~/.config/gtk-3.0/gtk.css` | — |
| gtk4-css.css | `~/.config/gtk-4.0/gtk.css` | — |
| qt5ct-colors.conf | `~/.config/qt5ct/colors/matugen.conf` | — |
| qt6ct-colors.conf | `~/.config/qt6ct/colors/matugen.conf` | — |
| cava-config | `~/.config/cava/config` | — |
| nvim-matugen.lua | `~/.config/nvim/lua/generated/matugen.lua` | — |
| firefox-userChrome.css | `~/.mozilla/firefox/chrome/userChrome.css` | — |
| swaync-variables.css | `~/.config/swaync/tokens/variables.css` | `swaync-client --reload-css` |
| kitty-theme.conf | `~/.config/kitty/kitty-theme.conf` | — |
| ghostty-theme.conf | `~/.config/ghostty/ghostty-theme.conf` | — |
| fastfetch-config.jsonc | `~/.config/fastfetch/config.jsonc` | — |

## The color palette

Matugen generates these color roles from your wallpaper, adapted from Material You:

| Role | Usage |
|---|---|
| `background` | Deepest background, page backgrounds |
| `surface` | Elevated surfaces, card backgrounds |
| `surface_container` | Sidebars, secondary surfaces |
| `surface_container_high` | Hover states, active elements |
| `primary` | Accent color, active borders, links |
| `on_primary` | Text on primary backgrounds |
| `primary_container` | Filled buttons, selected items |
| `on_primary_container` | Text on primary containers |
| `secondary` | Secondary accents |
| `tertiary` | Third-level accents (success states, prompts) |
| `on_surface` | Primary text color |
| `on_surface_variant` | Muted text, subtitles |
| `outline` | Low-emphasis borders, disabled elements |
| `outline_variant` | Subtle borders |
| `error` | Error text, critical indicators |

## Customizing templates

If you want to add a new app to the theming pipeline:

1. Create a template file in `~/.config/matugen/templates/` with `{{ colors.role.hex }}` placeholders
2. Add a `[templates.your_app]` section to `config.toml`:

```toml
[templates.your_app]
input_path = "~/.config/matugen/templates/your-template.conf"
output_path = "~/.config/your-app/config.conf"
post_hook = "pkill -SIGUSR1 your-app"  # optional
```

3. Change your wallpaper to trigger generation, or run manually:
```bash
matugen image -c ~/.config/matugen/config.toml ~/wallpaper.jpg
```
