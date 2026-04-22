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
- one or two `C` calc specs using `MOVE01`, `MOVE02`, `REVR01`, `REVR02`, or chained `REVR00`
- one or two `C` calc specs using `MOVE01`, `MOVE02`, `REVR01`, `REVR02`, or chained `REVR00`
- two or three `O` detail output specs, with the active one selected by the tiny calc path
- two parsed indicator-style gate modes on an output spec

That means the tiny program can:

- decode two input field slices from each input record
- transform one of those fields through a tiny fixed calc stage
- optionally run a second calc stage over the current calc result
- in a narrow chained case, let calc slot 1 reselect raw field `01` or `02`
- select one of two parsed detail output definitions
- in one constrained case, select a third parsed detail output definition
- optionally require indicator `01` to be on or off before the selected output emits
- emit one output line per input record

## Demo Sources

The demo source decks live in the repo root:

- [tiny_rpg_demo.src](/Users/mike/github/sw-embed/sw-cor24-rpg-ii/tiny_rpg_demo.src)
- [tiny_rpg_demo_tail3.src](/Users/mike/github/sw-embed/sw-cor24-rpg-ii/tiny_rpg_demo_tail3.src)
- [tiny_rpg_demo_gateoff.src](/Users/mike/github/sw-embed/sw-cor24-rpg-ii/tiny_rpg_demo_gateoff.src)
- [tiny_rpg_demo_rev3.src](/Users/mike/github/sw-embed/sw-cor24-rpg-ii/tiny_rpg_demo_rev3.src)
- [tiny_rpg_demo_revr_gateoff.src](/Users/mike/github/sw-embed/sw-cor24-rpg-ii/tiny_rpg_demo_revr_gateoff.src)
- [tiny_rpg_demo_revr6.src](/Users/mike/github/sw-embed/sw-cor24-rpg-ii/tiny_rpg_demo_revr6.src)
- [tiny_rpg_demo_chain.src](/Users/mike/github/sw-embed/sw-cor24-rpg-ii/tiny_rpg_demo_chain.src)
- [tiny_rpg_demo_chain_move1_6.src](/Users/mike/github/sw-embed/sw-cor24-rpg-ii/tiny_rpg_demo_chain_move1_6.src)
- [tiny_rpg_demo_chain_move2_revr1.src](/Users/mike/github/sw-embed/sw-cor24-rpg-ii/tiny_rpg_demo_chain_move2_revr1.src)
- [tiny_rpg_demo_chain_revr0_6.src](/Users/mike/github/sw-embed/sw-cor24-rpg-ii/tiny_rpg_demo_chain_revr0_6.src)
- [tiny_rpg_demo_chain_move2f6_6.src](/Users/mike/github/sw-embed/sw-cor24-rpg-ii/tiny_rpg_demo_chain_move2f6_6.src)

The first variant uses `MOVE01` and the 10-byte output definition.

The second variant uses `MOVE02` and the 3-byte output definition.

The gated variant uses `MOVE01`, selects the 10-byte output definition, and
suppresses it because indicator `01` is off.

The reverse variant uses `REVR02` and emits the selected 3-byte field in reverse order.

The reverse-plus-gate variant uses `REVR01` and emits the reversed 10-byte field only when
indicator `01` is off.

The reverse-plus-third-shape variant uses `REVR01` and emits the reversed field through a
third parsed 6-byte output definition.

The chained-calc variant uses `MOVE01` followed by `REVR00`, so a second calc slot reverses
the first calc result before output.

The chained-reselect variant uses `REVR01` followed by `MOVE01`, so calc slot 1
reselects raw field 01 after slot 0 has already influenced output-shape selection.

The chained-reverse-selector variant uses `MOVE02` followed by `REVR01`, so calc
slot 1 overrides the stage-0 result with reversed field 01 while keeping the short
output path chosen by stage 0.

The chained-third-shape variant uses `REVR01` followed by `REVR00`, so calc slot 1
works over the current calc result while stage 0 still selects the 6-byte output shape.

The chained-field2-third-shape variant uses `REVR01` followed by `MOVE02`, so stage 0
still selects the 6-byte output shape while calc slot 1 replaces the visible result
with a different decoded 6-byte field.

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

Run the reverse-field plus gate-off variant:

```sh
./demo.sh mini-revr-gateoff
```

Run the reverse-field plus third-output-shape variant:

```sh
./demo.sh mini-revr6
```

Run the two-calc chained variant:

```sh
./demo.sh mini-chain
```

Run the chained raw-field reselection variant:

```sh
./demo.sh mini-chain-move1-6
```

Run the chained reverse-field-selector variant:

```sh
./demo.sh mini-chain-move2-revr1
```

Run the chained third-output-shape variant:

```sh
./demo.sh mini-chain-revr0-6
```

Run the chained field-2 third-shape variant:

```sh
./demo.sh mini-chain-move2f6-6
```

Run the regression suite:

```sh
./build.sh test
```

## Pinned HLASM Snapshot

This repo can use a vendored stable `hlasm.s` snapshot instead of reading the
live sibling worktree directly.

The checked-in pin for that snapshot lives in
[toolchain/hlasm-vendor.toml](/Users/mike/github/sw-embed/sw-cor24-rpg-ii/toolchain/hlasm-vendor.toml).
It records:

- the upstream `sw-cor24-hlasm` repo path
- the pinned upstream ref, which can be a commit SHA or tag
- the gitignored vendored `hlasm.s` path used by this repo
- the refresh command
- the build precedence

Inspect the current pin:

```sh
./build.sh vendor-info
```

Refresh the local vendored copy from that pinned ref:

```sh
./build.sh vendor-hlasm
```

On a fresh clone, the intended rebuild flow is:

1. clone or place the upstream repo at the path recorded in `toolchain/hlasm-vendor.toml`
2. ensure that repo has the pinned commit or tag
3. run `./build.sh vendor-hlasm`
4. build or test this repo normally

After that, `build.sh` prefers:

1. `HLASM_STAGE0` if you set it explicitly
2. `work/vendor/sw-cor24-hlasm/hlasm.s` if it exists
3. `../sw-cor24-hlasm/hlasm.s` as a fallback

The vendored path lives under `work/vendor/` and is gitignored on purpose, so
you can keep this repo building against a stable snapshot while `sw-cor24-hlasm`
is mid-change, but still have a checked-in record of exactly which upstream
ref that snapshot should come from.

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
- `CREVR00` reverses the current calc result in a second calc slot
- a second-slot `CMOVE01` or `CMOVE02` can reselect a raw field in the current tiny chained subset
- a second-slot `CREVR01` or `CREVR02` can reverse a raw field in the current tiny chained subset
- `ODETAIL1000` defines a 10-byte output with no indicator gate
- `ODETAIL0301` defines a 3-byte output gated by indicator `01`
- `ODETAIL1001` defines a 10-byte output gated by indicator `01`
- `ODETAIL1002` defines a 10-byte output gated by indicator `01` being off
- `ODETAIL0600` defines a 6-byte output with no indicator gate

The current runtime still assumes a very specific record layout and program
shape. Those lines are parsed as metadata, but only inside the small supported
subset described above.

## Current Limits

Still missing:

- arbitrary numbers of files, fields, calcs, and outputs
- general C-spec execution beyond the current MOVE/REVR subset
- general O-spec formatting
- general indicator-driven calc/output branching beyond the current on/off gate modes
- user-friendly diagnostics for malformed RPG source

For the current boundary and examples, also see
[minimal-rpg-demo.md](/Users/mike/github/sw-embed/sw-cor24-rpg-ii/docs/minimal-rpg-demo.md).
