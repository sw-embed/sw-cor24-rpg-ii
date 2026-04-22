# Minimal RPG-II Demo

This repo now has a CLI-facing minimal RPG-II demo surface built around tiny
source programs loaded at runtime as external source decks.

Run it with:

```sh
./demo.sh mini
./demo.sh mini-tail3
./demo.sh mini-gateoff
./demo.sh mini-rev3
./demo.sh mini-revr-gateoff
./demo.sh mini-revr6
./demo.sh mini-chain
./demo.sh mini-chain-move1-6
./demo.sh mini-chain-move1-move2
./demo.sh mini-chain-move1-revr2
./demo.sh mini-chain-move2-revr1
./demo.sh mini-chain-revr0-6
./demo.sh mini-chain-move2f6-6
```

Current supported tiny program shapes:

- `tiny_rpg_demo.src`
  - `H` control header
  - `F` one input file: `INFIL`
  - `I` field 01: `A0110`
  - `I` field 02: `A0810`
  - `C` one MOVE-style calc stage selecting field `01`
  - `O` detail output definition 01 for 10 bytes
  - `O` detail output definition 02 for 3 bytes
- `tiny_rpg_demo_tail3.src`
  - `H` control header
  - `F` one input file: `INFIL`
  - `I` field 01: `A0110`
  - `I` field 02: `A0810`
  - `C` one MOVE-style calc stage selecting field `02`
  - `O` detail output definition 01 for 10 bytes
  - `O` detail output definition 02 for 3 bytes
- `tiny_rpg_demo_gateoff.src`
  - `H` control header
  - `F` one input file: `INFIL`
  - `I` field 01: `A0110`
  - `I` field 02: `A0810`
  - `C` one MOVE-style calc stage selecting field `01`
  - `O` detail output definition 01 for 10 bytes gated by indicator `01`
  - `O` detail output definition 02 for 3 bytes
- `tiny_rpg_demo_rev3.src`
  - `H` control header
  - `F` one input file: `INFIL`
  - `I` field 01: `A0110`
  - `I` field 02: `A0810`
  - `C` one REVR-style calc stage selecting field `02`
  - `O` detail output definition 01 for 10 bytes
  - `O` detail output definition 02 for 3 bytes
- `tiny_rpg_demo_revr_gateoff.src`
  - `H` control header
  - `F` one input file: `INFIL`
  - `I` field 01: `A0110`
  - `I` field 02: `A0810`
  - `C` one REVR-style calc stage selecting field `01`
  - `O` detail output definition 01 for 10 bytes gated by indicator-off mode `02`
  - `O` detail output definition 02 for 3 bytes
- `tiny_rpg_demo_revr6.src`
  - `H` control header
  - `F` one input file: `INFIL`
  - `I` field 01: `A0110`
  - `I` field 02: `A0810`
  - `C` one REVR-style calc stage selecting field `01`
  - `O` detail output definition 01 for 10 bytes
  - `O` detail output definition 02 for 3 bytes
  - `O` detail output definition 03 for 6 bytes
- `tiny_rpg_demo_chain.src`
  - `H` control header
  - `F` one input file: `INFIL`
  - `I` field 01: `A0110`
  - `I` field 02: `A0810`
  - `C` calc stage 01: `MOVE01`
  - `C` calc stage 02: `REVR00`
  - `O` detail output definition 01 for 10 bytes
  - `O` detail output definition 02 for 3 bytes
- `tiny_rpg_demo_chain_move1_6.src`
  - `H` control header
  - `F` one input file: `INFIL`
  - `I` field 01: `A0110`
  - `I` field 02: `A0810`
  - `C` calc stage 01: `REVR01`
  - `C` calc stage 02: `MOVE01`
  - `O` detail output definition 01 for 10 bytes
  - `O` detail output definition 02 for 3 bytes
  - `O` detail output definition 03 for 6 bytes
- `tiny_rpg_demo_chain_move1_move2.src`
  - `H` control header
  - `F` one input file: `INFIL`
  - `I` field 01: `A0110`
  - `I` field 02: `A0810`
  - `C` calc stage 01: `MOVE01`
  - `C` calc stage 02: `MOVE02`
  - `O` detail output definition 01 for 10 bytes
  - `O` detail output definition 02 for 3 bytes
- `tiny_rpg_demo_chain_move1_revr2.src`
  - `H` control header
  - `F` one input file: `INFIL`
  - `I` field 01: `A0110`
  - `I` field 02: `A0810`
  - `C` calc stage 01: `MOVE01`
  - `C` calc stage 02: `REVR02`
  - `O` detail output definition 01 for 10 bytes
  - `O` detail output definition 02 for 3 bytes
- `tiny_rpg_demo_chain_move2_revr1.src`
  - `H` control header
  - `F` one input file: `INFIL`
  - `I` field 01: `A0110`
  - `I` field 02: `A0810`
  - `C` calc stage 01: `MOVE02`
  - `C` calc stage 02: `REVR01`
  - `O` detail output definition 01 for 10 bytes
  - `O` detail output definition 02 for 3 bytes
