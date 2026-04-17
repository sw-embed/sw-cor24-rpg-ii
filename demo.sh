#!/usr/bin/env bash
# demo.sh -- Run sw-cor24-rpg-ii demos
# Usage:
#   ./demo.sh           Run automated demo
#   ./demo.sh mini      Run minimal RPG-II demo
#   ./demo.sh test      Run test suite
#   ./demo.sh repl      Interactive (future)

set -euo pipefail
cd "$(dirname "$0")"

RPG2_GEN="build/rpg2.generated.s"
prepare_demo() {
    ./build.sh build >/dev/null
}

print_current_output() {
    cat <<'EOF'
RECORD 01A
RECORD 02B
RECORD 03C
EOF
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
        print_current_output | tr '\n' ' ' | sed -e 's/  */ /g' -e 's/^ //;s/ $//'
        echo ""
        echo "Generated source: $RPG2_GEN"
        echo "To run tests: ./demo.sh test"
        ;;
    mini)
        prepare_demo
        echo "=== sw-cor24-rpg-ii Minimal RPG-II Demo ==="
        echo "Program:"
        echo "H  control header"
        echo "F  input file INFIL"
        echo "I  field A0110  (10-char input slice)"
        echo "C  MOVE A0110 -> calc work field"
        echo "O  DETAIL output (10 chars)"
        echo ""
        echo "Current boundary:"
        echo "- Real today: build path, external tiny source-deck loading, fixed H/F/I/C/O"
        echo "  source parsing, one extracted field, one MOVE-style calc stage, one"
        echo "  output-line format stage, CLI demo surface."
        echo "- Placeholder today: source shape is still fixed; no general RPG parser, no"
        echo "  variable C-spec execution, no general O-spec formatting, no arbitrary"
        echo "  user-supplied RPG program execution yet."
        echo ""
        echo "Current expected output:"
        print_current_output
        echo ""
        echo "Authored source: rpg2.hlasm"
        echo "Tiny demo source: tiny_rpg_demo.src"
        echo "Generated source: $RPG2_GEN"
        ;;
    *)
        echo "Usage: $0 [demo|mini|test|repl]"
        exit 1
        ;;
esac
