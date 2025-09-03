#!/usr/bin/sh

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
./install.sh


cd "$MIDNIGHT_INSTALL_SCRIPT_DIR"
./install.sh

# Shift Preservation types
EXTRA_PATH="/usr/share/X11/xkb/types/extra"
TYPE_NAME="FOUR_LEVEL_SHIFT_PRESERVE"
## Symbols layer
TYPE_DEFINITION='''
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
'''

if ! grep -q "$TYPE_NAME" "$EXTRA_PATH"; then
  TMP_FILE=$(mktemp)
  sed '/^};/i'"$TYPE_DEFINITION"'' "$EXTRA_PATH" > "$TMP_FILE"
  tee "$EXTRA_PATH" < "$TMP_FILE" > /dev/null
  rm "$TMP_FILE"
  echo "Successfully added the $TYPE_NAME type."
else
  echo "The $TYPE_NAME type already exists. No changes made."
fi

## Base layer
TYPE_NAME="SHIFT_PRESERVES_LEVEL1"
TYPE_DEFINITION='''
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
'''

if ! grep -q "$TYPE_NAME" "$EXTRA_PATH"; then
  TMP_FILE=$(mktemp)
  sed '/^};/i'"$TYPE_DEFINITION"'' "$EXTRA_PATH" > "$TMP_FILE"
  tee "$EXTRA_PATH" < "$TMP_FILE" > /dev/null
  rm "$TMP_FILE"
  echo "Successfully added the $TYPE_NAME type."
else
  echo "The $TYPE_NAME type already exists. No changes made."
fi


# Clean up
echo ''
rm -rf "$MAIN_DIR"
cd "$PREV_DIR"
