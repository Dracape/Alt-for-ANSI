#!/usr/bin/zsh
cd "$(dirname "$0")"
set -euo pipefail

echo "[1/3] Compiling home-row-mods"
rustc -C opt-level=2 "source/home-row-mods.rs" -o /usr/local/bin/homerowmods

echo "[2/3] Setting up udevmon"
cat > /etc/interception/udevmon.yaml << 'EOF'
- JOB: "intercept -g $DEVNODE | homerowmods | uinput -d $DEVNODE"
  DEVICE:
    HAS_PROPS:
      - INPUT_PROP_KEYBOARD
EOF

echo "[3/3] Restarting udevmon"
systemctl restart udevmon.service

echo "✔ Plugin installed and udevmon configured (without wordcaps)."
