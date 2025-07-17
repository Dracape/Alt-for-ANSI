#!/usr/bin/zsh
cd "$(dirname "$0")"
set -euo pipefail

echo "[1/3] Installing dependencies (interception-tools, rustc)"
if ! command -v interception-tools >/dev/null || ! command -v rustc >/dev/null; then
  echo "Installing..."
  if command -v pacman >/dev/null; then
    pacman -Sy --noconfirm interception-tools rust
  elif command -v apt >/dev/null; then
    apt update && apt install -y interception-tools rustc
  elif command -v dnf >/dev/null; then
    dnf install -y interception-tools rust
  else
    echo "Unsupported package manager. Install 'interception-tools' and 'rustc' manually." >&2
    exit 1
  fi
else
  echo "Dependencies already installed."
fi

echo "[2/3] Compiling plugins"
mkdir -p /usr/local/bin
rustc -C opt-level=2 "source/word-caps.rs" -o /usr/local/bin/wordcaps
rustc -C opt-level=2 "source/home-row-mods.rs" -o /usr/local/bin/homerowmods

echo "[3/3] Setting up udevmon"
mkdir -p /etc/interception
cat > /etc/interception/udevmon.yaml << 'EOF'
- JOB: "intercept -g $DEVNODE | homerowmods | wordcaps | uinput -d $DEVNODE"
  DEVICE:
    HAS_PROPS:
      - INPUT_PROP_KEYBOARD
EOF

systemctl enable udevmon &> /dev/null || true
systemctl restart udevmon

echo "✔ Plugins installed and udevmon configured."
