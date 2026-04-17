# HLASM Rewrite Plan

## Purpose

This project should stop extending the current hand-written `rpg2.s` path and
restart as an `hlasm`-authored rewrite with a structured-programming style.
The rewrite should be staged around the current reality of
`../sw-cor24-hlasm`: it is usable today as a macro-assembler, but its planned
structured control-flow syntax is not implemented yet.

## Current State Summary

### This repo today

- `docs/plan.md`, `docs/prd.md`, `docs/design.md`, and `docs/architecture.md`
  all assume a single hand-written COR24 assembly file named `rpg2.s`.
- `build.sh` and `demo.sh` are hard-wired to run `rpg2.s` directly with
  `cor24-run`.
- `rpg2.s` is only at the deck-reader stage. It currently:
  - reads a memory-backed deck descriptor,
  - emits the first 10 bytes of each record to UART,
  - halts after EOF.
- The current implementation is still far from the parser/runtime architecture
  described in the docs.

### `sw-cor24-hlasm` today

- `../sw-cor24-hlasm/build.sh build` succeeds locally.
- `../sw-cor24-hlasm/build.sh test` passes locally with 21/21 tests.
- The project is credible today as a text-to-text macro-assembler for COR24.
- The docs and demos show a split between implemented and planned features:
  - working today: plain passthrough, macro definition/expansion, conditional
    assembly (`SET`, `IFDEF`, `IFNDEF`, `IFEQ`, `IFNE`, `ELSEASM`,
    `ENDIFASM`);
  - not implemented yet: structured `IF`/`ELSEIF`/`ELSE`/`ENDIF`,
    `DO`/`DOEXIT`/`ITERATE`/`ENDDO`, `SELECT`/`WHEN`/`OTHERWISE`/`ENDSEL`.
- `hlasm.s` has handlers for conditional assembly, but no handlers for the
  planned structured-control constructs.

## File Type Recommendation

Do not keep the authored rewrite in `.s`.

### Recommended choice

- Use `rpg2.hlasm` for the authored source.

Why:

- it clearly distinguishes source intended for `sw-cor24-hlasm` from plain
  COR24 assembly;
- it matches the sibling repo's demos and documentation;
- it lets `.s` mean "generated plain assembly" instead of "hand-authored
  source".

### Reasonable alternatives

- `rpg2.asm`: generic and familiar, but does not distinguish HLASM input from
  plain assembler output.
- `rpg2.hla`: shorter, but less obvious and not used by the sibling repo.

### Recommended convention

- Authored source: `rpg2.hlasm`
- Generated output: `build/rpg2.generated.s`
- Keep `.s` as a generated artifact or debug artifact, not the primary source.

## Rewrite Direction

The rewrite should target a two-stage pipeline:

```text
rpg2.hlasm
  -> sw-cor24-hlasm
  -> plain COR24 assembly (.s)
  -> cor24-run
```

This changes the project from "directly author the runtime in raw COR24
assembly" to "author the runtime in HLASM-flavored source that lowers to plain
COR24 assembly".

## Structured-Programming Approach

Because `hlasm` does not yet implement structured control-flow lowering, the
rewrite should use a staged definition of "structured programming":

### Stage A: structure without new control keywords

Use `hlasm` immediately for:

- named macros for common subroutine prologues/epilogues;
- named macros for byte/word access patterns;
- named macros for descriptor-field offsets;
- conditional assembly for debug code, feature flags, and variant builds;
- disciplined section layout and naming instead of ad hoc labels.

In this stage, loops and branches are still emitted as ordinary COR24 assembly,
but the source is more structured because the repetitive patterns are factored
and named.

### Stage B: migrate to true structured control syntax

Once `sw-cor24-hlasm` implements and stabilizes structured `IF`, `DO`, and
`SELECT`, replace hand-lowered label/branch regions with the corresponding
HLASM forms.

That means the first rewrite should not depend on unimplemented `hlasm`
features. It should be prepared to adopt them later.

## Proposed Source Organization

Start with a single authored `rpg2.hlasm` file.

Reason:

- current `hlasm` non-goals and docs do not promise include/COPY support;
- the current repo already assumes a single-source workflow;
- a single file reduces build-pipeline churn while the toolchain is still
  maturing.

Within `rpg2.hlasm`, structure the file into explicit sections:

1. constants and memory-map definitions
2. macro layer
3. fixed-layout descriptors and working storage offsets
4. low-level I/O helpers
5. deck and buffer primitives
6. spec parser entry points
7. RPG cycle driver
8. calculation/output helpers
9. demo/test data

## Macro Layer to Add Early

The first HLASM rewrite should add a small, practical macro vocabulary:

- `PROC name` / `ENDPROC`
  - expand to the established COR24 prologue/epilogue pattern
- `CALL0 name`, `CALL1 name,arg`, `CALL2 name,arg1,arg2`
  - standardize call sites and stack cleanup
- `RET0`, `RET1 reg`
  - standardize returns
- `LOAD_ADDR reg,symbol`
  - wrap `la`
- `UART_EMIT reg`
  - wrap the UART busy-wait + store pattern when inlining is better than a call
- descriptor offset macros such as `DECK_BASE`, `DECK_LEN`, `DECK_COUNT`,
  `DECK_INDEX`

These are immediately useful with today's `hlasm` feature set.

## Architecture Changes for the Rewrite

The current docs describe a future full RPG-II processor. The rewrite should
preserve that target architecture, but change how the code is reached:

### Preserve

- memory-backed source deck, data deck, printer buffer, and optional output
  deck;
- flat working storage in COR24 SRAM;
- parser/runtime split;
- indicator table, field table, calculation evaluator, output formatter.

### Change

