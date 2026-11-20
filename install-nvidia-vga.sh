#!/usr/bin/env bash
# Instalator konfiguracji X11 dla GTX 750 Ti + przejściówka DVI->VGA bez EDID.
# Wrzuca plik 20-nvidia.conf do /etc/X11/xorg.conf.d/
set -euo pipefail

DEST_DIR="/etc/X11/xorg.conf.d"
DEST_FILE="$DEST_DIR/20-nvidia.conf"

if [[ $EUID -ne 0 ]]; then
    echo "Uruchom jako root:  sudo $0"
    exit 1
fi

mkdir -p "$DEST_DIR"

# Kopia zapasowa, jeśli plik już istnieje
if [[ -f "$DEST_FILE" ]]; then
    BACKUP="$DEST_FILE.bak.$(date +%Y%m%d-%H%M%S)"
    cp -a "$DEST_FILE" "$BACKUP"
    echo "Zrobiono kopię zapasową: $BACKUP"
fi

cat > "$DEST_FILE" << 'EOF'
Section "ServerLayout"
    Identifier     "Layout0"
    Screen      0  "Screen0" 0 0
    Option         "Xinerama" "0"
EndSection

Section "Monitor"
    Identifier     "Monitor0"
    VendorName     "Unknown"
    ModelName      "CRT-0"
    HorizSync       30.0 - 83.0
    VertRefresh     56.0 - 76.0
    ModeLine       "1440x900_75.00" 136.750 1440 1536 1688 1936 900 903 909 942 -hsync +vsync
    Option         "PreferredMode" "1440x900_75.00"
    Option         "DPMS"
EndSection

Section "Device"
    Identifier     "Device0"
    Driver         "nvidia"
    VendorName     "NVIDIA Corporation"
    BoardName      "NVIDIA GeForce GTX 750 Ti"
    Option         "UseEDID" "false"
    Option         "UseEDIDFreqs" "false"
EndSection

Section "Screen"
    Identifier     "Screen0"
    Device         "Device0"
    Monitor        "Monitor0"
    DefaultDepth    24
    Option         "Stereo" "0"
    Option         "nvidiaXineramaInfoOrder" "DVI-I-0"
    Option         "metamodes" "DVI-I-0: 1440x900_75.00 +0+0"
    Option         "SLI" "Off"
    Option         "MultiGPU" "Off"
    Option         "BaseMosaic" "off"
    SubSection     "Display"
        Depth       24
    EndSubSection
EndSection
EOF

chmod 644 "$DEST_FILE"
echo "Zainstalowano: $DEST_FILE"

# Ostrzeżenie, jeśli nie ma sterownika NVIDIA
if ! command -v nvidia-smi >/dev/null 2>&1 && ! lsmod | grep -q '^nvidia'; then
    echo
    echo "UWAGA: nie widzę zainstalowanego sterownika NVIDIA."
    echo "Ta konfiguracja działa tylko z zamkniętym sterownikiem (Debian: pakiet nvidia-driver)."
fi

echo
echo "Gotowe! Zrestartuj system (lub sesję graficzną), żeby zmiany zaczęły działać."
