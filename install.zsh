#!/usr/bin/zsh

# Prepare directory
rm -rf /tmp/graphene/*
mkdir /tmp/graphene
cd /tmp/graphene

# Download files
aria2c https://raw.githubusercontent.com/Dracape/graphene/main/graphite
aria2c https://raw.githubusercontent.com/xedrac/graphite-layout/main/linux/install.sh
aria2c https://raw.githubusercontent.com/xedrac/graphite-layout/main/linux/graphite.xslt

# Make the script executable
chmod +x ./install.sh

# Install
./install.sh

cd ~

# Clean up
rm -f /tmp/graphene
