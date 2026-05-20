# Big Sur Hyprland Theme

Een uitgebreid projectplan voor een macOS Big Sur-geinspireerd Hyprland-thema met Waybar, Kitty en een meegeleverde wallpaper. Dit document is bedoeld als briefing voor Cursor of een andere code-assistent om het volledige thema te bouwen, inclusief configuratiebestanden, styling, scripts en installatie-uitleg.

De wallpaper voor dit project staat in de repo als:

```text
assets/Background.jpg
assets/Lockscreen.jpg
```

Bij installatie wordt de wallpaper gekopieerd naar `~/.config/hypr/big-sur/Background.jpg` (of je gekozen `CONFIG_DIR`). Hyprland laadt de achtergrond via **hyprpaper** (`hypr/hyprpaper.conf`).

De lockscreen-afbeelding wordt gekopieerd naar `~/.config/hypr/big-sur/Lockscreen.jpg`. Zonder dit bestand stopt `install.sh`. Vervang `assets/Lockscreen.jpg` door je eigen Big Sur-stijl achtergrond (zelfde map als de repo-assets).

## Lockscreen (hyprlock)

Het thema gebruikt **[hyprlock](https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/)** voor een macOS-achtig vergrendelscherm: grote digitale klok (`$TIME12`), datum eronder, gebruikersnaam en wachtwoordveld.

| Item | Waarde |
|------|--------|
| Sneltoets | **Super+L** |
| Config | `hypr/hyprlock.conf` → `~/.config/hypr/hyprlock.conf` |
| Achtergrond | `~/.config/hypr/big-sur/Lockscreen.jpg` |
| Lettertype | Inter (via `inter-font` in `install.sh`) |

Na installatie: druk **Super+L** om te vergrendelen. Ontgrendelen met je Linux-gebruikerswachtwoord (PAM). Op Arch wordt het `hyprlock`-PAM-profiel meegeleverd.

Handmatig testen: `hyprlock` (leest standaard `~/.config/hypr/hyprlock.conf`).

Vergrendelen gebeurt **alleen op verzoek** (**Super+L** of `hyprlock`); bij opstarten zie je direct de desktop (wallpaper, Waybar). Kitty/terminal wordt niet automatisch gestart — open met **Super+T** of via het Waybar-dockicoon.

