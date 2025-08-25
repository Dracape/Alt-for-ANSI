#!/usr/bin/sh

# Prepare directory
rm -rf /tmp/graphene/*
mkdir /tmp/graphene
cd /tmp/graphene

# Download files
wget https://raw.githubusercontent.com/Dracape/graphene/main/xkb-layouts/graphite
wget https://raw.githubusercontent.com/xedrac/graphite-layout/main/linux/graphite.xslt
wget https://raw.githubusercontent.com/xedrac/graphite-layout/main/linux/install.sh

# Make the script executable
chmod +x ./install.sh

# Install
./install.sh

cd -

# Clean up
rm -rf /tmp/graphene/
