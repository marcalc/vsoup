#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

JSOUP_VERSION="${JSOUP_VERSION:-1.22.1}"
JSOUP_JAR="$SCRIPT_DIR/jsoup-${JSOUP_VERSION}.jar"
JSOUP_URL="https://repo1.maven.org/maven2/org/jsoup/jsoup/${JSOUP_VERSION}/jsoup-${JSOUP_VERSION}.jar"
HTML_FILE="$PROJECT_DIR/lexbor/benchmarks/lexbor/selectors/files/average.html"

# Check prerequisites
for cmd in java javac curl; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' is required but not found."
        exit 1
    fi
done

if [ ! -f "$HTML_FILE" ]; then
    echo "Error: HTML fixture not found at $HTML_FILE"
    echo "Run 'git submodule update --init' first."
    exit 1
fi

# Download jar if missing
if [ ! -f "$JSOUP_JAR" ]; then
    echo "Downloading jsoup ${JSOUP_VERSION} from Maven Central..."
    curl -fSL -o "$JSOUP_JAR" "$JSOUP_URL"
    echo "Saved to $JSOUP_JAR"
fi

# Compile
echo "Compiling JsoupBenchmark.java..."
javac -cp "$JSOUP_JAR" "$SCRIPT_DIR/JsoupBenchmark.java" -d "$SCRIPT_DIR"

# Run
echo ""
java -cp "$JSOUP_JAR:$SCRIPT_DIR" JsoupBenchmark "$HTML_FILE"
