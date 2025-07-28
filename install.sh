#!/usr/bin/sh

# Prepare directory
rm -rf /tmp/graphene/*
mkdir /tmp/graphene
cd /tmp/graphene

# Download files
aria2c https://raw.githubusercontent.com/Dracape/graphene/main/graphite
aria2c https://raw.githubusercontent.com/xedrac/graphite-layout/main/linux/graphite.xslt
aria2c https://raw.githubusercontent.com/xedrac/graphite-layout/main/linux/install.sh

# Make the script executable
chmod +x ./install.sh

# Install
./install.sh

cd ~

# Clean up
rm -rf /tmp/graphene/
