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
interpreter. The value is that the CLI now exposes a path that plausibly maps to
a complete tiny RPG program instead of only a raw deck-reader preview.
