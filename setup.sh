#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LEXBOR_DIR="$SCRIPT_DIR/lexbor"
LEXBOR_TAG="v2.6.0"

# Get lexbor source if needed
if [ ! -f "$LEXBOR_DIR/CMakeLists.txt" ]; then
    if [ -f "$SCRIPT_DIR/.gitmodules" ]; then
        echo "Initializing lexbor submodule..."
        cd "$SCRIPT_DIR"
        git submodule update --init
    else
        echo "Cloning lexbor ${LEXBOR_TAG}..."
        git clone --depth 1 --branch "$LEXBOR_TAG" https://github.com/nicktrandafil/lexbor.git "$LEXBOR_DIR"
    fi
fi

if [ ! -f "$LEXBOR_DIR/CMakeLists.txt" ]; then
    echo "Error: lexbor source not found at $LEXBOR_DIR"
    exit 1
fi

echo "Lexbor ${LEXBOR_TAG} source ready at $LEXBOR_DIR"

# Generate per-module unity build files from lexbor source tree
bash "$SCRIPT_DIR/generate_unity.sh"
