#!/usr/bin/zsh

# Prepare directory
rm -rf /tmp/graphene/*
mkdir /tmp/graphene

# Prepare files
aria2c -d /tmp/graphene https://raw.githubusercontent.com/Dracape/graphene/main/graphite https://raw.githubusercontent.com/xedrac/graphite-layout/main/linux/install.sh https://raw.githubusercontent.com/xedrac/graphite-layout/main/linux/graphite.xslt
chmod +x /tmp/graphene/install.sh

# Install
cd /tmp/graphene
./install.sh

# Clean up
rm -f /tmp/graphene