- `tiny_rpg_demo_chain_revr0_6.src`
  - `H` control header
  - `F` one input file: `INFIL`
  - `I` field 01: `A0110`
  - `I` field 02: `A0810`
  - `C` calc stage 01: `REVR01`
  - `C` calc stage 02: `REVR00`
  - `O` detail output definition 01 for 10 bytes
  - `O` detail output definition 02 for 3 bytes
  - `O` detail output definition 03 for 6 bytes
- `tiny_rpg_demo_chain_move2f6_6.src`
  - `H` control header
  - `F` one input file: `INFIL`
  - `I` field 01: `A0110`
  - `I` field 02: `A0510`
  - `C` calc stage 01: `REVR01`
  - `C` calc stage 02: `MOVE02`
  - `O` detail output definition 01 for 10 bytes
  - `O` detail output definition 02 for 3 bytes
  - `O` detail output definition 03 for 6 bytes

What is real end to end today:

- the authored `rpg2.hlasm -> generated .s -> cor24-run` build path
- loading of tiny demo source from an external source-deck buffer
- parsing of a narrow but now variable `H/F/I/C/O` tiny source shape
- two extracted input fields with runtime-decoded offsets and lengths up to 10 bytes
- one MOVE-style computed work field that selects field `01` or `02`
- one REVR-style computed work field that reverses selected field `01` or `02`
- an optional second calc slot that can transform the current calc result through source selector `00`
- calc slot 1 can also reselect raw field `01` or `02` through a tiny `MOVE` subset
- calc slot 1 can also reverse raw field `01` or `02` through a tiny `REVR` subset
- when calc slot 1 is a parsed `MOVE01` or `MOVE02` in a two-output program, it can now drive the matching output definition instead of leaving output selection fixed to calc slot 0
- when calc slot 1 is a parsed `REVR01` or `REVR02` in a two-output program, it can now also drive the matching output definition instead of leaving output selection fixed to calc slot 0
- calc slot 1 can also still operate on source selector `00` while the program uses the third output shape
- the third output shape can now be paired with a different decoded field so the 6-byte visible result is not always field 01
- up to three parsed O-spec output definitions with runtime-selected output length up to 10 bytes
- two parsed indicator-style output gate modes that can suppress or allow the selected detail line
- a CLI-facing demo command and regression fixture driven by live runtime output

What is still placeholder or fixed-shape:

- the tiny RPG source still has a very narrow known shape rather than supporting arbitrary programs
- the `C` stage is still a tiny fixed set of calc behaviors, not a general C-spec executor
- the second calc slot is still constrained to a tiny chained subset over the current calc result or a raw field reselection/reverse
- the `O` stage is still one active detail line per record, not a general O-spec formatter
- third-output-shape selection is still constrained to one narrow known-good calc/output combination
- output gating is still one tiny fixed-shape indicator case, not general indicator-driven branching
- the CLI demo runs the current fixed-shape program and reports its live runtime output,
  but it is still not a fully general RPG program surface

Next smallest meaningful capability:

- make the second calc slot fully metadata-driven for the same tiny `MOVE`/`REVR`
  subset instead of recognizing only the current known-good chained shapes
- keep the current limits on opcodes and operand forms, but remove the need for the
  runtime to special-case just a few demo combinations
- once that works, add one demo whose second calc slot is user-authored but not
  hard-coded as another one-off shape

Why this is the next step:

- it is smaller than a broader parser/runtime rewrite
- it moves the repo closer to a genuinely user-authored tiny program instead of just
  adding another canned demo variant
- it strengthens the current `C`-spec execution path, which is now the narrowest
  part of the remaining fixed-shape behavior

The practical next milestone is still not "general RPG-II". It is:

- one tiny user-authored two-calc program in the existing subset, parsed from source
  and run without adding another special-case execution path

Current execution path:

1. load and parse an external tiny `H/F/I/C/O` demo source
2. read each 80-byte input record from `test_deck.bin`
3. extract the runtime-decoded field slices
4. execute the first calc stage over one decoded field
5. optionally execute the second calc stage over the current calc result or a tiny raw-field selector
6. select one parsed output definition, apply its optional indicator gate, and format one output line with its runtime-decoded length
7. emit the line over UART if it is still enabled

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

(no output)

A10
B20
C30

A10 DROCER
B20 DROCER
C30 DROCER

A10 DR
B20 DR
C30 DR

A10 DROCER
B20 DROCER
C30 DROCER

RECORD
RECORD
RECORD

01A
02B
03C

A10
B20
C30

A10
B20
C30

RECORD
RECORD
RECORD

RD 01A
RD 02B
RD 03C
```

This is still a constrained demonstration, not a general RPG-II compiler or
interpreter. The value is that the repo now exposes a path that plausibly maps
to a complete tiny RPG program and states its current boundary explicitly.
