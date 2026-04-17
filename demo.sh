#!/usr/bin/env bash
# demo.sh -- Run sw-cor24-rpg-ii demos
# Usage:
#   ./demo.sh           Run automated demo
#   ./demo.sh mini      Run minimal RPG-II demo
#   ./demo.sh mini-tail3 Run alternate second-field minimal RPG-II demo
#   ./demo.sh test      Run test suite
#   ./demo.sh repl      Interactive (future)

set -euo pipefail
cd "$(dirname "$0")"

RPG2_GEN="build/rpg2.generated.s"
DECK_LOAD_ADDR=589824
SRC_DECK_LOAD_ADDR=655360
TEST_DECK="test_deck.bin"
TEST_SRC_DECK_BIN="build/tiny_rpg_demo.srcdeck.bin"
DEFAULT_DEMO_SRC="tiny_rpg_demo.src"
SHORT_DEMO_SRC="tiny_rpg_demo_tail3.src"
prepare_demo() {
    TEST_SRC_DECK_TXT="${1:-$DEFAULT_DEMO_SRC}" ./build.sh build >/dev/null
}
print_runtime_output() {
    local demo_src="${1:-$DEFAULT_DEMO_SRC}"
    TEST_SRC_DECK_TXT="$demo_src" \
    cor24-run --run "$RPG2_GEN" \
        --load-binary "$TEST_DECK@$DECK_LOAD_ADDR" \
        --load-binary "$TEST_SRC_DECK_BIN@$SRC_DECK_LOAD_ADDR" \
        --speed 0 -n 5000000 2>&1 | awk '
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
        '
}

case "${1:-demo}" in
    test)
        exec ./build.sh test
        ;;
    repl)
        echo "=== sw-cor24-rpg-ii REPL (not yet implemented) ==="
        echo "Type RPG-II commands. Ctrl-C to exit."
        echo ""
        ./build.sh run --terminal --echo
        ;;
    demo)
        echo "=== sw-cor24-rpg-ii Demo ==="
        echo ""
        prepare_demo
        print_runtime_output | tr '\n' ' ' | sed -e 's/  */ /g' -e 's/^ //;s/ $//'
        echo ""
        echo "Generated source: $RPG2_GEN"
        echo "To run tests: ./demo.sh test"
        ;;
    mini)
        prepare_demo "$DEFAULT_DEMO_SRC"
        echo "=== sw-cor24-rpg-ii Minimal RPG-II Demo ==="
        echo "Program:"
        echo "H  control header"
        echo "F  input file INFIL"
        echo "I  field 01: A0110  (10-char input slice)"
        echo "I  field 02: A0810  (3-char input tail slice)"
        echo "C  MOVE01 -> calc work field"
        echo "O  DETAIL01 output (10 chars)"
        echo "O  DETAIL02 output (3 chars)"
        echo ""
        echo "Current boundary:"
        echo "- Real today: build path, external tiny source-deck loading, fixed H/F/I/C/O"
        echo "  source parsing, two decoded I-spec fields, one MOVE-style calc stage that"
        echo "  selects field 01 or 02, and two selectable O-spec output definitions."
        echo "- Placeholder today: the subset is still tiny; there is no general RPG"
        echo "  parser, no variable C-spec execution beyond one MOVE selector, no general"
        echo "  O-spec formatting, and no arbitrary user-supplied RPG program execution."
        echo ""
        echo "Current runtime-produced output:"
        print_runtime_output "$DEFAULT_DEMO_SRC"
        echo ""
        echo "Authored source: rpg2.hlasm"
        echo "Tiny demo source: $DEFAULT_DEMO_SRC"
        echo "Alternate tiny demo source: $SHORT_DEMO_SRC"
        echo "Try: ./demo.sh mini-tail3"
        echo "Generated source: $RPG2_GEN"
        ;;
    mini-tail3)
        prepare_demo "$SHORT_DEMO_SRC"
        echo "=== sw-cor24-rpg-ii Minimal RPG-II Demo (Second-Field Variant) ==="
        echo "Program:"
        echo "H  control header"
        echo "F  input file INFIL"
        echo "I  field 01: A0110  (10-char input slice)"
        echo "I  field 02: A0810  (3-char input tail slice)"
        echo "C  MOVE02 -> calc work field"
        echo "O  DETAIL01 output (10 chars)"
        echo "O  DETAIL02 output (3 chars)"
        echo ""
        echo "Current boundary:"
        echo "- Real today: the external tiny source deck can now vary between two decoded"
        echo "  I-spec fields, and the single MOVE-style C-spec selects which one feeds"
        echo "  one of two parsed O-spec output definitions."
        echo "- Placeholder today: there is still only one calc op, one active output"
        echo "  line per record, and one input file in the supported runtime-parsed subset."
        echo ""
        echo "Current runtime-produced output:"
        print_runtime_output "$SHORT_DEMO_SRC"
        echo ""
        echo "Authored source: rpg2.hlasm"
        echo "Tiny demo source: $SHORT_DEMO_SRC"
        echo "Generated source: $RPG2_GEN"
        ;;
    *)
        echo "Usage: $0 [demo|mini|mini-tail3|test|repl]"
        exit 1
        ;;
esac
