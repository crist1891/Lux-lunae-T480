# Lux Lunae — Hyprland rice

Ace Combat 8 / Lux Lunae themed Hyprland setup: black-and-gold palette, jet-MFD style
Quickshell panels (a tall side panel on the empty desktop that slides away when a window
opens, then a top bar that slides in), end_4's keybinds with a **Super + /** cheat sheet.

Hyprland **0.55+** (Lua config) on **Arch Linux**.

## Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR-USER/lux-lunae-rice/main/install.sh)
```

(Replace `YOUR-USER`. The repo has to be public for the raw link to work; for a different
repo or branch run it with `LUX_REPO=user/repo LUX_BRANCH=main bash <(curl ...)`.)

**Private repo?** Create a fine-grained personal access token with read-only *Contents*
access to just this repo, then:

```bash
read -rs TOKEN   # paste the token (nothing is echoed)
curl -fsSL -H "Authorization: Bearer $TOKEN" \
  https://raw.githubusercontent.com/YOUR-USER/lux-lunae-rice/main/install.sh | LUX_TOKEN=$TOKEN bash
```

Run it as your normal user. It installs packages with `pacman`, backs up any existing
config as `*.bak-lux-<timestamp>`, copies the new one into `~/.config`, and adds you to the
`video` group. Log out and back in once, then start Hyprland from a TTY with `Hyprland`.

Check what it would do without changing anything: `LUX_DRY_RUN=1 bash install.sh`

## Keys

`Super + /` opens the cheat sheet (generated live from your Hyprland binds).
`Super + Return` terminal · `Super + R` launcher · `Super + Q` close · `Super + D` maximize ·
`Ctrl + Super + T` next wallpaper · `Ctrl + Super + R` restart the panels.

## Customising

- `~/.config/hypr/hyprland.lua` and `keybinds.lua` — compositor and binds
- `~/.config/quickshell/` — the panels (`Theme.qml` has the colors and slide speed)
- `~/.config/lux/walls/` — drop any jpg/png/webp in here to add wallpapers

## Notes

The wallpapers and the Shadow 22 emblem are Ace Combat 8 artwork/screenshots
(© Bandai Namco). They are included unmodified for personal use; the panels and installer
still work if you delete `.config/lux/walls` and `.config/lux/shadow22-emblem.*`.
