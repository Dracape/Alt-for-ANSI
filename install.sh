#!/usr/bin/env bash

set -e

case $1 in
	-l)
		MAIN_DIR=$PWD
		;;
	*)
		REPONAME='Alt-for-ANSI'
		MAIN_DIR="$(mktemp --directory "${TMPDIR:-/tmp}"'/'"$REPONAME"'-XXXXXXXXXXX')"
		git clone --filter=blob:none https://github.com/Dracape/"$REPONAME".git "$MAIN_DIR"
		;;
esac

MIDNIGHT_INSTALL_SCRIPT_DIR="$MAIN_DIR"/layouts/midnight/install
GRAPHENE_INSTALL_SCRIPT_DIR="$MAIN_DIR"/layouts/graphene/install

cd "$MAIN_DIR"/layouts

# Layouts
chmod +x {"$GRAPHENE_INSTALL_SCRIPT_DIR","$MIDNIGHT_INSTALL_SCRIPT_DIR"}/install.sh

cd "$GRAPHENE_INSTALL_SCRIPT_DIR"
sudo ./install.sh


cd "$MIDNIGHT_INSTALL_SCRIPT_DIR"
sudo ./install.sh

# Shift Preservation types
sudo mv "$MAIN_DIR"/types /usr/share/xkeyboard-config-2/types/alt-for-ansi && echo "Successfully wrote the new types"

COMPLETE_PATH="/usr/share/xkeyboard-config-2/types/complete"
INCLUDE_STATEMENT='    include "alt-for-ansi"'

if ! grep -q "$INCLUDE_STATEMENT" "$COMPLETE_PATH"; then
    TMP_FILE=$(mktemp)
    awk -v inc="$INCLUDE_STATEMENT" '/^};/ {print inc} {print}' "$COMPLETE_PATH" > "$TMP_FILE"
    sudo tee "$COMPLETE_PATH" < "$TMP_FILE" > /dev/null
    rm "$TMP_FILE"
    echo "Successfully added include statement to $COMPLETE_PATH"
else
    echo "Include statement already exists in $COMPLETE_PATH. No changes made."
fi

echo ''
echo 'Successfully installed!'

# Choose layout
echo 'Select a layout to activate:'
echo '1) Mid-Night'
echo '2) Graphene'

read -p 'Enter your choice (1 or 2): ' -n 1 -r choice

case $choice in
    1)
        if [ "$(localectl status | grep 'X11 Variant: ' | cut -f 5 -d ' ')" != "midnight" ]; then
        	localectl set-x11-keymap us pc105 midnight
        	sudo localectl set-x11-keymap us pc105 midnight
        fi
	# Set for Compositor
	if [ "$XDG_CURRENT_DESKTOP" == "GNOME" ]; then
    		gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us+midnight')]"

	elif [ "$XDG_CURRENT_DESKTOP" == "KDE" ]; then
    		kwriteconfig6 --file kxkbrc --group Layout --key LayoutList us
    		kwriteconfig6 --file kxkbrc --group Layout --key VariantList midnight
    		dbus-send --session --type=signal --reply-timeout=100 --dest=org.kde.keyboard /Layouts org.kde.keyboard.reloadConfig

	else
    		if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
        		echo "You're running Wayland with a compositor other than GNOME or KDE"
        		echo "I don't know how to enable the layout for your compositor."
        		echo "You will need to manually enable it in your window manager."
        		exit 1
    		else
        		setxkbmap us -variant midnight
    		fi
	fi
        echo "Mid-Night layout activated."
        ;;
    2)
        if [ "$(localectl status | grep 'X11 Variant: ' | cut -f 5 -d ' ')" != "graphene" ]; then
        	localectl set-x11-keymap us pc105 graphene
        	sudo localectl set-x11-keymap us pc105 graphene
        fi
        # Set for Compositor
	if [ "$XDG_CURRENT_DESKTOP" == "GNOME" ]; then
    		gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us+graphene')]"

	elif [ "$XDG_CURRENT_DESKTOP" == "KDE" ]; then
    		kwriteconfig6 --file kxkbrc --group Layout --key LayoutList us
    		kwriteconfig6 --file kxkbrc --group Layout --key VariantList graphene
    		dbus-send --session --type=signal --reply-timeout=100 --dest=org.kde.keyboard /Layouts org.kde.keyboard.reloadConfig

	else
    		if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
        		echo "You're running Wayland with a compositor other than GNOME or KDE"
        		echo "You will need to manually enable it in your window manager."
        		exit 1
    		else
        		setxkbmap us -variant graphene
    		fi
	fi
        echo "Graphene layout activated."
        ;;
    *)
        echo "Invalid choice. No layout activated"
        ;;
esac

# Clean up
echo ''
rm -rf "$MAIN_DIR"
