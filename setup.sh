#!/bin/bash

# Install Wine
sudo apt-get update
sudo apt-get install -y wine

# Set execute permission on the metaeditor file
cd /path/to/app/directory
chmod +x metaeditor