**TTY vóór Hyprland:** wat je ziet *vóór* Hyprland (Arch-prompt, logo, tekstlogin op tty1) valt buiten hyprlock en dit thema. Standaard start **install.sh** Hyprland automatisch via `~/.bash_profile` en `start-hyprland.sh` (alleen op tty1). Zie [Geen terminal bij opstarten](#geen-terminal-bij-opstarten).

Na wijzigingen: `hyprctl reload` en opnieuw inloggen, of `./scripts/reload-theme.sh`.

## Doel Van Het Project

Het doel is om een moderne Linux desktop te maken die visueel aansluit bij het macOS Big Sur kleurenschema: diepe nachtblauwe achtergronden, zachte rode en paarse accenten, koele cyaan/blauwe tinten, glasachtige panelen, subtiele transparantie en afgeronde vormen.

Het thema moet niet letterlijk macOS kopieren, maar wel dezelfde sfeer oproepen:

- rustig en premium;
- kleurrijk zonder druk te worden;
- zachte blur en transparantie;
- vloeiende animaties;
- duidelijke typografie;
- consistente spacing;
- bruikbaar als dagelijkse desktopomgeving.

## Gewenste Componenten

Het project moet minimaal configuratie en styling bevatten voor:

- Hyprland
- Waybar
- Kitty
- wallpaper-installatie
- fonts en icon fonts
- optionele rofi/wofi launcher styling
- optionele notification styling via dunst of mako
- een `install.sh` installatiescript
- een backup-mechanisme voor bestaande configuratie
- een uninstall- of restore-uitleg

## Visuele Richting

De visuele stijl moet gebaseerd zijn op macOS Big Sur, met name het kleurgevoel van de meegeleverde wallpaper.

### Kernwoorden

- Big Sur
- glossy maar niet overdreven
- glassmorphism
- zachte blur
- diepe blauwe basis
- rood-blauwe kleurvlakken
- paarse highlights
- lichte cyaan-accenten
- afgeronde hoeken
- subtiele schaduw
- rustige desktop

### Niet Gewenst

Vermijd:

- harde neon cyberpunk-styling;
- overmatig felle gradients;
- te veel paarse UI tegelijk;
- dikke borders;
- schreeuwerige terminalkleuren;
- zware animaties die de desktop traag maken;
- een exacte macOS-kloon met Apple-logo's.

## Kleurenschema

Het thema moet een palette gebruiken dat aansluit op `Background.jpg`.

Aanbevolen kleuren:

```text
Deep Navy        #171738
Midnight Blue    #202052
Soft Indigo      #363A7A
Big Sur Red      #C83A36
Dark Crimson     #8F232D
Violet Glow      #9E5BFF
Lavender Purple  #B46CFF
Sky Cyan         #67C7E8
Cool Blue        #4D8FCB
Frost White      #F5F7FA
Muted White      #D8DEE9
Panel Glass      rgba(23, 23, 56, 0.62)
Border Glass     rgba(245, 247, 250, 0.16)
Shadow           rgba(0, 0, 0, 0.35)
```

Gebruik deze kleuren consequent in alle onderdelen:

- Hyprland borders;
- Waybar background, hover states en active workspace;
- Kitty foreground/background/cursor;
- launcher styling;
- notificaties;
- eventuele lockscreen of logout menu styling.

## Projectstructuur

Cursor moet de volgende projectstructuur maken:

```text
big-sur-hyprland-theme/
├── README.md
├── install.sh
├── uninstall.sh
├── assets/
│   ├── Background.jpg
│   └── Lockscreen.jpg
├── hypr/
│   ├── hyprland.conf
│   ├── hyprpaper.conf
│   ├── hyprlock.conf
│   ├── keybinds.conf
│   ├── windowrules.conf
│   └── theme.conf
├── waybar/
│   ├── config.jsonc
│   └── style.css
├── kitty/
│   ├── kitty.conf
│   └── big-sur.conf
├── rofi/
│   └── big-sur.rasi
├── dunst/
│   └── dunstrc
└── scripts/
    ├── apply-wallpaper.sh
    ├── start-waybar.sh
    ├── start-hyprland.sh
    ├── setup-bash-profile.sh
    ├── reload-theme.sh
    ├── toggle-osk.sh
    ├── rotate-display.sh
    ├── diagnose-convertible.sh
    ├── backup-configs.sh
    ├── enable-audio.sh
    ├── enable-network.sh
    ├── enable-bluetooth.sh
    ├── open-bluetooth.sh
    ├── enable-graphical-login.sh
    ├── fix-audio.sh
    └── sync-to-linux-home.sh
```

Als Cursor een bestaand dotfiles-project gebruikt, mag deze structuur worden aangepast, maar de scheiding tussen `hypr`, `waybar`, `kitty`, `assets` en `scripts` moet behouden blijven.

## Hyprland Eisen

De Hyprland-configuratie moet:

- `Background.jpg` als wallpaper gebruiken via `hyprpaper` of `swww`;
- zachte animaties inschakelen;
- afgeronde vensters gebruiken;
- subtiele borders gebruiken;
- blur inschakelen;
- shadows inschakelen;
- transparantie gebruiken voor floating windows;
- Waybar automatisch starten;
- Kitty als standaardterminal gebruiken;
- een launcher starten via rofi of wofi;
- media keys ondersteunen;
- screenshot keybinds bevatten;
- volume en brightness keybinds bevatten.

### Hyprland Styling Richting

Aanbevolen instellingen:

```ini
general {
    gaps_in = 6
    gaps_out = 12
    border_size = 2
    col.active_border = rgba(67c7e8ff) rgba(b46cffff) 45deg
    col.inactive_border = rgba(363a7a88)
    layout = dwindle
}

decoration {
    rounding = 14
    active_opacity = 0.96
    inactive_opacity = 0.88

    blur {
        enabled = true
        size = 7
        passes = 3
        new_optimizations = true
    }

    shadow {
        enabled = true
        range = 18
        render_power = 3
        color = rgba(00000055)
    }
}

animations {
    enabled = true
}
```

Cursor moet controleren of de syntax past bij de actuele Hyprland-versie. Als een instelling verouderd is, moet Cursor de moderne Hyprland-syntax gebruiken.

## Waybar Eisen

Waybar voelt als een **zwevende Big Sur menubar** (36px hoog, 8px top-margin, afgeronde hoeken):

- semi-transparante glasachtige achtergrond met subtiele schaduw;
- afgeronde pill-modules met lichte borders;
- rustige spacing en hover-transities;
- actieve workspace met cyaan/paarse gradient;
- waarschuwingen in Big Sur-rood;
- icon-only statusmodules met tooltips (volume, netwerk); batterij toont icoon **en** percentage (`{icon} {capacity}%`).

### Layout

| Zone | Modules |
|------|---------|
| Links | `group/launchers` — dock-pill met terminal, browser, bestandsbeheer, VS Code |
| Midden | `hyprland/workspaces` — 5 persistente workspaces (●/○) |
| Rechts | `group/quick` (toetsenbord, rotatie, herstart, audio, wifi, bluetooth) + `group/status` (audio, netwerk, batterij, tray) + `clock` |

### Waybar Modules

```jsonc
{
  "layer": "top",
  "position": "top",
  "height": 36,
  "margin-top": 8,
  "margin-left": 16,
  "margin-right": 16,
  "modules-left": ["group/launchers"],
  "modules-center": ["hyprland/workspaces"],
  "modules-right": ["group/quick", "group/status", "clock"]
}
```

Rechts vóór de status-pill: `group/quick` met klikbare custom-modules:

| Module | Icoon | Klik | Actie |
|--------|-------|------|-------|
| `custom/keyboard` | 󰌌 | Links | `toggle-osk.sh` — schermtoetsenbord (wvkbd) aan/uit |
| `custom/rotate` | 󰍹 | Links | `rotate-display.sh` — rotatie 0° → 90° → 180° → 270° |
| `custom/restart` | 󰑐 | Links | `~/.config/big-sur/scripts/restart-session.sh` — Hyprland + Waybar + wallpaper herladen |
| `custom/restart` | 󰑐 | Rechts | `restart-computer.sh` — bevestiging (rofi/wofi) en `loginctl reboot` |
| `custom/audio` | 󰓃 | Links | `pavucontrol` |
| `custom/wifi` | 󰖩 | Links | `nm-connection-editor` |
| `custom/bluetooth` | 󰂯 | Links | `open-bluetooth.sh` → blueman-manager of bluetoothctl |

`install.sh` kopieert alle scripts naar `~/.config/big-sur/scripts/`. Bij handmatige installatie: zelfde map aanmaken en `scripts/*.sh` daarheen kopiëren (`chmod +x`).

Links in de menubar: `group/launchers` met vier klikbare custom-modules (Nerd Font-iconen) die dezelfde apps starten als de Hyprland-keybinds:

| Module | Icoon | `on-click` | Keybind |
|--------|-------|------------|---------|
| `custom/terminal` | 󰆍 | `kitty` | Super+T |
| `custom/browser` | 󰖟 | `firefox` | Super+B |
| `custom/files` | 󰝰 | `dolphin` | Super+E |
| `custom/code` | 󰨞 | `launch-code.sh` | Super+Shift+C |

### Waybar CSS Richting

Zie `waybar/style.css`. Kernpunten:

- `window#waybar` — floating bar: `border-radius: 14px`, glass panel `rgba(23, 23, 56, 0.58)`, box-shadow;
- `#launchers` — dock-pill met hover-glow (cyaan) en active-state (paars);
- `#workspaces` — gecentreerde pill, active workspace gradient `#67c7e8 → #b46cff`;
- `#quick` — quick-action pill (zelfde stijl als launchers): toetsenbord, rotatie, herstart, audio, wifi, bluetooth;
- `#status` — gegroepeerde status-pill; icon-only modules met tooltips;
- `#clock` — aparte pill rechts, klik rechts wisselt datum/tijd.

## Kitty Eisen

Kitty moet een rustige Big Sur terminalstijl krijgen:

- donkere navy achtergrond;
- frost-white foreground;
- cyaan cursor;
- zachte rood/paarse ANSI-kleuren;
- lichte transparantie;
- geen overmatige opacity waardoor tekst slecht leesbaar wordt;
- JetBrainsMono Nerd Font of vergelijkbare Nerd Font;
- padding rond terminalinhoud.

### Kitty Config Richting

```conf
include big-sur.conf

font_family JetBrainsMono Nerd Font
font_size 11.5

window_padding_width 10
background_opacity 0.88
dynamic_background_opacity yes

cursor_shape beam
cursor_blink_interval 0.5

enable_audio_bell no
confirm_os_window_close 0
```

### Kitty Theme Richting

```conf
foreground #F5F7FA
background #171738
selection_foreground #171738
selection_background #67C7E8
cursor #67C7E8
cursor_text_color #171738

color0  #171738
color1  #C83A36
color2  #67C7E8
color3  #B46CFF
color4  #4D8FCB
color5  #9E5BFF
color6  #67C7E8
color7  #D8DEE9
color8  #363A7A
color9  #E0524D
color10 #8DE3FF
color11 #C995FF
color12 #6EADE8
color13 #C184FF
color14 #91E6FF
color15 #F5F7FA
```

## Wallpaper Installatie

De wallpaper moet in het project staan als:

```text
assets/Background.jpg
```

Tijdens installatie moet het script deze kopieren naar:

```text
~/.config/hypr/big-sur/Background.jpg
```

Hyprpaper-config (huidige hyprpaper-syntax):

```ini
wallpaper {
    monitor =
    path = ~/.config/hypr/big-sur/Background.jpg
    fit_mode = cover
}
```

Als `swww` wordt gebruikt (niet standaard in dit thema):

```bash
swww img "$HOME/.config/hypr/big-sur/Background.jpg" --transition-type grow --transition-duration 1
```

Dit thema gebruikt **hyprpaper** (niet `swww`) voor de desktopachtergrond.

## Fonts

Aanbevolen fonts:

- Inter
- SF Pro Display als de gebruiker dit zelf installeert
- JetBrainsMono Nerd Font
- Symbols Nerd Font

Gebruik geen Apple fonts als automatische download, tenzij de gebruiker daar expliciet zelf voor kiest. Gebruik Inter en JetBrainsMono Nerd Font als open alternatieven.

## Dependencies

Het project moet rekening houden met verschillende distributies, maar primair mikken op Arch Linux of Arch-gebaseerde distributies zoals EndeavourOS.

Minimale dependencies:

```text
hyprland
waybar
kitty
hyprpaper of swww
rofi-wayland of wofi
dunst of mako
wl-clipboard
grim
slurp
brightnessctl
playerctl
pavucontrol
pipewire
pipewire-pulse
pipewire-alsa
wireplumber
alsa-utils
alsa-firmware
sof-firmware
networkmanager
network-manager-applet
iw
wireless-regdb
linux-firmware
bluez
bluez-utils
blueman
upower
dolphin
firefox
code
ttf-jetbrains-mono-nerd
inter-font
wlr-randr
```

**Schermtoetsenbord (wvkbd):** staat **niet** in de officiële Arch-repositories — alleen [AUR](https://aur.archlinux.org/packages/wvkbd). Fallback **onboard** via `pacman` (in `install.sh`). Geen systemd-service; start via Waybar 󰌌 of `toggle-osk.sh`.

```bash
yay -S wvkbd-deskintl    # aanbevolen op vouw-/touchscherm (HP EliteBook x360)
# of:
yay -S wvkbd             # mobintl layout → binary wvkbd-mobintl
```

Voor Arch (officiële repos):

```bash
sudo pacman -S hyprland waybar kitty hyprpaper rofi-wayland dunst wl-clipboard grim slurp brightnessctl playerctl pavucontrol pipewire pipewire-pulse pipewire-alsa wireplumber alsa-utils alsa-firmware sof-firmware networkmanager network-manager-applet iw wireless-regdb linux-firmware bluez bluez-utils blueman upower dolphin firefox code ttf-jetbrains-mono-nerd inter-font wlr-randr jq onboard
```

**Audio (Arch):** gebruik **PipeWire** met `pipewire-pulse` (PulseAudio-compatibiliteit voor Waybar `pulseaudio`-module en `pavucontrol`). Het legacy `pulseaudio`-pakket is niet nodig. Voor Intel-laptops (bijv. HP EliteBook) installeert `install.sh` ook `alsa-firmware`, `sof-firmware` en `alsa-utils`. `install.sh` schakelt de officiële user-units in via `scripts/enable-audio.sh` en probeert laptop-speakers als standaard uitgang via `scripts/fix-audio.sh --auto`:

```text
pipewire.service
pipewire-pulse.service
wireplumber.service
```

Op Windows/Git Bash worden pakketten en systemd overgeslagen; voer `./install.sh` opnieuw uit in je Hyprland-sessie op Linux.

**Bluetooth (Arch):** `bluez` levert `bluetoothd`; `bluez-utils` levert `bluetoothctl`; `blueman` is de GUI. `install.sh` schakelt de stack in via `scripts/enable-bluetooth.sh` (`systemctl enable --now bluetooth`, `rfkill unblock bluetooth`, adapter aan).

Firefox staat in de officiële Arch-repositories (`firefox`). Visual Studio Code heet op Arch **`code`** (open-source build in `extra`; volledige Visual Studio IDE is alleen Windows/macOS). `install.sh` installeert beide samen met de overige pakketten. Waybar en **Super+Shift+C** starten VS Code via `scripts/launch-code.sh` (fallback: `code-oss`, `codium`). Voor een andere browser pas je `$browser` in `hypr/keybinds.conf` en `custom/browser` in `waybar/config.jsonc` aan. Voor een andere editor pas je `$editor`, `launch-code.sh` en `custom/code` aan.

Als pakketten niet bestaan op de distro van de gebruiker, moet de README uitleggen dat de gebruiker distro-specifieke pakketnamen moet gebruiken.

## Installatiescript

Het project moet een `install.sh` bevatten.

Het script moet:

- controleren of het vanaf de projectroot wordt gestart;
- controleren of `Background.jpg` of `assets/Background.jpg` bestaat;
- benodigde configuratiemappen maken;
- bestaande configs backuppen;
- nieuwe configs installeren;
- scripts executable maken;
- Waybar, Hyprland en Kitty configs plaatsen;
- wallpaper kopieren;
- uitleg tonen na installatie;
- nooit zomaar bestaande bestanden verwijderen zonder backup.

### Verwachte Installatiecommando's

De README moet aan gebruikers uitleggen:

```bash
chmod +x install.sh scripts/*.sh
./install.sh
```

Voer installatie uit **in je Linux Hyprland-sessie**, niet alleen vanuit Git Bash op Windows (zie Troubleshooting).

Na installatie start Hyprland automatisch na login op tty1 (`setup-bash-profile.sh` + `start-hyprland.sh`). Herstart daarna of log opnieuw in.

```bash
chmod +x uninstall.sh
./uninstall.sh
```

### Install Script Specificatie Voor Cursor

Cursor moet een `install.sh` genereren met ongeveer deze logica:

```bash
#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/big-sur-theme-backup-$(date +%Y%m%d-%H%M%S)"

echo "Installing Big Sur Hyprland theme..."

if [ ! -f "$PROJECT_DIR/assets/Background.jpg" ]; then
  echo "Missing assets/Background.jpg"
  exit 1
fi

mkdir -p "$BACKUP_DIR"
mkdir -p "$HOME/.config/hypr"
mkdir -p "$HOME/.config/waybar"
mkdir -p "$HOME/.config/kitty"
mkdir -p "$HOME/.config/rofi"
mkdir -p "$HOME/.config/dunst"
mkdir -p "$HOME/.config/hypr/big-sur"

backup_path() {
  local path="$1"
  if [ -e "$path" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${path#$HOME/.config/}")"
    cp -r "$path" "$BACKUP_DIR/${path#$HOME/.config/}"
  fi
}

backup_path "$HOME/.config/hypr/hyprland.conf"
backup_path "$HOME/.config/hypr/hyprpaper.conf"
backup_path "$HOME/.config/waybar/config.jsonc"
backup_path "$HOME/.config/waybar/style.css"
backup_path "$HOME/.config/kitty/kitty.conf"
backup_path "$HOME/.config/kitty/big-sur.conf"
backup_path "$HOME/.config/rofi/big-sur.rasi"
backup_path "$HOME/.config/dunst/dunstrc"

cp "$PROJECT_DIR/assets/Background.jpg" "$HOME/.config/hypr/big-sur/Background.jpg"
cp "$PROJECT_DIR/hypr/"*.conf "$HOME/.config/hypr/"
cp "$PROJECT_DIR/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
cp "$PROJECT_DIR/waybar/style.css" "$HOME/.config/waybar/style.css"
cp "$PROJECT_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
cp "$PROJECT_DIR/kitty/big-sur.conf" "$HOME/.config/kitty/big-sur.conf"

if [ -f "$PROJECT_DIR/rofi/big-sur.rasi" ]; then
  cp "$PROJECT_DIR/rofi/big-sur.rasi" "$HOME/.config/rofi/big-sur.rasi"
fi

if [ -f "$PROJECT_DIR/dunst/dunstrc" ]; then
  cp "$PROJECT_DIR/dunst/dunstrc" "$HOME/.config/dunst/dunstrc"
fi

chmod +x "$PROJECT_DIR/scripts/"*.sh 2>/dev/null || true

echo "Installation complete."
echo "Backup created at: $BACKUP_DIR"
echo "Reload Hyprland with: hyprctl reload"
echo "Restart Waybar if needed: pkill waybar && waybar &"
```

Cursor moet dit script waar nodig verbeteren, maar de basisprincipes moeten hetzelfde blijven:

- strict bash mode;
- backups;
- duidelijke foutmeldingen;
- geen destructieve acties zonder backup;
- projectroot detectie;
- bestandspaden met quotes.

## Uninstall Script

Het project mag ook een `uninstall.sh` maken. Dit script moet niet blind bestanden verwijderen. Het moet:

- uitleg tonen;
- vragen om bevestiging;
- thema-specifieke bestanden verwijderen;
- vertellen waar backups staan;
- geen willekeurige gebruikersconfiguratie wissen.

Voorbeeld:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "This will remove the Big Sur Hyprland theme files from ~/.config."
read -r -p "Continue? [y/N] " answer

case "$answer" in
  y|Y|yes|YES)
    rm -f "$HOME/.config/hypr/big-sur/Background.jpg"
    rm -f "$HOME/.config/kitty/big-sur.conf"
    rm -f "$HOME/.config/rofi/big-sur.rasi"
    echo "Theme-specific files removed."
    echo "Restore full configs manually from your backup directory if needed."
    ;;
  *)
    echo "Cancelled."
    ;;
