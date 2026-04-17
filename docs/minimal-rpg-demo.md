# Minimal RPG-II Demo

This repo now has a CLI-facing minimal RPG-II demo surface built around the
fixed-shape source fixture embedded in `rpg2.hlasm`.

Run it with:

```sh
./demo.sh mini
```

Current fixed program shape:

- `H` control header
- `F` one input file: `INFIL`
- `I` one extracted field: `A0105`
- `C` one MOVE-style calc stage from the extracted field into a computed work field
- `O` one detail output record definition

What is real end to end today:

- the authored `rpg2.hlasm -> generated .s -> cor24-run` build path
- parsing of the embedded fixed-shape `H/F/I/C/O` fixture
- one extracted input field
- one MOVE-style computed work field
- one output-line assembly stage
- a CLI-facing demo command and regression fixture

What is still placeholder or fixed-shape:

- the RPG source is embedded in `rpg2.hlasm`, not loaded as an arbitrary user program
- `I` extraction is hard-wired to one known 10-byte slice
- the `C` stage is one fixed MOVE-style copy, not a general C-spec executor
- the `O` stage is one fixed 10-byte detail line, not a general O-spec formatter
- the CLI demo presents the current expected output explicitly rather than running a
  fully general RPG program surface

Current execution path:

1. parse the embedded `H/F/I/C/O` source fixture
2. read each 80-byte input record from `test_deck.bin`
3. extract the first 10 bytes into `A0105`
4. copy that field through the fixed C-spec-like work field
5. format one 10-byte output line
6. emit the line over UART

The CLI demo currently validates that the `rpg2.hlasm -> generated .s` path
still builds, then presents the current fixed-shape program and its expected
output explicitly.

Current expected output remains:

```text
RECORD 01A
RECORD 02B
RECORD 03C
```

This is still a constrained demonstration, not a general RPG-II compiler or
interpreter. The value is that the repo now exposes a path that plausibly maps
to a complete tiny RPG program and states its current boundary explicitly.
