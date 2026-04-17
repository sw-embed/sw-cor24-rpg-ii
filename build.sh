#!/usr/bin/env bash
set -euo pipefail

# sw-cor24-rpg-ii -- Build script
# Usage:
#   ./build.sh              Assemble check only
#   ./build.sh run          Build and run on emulator
#   ./build.sh test         Run test suite
#   ./build.sh clean        Remove build artifacts

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

HLASM_SRC="rpg2.hlasm"
HLASM_STAGE0="../sw-cor24-hlasm/hlasm.s"
BUILD_DIR="build"
RPG2_GEN="$BUILD_DIR/rpg2.generated.s"
RPG2_LEGACY="rpg2.s"
SRC_LOAD_ADDR=524288
DECK_LOAD_ADDR=589824
TEST_DECK="test_deck.bin"
RUN="cor24-run"

if ! command -v cor24-run &>/dev/null; then
    echo "ERROR: cor24-run not found. Build sw-cor24-emulator first."
    exit 1
fi

if [[ ! -f "$HLASM_SRC" ]]; then
    echo "ERROR: $HLASM_SRC not found."
    exit 1
fi

if [[ ! -f "$HLASM_STAGE0" ]]; then
    echo "ERROR: $HLASM_STAGE0 not found."
    exit 1
fi

if [[ ! -f "$TEST_DECK" ]]; then
    echo "ERROR: $TEST_DECK not found."
    exit 1
fi

generate() {
    mkdir -p "$BUILD_DIR"
    echo "=== Generating $RPG2_GEN from $HLASM_SRC ==="
    $RUN --run "$HLASM_STAGE0" --load-binary "$HLASM_SRC@$SRC_LOAD_ADDR" \
        --speed 0 -n 2000000 2>&1 \
        | awk '
            BEGIN { capture = 0 }
            /^UART output:/ {
                capture = 1
                sub(/^UART output: /, "")
                gsub(/\r/, "")
                print
                next
            }
            capture && /^Executed / { capture = 0; next }
            capture {
                gsub(/\r/, "")
                print
            }
        ' > "$RPG2_GEN"

    if [[ ! -s "$RPG2_GEN" ]]; then
        echo "ERROR: generated source is empty: $RPG2_GEN"
        exit 1
    fi
}

build() {
    generate
    echo "=== Assembling $RPG2_GEN ==="
    $RUN --run "$RPG2_GEN" --load-binary "$TEST_DECK@$DECK_LOAD_ADDR" \
        --speed 0 -n 50000 2>&1 | tail -5
    echo "Assemble check OK."
}

run() {
    build
    echo ""
    echo "=== Running ==="
    $RUN --run "$RPG2_GEN" --load-binary "$TEST_DECK@$DECK_LOAD_ADDR" \
        --speed 0 "${@:2}"
}

test_suite() {
    echo "=== sw-cor24-rpg-ii Test Suite ==="
    if ! command -v reg-rs &>/dev/null; then
        echo "ERROR: reg-rs not found."
        exit 1
    fi
    reg-rs run -p rpg2_ --parallel
}

clean() {
    rm -rf build/
    echo "Cleaned."
}

CMD="${1:-build}"

case "$CMD" in
    build)  build ;;
    run)    shift; run "$@" ;;
    test)   test_suite ;;
    clean)  clean ;;
    *)      echo "Usage: $0 {build|run|test|clean}"; exit 1 ;;
esac