esac
```

## Keybinds

Aanbevolen keybinds:

```ini
$mainMod = SUPER
$terminal = kitty
$fileManager = dolphin
$browser = firefox
$editor = bash "$HOME/.config/big-sur/scripts/launch-code.sh"
$menu = rofi -show drun -theme ~/.config/rofi/big-sur.rasi

bind = $mainMod, T, exec, $terminal
bind = $mainMod, Q, killactive
bind = $mainMod, M, exit
bind = $mainMod, E, exec, $fileManager
bind = $mainMod, B, exec, $browser
bind = $mainMod SHIFT, C, exec, $editor
bind = $mainMod, Space, exec, $menu
bind = $mainMod, L, exec, hyprlock
bind = $mainMod, V, togglefloating
bind = $mainMod, F, fullscreen

bind = , Print, exec, grim -g "$(slurp)" "$HOME/Pictures/Screenshot-$(date +%F-%H%M%S).png"
bind = $mainMod, Print, exec, grim "$HOME/Pictures/Screenshot-$(date +%F-%H%M%S).png"

binde = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
binde = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

binde = , XF86MonBrightnessUp, exec, brightnessctl set +5%
binde = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

# Convertible: schermrotatie (zelfde script als Waybar-knop)
bind = $mainMod SHIFT, R, exec, /usr/bin/bash "$HOME/.config/big-sur/scripts/rotate-display.sh"
```

Cursor moet deze keybinds splitsen naar `hypr/keybinds.conf` en vanuit `hyprland.conf` sourcen.

## Hyprland Config Indeling

Aanbevolen `hyprland.conf`:

```ini
source = ~/.config/hypr/theme.conf
source = ~/.config/hypr/keybinds.conf
source = ~/.config/hypr/windowrules.conf

