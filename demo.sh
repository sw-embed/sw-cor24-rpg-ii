#!/usr/bin/env bash
# demo.sh -- Run sw-cor24-rpg-ii demos
# Usage:
#   ./demo.sh           Run automated demo
#   ./demo.sh test      Run test suite
#   ./demo.sh repl      Interactive (future)

set -euo pipefail
cd "$(dirname "$0")"

RPG2="rpg2.s"
RUN="cor24-run --run $RPG2 --speed 0"

case "${1:-demo}" in
    test)
        exec ./build.sh test
        ;;
    repl)
        echo "=== sw-cor24-rpg-ii REPL (not yet implemented) ==="
        echo "Type RPG-II commands. Ctrl-C to exit."
        echo ""
        cor24-run --run "$RPG2" --terminal --echo --speed 0
        ;;
    demo)
        echo "=== sw-cor24-rpg-ii Demo ==="
        echo ""
        if [[ ! -f "$RPG2" ]]; then
            echo "rpg2.s not yet created. Run build.sh first."
            exit 1
        fi
        $RUN -n 5000000 2>&1 | grep "^UART output:" -A 20 | tr '\n' ' ' \
            | sed -e 's/.*UART output: //' -e 's/Executed.*//' \
            | sed -e 's/  */ /g' -e 's/^ //;s/ $//'
        echo ""
        echo "To run tests: ./demo.sh test"
        ;;
    *)
        echo "Usage: $0 [demo|test|repl]"
        exit 1
        ;;
esac
