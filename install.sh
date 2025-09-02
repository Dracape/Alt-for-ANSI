#!/usr/bin/sh

PREV_DIR=$(pwd)
REPONAME='modANSI'
GRAPHENE_INSTALL_SCRIPT_DIR=graphene/install
MIDNIGHT_INSTALL_SCRIPT_DIR=midnight/install

cd /tmp

rm -rf "$REPONAME"
git clone https://github.com/Dracape/"$REPONAME".git
cd "$REPONAME"/layouts

# Make the scripts executable
chmod +x "$GRAPHENE_INSTALL_SCRIPT_DIR"/install.sh "$MIDNIGHT_INSTALL_SCRIPT_DIR"/install.sh

# Install
cd "$GRAPHENE_INSTALL_SCRIPT_DIR"
./install.sh

cd "$MIDNIGHT_INSTALL_SCRIPT_DIR"
./install.sh


cd "$PREV_DIR"

# Clean up
rm -rf /tmp/"$REPONAME"