exec-once = hyprpaper
exec-once = bash -c 'sleep 1; S="$HOME/.config/big-sur/scripts/start-waybar.sh"; if [ -x "$S" ]; then exec "$S"; else exec waybar; fi'
exec-once = dunst

monitor = ,preferred,auto,1

input {
    kb_layout = us
    follow_mouse = 1

    touchpad {
        natural_scroll = true
        tap-to-click = true
    }
}
```

Gebruikers moeten `kb_layout` kunnen aanpassen naar bijvoorbeeld:

```ini
kb_layout = us
```

of:

```ini
kb_layout = nl
```

## Window Rules

Hyprland 0.48+ gebruikt `windowrule` met expliciete `match:`-velden (niet meer `windowrulev2`). Vanaf 0.54+ moet elke named rule `name = ...` als eerste sleutel hebben. Aanbevolen regels in `hypr/windowrules.conf`:

```ini
windowrule {
    name = pavucontrol-float
    match:class = ^(pavucontrol)$
    float = on
    size = 760 520
    center = on
}

windowrule {
    name = blueman-manager-float
    match:class = ^(blueman-manager)$
    float = on
    center = on
}

windowrule {
    name = kitty-opacity
    match:class = ^(kitty)$
    opacity = 0.94 0.88
}
```

Op Hyprland 0.54+ is `bind = ..., togglesplit` vervangen door `bind = ..., layoutmsg, togglesplit` (dwindle-layout).

## Rofi Styling

Als rofi wordt gebruikt, moet het thema:

- donker transparant paneel hebben;
- Big Sur accentkleuren gebruiken;
- afgeronde hoeken;
- duidelijke geselecteerde regel;
- geen felle witte grote randen.

Voorbeeld:

```rasi
* {
    bg: rgba(23, 23, 56, 0.82);
    fg: #F5F7FA;
    muted: #D8DEE9;
    accent: #67C7E8;
    accent2: #B46CFF;
    danger: #C83A36;
}

window {
    transparency: "real";
    background-color: @bg;
    border: 1px;
    border-color: rgba(245, 247, 250, 0.16);
    border-radius: 18px;
}
```

## Dunst Styling

Dunst moet notificaties maken die lijken op kleine Big Sur popups:

- donker glasachtig paneel;
- afgeronde hoeken;
- subtiele border;
- cyaan/paarse accentlijn;
- rode urgent notifications.

Aanbevolen richting:

```ini
[global]
    corner_radius = 14
    frame_width = 1
    frame_color = "#67C7E8"
    separator_color = frame
    padding = 12
    horizontal_padding = 14
    background = "#171738"
    foreground = "#F5F7FA"
```

## Scripts

### `scripts/apply-wallpaper.sh`

Moet de wallpaper opnieuw toepassen.

Voor `hyprpaper` (zoals in `scripts/apply-wallpaper.sh`):

```bash
#!/usr/bin/env bash
set -euo pipefail

WALLPAPER="$HOME/.config/hypr/big-sur/Background.jpg"

hyprctl hyprpaper wallpaper ",$WALLPAPER,cover"
```

Voor `swww`:

```bash
#!/usr/bin/env bash
set -euo pipefail

WALLPAPER="$HOME/.config/hypr/big-sur/Background.jpg"

swww query >/dev/null 2>&1 || swww init
swww img "$WALLPAPER" --transition-type grow --transition-duration 1
```

### `scripts/start-waybar.sh`

Start Waybar veilig: controleert binary en `~/.config/waybar/config.jsonc`, stopt oude instanties, logt naar `~/.cache/big-sur/waybar.log`.

### `scripts/enable-audio.sh`

Schakelt de stock Arch **PipeWire** user-services in en start ze (`pipewire`, `pipewire-pulse`, `wireplumber`), controleert of ze actief zijn, en roept `fix-audio.sh --auto` aan om analoge laptop-speakers te prefereren. Wordt automatisch aangeroepen door `install.sh` op Linux met een actieve systemd user-sessie. Handmatig:

```bash
bash ~/.config/big-sur/scripts/enable-audio.sh
```

### `scripts/fix-audio.sh`

Diagnose en herstel wanneer je geen speakers ziet in pavucontrol of het verkeerde apparaat (HDMI) actief is:

```bash
bash ~/.config/big-sur/scripts/fix-audio.sh          # interactief: lijst sinks, kies uitgang
bash ~/.config/big-sur/scripts/fix-audio.sh --auto   # prefer analog/built-in speakers
wpctl status                                         # snelle status
```

### `scripts/toggle-osk.sh`

Schakelt een **Wayland-schermtoetsenbord** in/uit. Voorkeur: **wvkbd** (`wvkbd-deskintl` of `wvkbd-mobintl`). Valt terug op **onboard** als wvkbd ontbreekt. Waybar-knop `custom/keyboard` (󰌌) in `group/quick`.

**Geen systemd:** wvkbd is een gewoon proces — niet `systemctl enable wvkbd` (die unit bestaat niet).

```bash
bash ~/.config/big-sur/scripts/toggle-osk.sh
```

Arch: installeer via AUR (`yay -S wvkbd-deskintl`). `install.sh` installeert **onboard** uit pacman als fallback. Diagnose: `scripts/diagnose-convertible.sh`.

### `scripts/rotate-display.sh`

Roteert het **primaire paneel** (meestal `eDP-1` op laptops) in stappen **0° → 90° → 180° → 270°** via Hyprland:

```bash
hyprctl keyword monitor <naam>,transform,<0-3>
```

Waybar-knop `custom/rotate` (󰍹) en sneltoets **Super+Shift+R**. Status wordt bewaard in `~/.cache/big-sur/display-rotation`. Hyprland 0.54+: `hyprctl keyword monitor <naam>,transform,<0-3>` met fallback naar volledige monitor-regel; bij fouten `notify-send`. Als `hyprctl` niet beschikbaar is, valt het script terug op `wlr-randr --transform`.

### `scripts/diagnose-convertible.sh`

Optionele checklist voor vouw-laptops (HP EliteBook x360): scripts aanwezig/uitvoerbaar, Waybar-paden, wvkbd/onboard, `hyprctl monitors`, waarschuwing voor kanshi/shikane.

Handmatig:

```bash
bash ~/.config/big-sur/scripts/rotate-display.sh
```

### `scripts/launch-code.sh`

Start **Visual Studio Code** met fallback voor verschillende Arch-pakketten: `code` (officiële OSS-build in `extra`), `code-oss`, of `codium`. Waybar-knop `custom/code` (󰨞) en sneltoets **Super+Shift+C** gebruiken dit script.

```bash
bash ~/.config/big-sur/scripts/launch-code.sh
```

Als geen editor gevonden wordt: desktopmelding (indien `notify-send` beschikbaar) en fout op stderr.

### `scripts/reload-theme.sh`

Herlaadt Hyprland, start Waybar via `start-waybar.sh`, en past de wallpaper toe.

### `scripts/enable-network.sh`

Schakelt **NetworkManager** in (system-wide), zet WiFi-radio aan, toont `nmcli`-diagnose. Controleert **iwd**-conflicten (alleen één WiFi-backend tegelijk). Waybar wifi-knop opent `nm-connection-editor` — werkt alleen als NetworkManager draait.

```bash
bash ~/.config/big-sur/scripts/enable-network.sh
bash ~/.config/big-sur/scripts/enable-network.sh --connect "JouwSSID"
```

Wordt automatisch aangeroepen door `install.sh` op Linux.

### `scripts/enable-bluetooth.sh`

Schakelt **bluetooth.service** in (BlueZ), deblokkeert Bluetooth via `rfkill`, zet de adapter aan (`bluetoothctl power on`), toont status. Waybar 󰂯 opent `open-bluetooth.sh`.

```bash
bash ~/.config/big-sur/scripts/enable-bluetooth.sh
```

Wordt automatisch aangeroepen door `install.sh` op Linux (`-y`).

### `scripts/open-bluetooth.sh`

Opent **blueman-manager** als dat geïnstalleerd is; anders **bluetoothctl** in kitty/foot/alacritty.

```bash
bash ~/.config/big-sur/scripts/open-bluetooth.sh
```

### `scripts/start-hyprland.sh`

Start Hyprland op **tty1** na login (geen display manager). Wordt aangeroepen vanuit `~/.bash_profile`. Slaat over als `WAYLAND_DISPLAY` al gezet is of je niet op `/dev/tty1` zit. Probeert `Hyprland`, daarna `hyprland`.

### `scripts/setup-bash-profile.sh`

Voegt een gemarkeerd blok toe aan `~/.bash_profile` dat `~/.config/big-sur/scripts/start-hyprland.sh` aanroept. Idempotent (overslaat als markers al bestaan). Waarschuwt om SDDM uit te schakelen als je die eerder installeerde. Wordt automatisch door `install.sh` aangeroepen op Linux (`-y`).

```bash
bash ~/.config/big-sur/scripts/setup-bash-profile.sh
bash ~/.config/big-sur/scripts/setup-bash-profile.sh -y   # non-interactief
```

### `scripts/enable-graphical-login.sh`

**Niet onderdeel van de standaard Big Sur-installatie** (`install.sh` roept dit niet aan). Optioneel handmatig: installeert **SDDM** op Arch (optioneel **qt6ct** voor Qt6-thema), maakt basis `/etc/sddm.conf.d/`, schakelt `sddm.service` in.

```bash
./scripts/enable-graphical-login.sh
```

Als je SDDM gebruikt: schakel autostart in `~/.bash_profile` uit (markers `# >>> big-sur-hyprland autostart >>>`) om dubbele Hyprland-sessies te voorkomen.

