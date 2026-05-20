#!/usr/bin/env bash
# List PipeWire sinks, set default output, unmute and set volume.
# Useful when pavucontrol shows no "Speakers" or the wrong profile (HDMI vs analog).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTO=false
SET_VOLUME="50%"

usage() {
  cat <<'EOF'
Usage: fix-audio.sh [options]

Options:
  --auto          Prefer built-in analog speakers (non-interactive)
  --volume PCT    Volume for --auto (default: 50%)
  -h, --help      Show this help

Examples:
  bash fix-audio.sh              # interactive: list sinks, pick default
  bash fix-audio.sh --auto       # set analog/built-in speakers if found
  wpctl status                   # quick overview (same as step 1)
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --auto)
      AUTO=true
      shift
      ;;
    --volume)
      SET_VOLUME="${2:?--volume requires a value like 50%}"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Onbekende optie: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "fix-audio: $1 niet gevonden — installeer pipewire-pulse (pactl) of wireplumber (wpctl)." >&2
    exit 1
  fi
}

check_services() {
  if ! command -v systemctl >/dev/null 2>&1; then
    return 0
  fi
  local unit failed=0
  for unit in pipewire.service pipewire-pulse.service wireplumber.service; do
    if systemctl --user cat "$unit" >/dev/null 2>&1; then
      if ! systemctl --user is-active --quiet "$unit"; then
        echo "fix-audio: WAARSCHUWING — $unit draait niet."
        echo "  Voer uit: bash \"$SCRIPT_DIR/enable-audio.sh\""
        failed=1
      fi
    fi
  done
  return "$failed"
}

wait_for_pipewire() {
  local i
  for i in $(seq 1 15); do
    if command -v wpctl >/dev/null 2>&1 && wpctl status >/dev/null 2>&1; then
      return 0
    fi
    if command -v pactl >/dev/null 2>&1 && pactl info >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.2
  done
  echo "fix-audio: PipeWire reageert niet — controleer services (enable-audio.sh)." >&2
  return 1
}

show_status() {
  echo ""
  echo "=== wpctl status ==="
  if command -v wpctl >/dev/null 2>&1; then
    wpctl status || true
  else
    echo "(wpctl niet gevonden)"
  fi

  echo ""
  echo "=== Audio-uitgangen (pactl) ==="
  if command -v pactl >/dev/null 2>&1; then
    pactl list sinks short 2>/dev/null || echo "(geen sinks — firmware/services?)"
    echo ""
    echo "Standaard sink: $(pactl get-default-sink 2>/dev/null || echo onbekend)"
  else
    echo "(pactl niet gevonden)"
  fi
  echo ""
}

# Score sink lines from `pactl list sinks short`: lower = better for laptop speakers.
score_sink_line() {
  local line="$1"
  local lower
  lower="$(printf '%s' "$line" | tr '[:upper:]' '[:lower:]')"

  case "$lower" in
    *hdmi* | *displayport* | *nvidia*) echo 100 ;;
    *usb* | *dock* | *headset*) echo 80 ;;
    *speaker* | *speakers* | *luidspreker*) echo 10 ;;
    *analog* | *built-in* | *builtin* | *internal*) echo 15 ;;
    *alsa_output*) echo 50 ;;
    *) echo 60 ;;
  esac
}

collect_sinks() {
  if ! command -v pactl >/dev/null 2>&1; then
    return 1
  fi
  pactl list sinks short 2>/dev/null || return 1
}

pick_best_speaker_sink() {
  local best_line="" best_score=999 line score name

  while IFS= read -r line; do
    [ -n "$line" ] || continue
    score="$(score_sink_line "$line")"
    if [ "$score" -lt "$best_score" ]; then
      best_score="$score"
      best_line="$line"
    fi
  done < <(collect_sinks)

  if [ -z "$best_line" ]; then
    return 1
  fi

  # Reject HDMI-only when score is high (no analog candidate).
  if [ "$best_score" -ge 80 ]; then
    return 1
  fi

  name="$(printf '%s' "$best_line" | awk '{print $2}')"
  printf '%s\n' "$name"
}

apply_sink() {
  local sink_name="$1"

  echo "fix-audio: standaard uitgang → $sink_name"

  if command -v pactl >/dev/null 2>&1; then
    pactl set-default-sink "$sink_name"
    pactl set-sink-mute "$sink_name" 0
    pactl set-sink-volume "$sink_name" "$SET_VOLUME"
  fi

  if command -v wpctl >/dev/null 2>&1; then
    wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 2>/dev/null || true
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "$SET_VOLUME" 2>/dev/null || true
  fi
}

interactive_pick() {
  local -a lines=() names=()
  local i choice line name

  mapfile -t lines < <(collect_sinks || true)

  if [ "${#lines[@]}" -eq 0 ]; then
    echo ""
    echo "Geen audio-uitgangen gevonden."
    echo ""
    echo "Veelvoorkomende oorzaken (HP EliteBook / Intel):"
    echo "  • wireplumber niet actief: bash \"$SCRIPT_DIR/enable-audio.sh\""
    echo "  • firmware ontbreekt: sudo pacman -S --needed alsa-firmware sof-firmware"
    echo "  • verkeerd profiel: in pavucontrol tabblad Configuratie → Analog Stereo"
    echo "  • sink heet anders dan \"Speakers\" (bijv. Built-in Audio Analog Stereo)"
    return 1
  fi

  echo ""
  echo "Kies standaard uitgang:"
  for i in "${!lines[@]}"; do
    line="${lines[$i]}"
    name="$(printf '%s' "$line" | awk '{print $2}')"
    names+=("$name")
    printf '  [%d] %s\n' "$((i + 1))" "$line"
  done
  echo "  [0] Annuleren"
  echo ""
  printf 'Nummer: '
  read -r choice

  case "$choice" in
    '' | 0) echo "Geannuleerd."; return 0 ;;
    *[!0-9]*)
      echo "Ongeldige keuze."
      return 1
      ;;
  esac

  if [ "$choice" -lt 1 ] || [ "$choice" -gt "${#names[@]}" ]; then
    echo "Ongeldige keuze."
    return 1
  fi

  apply_sink "${names[$((choice - 1))]}"
}

auto_fix() {
  local sink_name

  sink_name="$(pick_best_speaker_sink || true)"
  if [ -z "$sink_name" ]; then
    echo "fix-audio: geen analoge/laptop-speakers gevonden (automatisch)."
    echo "  Tip: bash \"$SCRIPT_DIR/fix-audio.sh\" (interactief) of controleer pavucontrol → Configuratie."
    return 1
  fi

  apply_sink "$sink_name"
  echo "fix-audio: volume $SET_VOLUME, dempen uit."
}

require_command pactl
check_services || true
wait_for_pipewire || exit 1
show_status

if [ "$AUTO" = true ]; then
  auto_fix || true
else
  interactive_pick || true
fi

echo ""
echo "Test: speaker-test -c 2 -t wav -l 1   (Ctrl+C om te stoppen)"
echo "Of: pavucontrol → tabblad Uitgang — zoek \"Built-in Audio\" / \"Analog Stereo\"."
