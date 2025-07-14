#!/usr/bin/zsh

set -euo pipefail

# Abort if not running as root
if (( EUID != 0 )); then
  echo "This script must be run as root." >&2
  exit 1
fi

# Define working paths
WORKDIR="/tmp/graphene"
LAYOUT_DIR="$WORKDIR/layout"

echo "[0/5] Cleaning workspace"
rm -rf "$WORKDIR"

echo "[1/5] Cloning 'plugins/' and 'graphite' from graphene repository"
git clone --depth=1 --filter=blob:none --sparse https://github.com/DestroyerBDT/graphene.git "$WORKDIR"
git -C "$WORKDIR" sparse-checkout set plugins graphite

# Prepare layout directory
mkdir -p "$LAYOUT_DIR"
mv "$WORKDIR/graphite" "$LAYOUT_DIR/graphite"

echo "[2/5] Cloning layout installer components from graphite-layout"
git clone --depth=1 --filter=blob:none --sparse https://github.com/xedrac/graphite-layout.git "$WORKDIR/.tmp-layout"
git -C "$WORKDIR/.tmp-layout" sparse-checkout set linux/install.sh linux/graphite.xslt

mv "$WORKDIR/.tmp-layout/linux/install.sh" "$LAYOUT_DIR/install.sh"
mv "$WORKDIR/.tmp-layout/linux/graphite.xslt" "$LAYOUT_DIR/graphite.xslt"
rm -rf "$WORKDIR/.tmp-layout"

echo "[3/5] Running layout installer"
chmod +x "$LAYOUT_DIR/install.sh"
( cd "$LAYOUT_DIR" && ./install.sh )

echo "[4/5] Executing plugin installation script"
"$WORKDIR/plugins/install.zsh"

echo "[5/5] Cleaning up temporary installation files"
rm -rf "$WORKDIR"

echo "✔ Installation complete."