Na installatie: **herstart**. Verwijder `exec Hyprland` uit `~/.bash_profile` / `~/.zprofile` als je van shell-autostart naar SDDM gaat.

### `scripts/backup-configs.sh`

Moet dezelfde backup-logica bevatten als `install.sh`, of door `install.sh` worden aangeroepen.

## README Moet Bevatten

Cursor moet deze README uiteindelijk omzetten naar een echte project-README met:

- projectnaam;
- screenshot of wallpaper preview;
- korte beschrijving;
- features;
- dependencies;
- installatie;
- handmatige installatie;
- projectstructuur;
- configuratie-uitleg;
- kleurenschema;
- troubleshooting;
- uninstall/restore;
- credits voor wallpaper als relevant;
- licentie-sectie.

## Handmatige Installatie

Naast `install.sh` moet de README ook handmatige installatie beschrijven:

```bash
mkdir -p ~/.config/hypr ~/.config/waybar ~/.config/kitty
cp -r hypr/*.conf ~/.config/hypr/
cp waybar/config.jsonc ~/.config/waybar/config.jsonc
cp waybar/style.css ~/.config/waybar/style.css
cp kitty/kitty.conf ~/.config/kitty/kitty.conf
cp kitty/big-sur.conf ~/.config/kitty/big-sur.conf
mkdir -p ~/.config/hypr/big-sur ~/.config/big-sur/scripts
cp assets/Background.jpg ~/.config/hypr/big-sur/Background.jpg
cp scripts/*.sh ~/.config/big-sur/scripts/
chmod +x ~/.config/big-sur/scripts/*.sh
hyprctl reload
pkill waybar && waybar &
```

## Troubleshooting

### Geen terminal bij opstarten

**Symptoom:** Na boot zie je Arch-prompt → logo → **tekstlogin (tty1)**. Pas na `login` + handmatig `Hyprland` kom je op de desktop.

**Oorzaak:** Hyprland start niet automatisch na shell-login, of SDDM blokkeert de tty1-flow.

**Standaard (Big Sur-thema):** `install.sh` kopieert `start-hyprland.sh` en roept `setup-bash-profile.sh -y` aan. Dat voegt aan `~/.bash_profile` toe:

```bash
# >>> big-sur-hyprland autostart >>>
# Start Hyprland na login op tty1 (geen SDDM)
if [ -z "${WAYLAND_DISPLAY:-}" ] && [ "$(tty 2>/dev/null || echo)" = "/dev/tty1" ]; then
  exec bash "$HOME/.config/big-sur/scripts/start-hyprland.sh"
fi
# <<< big-sur-hyprland autostart <<<
```

Log daarna uit en opnieuw in op tty1, of herstart:

```bash
cd /pad/naar/big-sur-hyprland-theme
chmod +x install.sh scripts/*.sh
./install.sh
sudo reboot
```

Handmatig (als autostart ontbreekt):

```bash
bash ~/.config/big-sur/scripts/setup-bash-profile.sh -y
sudo reboot
```

**SDDM uitschakelen:** dit thema installeert **geen** SDDM. Had je SDDM eerder ingeschakeld, zet die uit vóór je op tty1 inlogt:

```bash
sudo systemctl disable --now sddm.service
sudo reboot
```

**Niet verwarren met hyprlock:** hyprlock (Super+L) is alleen het vergrendelscherm *ná* Hyprland-start, niet de boot-flow vóór Hyprland.

**Optioneel — SDDM (grafisch inlogscherm, niet standaard):**

```bash
./scripts/enable-graphical-login.sh
sudo reboot
```

Kies op het SDDM-scherm sessie **Hyprland**. Verwijder het Big Sur-blok uit `~/.bash_profile` om dubbele starts te voorkomen.

