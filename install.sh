#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Lux Lunae rice — installer for Arch Linux
#  Hyprland (Lua config) + Quickshell side panel / top bar
#
#  Install straight from GitHub (public repo):
#    bash <(curl -fsSL https://raw.githubusercontent.com/YOUR-USER/lux-lunae-rice/main/install.sh)
#  Private repo (needs a read-only token in $TOKEN):
#    curl -fsSL -H "Authorization: Bearer $TOKEN" \
#      https://raw.githubusercontent.com/YOUR-USER/lux-lunae-rice/main/install.sh | LUX_TOKEN=$TOKEN bash
#
#  Or, from a clone / unpacked folder:   ./install.sh
#  Existing configs are moved to *.bak-lux-<timestamp>; re-running is safe.
# ─────────────────────────────────────────────────────────────
set -euo pipefail

# >>> edit this one line after you create the repo (or set LUX_REPO=user/repo when running) <<<
REPO="${LUX_REPO:-crist1891/Lux-lunae-T480}"
BRANCH="${LUX_BRANCH:-main}"

if [ "$(id -u)" -eq 0 ]; then
  echo "Run this as your normal user (it uses sudo where needed), not as root." >&2
  exit 1
fi

# ── When piped from curl there is no local copy of the files: download the repo first ──
SELF="${BASH_SOURCE[0]:-}"
if [ -z "$SELF" ] || [ ! -f "$SELF" ]; then
  TOKEN="${LUX_TOKEN:-${GITHUB_TOKEN:-}}"
  TMP="$(mktemp -d)"
  if [ -n "$TOKEN" ]; then
    # private repo: GitHub API tarball, authenticated with a read-only token
    URL="${LUX_URL:-https://api.github.com/repos/$REPO/tarball/$BRANCH}"
    echo "==> downloading $REPO (private, using token)"
    curl -fsSL -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" "$URL" \
      | tar -xz -C "$TMP" --strip-components=1
  else
    URL="${LUX_URL:-https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz}"
    echo "==> downloading $URL"
    curl -fsSL "$URL" | tar -xz -C "$TMP" --strip-components=1
  fi
  exec bash "$TMP/install.sh" "$@"
fi
HERE="$(cd "$(dirname "$SELF")" && pwd)"
if [ ! -f "$HERE/.config/hypr/hyprland.lua" ]; then
  echo "Can't find the config files next to install.sh ($HERE)." >&2
  exit 1
fi
if [ -n "${LUX_DRY_RUN:-}" ]; then echo "dry run: would install from $HERE"; exit 0; fi

echo "==> core packages"
sudo pacman -S --needed --noconfirm \
  hyprland hyprlock hypridle quickshell wofi mako kitty swaybg \
  grim slurp wl-clipboard cliphist pavucontrol playerctl brightnessctl \
  pipewire pipewire-pulse pipewire-alsa wireplumber \
  bluez bluez-utils blueman fastfetch starship btop libnotify jq bc xdg-user-dirs \
  mesa vulkan-intel intel-media-driver \
  qt6-imageformats webp-pixbuf-loader \
  ttf-jetbrains-mono-nerd noto-fonts-emoji \
  xdg-desktop-portal-hyprland

echo "==> extras for the end_4 keybinds (not fatal if one is missing)"
sudo pacman -S --needed --noconfirm \
  thunar firefox hyprshot hyprpicker tesseract tesseract-data-eng wf-recorder \
  || echo "   (some optional packages could not be installed — those keybinds just won't do anything)"

echo "==> fonts (emblem-style display faces)"
FD="$HOME/.local/share/fonts/lux"; mkdir -p "$FD"
G=https://github.com/google/fonts/raw/main/ofl
for f in almendra/Almendra-Regular.ttf almendra/Almendra-Bold.ttf \
         pirataone/PirataOne-Regular.ttf \
         cinzeldecorative/CinzelDecorative-Regular.ttf; do
  curl -fsSL "$G/$f" -o "$FD/$(basename "$f")" || echo "   (could not fetch $f — install it manually)"
done
fc-cache -f

echo "==> configs (existing ones moved to *.bak-lux-<timestamp>)"
STAMP=$(date +%Y%m%d-%H%M%S)
backup() { if [ -e "$1" ]; then mv "$1" "$1.bak-lux-$STAMP"; fi; return 0; }
mkdir -p "$HOME/.config"
for d in hypr hypridle quickshell kitty wofi mako lux fastfetch; do
  [ -d "$HERE/.config/$d" ] || continue
  backup "$HOME/.config/$d"
  cp -r "$HERE/.config/$d" "$HOME/.config/$d"
done
backup "$HOME/.config/starship.toml"
cp "$HERE/.config/starship.toml" "$HOME/.config/starship.toml"

sed -i "s#__HOME__#$HOME#g" "$HOME/.config/fastfetch/config.jsonc"
chmod +x "$HOME/.config/quickshell/scripts/"*.sh "$HOME/.config/lux/"*.sh
mkdir -p "$HOME/Pictures" "$HOME/Videos"
grep -q "starship init" "$HOME/.bashrc" 2>/dev/null || echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
grep -q "fastfetch" "$HOME/.bashrc" 2>/dev/null || echo '[ "$TERM" = xterm-kitty ] && fastfetch' >> "$HOME/.bashrc"

echo "==> services and permissions"
sudo systemctl enable --now bluetooth.service || true
# brightness keys: brightnessctl needs the 'video' group on real hardware
sudo usermod -aG video "$USER" || true

echo
echo "Done."
echo "  • Log out and back in once (so the 'video' group applies), then start it from a TTY:  Hyprland"
echo "  • Super + /  shows every keybind.   Ctrl+Super+R restarts the panels."
echo "  • If the side panel / top bar don't appear, run  qs  in a terminal inside Hyprland to see QML errors."
