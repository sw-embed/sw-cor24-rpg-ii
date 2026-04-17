# Minimal RPG-II Demo

This repo now has a CLI-facing minimal RPG-II demo surface built around the
fixed-shape tiny source program in `tiny_rpg_demo.src`, loaded at runtime as an
external source deck.

Run it with:

```sh
./demo.sh mini
```

Current fixed program shape:

- `H` control header
- `F` one input file: `INFIL`
- `I` one extracted field: `A0110`
- `C` one MOVE-style calc stage from the extracted field into a computed work field
- `O` one detail output record definition

What is real end to end today:

- the authored `rpg2.hlasm -> generated .s -> cor24-run` build path
- loading of the tiny demo source from an external source-deck buffer
- parsing of the fixed-shape `H/F/I/C/O` demo source
- one extracted input field
- one MOVE-style computed work field
- one output-line assembly stage
- a CLI-facing demo command and regression fixture driven by live runtime output

What is still placeholder or fixed-shape:

- the tiny RPG source still has a fixed known shape rather than supporting arbitrary programs
- `I` extraction is hard-wired to one known 10-byte slice
- the `C` stage is one fixed MOVE-style copy, not a general C-spec executor
- the `O` stage is one fixed 10-byte detail line, not a general O-spec formatter
- the CLI demo runs the current fixed-shape program and reports its live runtime output,
  but it is still not a fully general RPG program surface

Smallest remaining gap to a runnable tiny user-supplied RPG program:

1. decode one real `I`-spec field definition from that external user-supplied source into
   runtime field metadata
2. decode one real `C`-spec operation from that source into a tiny executable calc
   form instead of the fixed MOVE-style path
3. decode one real `O`-spec detail-line definition from that source into runtime
   output metadata
4. generalize the CLI demo beyond this known-good tiny shape so it can surface
   runtime output for a broader user-supplied program subset

The practical next milestone is not "general RPG-II". It is:

- one tiny user-supplied program with one `I` field, one `C` operation, and one
  `O` detail line, all parsed from source at runtime

Current execution path:

1. load and parse the external fixed-shape `H/F/I/C/O` demo source
2. read each 80-byte input record from `test_deck.bin`
3. extract the first 10 bytes into `A0110`
4. copy that field through the fixed C-spec-like work field
5. format one 10-byte output line
6. emit the line over UART

The CLI demo currently validates that the `rpg2.hlasm -> generated .s` path
still builds, then runs the current fixed-shape tiny program and reports its
actual runtime-produced UART output.

Current runtime-produced output is:

```text
RECORD 01A
RECORD 02B
RECORD 03C
```

This is still a constrained demonstration, not a general RPG-II compiler or
interpreter. The value is that the repo now exposes a path that plausibly maps
to a complete tiny RPG program and states its current boundary explicitly.
