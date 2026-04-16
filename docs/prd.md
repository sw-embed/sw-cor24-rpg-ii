# Product Requirements Document

## Product name

**RPG-II for COR24**

## Tagline

An RPG-II report program generator/assembler for the COR24 24-bit RISC ISA, written entirely in COR24 assembly.

## Purpose

RPG-II for COR24 provides a historically authentic RPG-II processor that:

- accepts fixed-column RPG-II source from an in-memory card deck
- implements the RPG cycle (read, calculate, output, total)
- produces printed reports via UART and/or line-printer buffer
- optionally produces output card decks
- runs entirely on COR24 hardware or the emulator

The implementation language is **COR24 assembly**. There is no high-level language intermediary -- the RPG-II processor is itself a COR24 assembly program.

## Users

Primary users are:

- the project author
- students learning about report generators and batch processing
- people interested in historical language processors
- COR24 ecosystem developers wanting a realistic RPG workload

## Core value

The core value is:

- historical authenticity (RPG-II was originally implemented in assembler)
- educational visibility (every byte of the RPG-II processor is inspectable COR24 assembly)
- batch record processing on a minimal 24-bit RISC machine
- a compelling web UI demo showing card deck input flowing through the RPG cycle to printed output

## RPG-II scope

The initial implementation supports a minimal but useful RPG-II subset:

### Input
- One primary input file (card deck, 80-byte records)
- Fixed-column field definitions (F-spec)
- Record identification by type code

### Indicators
- General-purpose indicators (01-99)
- MR (matching record) indicators
- LR (last record) indicator
- L1-L9 (control-level) indicators
- OA-OG (output) indicators
- OV (overflow) indicator

### Calculations (C-specs)
- ADD, SUB, MULT, DIV
- Z-ADD, Z-SUB
- MOVE, MOVEL, MOVR
- COMP, CAB, CAS
- SETON, SETOF
- GOTO, TAG

### Output (O-specs)
- Detail lines (printer)
- Total lines (printer)
- Heading lines (printer)
- Output records (card punch)
- Field editing (zero suppress, blank fill, comma insertion)

### RPG Cycle
- Detail time processing
- Total time processing
- Control break detection (single level initially)

## Goals

### G1. Fixed-column RPG-II source

The processor shall accept RPG-II source as 80-byte records loaded into an in-memory card deck, following the classic fixed-column format.

### G2. Complete RPG cycle

The processor shall implement the full RPG cycle: read input, evaluate indicators, execute calculations, produce output, detect control breaks, handle totals.

### G3. Memory-backed I/O

The processor shall use memory-backed card decks and line-printer buffers, with optional UART output for interactive demonstration.

### G4. COR24 assembly implementation

The entire RPG-II processor shall be written in COR24 assembly. No C, Rust, Python, or other high-level language code.

### G5. Shell script build system

Build, test, and demo shall be driven by shell scripts and Make, following the patterns established by sibling repos (sw-cor24-forth, sw-cor24-apl).

### G6. Regression testing with reg-rs

Tests shall use `reg-rs` for golden-output regression testing, consistent with other COR24 language implementations.

## Non-goals

RPG-II for COR24 does not initially provide:

- floating point support
- multiple input files
- indexed or keyed file access
- disk I/O
- full RPG II/III/IV compatibility
- interactive console input (deferred)
- externally callable subroutines

## Constraints

### C1. Implementation language

COR24 assembly only. Shell scripts for build/test orchestration.

### C2. Target platform

COR24 emulator (`cor24-run`) and COR24 FPGA hardware.

### C3. Memory model

All data in COR24 address space (1 MB SRAM + 8 KB EBR stack).

### C4. Register constraints

3 general-purpose registers (r0, r1, r2), frame pointer (fp), stack pointer (sp). No hardware divide.

### C5. I/O model

UART at 0xFF0100. Card decks and line-printer buffers are memory-backed.

## Success criteria

### Phase 1 success

A card listing program (RPG-II source) can be loaded and processed to produce UART output.

### Phase 2 success

A field extraction and totals report can be processed correctly.

### Phase 3 success

A control break report produces correct subtotals and grand totals.

### Phase 4 success

The system handles multiple record types, edited output, and page formatting.