**Alternatief:** `greetd` + `tuigreet` (minimalistisch). Zie [Arch Wiki SDDM](https://wiki.archlinux.org/title/SDDM) als je een display manager wilt.

### WiFi werkt niet (Hyprland / HP EliteBook x360)

Intel WiFi (`iwlwifi`) op EliteBook x360 vereist **NetworkManager**, firmware en geen conflict met **iwd**.

**Snel herstel:**

```bash
cd /pad/naar/big-sur-hyprland-theme
chmod +x scripts/enable-network.sh
./scripts/enable-network.sh
# verbinden:
./scripts/enable-network.sh --connect "JouwSSID"
```

**Pakketten** (zitten in `install.sh` / `ARCH_PACKAGES`):

```bash
sudo pacman -S --needed networkmanager network-manager-applet iw wireless-regdb linux-firmware
sudo systemctl enable --now NetworkManager
```

**Diagnose:**

```bash
systemctl status NetworkManager
nmcli radio wifi on
nmcli device status
nmcli dev wifi list
rfkill list
lsmod | grep iwlwifi
dmesg | grep -i iwl | tail
```

| Probleem | Oplossing |
|----------|-----------|
| `iwd` en NetworkManager tegelijk | `./scripts/enable-network.sh` (schakelt iwd uit) of `sudo systemctl disable --now iwd` |
| WiFi soft-blocked | `rfkill unblock wifi` |
| Geen netwerken in lijst | `sudo pacman -S linux-firmware`; herstart |
| Waybar wifi-knop doet niets | NetworkManager moet draaien; knop opent `nm-connection-editor` |
| Alleen ethernet werkt | Controleer BIOS: wireless enabled; kernel ≥ recent met iwlwifi |

**Waybar:** quick-bar icoon 󰖩 → `nm-connection-editor`. Status-icoon 󰤨 (`network`-module) toont signaal wanneer verbonden.

### Bluetooth / BlueZ werkt niet (Hyprland / HP EliteBook x360)

**Symptoom:** Bluetooth-icoon in Waybar (󰂯) opent niets, geen apparaten zichtbaar, of `bluetoothctl` meldt `Powered: no`.

**Oorzaak:** `bluetooth.service` niet ingeschakeld, adapter software-geblokkeerd (`rfkill`), of ontbrekende pakketten (`bluez`, `bluez-utils`, `blueman`).

**Snel herstel:**

```bash
cd /pad/naar/big-sur-hyprland-theme
chmod +x scripts/enable-bluetooth.sh scripts/open-bluetooth.sh
./scripts/enable-bluetooth.sh
# of via install (pakketten + service):
./install.sh -y
```

**Pakketten** (zitten in `install.sh` / `ARCH_PACKAGES`):

```bash
sudo pacman -S --needed bluez bluez-utils blueman
sudo systemctl enable --now bluetooth
rfkill unblock bluetooth
bluetoothctl power on
```

**Diagnose:**

```bash
systemctl status bluetooth
rfkill list
bluetoothctl show
bluetoothctl devices
dmesg | grep -i bluetooth | tail
```

| Probleem | Oplossing |
|----------|-----------|
| `bluetoothctl: command not found` | `sudo pacman -S bluez bluez-utils` |
| `Powered: no` | `bluetoothctl power on` of `./scripts/enable-bluetooth.sh` |
| Bluetooth soft-blocked (HP laptop) | `rfkill unblock bluetooth` — script doet dit automatisch |
| `bluetooth.service` inactive | `sudo systemctl enable --now bluetooth` |
| Waybar 󰂯 doet niets | `./install.sh` op Linux; knop roept `open-bluetooth.sh` aan (blueman of bluetoothctl) |
| Geen GUI, alleen CLI | `sudo pacman -S blueman` of `bluetoothctl` in terminal |
| Permissie / pairing | Optioneel: `sudo usermod -aG bluetooth "$USER"` en opnieuw inloggen |

**Waybar:** quick-bar icoon 󰂯 → `~/.config/big-sur/scripts/open-bluetooth.sh` (Blueman-manager, anders `bluetoothctl` in kitty).

### Visual Studio Code start niet (Waybar 󰨞 / Super+Shift+C)

**Symptoom:** Klik op het VS Code-icoon in de Waybar-dock (links) of druk **Super+Shift+C** — er gebeurt niets, of je ziet geen icoon.

**Oorzaak:** Het thema startte hardcoded `code`. Op Arch kan het binaire anders heten (`code`, `code-oss`, `codium`) of het pakket is niet geïnstalleerd. Hyprland/Waybar geven dan geen duidelijke fout.

**Snel herstel:**

```bash
cd /pad/naar/big-sur-hyprland-theme
chmod +x scripts/launch-code.sh
./install.sh          # kopieert script + configs naar ~/.config
# of alleen het script:
cp scripts/launch-code.sh ~/.config/big-sur/scripts/
chmod +x ~/.config/big-sur/scripts/launch-code.sh
hyprctl reload
pkill waybar; ~/.config/big-sur/scripts/start-waybar.sh
```

**Diagnose:**

```bash
which code code-oss codium 2>/dev/null
command -v code || command -v code-oss || command -v codium
bash ~/.config/big-sur/scripts/launch-code.sh   # moet VS Code openen
```

**Pakket installeren** (kies één):

```bash
sudo pacman -S code          # Visual Studio Code (OSS) — staat in install.sh ARCH_PACKAGES
# alternatieven:
sudo pacman -S code-oss      # community build
yay -S codium-bin            # VSCodium (AUR)
```

| Probleem | Oplossing |
|----------|-----------|
| `code: command not found` | `sudo pacman -S code` of gebruik `launch-code.sh` (valt terug op code-oss/codium) |
| Icoon ontbreekt in Waybar | `custom/code` staat in `group/launchers`; herinstalleer configs via `./install.sh` |
| Sneltoets werkt niet | `hyprctl reload` na wijziging in `keybinds.conf`; geen conflict — alleen **Super+Shift+C** is gebonden |
| Klik werkt, toets niet (of omgekeerd) | Beide moeten `launch-code.sh` aanroepen; sync configs opnieuw |
| Script niet gevonden | `./install.sh` in **Linux Hyprland-sessie** (niet vanuit Windows Git Bash) |

**Waybar:** dock-icoon 󰨞 → `launch-code.sh`. **Keybind:** Super+Shift+C (zelfde launcher).

### Configs Verschijnen Niet In Je Hyprland-sessie

Als je `install.sh` vanaf **Windows (Git Bash)** hebt gedraaid, staan de bestanden in je **Windows**-profiel, bijvoorbeeld:

```text
C:\Users\<jouw-naam>\.config\hypr\
```

Hyprland op **Linux** leest `~/.config` in je **Linux**-home (bijv. `/home/<jouw-naam>/.config`), niet de Windows-map.

**Oplossing (kies één):**

1. **Opnieuw installeren in je Hyprland-sessie** (aanbevolen):

```bash
cd /pad/naar/big-sur-hyprland-theme
chmod +x install.sh scripts/*.sh
./install.sh
```

Het script toont `CONFIG_DIR` en waarschuwt als je op Windows draait.

2. **Kopiëren vanaf een eerdere Windows-installatie** (dual boot / VM met gedeelde schijf):

```bash
./scripts/sync-to-linux-home.sh /mnt/c/Users/<jouw-naam>/.config
hyprctl reload
pkill waybar; waybar &
```

3. **Expliciet doelpad** (bijv. andere gebruiker of test):

```bash
./install.sh --config-dir "$HOME/.config"
# of
BIG_SUR_CONFIG_DIR="$HOME/.config" ./install.sh
```

Controleer in Hyprland waar configs staan:

```bash
echo "$HOME"
ls -la ~/.config/hypr/hyprland.conf
hyprctl reload
```

### Installatie Vanaf Windows (Git Bash)

- Paketten (`pacman`) worden overgeslagen; alleen configs worden gekopieerd.
- Gebruik `./install.sh` **niet** als vervanging voor installatie op Linux, tenzij je bewust naar Windows `.config` schrijft.
- Na bevestiging (`-y`) of interactieve waarschuwing worden exacte paden getoond.

### Wallpaper Verschijnt Niet

Controleer:

```bash
ls ~/.config/hypr/big-sur/Background.jpg
```

Controleer daarna of `hyprpaper` draait:

```bash
pgrep hyprpaper
```

Start opnieuw:

```bash
hyprpaper &
```

Of gebruik het script:

```bash
scripts/apply-wallpaper.sh
```

### Waybar niet zichtbaar / Waybar start niet

**Snel herstellen (in je Hyprland-sessie op Linux):**

```bash
# Na install.sh of sync:
~/.config/big-sur/scripts/start-waybar.sh

# Of vanuit de projectmap:
./scripts/reload-theme.sh
```

**Controlelijst (NL / EN):**

| Probleem | Oplossing |
|----------|-----------|
| Configs staan op Windows, niet in Linux `~/.config` | `./install.sh` in Hyprland, of `./scripts/sync-to-linux-home.sh /mnt/c/Users/.../.config` |
| `waybar` niet geïnstalleerd | `sudo pacman -S waybar` (of distro-equivalent) |
| Geen `~/.config/waybar/config.jsonc` | `./install.sh` of handmatig kopiëren uit `waybar/` |
| Waybar start te vroeg na login | `hypr/hyprland.conf` gebruikt `sleep 1` + `start-waybar.sh`; na wijziging: `hyprctl reload` en script opnieuw |
| Proces crasht direct | `waybar` in terminal (fout op stderr) of log: `~/.cache/big-sur/waybar.log` |
| Oude Waybar (< 0.9.17) | `waybar --version` — **groups** (`group/launchers`) vereisen recente Waybar |
| Alleen iconen ontbreken | Nerd Font: `sudo pacman -S ttf-jetbrains-mono-nerd`, daarna Waybar herstarten |
| VS Code-icoon / Super+Shift+C doet niets | `sudo pacman -S code`; test `bash ~/.config/big-sur/scripts/launch-code.sh` — zie [Visual Studio Code start niet](#visual-studio-code-start-niet-waybar--supershiftc) |

**Diagnose:**

```bash
command -v waybar
ls -la ~/.config/waybar/config.jsonc ~/.config/waybar/style.css
pgrep -a waybar
waybar --version
waybar   # stop met Ctrl+C na controle; fouten verschijnen in de terminal
```

**Hyprland autostart** (in `~/.config/hypr/hyprland.conf` na installatie):

```ini
exec-once = hyprpaper
exec-once = bash -c 'sleep 1; S="$HOME/.config/big-sur/scripts/start-waybar.sh"; if [ -x "$S" ]; then exec "$S"; else exec waybar; fi'
exec-once = dunst
```

Veel voorkomende oorzaken:

- fout in `config.jsonc` (JSONC-syntax, onbekende module);
- fout in `style.css`;
- ontbrekend font (bar kan wel starten, iconen ontbreken);
- Waybar niet in PATH / niet geïnstalleerd;
- configs niet in Linux-home (`/home/joey/.config`, niet `C:\Users\...\.config`).

### Kitty Theme Werkt Niet

Controleer of `kitty.conf` dit bevat:

```conf
include big-sur.conf
```

Controleer of het bestand bestaat:

```bash
ls ~/.config/kitty/big-sur.conf
```

### Icons Ontbreken

Installeer een Nerd Font:

```bash
sudo pacman -S ttf-jetbrains-mono-nerd
```

Daarna Waybar opnieuw starten:

```bash
pkill waybar
waybar &
```

### Batterij Toont Geen Percentage

In `waybar/config.jsonc` gebruikt de `battery`-module `{icon} {capacity}%` (niet alleen het icoon). Na wijziging:

```bash
pkill waybar && ~/.config/big-sur/scripts/start-waybar.sh
```

Tooltip toont ook `{capacity}%` en resterende tijd (`{time}`). Waarschuwing/kritiek via `states` (30% / 15%) en CSS `#battery.warning` / `#battery.critical`.

Installeer **upower** (staat in `install.sh`); zonder dit pakket kan Waybar soms 0% of een leeg icoon tonen op laptops:

```bash
sudo pacman -S upower
upower -i /org/freedesktop/UPower/devices/battery_BAT0
```

Controleer welke batterij-naam je systeem gebruikt:

```bash
ls /sys/class/power_supply/
```

Staat er `BAT1` in plaats van `BAT0`, pas dan in `waybar/config.jsonc` aan: `"bat": "BAT1"`.

### HP EliteBook x360 / convertible laptops

Dit thema werkt op een **HP EliteBook x360** (2-in-1 business-laptop) zonder speciale aanpassingen voor het merk. De meeste problemen komen **niet** door HP/Hyprland-incompatibiliteit, maar door ontbrekende pakketten, verkeerde installatiepad (Windows vs Linux `~/.config`), of laptop-specifieke randzaken hieronder.

| Onderdeel | Op EliteBook x360 | In dit thema |
|-----------|-------------------|--------------|
| Grafiek | Meestal **Intel** (geen NVIDIA-driver-gedoe) | Geen GPU-specifieke config nodig |
| WiFi | Vaak **Intel** (`iwlwifi`); soms Realtek op oudere modellen | NetworkManager + `enable-network.sh`; Waybar wifi-knop → `nm-connection-editor` |
| Bluetooth | Vaak **Intel**; rfkill-blok op HP | `bluez` + `bluez-utils` + `blueman` + `enable-bluetooth.sh`; Waybar 󰂯 → `open-bluetooth.sh` |
| Batterij | Eén interne batterij (`BAT0`); zelden twee | Waybar `battery` met `"bat": "BAT0"` + pakket **upower** |
| Touchpad | Werkt via Hyprland `input { touchpad { ... } }` | `natural_scroll`, `tap-to-click` in `hypr/hyprland.conf` |
| Touchscreen | Vaak Wacom/ELAN; werkt vaak out-of-the-box als pointer | Geen aparte tablet-modus in Hyprland-config |
| Schermtoetsenbord | Handig in tablet-/vouwstand | Waybar 󰌌 → `toggle-osk.sh` (**wvkbd**) |
| Schermrotatie (handmatig) | Geen automatische G-sensor-rotate | Waybar 󰍹 of **Super+Shift+R** → `rotate-display.sh` (0°→90°→180°→270°) |
| Auto-rotate (tablet) | **Niet** ingebouwd | Optioneel later: `iio-sensor-proxy` + script |
| Vingerafdruk | Vaak **niet** bruikbaar zonder extra drivers (`fprintd`) | Niet onderdeel van het thema |
| Suspend / fan | Standaard kernel/ACPI | Geen thema-specifieke instellingen |

**Veelvoorkomende klachten op deze laptop:**

1. **Waybar ontbreekt helemaal** — Meestal configs in `C:\Users\...\.config` i.p.v. Linux `/home/<user>/.config`. Oplossing: `./install.sh` **in je Hyprland-sessie** of `sync-to-linux-home.sh` (zie [Configs Verschijnen Niet](#configs-verschijnen-niet-in-je-hyprland-sessie)).

2. **Leeg batterij-icoon of 0%** — Installeer `upower`, controleer `BAT0` vs `BAT1`, herstart Waybar. Soms helpt `systemctl enable --now upower` (user-service niet altijd nodig; daemon draait system-wide).

3. **WiFi werkt niet / icoon blijft los** — `./scripts/enable-network.sh`; firmware `linux-firmware`; geen iwd+NM tegelijk. Waybar 󰖩 → `nm-connection-editor` (alleen als NetworkManager actief is).

3b. **Bluetooth werkt niet** — `./scripts/enable-bluetooth.sh`; `rfkill unblock bluetooth`; `bluetoothctl power on`. Waybar 󰂯 → `open-bluetooth.sh`. Zie [Bluetooth / BlueZ werkt niet](#bluetooth--bluez-werkt-niet-hyprland--hp-elitebook-x360).

3c. **VS Code start niet (󰨞 / Super+Shift+C)** — Installeer `code` (`sudo pacman -S code`) of test `bash ~/.config/big-sur/scripts/launch-code.sh`. Zie [Visual Studio Code start niet](#visual-studio-code-start-niet-waybar--supershiftc).

4. **Boot vraagt terminal-login vóór desktop** — `./install.sh` op Linux (autostart via `setup-bash-profile.sh`). SDDM uit? `sudo systemctl disable --now sddm.service`. Zie [Geen terminal bij opstarten](#geen-terminal-bij-opstarten).

5. **Touchscreen reageert niet / alleen touchpad** — Controleer in Hyprland: `hyprctl devices` (touch-device zichtbaar?). Soms ontbreken firmware-pakketten (`linux-firmware`).

6. **Verticaal / tablet-modus (vouw-laptop)** — Na `./install.sh` op Linux:
   - **Rotatie:** klik 󰍹 in Waybar of druk **Super+Shift+R** (elke druk: 0° → 90° → 180° → 270°). Script: `~/.config/big-sur/scripts/rotate-display.sh`. Vereist Hyprland (`hyprctl keyword monitor eDP-1,transform,<0-3>`) of fallback `wlr-randr`.
   - **Schermtoetsenbord:** klik 󰌌 in Waybar → `toggle-osk.sh` (wvkbd of onboard-fallback). AUR: `yay -S wvkbd-deskintl`; of `sudo pacman -S onboard` / `./install.sh -y`. Geen `systemctl enable wvkbd`.
   - **Werkt niets:** `bash ~/.config/big-sur/scripts/diagnose-convertible.sh` — zie [Schermtoetsenbord / rotatie werkt niet](#schermtoetsenbord--rotatie-werkt-niet-waybar---).
   - Draai je fysiek het scherm zonder knop: er is **geen** automatische rotatie; gebruik de Waybar-knop of sneltoets.
   - Werkt rotatie niet terwijl `hyprctl` “ok” zegt: controleer of **kanshi/shikane** niet tegelijk je monitors beheert (die overschrijven `hyprctl keyword`). Zie [Hyprland monitors](https://wiki.hypr.land/Configuring/Monitors/).

7. **Helderheidstoetsen (Fn)** — Thema gebruikt `brightnessctl` (in `hypr/keybinds.conf`). Als toetsen niets doen: `brightnessctl info` en eventueel `brightnessctl --list`.

**Snelle diagnose op de EliteBook (in Hyprland-terminal):**

```bash
ls /sys/class/power_supply/
upower -e | grep -i bat
nmcli -t -f ACTIVE,SSID dev wifi
bash ~/.config/big-sur/scripts/enable-bluetooth.sh
bluetoothctl show
hyprctl devices
hyprctl monitors | grep -E '^Monitor|transform'
bash ~/.config/big-sur/scripts/diagnose-convertible.sh
bash ~/.config/big-sur/scripts/rotate-display.sh
bash ~/.config/big-sur/scripts/toggle-osk.sh
~/.config/big-sur/scripts/start-waybar.sh
```

Na wijzigingen aan `waybar/config.jsonc`: `pkill waybar && ~/.config/big-sur/scripts/start-waybar.sh`.

### Schermtoetsenbord / rotatie werkt niet (Waybar 󰌌 / 󰍹)

**Symptoom:** Klik op het toetsenbord- of rotatie-icoon in Waybar doet niets; **Super+Shift+R** roteert niet; geen melding of OSK verschijnt niet.

**Veelvoorkomende oorzaken:**

| Oorzaak | Oplossing |
|---------|-----------|
| Scripts staan niet in Linux `~/.config` | Alleen `./install.sh` **in Hyprland** (niet alleen configs vanaf Windows kopiëren). Na `sync-to-linux-home.sh` worden scripts nu ook gekopieerd — anders ontbreken `toggle-osk.sh` / `rotate-display.sh`. |
| Scripts niet uitvoerbaar | `chmod +x ~/.config/big-sur/scripts/*.sh` of opnieuw `./install.sh -y` |
| `wvkbd` niet geïnstalleerd | AUR: `yay -S wvkbd-deskintl`. Fallback: `sudo pacman -S onboard` (wordt door `install.sh` meegeïnstalleerd). |
| Rotatie: `hyprctl` zegt ok maar scherm draait niet | Externe monitor-daemon (**kanshi** / **shikane**) overschrijft Hyprland — uitschakelen of rotatie daar configureren. |
| Rotatie: verkeerde monitor | Script kiest `eDP-*` automatisch; controleer met `hyprctl monitors`. |

**Diagnose (op de laptop, in Hyprland-terminal):**

```bash
cd ~/Pictures/Apple   # of je clone-pad
./install.sh -y       # scripts + configs naar ~/.config
bash ~/.config/big-sur/scripts/diagnose-convertible.sh
```

**Handmatig testen:**

```bash
bash ~/.config/big-sur/scripts/toggle-osk.sh
bash ~/.config/big-sur/scripts/rotate-display.sh
hyprctl monitors | grep -E '^Monitor|transform'
```

**Waybar herladen na config-wijziging:**

```bash
pkill waybar
~/.config/big-sur/scripts/start-waybar.sh
```

Waybar gebruikt expliciet: `/usr/bin/bash "$HOME/.config/big-sur/scripts/toggle-osk.sh"` en hetzelfde voor `rotate-display.sh`.

### Schermtoetsenbord: `error target not found wvkbd`

**Symptoom:** `error: target not found: wvkbd` (soms verkeerd gelezen als `WVkBD`) tijdens `./install.sh` of `pacman -S wvkbd`.

**Oorzaak:** `wvkbd` staat **niet** in de officiële Arch-repositories — alleen in de **AUR**. Dit is een **pacman**-fout, geen systemd-service.

**Oplossing:**

```bash
# Installeer via AUR-helper (yay of paru):
yay -S wvkbd-deskintl    # aanbevolen op HP EliteBook x360 / touch
# of:
yay -S wvkbd               # levert wvkbd-mobintl

# Toggle (geen systemctl):
bash ~/.config/big-sur/scripts/toggle-osk.sh
```

Gebruik **niet** `systemctl enable wvkbd` — er is geen `wvkbd.service` op Arch.

### SDDM / grafisch inloggen: `error target not found qt6-ct`

**Symptoom:** `error: target not found: qt6-ct` tijdens `./scripts/enable-graphical-login.sh`.

**Oorzaak:** Het pakket heet op Arch **`qt6ct`** (zonder streepje), repository **extra** — niet `qt6-ct`. SDDM zelf heeft **qt6ct niet nodig**; het is alleen een optionele Qt6-configuratietool.

**Oplossing:**

```bash
# Vereist voor grafisch inloggen:
sudo pacman -S --needed sddm hyprland
sudo systemctl enable --now sddm.service

# Optioneel (Qt6-thema voor SDDM-greeter):
sudo pacman -S --needed qt6ct

# Of opnieuw via het script (installeert sddm; qt6ct faalt niet de rest):
./scripts/enable-graphical-login.sh -y
sudo reboot
```

### Geen Geluid / Waybar Volume Werkt Niet

Arch gebruikt PipeWire; Waybar blijft de module-naam `pulseaudio` gebruiken (compat via `pipewire-pulse`).

1. Installeer pakketten (of `./install.sh` op Linux):

```bash
sudo pacman -S --needed pipewire pipewire-pulse pipewire-alsa wireplumber pavucontrol alsa-utils alsa-firmware sof-firmware
```

2. Schakel user-services in:

```bash
systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service
# of:
bash ~/.config/big-sur/scripts/enable-audio.sh
```

3. Controleer:

```bash
wpctl status
pactl info   # Server Name: PulseAudio (on PipeWire ...)
```

4. Herstart Waybar na installatie.

### Speakers Niet Zichtbaar in pavucontrol

Op een HP EliteBook (Intel) heet de uitgang vaak **Built-in Audio Analog Stereo**, niet letterlijk "Speakers". Waybar opent pavucontrol via het audio-icoon (quick bar en volume in de statusbalk).

1. **Services en firmware**

```bash
sudo pacman -S --needed pipewire pipewire-pulse pipewire-alsa wireplumber pavucontrol alsa-utils alsa-firmware sof-firmware
bash ~/.config/big-sur/scripts/enable-audio.sh
```

2. **Diagnose — zijn er sinks?**

```bash
wpctl status
pactl list sinks short
systemctl --user status pipewire wireplumber pipewire-pulse
```

Geen sinks → meestal `wireplumber` niet actief of Intel-firmware ontbreekt (`sof-firmware`). Herstart services of log opnieuw in.

3. **Verkeerd profiel (HDMI i.p.v. speakers)**

Open pavucontrol → tabblad **Configuratie** → kies **Analog Stereo** (niet HDMI / DisplayPort). Tabblad **Uitgang** → selecteer **Built-in Audio** en zet volume omhoog (niet gedempt).

4. **Automatisch standaard uitgang instellen**

```bash
bash ~/.config/big-sur/scripts/fix-audio.sh --auto
# of interactief:
bash ~/.config/big-sur/scripts/fix-audio.sh
speaker-test -c 2 -t wav -l 1
```

5. **Waybar toont geen volume**

Controleer `pactl info` (Server Name: PulseAudio on PipeWire). Herstart Waybar:

```bash
pkill waybar && ~/.config/big-sur/scripts/start-waybar.sh
```

Hover over het volume-icoon in Waybar: tooltip toont `{desc}` (actieve sink-naam).

### Hyprland Config Geeft Fouten

Bekijk Hyprland logs:

```bash
hyprctl systeminfo
journalctl --user -xe
```

Controleer of gebruikte configopties nog geldig zijn voor jouw Hyprland-versie.

## Cursor Opdracht

Gebruik onderstaande opdracht in Cursor om het echte project te laten genereren.

```text
Maak van deze README een volledig Hyprland theme project.

Gebruik Background.jpg als wallpaper en plaats deze in assets/Background.jpg.

Genereer alle bestanden volgens de projectstructuur:
- install.sh
- uninstall.sh
- hypr/hyprland.conf
- hypr/hyprpaper.conf
- hypr/theme.conf
- hypr/keybinds.conf
- hypr/windowrules.conf
- waybar/config.jsonc
- waybar/style.css
- kitty/kitty.conf
- kitty/big-sur.conf
- rofi/big-sur.rasi
- dunst/dunstrc
- scripts/apply-wallpaper.sh
- scripts/start-hyprland.sh
- scripts/setup-bash-profile.sh
- scripts/reload-theme.sh
- scripts/backup-configs.sh

Gebruik een macOS Big Sur kleurenschema dat past bij Background.jpg:
deep navy, cyan, violet, red, frost white en glassmorphism panels.

Zorg dat install.sh:
- strict bash gebruikt;
- bestaande configs backupt;
- geen bestanden verwijdert zonder backup;
- duidelijke output geeft;
- paden correct quote;
- controleert of assets/Background.jpg bestaat;
- alle configs naar ~/.config kopieert;
- scripts executable maakt.

Zorg dat de README een volledige gebruikershandleiding wordt met installatie, handmatige installatie, dependencies, troubleshooting, restore en uninstall.
```

## Acceptatiecriteria

Het project is klaar als:

- `install.sh` zonder syntaxfouten draait;
- bestaande configs eerst worden gebackupt;
- `Background.jpg` wordt geinstalleerd;
- Hyprland de wallpaper laadt;
- Waybar bovenaan verschijnt met Big Sur styling;
- Kitty het Big Sur kleurenthema gebruikt;
- rofi of wofi past bij de rest van de desktop;
- notificaties visueel aansluiten;
- alle scripts uitvoerbaar zijn;
- de README volledig uitlegt hoe installatie en herstel werken.

## Licentie

Gebruik bijvoorbeeld:

```text
MIT License
```

Let op: als de wallpaper niet zelfgemaakt is, vermeld dan de bron of houd de wallpaper buiten de licentie van de code.

