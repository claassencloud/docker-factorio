#!/usr/bin/env bash

# Entrypoint script for Factorio headless server

set -e

# Copy default server settings if it doesn't exist
if [[ ! -f write-data/server-settings.json ]]; then
  # Move default settings if server-settings.json doesn't exist
  echo "server-settings.json doesn't exist, creating..."
  cp server-settings.json write-data/server-settings.json
else
  echo "server-settings.json exists!"
fi

# Update server password
sed -i "s/\"game_password\": \"\"/\"game_password\": \"$FACTORIO_GAME_PASSWORD\"/" write-data/server-settings.json

# Create a save if one does not exist
if [[ ! -f saves/save.zip ]]; then
  echo "Default save doesn't exist, creating..."
  ./bin/x64/factorio --create saves/save.zip
else 
  echo "Default save exists!"
fi

# Start the server
./bin/x64/factorio --start-server saves/save.zip --server-settings write-data/server-settings.json
