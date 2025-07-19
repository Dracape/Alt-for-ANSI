#!/usr/bin/zsh

# Prepare directory
rm -rf /tmp/graphene/*
mkdir /tmp/graphene
cd /tmp/graphene

# Prepare files
aria2c https://raw.githubusercontent.com/Dracape/graphene/main/graphite https://raw.githubusercontent.com/xedrac/graphite-layout/main/linux/install.sh https://raw.githubusercontent.com/xedrac/graphite-layout/main/linux/graphite.xslt
chmod +x /tmp/graphene/install.sh

# Install
./install.sh

# Clean up
rm -f /tmp/graphene
