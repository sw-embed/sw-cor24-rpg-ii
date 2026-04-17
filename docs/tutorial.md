# Tutorial

This repo is building toward a small RPG-II compiler/runtime for the COR24
stack. Today it supports a deliberately narrow runnable subset that is useful
for understanding the pipeline and for experimenting with tiny fixed-shape RPG
programs.

## What This Is For

The current implementation is most useful for:

- learning how RPG-style source specs can be decoded into runtime metadata
- validating the `hlasm -> generated .s -> cor24-run` toolchain
- experimenting with tiny card-oriented input/output examples
- growing the compiler one constrained capability at a time

It is not yet a general RPG-II compiler or interpreter.

## Current Tiny Subset

The current runnable subset supports:

- one `H` spec
- one `F` input file spec
- two `I` field specs
- one `C` calc spec using `MOVE01`, `MOVE02`, or `REVR01` / `REVR02`
- two `O` detail output specs, with the active one selected by the `MOVE`
- one parsed indicator-style gate on an output spec

That means the tiny program can:

- decode two input field slices from each input record
- transform one of those fields through a tiny fixed calc stage
- select one of two parsed detail output definitions
- optionally suppress the selected output definition through indicator `01`
- emit one output line per input record

## Demo Sources

The demo source decks live in the repo root:

- [tiny_rpg_demo.src](/Users/mike/github/sw-embed/sw-cor24-rpg-ii/tiny_rpg_demo.src)
- [tiny_rpg_demo_tail3.src](/Users/mike/github/sw-embed/sw-cor24-rpg-ii/tiny_rpg_demo_tail3.src)
- [tiny_rpg_demo_gateoff.src](/Users/mike/github/sw-embed/sw-cor24-rpg-ii/tiny_rpg_demo_gateoff.src)
- [tiny_rpg_demo_rev3.src](/Users/mike/github/sw-embed/sw-cor24-rpg-ii/tiny_rpg_demo_rev3.src)

The first variant uses `MOVE01` and the 10-byte output definition.

The second variant uses `MOVE02` and the 3-byte output definition.

The gated variant uses `MOVE01`, selects the 10-byte output definition, and
suppresses it because indicator `01` is off.

The reverse variant uses `REVR02` and emits the selected 3-byte field in reverse order.

## Running The Demos

Build/check the generated assembly:

```sh
./build.sh build
```

Run the default tiny demo:

```sh
./demo.sh mini
```

Run the second-field / second-output variant:

```sh
./demo.sh mini-tail3
```

Run the indicator-gated no-output variant:

```sh
./demo.sh mini-gateoff
```

Run the reverse-field variant:

```sh
./demo.sh mini-rev3
```

Run the regression suite:

```sh
./build.sh test
```

## Pinned HLASM Snapshot

This repo can use a vendored stable `hlasm.s` snapshot instead of reading the
live sibling worktree directly.

Refresh the local vendored copy from the last pushed sibling `origin/main`:

```sh
./build.sh vendor-hlasm
```

After that, `build.sh` prefers:

1. `HLASM_STAGE0` if you set it explicitly
2. `work/vendor/sw-cor24-hlasm/hlasm.s` if it exists
3. `../sw-cor24-hlasm/hlasm.s` as a fallback

The vendored path lives under `work/vendor/` and is gitignored on purpose, so
you can keep this repo building against a stable snapshot while `sw-cor24-hlasm`
is mid-change.

## How The Pipeline Works

1. `rpg2.hlasm` is the authored source.
2. `build.sh` runs the selected HLASM stage-0 snapshot to generate `build/rpg2.generated.s`.
3. The chosen tiny source deck is packed into `build/tiny_rpg_demo.srcdeck.bin`.
4. `cor24-run` loads:
   - the generated COR24 assembly
   - the data deck from `test_deck.bin`
   - the tiny RPG source deck at runtime
5. The runtime parses the source specs, executes the tiny calc/output path, and emits UART output.

## Reading The Current Demo Programs

The demo source lines are intentionally compact:

- `IA0110` means field 01 spans columns 1-10
- `IA0810` means field 02 spans columns 8-10
- `CMOVE01` selects field 01
- `CMOVE02` selects field 02
- `CREVR01` reverses field 01
- `CREVR02` reverses field 02
- `ODETAIL1000` defines a 10-byte output with no indicator gate
- `ODETAIL0301` defines a 3-byte output gated by indicator `01`
- `ODETAIL1001` defines a 10-byte output gated by indicator `01`

The current runtime still assumes a very specific record layout and program
shape. Those lines are parsed as metadata, but only inside the small supported
subset described above.

## Current Limits

Still missing:

- arbitrary numbers of files, fields, calcs, and outputs
- general C-spec execution beyond the current MOVE/REVR subset
- general O-spec formatting
- general indicator-driven calc/output branching beyond the one parsed gate
- user-friendly diagnostics for malformed RPG source

For the current boundary and examples, also see
[minimal-rpg-demo.md](/Users/mike/github/sw-embed/sw-cor24-rpg-ii/docs/minimal-rpg-demo.md).
