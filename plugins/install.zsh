#!/usr/bin/zsh

set -euo pipefail

echo "[1/4] Verifying required tools (interception-tools, rustc)"

check_missing=()

if ! command -v udevmon &>/dev/null; then
  check_missing+=("interception-tools")
fi

if ! command -v rustc &>/dev/null; then
  check_missing+=("rust")
fi

if (( ${#check_missing[@]} > 0 )); then
  echo "Missing dependencies: $check_missing"
  echo "Attempting to install..."

  if command -v pacman &>/dev/null; then
    pacman -Sy --noconfirm "${check_missing[@]}"
  elif command -v apt &>/dev/null; then
    apt update && apt install -y "${check_missing[@]}"
  elif command -v dnf &>/dev/null; then
    dnf install -y "${check_missing[@]}"
  else
    echo "Unsupported package manager. Install ${check_missing[*]} manually." >&2
    exit 1
  fi
fi

echo "[2/4] Compiling plugins from ./source/"

SOURCE_DIR="$(dirname "$0")/source"

for src in "$SOURCE_DIR"/*.rs; do
  name="$(basename "$src" .rs)"
  echo " → Compiling $name..."
  rustc -C opt-level=2 -o "/usr/local/bin/$name" "$src"
done

echo "[3/4] Writing udevmon configuration"

mkdir -p /etc/interception
cat > /etc/interception/udevmon.yaml << 'EOF'
- JOB: "intercept -g $DEVNODE | homerowmods | wordcaps | uinput -d $DEVNODE"
  DEVICE:
    HAS_PROPS:
      - "INPUT_PROP_KEYBOARD"
EOF

echo "[4/4] Enabling and restarting udevmon"

systemctl enable udevmon &>/dev/null || true
systemctl restart udevmon

echo "✔ Plugin installation complete."
