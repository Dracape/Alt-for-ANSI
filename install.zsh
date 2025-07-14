#!/usr/bin/zsh

if (( EUID != 0 )); then
  echo "This script must be run as root"
  exit 1
fi

echo "--- Starting Setup ---"

# --- 1. Install Dependencies ---
echo "[1/7] Checking dependencies..."

missing=()
for cmd in rustc intercept udevmon; do
    if ! command -v $cmd >/dev/null; then
        missing+=("$cmd")
    fi
done

if (( ${#missing[@]} > 0 )); then
    echo "Missing required tools: ${missing[@]}"
    echo "Attempting to install..."

    if command -v apt >/dev/null; then
        apt update
        apt install -y rustc interception-tools
    elif command -v dnf >/dev/null; then
        dnf install -y rustc interception-tools
    elif command -v pacman >/dev/null; then
        pacman -Syu --noconfirm rust interception-tools
    else
        echo "ERROR: Unsupported package manager. Install these manually: ${missing[@]}"
        exit 1
    fi

    # Re-check
    for cmd in "${missing[@]}"; do
        if ! command -v $cmd >/dev/null; then
            echo "ERROR: $cmd still not found after installation. Aborting."
            exit 1
        fi
    done

    echo "All dependencies installed successfully."
else
    echo "All required dependencies are present."
fi

# --- 2. Compile and Install Word Caps Plugin ---
echo "[2/7] Compiling and installing the 'wordcaps' plugin..."
if [[ ! -f ./plugins/word-caps.rs ]]; then
    echo "ERROR: ./plugins/word-caps.rs not found. Aborting."; exit 1
fi
if ! rustc -C opt-level=2 -o /usr/local/bin/wordcaps ./plugins/word-caps.rs; then
    echo "ERROR: Compilation of 'wordcaps' failed. Aborting."; exit 1
fi
echo "'wordcaps' plugin installed successfully."

# --- 3. Compile and Install Home Row Mods Plugin ---
echo "[3/7] Compiling and installing the 'homerowmods' plugin..."
if [[ ! -f ./plugins/home-row-mods.rs ]]; then
    echo "ERROR: ./plugins/home-row-mods.rs not found. Aborting."; exit 1
fi
if ! rustc -C opt-level=2 -o /usr/local/bin/homerowmods ./plugins/home-row-mods.rs; then
    echo "ERROR: Compilation of 'homerowmods' failed. Aborting."; exit 1
fi
echo "'homerowmods' plugin installed successfully."

# --- 4. Create Final Interception Tools Configuration ---
echo "[4/7] Creating final udevmon configuration..."
mkdir -p /etc/interception
cat > /etc/interception/udevmon.yaml << 'EOF'
- JOB: intercept -g $DEVNODE | homerowmods | wordcaps | uinput -d $DEVNODE
  DEVICE:
    HAS_PROPS:
      - INPUT_PROP_KEYBOARD
EOF
echo "Configuration created at /etc/interception/udevmon.yaml."

# --- 5. Enable and Restart udevmon ---
echo "[5/7] Restarting service..."
systemctl enable udevmon.service &> /dev/null
systemctl restart udevmon.service

echo
echo "--- SUCCESS ---"
echo "Setup complete"
echo "✔ Word Caps and Home Row Mods installed from source"
echo "✔ Configuration applied"
