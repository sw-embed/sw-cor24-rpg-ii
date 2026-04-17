#!/usr/bin/env bash
set -euo pipefail

# sw-cor24-rpg-ii -- Build script
# Usage:
#   ./build.sh              Assemble check only
#   ./build.sh run          Build and run on emulator
#   ./build.sh test         Run test suite
#   ./build.sh vendor-hlasm Refresh vendored stable HLASM stage-0
#   ./build.sh clean        Remove build artifacts

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

HLASM_SRC="rpg2.hlasm"
BUILD_DIR="build"
WORK_DIR="work"
VENDORED_HLASM_DIR="$WORK_DIR/vendor/sw-cor24-hlasm"
VENDORED_HLASM_STAGE0="$VENDORED_HLASM_DIR/hlasm.s"
FALLBACK_HLASM_STAGE0="../sw-cor24-hlasm/hlasm.s"
RPG2_GEN="$BUILD_DIR/rpg2.generated.s"
RPG2_LEGACY="rpg2.s"
SRC_LOAD_ADDR=524288
SRC_DECK_LOAD_ADDR=655360
DECK_LOAD_ADDR=589824
TEST_DECK="test_deck.bin"
TEST_SRC_DECK_TXT="${TEST_SRC_DECK_TXT:-tiny_rpg_demo.src}"
TEST_SRC_DECK_BIN="$BUILD_DIR/tiny_rpg_demo.srcdeck.bin"
RUN="cor24-run"
HLASM_STAGE0_MAX_INSN=12000000
HLASM_STAGE0_TAIL_LABEL="_indicator_table:"
SRC_DECK_RECORD_COUNT=0

if [[ -n "${HLASM_STAGE0:-}" ]]; then
    HLASM_STAGE0="$HLASM_STAGE0"
elif [[ -f "$VENDORED_HLASM_STAGE0" ]]; then
    HLASM_STAGE0="$VENDORED_HLASM_STAGE0"
else
    HLASM_STAGE0="$FALLBACK_HLASM_STAGE0"
fi

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

if [[ ! -f "$TEST_SRC_DECK_TXT" ]]; then
    echo "ERROR: $TEST_SRC_DECK_TXT not found."
    exit 1
fi

generate() {
    mkdir -p "$BUILD_DIR"
    echo "=== Using HLASM stage-0: $HLASM_STAGE0 ==="
    echo "=== Generating $RPG2_GEN from $HLASM_SRC ==="
    $RUN --run "$HLASM_STAGE0" --load-binary "$HLASM_SRC@$SRC_LOAD_ADDR" \
        --speed 0 -n "$HLASM_STAGE0_MAX_INSN" 2>&1 \
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

    if ! rg -q "^${HLASM_STAGE0_TAIL_LABEL}$" "$RPG2_GEN"; then
        echo "ERROR: generated source is incomplete: missing tail label ${HLASM_STAGE0_TAIL_LABEL}"
        exit 1
    fi
}

pack_source_deck() {
    mkdir -p "$BUILD_DIR"
    SRC_DECK_RECORD_COUNT="$(awk 'END { print NR + 0 }' "$TEST_SRC_DECK_TXT")"
    awk '
        {
            line = substr($0, 1, 80)
            printf "%-80s", line
        }
    ' "$TEST_SRC_DECK_TXT" > "$TEST_SRC_DECK_BIN"

    if [[ ! -s "$TEST_SRC_DECK_BIN" ]]; then
        echo "ERROR: packed source deck is empty: $TEST_SRC_DECK_BIN"
        exit 1
    fi

    if [[ "$SRC_DECK_RECORD_COUNT" -le 0 ]]; then
        echo "ERROR: source deck has no records: $TEST_SRC_DECK_TXT"
        exit 1
    fi
}

patch_source_deck_count() {
    local patched="$BUILD_DIR/rpg2.generated.patched.s"
    awk -v count="$SRC_DECK_RECORD_COUNT" '
        BEGIN { in_src_desc = 0; word_index = 0 }
        /^_src_desc:$/ {
            in_src_desc = 1
            word_index = 0
            print
            next
        }
        in_src_desc && /^[[:space:]]*\.word[[:space:]]+/ {
            word_index++
            if (word_index == 3) {
                printf "\t.word\t%s\n", count
                in_src_desc = 0
                next
            }
        }
        { print }
    ' "$RPG2_GEN" > "$patched"
    mv "$patched" "$RPG2_GEN"
}

vendor_hlasm() {
    local source_repo="../sw-cor24-hlasm"
    local source_ref="origin/main"
    local vendor_readme="$VENDORED_HLASM_DIR/README.txt"
    local vendor_commit

    if [[ ! -d "$source_repo/.git" ]]; then
        echo "ERROR: source repo not found: $source_repo"
        exit 1
    fi

    vendor_commit="$(git -C "$source_repo" rev-parse "$source_ref")"
    mkdir -p "$VENDORED_HLASM_DIR"
    git -C "$source_repo" show "$source_ref:hlasm.s" > "$VENDORED_HLASM_STAGE0"
    cat > "$vendor_readme" <<EOF
Vendored stable HLASM stage-0 snapshot for sw-cor24-rpg-ii.
Source repo: $source_repo
Source ref: $source_ref
Source commit: $vendor_commit
Refresh with: ./build.sh vendor-hlasm
EOF
    echo "Vendored $VENDORED_HLASM_STAGE0 from $source_repo@$vendor_commit"
}

build() {
    generate
    pack_source_deck
    patch_source_deck_count
    echo "=== Assembling $RPG2_GEN ==="
    $RUN --run "$RPG2_GEN" \
        --load-binary "$TEST_DECK@$DECK_LOAD_ADDR" \
        --load-binary "$TEST_SRC_DECK_BIN@$SRC_DECK_LOAD_ADDR" \
        --speed 0 -n 50000 2>&1 | tail -5
    echo "Assemble check OK."
}

run() {
    build
    echo ""
    echo "=== Running ==="
    $RUN --run "$RPG2_GEN" \
        --load-binary "$TEST_DECK@$DECK_LOAD_ADDR" \
        --load-binary "$TEST_SRC_DECK_BIN@$SRC_DECK_LOAD_ADDR" \
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
    vendor-hlasm) vendor_hlasm ;;
    clean)  clean ;;
    *)      echo "Usage: $0 {build|run|test|vendor-hlasm|clean}"; exit 1 ;;
esac
