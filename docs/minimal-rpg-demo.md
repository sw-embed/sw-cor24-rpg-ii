# Minimal RPG-II Demo

This repo now has a CLI-facing minimal RPG-II demo surface built around tiny
source programs loaded at runtime as external source decks.

Run it with:

```sh
./demo.sh mini
./demo.sh mini-tail3
```

Current supported tiny program shapes:

- `tiny_rpg_demo.src`
  - `H` control header
  - `F` one input file: `INFIL`
  - `I` field 01: `A0110`
  - `I` field 02: `A0810`
  - `C` one MOVE-style calc stage selecting field `01`
  - `O` one detail output record definition for 10 bytes
- `tiny_rpg_demo_tail3.src`
  - `H` control header
  - `F` one input file: `INFIL`
  - `I` field 01: `A0110`
  - `I` field 02: `A0810`
  - `C` one MOVE-style calc stage selecting field `02`
  - `O` one detail output record definition for 3 bytes

What is real end to end today:

- the authored `rpg2.hlasm -> generated .s -> cor24-run` build path
- loading of tiny demo source from an external source-deck buffer
- parsing of a narrow but now variable `H/F/I/C/O` tiny source shape
- two extracted input fields with runtime-decoded offsets and lengths up to 10 bytes
- one MOVE-style computed work field that selects field `01` or `02`
- one output-line assembly stage with runtime-decoded output length up to 10 bytes
- a CLI-facing demo command and regression fixture driven by live runtime output

What is still placeholder or fixed-shape:

- the tiny RPG source still has a very narrow known shape rather than supporting arbitrary programs
- the `C` stage is one fixed MOVE-style selector, not a general C-spec executor
- the `O` stage is still one detail line, not a general O-spec formatter
- the CLI demo runs the current fixed-shape program and reports its live runtime output,
  but it is still not a fully general RPG program surface

Smallest remaining gap to a runnable tiny user-supplied RPG program:

1. decode one real `I`-spec field definition from that external user-supplied source into
   runtime field metadata
2. decode one real `C`-spec operation from that source into a tiny executable calc
   form instead of the fixed MOVE-style path
3. decode one real `O`-spec detail-line definition from that source into runtime
   output metadata
4. broaden the CLI/demo path beyond these known-good tiny shapes so it can surface
   runtime output for a slightly broader user-supplied program subset

The practical next milestone is not "general RPG-II". It is:

- one tiny user-supplied program with a couple of `I` fields, one `C` operation, and one
  `O` detail line, all parsed from source at runtime

Current execution path:

1. load and parse an external tiny `H/F/I/C/O` demo source
2. read each 80-byte input record from `test_deck.bin`
3. extract the runtime-decoded field slices
4. copy the selected field through the fixed C-spec-like work field
5. format one output line with runtime-decoded length
6. emit the line over UART

The CLI demo currently validates that the `rpg2.hlasm -> generated .s` path
still builds, then runs the selected tiny program and reports its
actual runtime-produced UART output.

Current runtime-produced outputs are:

```text
RECORD 01A
RECORD 02B
RECORD 03C

01A
02B
03C
```

This is still a constrained demonstration, not a general RPG-II compiler or
interpreter. The value is that the repo now exposes a path that plausibly maps
to a complete tiny RPG program and states its current boundary explicitly.