- authored implementation language becomes HLASM-flavored source;
- build becomes a two-stage transform;
- `.s` is no longer the system of record;
- repetitive low-level idioms move into macros and conditional-assembly blocks.

## Capability Gaps That Matter

These gaps in `sw-cor24-hlasm` directly affect the rewrite plan:

1. Structured control flow is documented but not implemented.
   The RPG cycle, spec scanning loops, and output-formatting branches cannot
   rely on `IF`/`DO`/`SELECT` yet.
2. The assembler emits plain assembly text via UART.
   The build pipeline needs a capture step to write generated output to a file
   such as `build/rpg2.generated.s`.
3. The project still appears to be single-file oriented.
   The rewrite should avoid assuming include files or macro libraries until the
   tool supports them cleanly.

## When To Pivot Upstream Into `hlasm`

If a missing `hlasm` feature is the main reason the RPG-II rewrite becomes
awkward, repetitive, or blocked, the correct next step may be to improve
`../sw-cor24-hlasm` first and resume the rewrite afterward.

Use this pivot rule:

- stay in `sw-cor24-rpg-ii` when the missing convenience can be handled with a
  small local macro or a temporary hand-lowered branch sequence;
- pivot to `sw-cor24-hlasm` when the missing feature would otherwise force
  repeated boilerplate across major parts of the RPG-II runtime or would make
  the generated code materially harder to validate.

### Highest-value upstream features

1. Structured `IF` / `ELSEIF` / `ELSE` / `ENDIF`
   This is the biggest readability win for parser dispatch, indicator-driven
   calculation gating, and formatting decisions.
2. Structured `DO` / `DOEXIT` / `ITERATE` / `ENDDO`
   This directly helps source-deck scanning, record loops, and buffer walkers.
3. Structured `SELECT` / `WHEN` / `OTHERWISE` / `ENDSEL`
   This is a good fit for spec-type dispatch and opcode dispatch.
4. Include or macro-library support
   Useful later, but less urgent than structured control flow.

### Practical pivot threshold

Pivot to upstream `hlasm` work if either of these becomes true:

- the rewrite reaches a point where three or more major runtime areas need the
  same missing control construct;
- the hand-lowered fallback is obscuring intent enough that review and test
  maintenance become the dominant cost.

## Build and Tooling Changes

Replace the current direct build model:

```text
rpg2.s -> cor24-run
```

with:

```text
rpg2.hlasm
  -> cor24-run --run ../sw-cor24-hlasm/hlasm.s --load-binary ...
  -> capture UART output to build/rpg2.generated.s
  -> cor24-run --run build/rpg2.generated.s
```

Build-script changes needed:

- change `build.sh` to treat `rpg2.hlasm` as the primary source;
- add a generation step before assemble/run;
- keep `make`, `demo.sh`, and `reg-rs` pointed at the generated `.s`;
- add a debug option to preserve generated output for inspection.

## Migration Phases

### Phase 0: planning and repo prep

- add this plan;
- choose `rpg2.hlasm` as the primary source name;
- update docs that currently claim `rpg2.s` is the authored program;
- adjust build scripts to reserve `.s` for generated output.

### Phase 1: toolchain spike

- create the minimal `rpg2.hlasm` hello-world/UART program;
- prove generation of `build/rpg2.generated.s`;
- prove the generated `.s` assembles and runs;
- define the first macro layer.

Exit criteria:

- one-command build from `.hlasm` to running COR24 program.

### Phase 2: runtime skeleton rewrite

- port `_emit_char`, `_emit_crlf`, and deck primitives into `rpg2.hlasm`;
- preserve existing step-2 behavior as the first compatibility milestone;
- add macros for subroutine structure and descriptor offsets.

Exit criteria:

- generated program reproduces today's record-read demo behavior.

### Phase 3: parser/runtime foundation

- implement the spec dispatcher and parser tables in HLASM-authored source;
- keep control flow hand-lowered where necessary;
- use conditional assembly for feature flags and tracing.

Exit criteria:

- source-deck traversal and spec classification run from generated output.

### Phase 4: structured-control adoption

- when `hlasm` lands real structured lowering, selectively replace the most
  complex branch-heavy regions:
  - spec scanning loops,
  - detail/total cycle control,
  - formatting decision trees.
- if structured lowering is still absent when Phase 3 reaches one of those
  regions, pause the rewrite and open the corresponding upstream `hlasm`
  feature step first.

Exit criteria:

- the most error-prone branch forests are authored with structured constructs
  instead of manual label choreography.

## Validation Strategy

Use three layers of validation:

1. HLASM generation checks
   - verify `rpg2.hlasm` generates stable `.s` output;
   - keep a small regression around macro expansion shape when practical.
2. Runtime behavioral checks
   - preserve the existing `reg-rs` behavior for deck reading first;
   - add tests per feature milestone rather than attempting a full rewrite at
     once.
3. Differential checks during migration
   - where the old `rpg2.s` still exists, compare UART output between old and
     rewritten variants for the same test deck.

## Recommended Near-Term Scope

The next implementation step should not be "rewrite all of RPG-II in HLASM".
It should be:

1. switch the primary source to `rpg2.hlasm`;
2. establish the two-stage build;
3. port the existing UART + deck-reader subset;
4. add only the macro/conditional structure that today's `hlasm` supports.

That gets the repo onto the new track without depending on unfinished
structured-control features.

## Bottom Line

Use `rpg2.hlasm` as the new authored source format and treat `.s` as generated
output. Rewrite now using `hlasm` macros and conditional assembly, but do not
block the project on unimplemented `IF`/`DO`/`SELECT` lowering. Build the
runtime in staged compatibility milestones, then adopt true structured control
syntax when `sw-cor24-hlasm` is ready for it.
