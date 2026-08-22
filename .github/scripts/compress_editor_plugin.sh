#!/bin/bash
set -e

# MIT License
#
# Copyright (c) 2026 Poing Studios

echo ">>> Compressing Godot FMOD Plugin..."

cd platforms/godot_editor

RAW_VERSION=$(grep "version=" addons/godot_fmod/plugin.cfg | cut -d'"' -f2)
CH_VERSION=${RAW_VERSION#v}
ZIP_NAME="godot-fmod-v${CH_VERSION}.zip"

echo "Version detected: $CH_VERSION"

mkdir -p build_stage/addons
cp -R addons/godot_fmod build_stage/addons/

cd build_stage
zip -qr "$ZIP_NAME" addons

mv "$ZIP_NAME" ../
cd ..
rm -rf build_stage

echo ">>> Successfully created platforms/godot_editor/$ZIP_NAME"

if [ -n "$GITHUB_ENV" ]; then
    echo "ZIP_NAME=$ZIP_NAME" >> "$GITHUB_ENV"
    echo "PLUGIN_TAG=v$CH_VERSION" >> "$GITHUB_ENV"
fi
