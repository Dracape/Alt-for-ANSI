#!/usr/bin/zsh
cd "$(dirname "$0")"
set -euo pipefail

echo "[1/3] Compiling rr-shift"
rustc -C opt-level=2 "source/rr-shift.rs" -o /usr/local/bin/rr-shift

echo "[2/3] Setting up udevmon"
cat > /etc/interception/udevmon.yaml << 'EOF'
- JOB: "intercept -g $DEVNODE | rr-shift | uinput -d $DEVNODE"
  DEVICE:
    HAS_PROPS:
      - INPUT_PROP_KEYBOARD
EOF

echo "[3/3] Restarting udevmon"
systemctl restart udevmon.service

echo "✔ Plugin 'rr-shift' (Right-ring shift) installed and udevmon configured."
