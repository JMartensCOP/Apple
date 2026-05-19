# Big Sur Hyprland Theme

Een uitgebreid projectplan voor een macOS Big Sur-geinspireerd Hyprland-thema met Waybar, Kitty en een meegeleverde wallpaper. Dit document is bedoeld als briefing voor Cursor of een andere code-assistent om het volledige thema te bouwen, inclusief configuratiebestanden, styling, scripts en installatie-uitleg.

De wallpaper voor dit project is:

```text
Background.jpg
```

Deze afbeelding moet worden gebruikt als standaardachtergrond van het Hyprland-thema.

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
│   └── Background.jpg
├── hypr/
│   ├── hyprland.conf
│   ├── hyprpaper.conf
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
    ├── reload-theme.sh
    └── backup-configs.sh
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

Waybar moet voelen als een zwevende Big Sur menubar:

- semi-transparante achtergrond;
- blur-effect waar mogelijk;
- afgeronde modules;
- subtiele borders;
- rustige spacing;
- duidelijke iconen;
- actieve workspace met cyaan/paarse highlight;
- waarschuwingen in rood;
- batterijstatus;
- netwerkstatus;
- klok;
- audio;
- tray;
- CPU/RAM optioneel;
- backlight indien beschikbaar.

### Waybar Modules

Aanbevolen modules:

```jsonc
{
  "layer": "top",
  "position": "top",
  "height": 34,
  "spacing": 8,
  "modules-left": ["hyprland/workspaces"],
  "modules-center": ["clock"],
  "modules-right": ["pulseaudio", "network", "battery", "tray"]
}
```

### Waybar CSS Richting

De Waybar CSS moet ongeveer deze stijl volgen:

```css
* {
  font-family: "SF Pro Display", "Inter", "JetBrainsMono Nerd Font", sans-serif;
  font-size: 13px;
  border: none;
  border-radius: 0;
  min-height: 0;
}

window#waybar {
  background: rgba(23, 23, 56, 0.62);
  color: #f5f7fa;
  border-bottom: 1px solid rgba(245, 247, 250, 0.14);
}

#workspaces button {
  color: #d8dee9;
  background: transparent;
  padding: 0 10px;
  margin: 5px 2px;
  border-radius: 999px;
}

#workspaces button.active {
  color: #171738;
  background: linear-gradient(135deg, #67c7e8, #b46cff);
}

#clock,
#pulseaudio,
#network,
#battery,
#tray {
  background: rgba(245, 247, 250, 0.10);
  color: #f5f7fa;
  padding: 0 12px;
  margin: 5px 3px;
  border-radius: 999px;
  border: 1px solid rgba(245, 247, 250, 0.12);
}
```

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

Hyprpaper-config:

```ini
preload = ~/.config/hypr/big-sur/Background.jpg
wallpaper = ,~/.config/hypr/big-sur/Background.jpg
```

Als `swww` wordt gebruikt:

```bash
swww img "$HOME/.config/hypr/big-sur/Background.jpg" --transition-type grow --transition-duration 1
```

Cursor mag kiezen tussen `hyprpaper` en `swww`, maar moet in de README vermelden welke dependency wordt gebruikt.

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
networkmanager
ttf-jetbrains-mono-nerd
inter-font
```

Voor Arch:

```bash
sudo pacman -S hyprland waybar kitty hyprpaper rofi-wayland dunst wl-clipboard grim slurp brightnessctl playerctl pavucontrol networkmanager ttf-jetbrains-mono-nerd inter-font
```

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
chmod +x install.sh
./install.sh
```

Optioneel:

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
$menu = rofi -show drun -theme ~/.config/rofi/big-sur.rasi

bind = $mainMod, Return, exec, $terminal
bind = $mainMod, Q, killactive
bind = $mainMod, M, exit
bind = $mainMod, E, exec, $fileManager
bind = $mainMod, Space, exec, $menu
bind = $mainMod, V, togglefloating
bind = $mainMod, F, fullscreen

bind = , Print, exec, grim -g "$(slurp)" "$HOME/Pictures/Screenshot-$(date +%F-%H%M%S).png"
bind = $mainMod, Print, exec, grim "$HOME/Pictures/Screenshot-$(date +%F-%H%M%S).png"

binde = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
binde = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

binde = , XF86MonBrightnessUp, exec, brightnessctl set +5%
binde = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
```

Cursor moet deze keybinds splitsen naar `hypr/keybinds.conf` en vanuit `hyprland.conf` sourcen.

## Hyprland Config Indeling

Aanbevolen `hyprland.conf`:

```ini
source = ~/.config/hypr/theme.conf
source = ~/.config/hypr/keybinds.conf
source = ~/.config/hypr/windowrules.conf

exec-once = waybar
exec-once = hyprpaper
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

Aanbevolen regels:

```ini
windowrulev2 = float,class:^(pavucontrol)$
windowrulev2 = size 760 520,class:^(pavucontrol)$
windowrulev2 = center,class:^(pavucontrol)$

windowrulev2 = float,class:^(blueman-manager)$
windowrulev2 = center,class:^(blueman-manager)$

windowrulev2 = opacity 0.94 0.88,class:^(kitty)$
```

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

Voor `hyprpaper`:

```bash
#!/usr/bin/env bash
set -euo pipefail

WALLPAPER="$HOME/.config/hypr/big-sur/Background.jpg"

hyprctl hyprpaper unload all || true
hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper ",$WALLPAPER"
```

Voor `swww`:

```bash
#!/usr/bin/env bash
set -euo pipefail

WALLPAPER="$HOME/.config/hypr/big-sur/Background.jpg"

swww query >/dev/null 2>&1 || swww init
swww img "$WALLPAPER" --transition-type grow --transition-duration 1
```

### `scripts/reload-theme.sh`

Moet Hyprland en Waybar reloaden:

```bash
#!/usr/bin/env bash
set -euo pipefail

hyprctl reload
pkill waybar || true
waybar >/tmp/waybar-big-sur.log 2>&1 &
```

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
mkdir -p ~/.config/hypr/big-sur
cp assets/Background.jpg ~/.config/hypr/big-sur/Background.jpg
hyprctl reload
pkill waybar && waybar &
```

## Troubleshooting

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

### Waybar Start Niet

Run Waybar handmatig:

```bash
waybar
```

Veel voorkomende oorzaken:

- fout in `config.jsonc`;
- fout in `style.css`;
- ontbrekend font;
- ontbrekende module zoals battery op desktop-pc;
- oude Waybar-versie.

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

