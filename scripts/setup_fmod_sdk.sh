#!/bin/bash
# MIT License
#
# Copyright (c) 2026 Poing Studios

# scripts/setup_fmod_sdk.sh
# Sets up FMOD Engine SDK in platforms/gdextension/thirdparty/fmod

FMOD_DEST="platforms/gdextension/thirdparty/fmod"

show_help() {
    echo "Usage: ./scripts/setup_fmod_sdk.sh [path_to_fmod_sdk_installation]"
    echo ""
    echo "Copies or symlinks an existing FMOD Engine 2.03.x SDK directory into: $FMOD_DEST"
    echo ""
    echo "Examples:"
    echo "  ./scripts/setup_fmod_sdk.sh /Applications/FMOD\\ Programmers\\ API\\ Mac"
    echo "  ./scripts/setup_fmod_sdk.sh /opt/fmodstudioapi203"
    echo "  ./scripts/setup_fmod_sdk.sh \"C:/Program Files (x86)/FMOD SoundSystem/FMOD Studio API Windows\""
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi

if [ -n "$1" ]; then
    SRC_DIR="$1"
    if [ ! -d "$SRC_DIR" ]; then
        echo "Error: Directory '$SRC_DIR' not found."
        exit 1
    fi

    mkdir -p "$FMOD_DEST"
    echo ">>> Copying FMOD SDK from '$SRC_DIR' to '$FMOD_DEST'..."
    cp -R "$SRC_DIR"/api "$FMOD_DEST"/ 2>/dev/null || cp -R "$SRC_DIR"/* "$FMOD_DEST"/

    # Setup local demo banks if found in SDK examples
    if [ -d "$SRC_DIR/api/studio/examples/media" ]; then
        mkdir -p "platforms/godot_editor/banks/Desktop"
        cp "$SRC_DIR"/api/studio/examples/media/*.bank "platforms/godot_editor/banks/Desktop/" 2>/dev/null
        echo ">>> Copied sample audio banks to platforms/godot_editor/banks/Desktop (ignored by git)"
    fi

    echo ">>> FMOD SDK setup complete in $FMOD_DEST"
    exit 0
fi

# Check if already present
if [ -d "$FMOD_DEST/api/core/inc" ] || [ -d "$FMOD_DEST/core/inc" ]; then
    echo ">>> FMOD SDK is already configured in $FMOD_DEST"
    exit 0
fi

echo "================================================================="
echo " FMOD SDK 2.03.x Setup"
echo "================================================================="
echo "1. Download the FMOD Engine 2.03.x SDK from: https://fmod.com/download"
echo "2. Run this script pointing to your installed/extracted FMOD SDK:"
echo "   ./scripts/setup_fmod_sdk.sh <path_to_fmod_sdk>"
echo "================================================================="
exit 1
