#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LEXBOR_DIR="$SCRIPT_DIR/lexbor"

# Check prerequisites
for cmd in cmake make cc; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' is required but not found. Please install it first."
        exit 1
    fi
done

# Initialize submodule if needed
if [ -f "$SCRIPT_DIR/.gitmodules" ] && [ ! -f "$LEXBOR_DIR/CMakeLists.txt" ]; then
    echo "Initializing lexbor submodule..."
    cd "$SCRIPT_DIR"
    git submodule update --init
fi

if [ ! -d "$LEXBOR_DIR" ]; then
    echo "Error: lexbor directory not found at $LEXBOR_DIR"
    echo "Run: git submodule update --init"
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
