#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LEXBOR_DIR="$SCRIPT_DIR/lexbor"
LEXBOR_TAG="v2.6.0"

# Check prerequisites
for cmd in cmake make cc; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' is required but not found. Please install it first."
        exit 1
    fi
done

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

cd "$LEXBOR_DIR"
LEXBOR_VERSION=$(git describe --tags 2>/dev/null || echo "unknown")
echo "Building lexbor ${LEXBOR_VERSION} static library..."

mkdir -p build
cd build
cmake .. -DLEXBOR_BUILD_SHARED=OFF -DLEXBOR_BUILD_STATIC=ON -DCMAKE_C_FLAGS="-fPIC"
make -j$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)

if [ -f "liblexbor_static.a" ]; then
    echo "Success: liblexbor_static.a built at $LEXBOR_DIR/build/liblexbor_static.a"
else
    echo "Error: liblexbor_static.a not found after build"
    exit 1
fi
