#!/usr/bin/bash

set -e

PREV_DIR=$(pwd)
REPONAME='modANSI'
MAIN_DIR=/tmp/"$REPONAME"

GRAPHENE_INSTALL_SCRIPT_DIR="$MAIN_DIR"/layouts/graphene/install
MIDNIGHT_INSTALL_SCRIPT_DIR="$MAIN_DIR"/layouts/midnight/install

cd /tmp

rm -rf "$REPONAME"
git clone https://github.com/Dracape/"$REPONAME".git
cd "$REPONAME"/layouts


# Layouts
chmod +x "$GRAPHENE_INSTALL_SCRIPT_DIR"/install.sh "$MIDNIGHT_INSTALL_SCRIPT_DIR"/install.sh

cd "$GRAPHENE_INSTALL_SCRIPT_DIR"
sudo ./install.sh


cd "$MIDNIGHT_INSTALL_SCRIPT_DIR"
sudo ./install.sh

# Shift Preservation types
EXTRA_PATH="/usr/share/X11/xkb/types/extra"
TYPE_NAME="FOUR_LEVEL_SHIFT_PRESERVE"
## Symbols layer
TYPE_DEFINITION='
    type "FOUR_LEVEL_SHIFT_PRESERVE" {
	modifiers = Shift + LevelThree;
	map[None] = Level1;
	map[Shift] = Level2;
	map[LevelThree] = Level3;
	map[Shift+LevelThree] = Level3;
	preserve[Shift+LevelThree] = Shift;
	level_name[Level1] = "Base";
	level_name[Level2] = "Shift";
	level_name[Level3] = "AltGr";
	level_name[Level4] = "Shift AltGr";
    };
'

if ! grep -q "$TYPE_NAME" "$EXTRA_PATH"; then
  TMP_FILE=$(mktemp)
  awk -v def="$TYPE_DEFINITION" '/^};/ {print def} {print}' "$EXTRA_PATH" > "$TMP_FILE"
  sudo tee "$EXTRA_PATH" < "$TMP_FILE" > "/dev/null"
  rm "$TMP_FILE"
  echo "Successfully added the $TYPE_NAME type."
else
  echo "The $TYPE_NAME type already exists. No changes made."
fi

## Base layer
TYPE_NAME="SHIFT_PRESERVES_LEVEL1"
TYPE_DEFINITION='
    type "SHIFT_PRESERVES_LEVEL1" {
	modifiers = Shift + LevelThree;
	map[None] = Level1;
	map[Shift] = Level1;
	map[LevelThree] = Level3;
	map[Shift+LevelThree] = Level4;
	preserve[Shift] = Shift;
	level_name[Level1] = "Base";
	level_name[Level2] = "Shift";
	level_name[Level3] = "AltGr";
	level_name[Level4] = "Shift AltGr";
    };
'

if ! grep -q "$TYPE_NAME" "$EXTRA_PATH"; then
  TMP_FILE=$(mktemp)
  awk -v def="$TYPE_DEFINITION" '/^};/ {print def} {print}' "$EXTRA_PATH" > "$TMP_FILE"
  sudo tee "$EXTRA_PATH" < "$TMP_FILE" > /dev/null
  rm "$TMP_FILE"
  echo "Successfully added the $TYPE_NAME type."
else
  echo "The $TYPE_NAME type already exists. No changes made."
fi

echo ""
echo "Successfully installed!"

# Choose layout
echo "Select a layout to activate:"
echo "1) Mid-Night"
echo "2) Graphene"

read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        localectl set-x11-keymap us pc105 midnight
        sudo localectl set-x11-keymap us pc105 midnight
        gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us+midnight')]"
        echo "Mid-Night layout activated."
        ;;
    2)
        localectl set-x11-keymap us pc105 graphene
        sudo localectl set-x11-keymap us pc105 graphene
        gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us+graphene')]"
        echo "Graphene layout activated."
        ;;
    *)
        echo "Invalid choice. Please run the script again and select 1 or 2."
        ;;
esac

# Clean up
echo ''
rm -rf "$MAIN_DIR"
cd "$PREV_DIR"
