#!/usr/bin/env bash
# Add Big Sur Hyprland autostart to ~/.bash_profile (tty1, no SDDM).
set -euo pipefail

MARKER_BEGIN="# >>> big-sur-hyprland autostart >>>"
MARKER_END="# <<< big-sur-hyprland autostart <<<"
PROFILE="${HOME}/.bash_profile"
START_SCRIPT="${HOME}/.config/big-sur/scripts/start-hyprland.sh"

usage() {
  cat <<'EOF'
Usage: setup-bash-profile.sh [options]

Configures ~/.bash_profile to run start-hyprland.sh on tty1 after login.
SDDM is not used — fits the Big Sur theme boot flow.

Options:
  -y, --yes   Skip confirmation
  -h, --help  Show this help
EOF
}

FORCE=false
while [ $# -gt 0 ]; do
  case "$1" in
    -y|--yes) FORCE=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ "$(uname -s 2>/dev/null || echo unknown)" != "Linux" ]; then
  echo "setup-bash-profile: alleen op Linux."
  exit 0
fi

if [ -f "$PROFILE" ] && grep -qF "$MARKER_BEGIN" "$PROFILE" 2>/dev/null; then
  echo "setup-bash-profile: Big Sur-blok staat al in $PROFILE"
  exit 0
fi

echo "Zorg dat SDDM uit staat als je die eerder installeerde:"
echo "  sudo systemctl disable --now sddm.service"
echo ""

if [ "$FORCE" != true ]; then
  echo "Dit voegt Hyprland-autostart toe aan: $PROFILE"
  echo "  → $START_SCRIPT (alleen op /dev/tty1)"
  echo ""
  read -r -p "Doorgaan? [y/N] " answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *) echo "Geannuleerd."; exit 0 ;;
  esac
fi

if [ ! -x "$START_SCRIPT" ]; then
  echo "setup-bash-profile: $START_SCRIPT ontbreekt of is niet uitvoerbaar."
  echo "  Voer eerst ./install.sh uit in je Hyprland-sessie."
  exit 1
fi

touch "$PROFILE"
cp "$PROFILE" "${PROFILE}.bak.$(date +%Y%m%d-%H%M%S)" 2>/dev/null || true

cat >>"$PROFILE" <<EOF

$MARKER_BEGIN
# Start Hyprland na login op tty1 (geen SDDM)
if [ -z "\${WAYLAND_DISPLAY:-}" ] && [ "\$(tty 2>/dev/null || echo)" = "/dev/tty1" ]; then
  exec bash "$START_SCRIPT"
fi
$MARKER_END
EOF

echo "setup-bash-profile: toegevoegd aan $PROFILE"
echo "  Log uit en opnieuw in op tty1, of: reboot"
