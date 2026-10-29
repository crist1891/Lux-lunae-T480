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
REPO="${LUX_REPO:-YOUR-USER/lux-lunae-rice}"
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
  hyprland hyprlock hypridle quickshell wofi kitty swaybg \
  grim slurp wl-clipboard cliphist pavucontrol playerctl brightnessctl \
  pipewire pipewire-pulse pipewire-alsa wireplumber libpulse \
  bluez bluez-utils blueman iw fastfetch starship btop libnotify jq bc xdg-user-dirs \
  mesa vulkan-intel intel-media-driver \
  qt6-imageformats webp-pixbuf-loader \
  ttf-jetbrains-mono-nerd noto-fonts-emoji \
  xdg-desktop-portal-hyprland \
  sddm xorg-server

echo "==> apps and extras (not fatal if one is missing)"
sudo pacman -S --needed --noconfirm \
  dolphin kio-extras breeze-icons archlinux-xdg-menu kdeconnect \
  firefox hyprshot hyprpicker tesseract tesseract-data-eng wf-recorder \
  || echo "   (some optional packages could not be installed — those features just won't do anything)"
# power profiles (the button in the side panel). It conflicts with TLP, so skip it if TLP is installed.
if pacman -Qq tlp >/dev/null 2>&1; then
  echo "   TLP is installed — skipping power-profiles-daemon (the power-profile button won't work)."
else
  sudo pacman -S --needed --noconfirm power-profiles-daemon && sudo systemctl enable --now power-profiles-daemon.service || true
fi
# Dolphin outside KDE: build its application menu cache so "Open with ..." works
if command -v kbuildsycoca6 >/dev/null 2>&1; then XDG_MENU_PREFIX=arch- kbuildsycoca6 --noincremental >/dev/null 2>&1 || true; fi
# the shell is the notification daemon now; a running mako would block it
pkill -x mako 2>/dev/null || true

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
for d in hypr hypridle quickshell kitty wofi lux fastfetch; do
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
# ThinkPad mute / mic-mute key LEDs follow the real mute state
sudo install -Dm644 "$HERE/system/90-lux-thinkpad-leds.rules" /etc/udev/rules.d/90-lux-thinkpad-leds.rules
sudo udevadm control --reload >/dev/null 2>&1 || true
sudo udevadm trigger --subsystem-match=leds >/dev/null 2>&1 || true

echo "==> clock"
sudo timedatectl set-ntp true || true
if [ -n "${LUX_TZ:-}" ]; then
  sudo timedatectl set-timezone "$LUX_TZ" && echo "   timezone set to $LUX_TZ"
elif [ "$(timedatectl show -p Timezone --value 2>/dev/null)" = "UTC" ]; then
  echo "   NOTE: the timezone is UTC, so the clock shows UTC time. Set yours with, for example:"
  echo "         sudo timedatectl set-timezone America/New_York      (list: timedatectl list-timezones)"
  echo "         or re-run this installer with LUX_TZ=America/New_York"
fi

echo "==> SDDM login screen"
T=/usr/share/sddm/themes/lux-lunae
sudo mkdir -p "$T"
sudo cp "$HERE/sddm/lux-lunae/Main.qml" "$HERE/sddm/lux-lunae/metadata.desktop" "$HERE/sddm/lux-lunae/theme.conf" "$T/"
# the original pictures, copied untouched (skipped if you removed them)
[ -f "$HERE/.config/lux/walls/Cope_watches_Tewy.png" ] && sudo cp "$HERE/.config/lux/walls/Cope_watches_Tewy.png" "$T/background.png"
[ -f "$HERE/.config/lux/shadow22-emblem.png" ] && sudo cp "$HERE/.config/lux/shadow22-emblem.png" "$T/emblem.png"
# fonts for the greeter (it runs as its own user and can't see ~/.local/share/fonts)
sudo mkdir -p /usr/local/share/fonts/lux && sudo cp "$HOME"/.local/share/fonts/lux/*.ttf /usr/local/share/fonts/lux/ 2>/dev/null || true
sudo fc-cache -f
sudo mkdir -p /etc/sddm.conf.d
printf '[Theme]\nCurrent=lux-lunae\n' | sudo tee /etc/sddm.conf.d/10-lux-lunae.conf >/dev/null
if grep -qs '^Current=' /etc/sddm.conf; then
  echo "   NOTE: /etc/sddm.conf sets its own theme and overrides ours — remove its Current= line."
fi
# --force replaces any other display manager that was enabled (gdm, lightdm, ...)
sudo systemctl enable --force sddm.service

echo
echo "Done."
echo "  • Reboot: SDDM shows the Lux Lunae login screen — pick the Hyprland session."
echo "    (No login manager? log out and back in once for the 'video' group, then run  Hyprland  from a TTY.)"
echo "  • Preview the login screen first:  sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/lux-lunae"
echo "  • Super + /  shows every keybind.   Ctrl+Super+R restarts the panels."
echo "  • If the side panel / top bar don't appear, run  qs  in a terminal inside Hyprland to see QML errors."
