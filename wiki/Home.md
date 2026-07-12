# Welcome to Hyprland Dotfiles

A fully themed **Arch Linux** Hyprland rice powered by [matugen](https://github.com/InioX/matugen) for automatic Material You color generation.

![Preview](../preview.png)

## The Story

I got tired of it.

Tired of cloning someone else's dotfiles, running their install script, and watching things break in ways I couldn't understand. Tired of themes that looked great in screenshots but fell apart on my hardware. Tired of spending more time fixing broken configs than actually using my system.

So I decided to build my own.

Every config here was written from scratch, tested on real hardware, and designed to work together as a cohesive system. No borrowed snippets I don't understand. No black-box installers. Just clean, modular configs that I can explain, debug, and improve.

This rice is the result of that philosophy. It's not just a set of config files -- it's a reproducible, maintainable Arch Linux setup that anyone can clone, install, and understand.

## Philosophy

- **Reproducible** — clone the repo, run the installer, get the same setup every time
- **Maintainable** — modular configs with clear separation of concerns
- **Automatic** — colors generate from your wallpaper, not hardcoded
- **Consistent** — every app uses the same color palette, from GTK to Qt to Firefox to Neovim

## What you get

| Component | Description |
|---|---|
| Hyprland | Window manager with animations and blur |
| Hyprlock | Lock screen with blurred wallpaper and matugen colors |
| Wlogout | Glass-morphism logout menu with SVG icons |
| Waybar | Modular status bar with workspace, audio, network, battery, and more |
| Rofi | App launcher, WiFi menu, and Bluetooth selector |
| Cava | Terminal audio visualizer with gradient colors |
| SwayNC | Notification center themed with matugen |
| Neovim | LazyVim with custom matugen colorscheme |
| GTK3/GTK4 | Desktop apps themed with matugen |
| Qt5/Qt6 | Qt apps (Dolphin, Okular, etc.) using Fusion style with matugen palette |
| Firefox | Custom userChrome.css for themed browser UI |
| Brave | Dark mode with GTK theme integration |
| Matugen | Automatic color generation from wallpaper |

## Quick start

```bash
git clone https://github.com/matrix-node/hyprland_dotfiles.git
cd hyprland_dotfiles
./install.sh --yes
reboot
```

See the [Installation](Installation) page for detailed steps.
