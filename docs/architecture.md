# Architecture

## Overview

A single COR24 assembly program (`rpg2.s`) that reads fixed-column RPG-II
source from an in-memory card deck, executes the RPG cycle, and produces
output via UART and/or memory-backed printer buffer.

```
Input card deck (80-byte records)
    |
    v
+---------------------------+
| RPG-II Processor          |
|  Spec parser              |
|  Indicator table          |
|  Field storage            |
|  RPG cycle driver         |
|  Calculation evaluator    |
|  Output formatter         |
+---------------------------+
    |
    v
UART (0xFF0100)  /  Line-printer buffer
```

## Platform

COR24 24-bit RISC: 3 GP registers (r0-r2), fp, sp, 24-bit words,
variable-length instructions (1/2/4 bytes), UART at 0xFF0100.

## Memory Layout

| Region | Address | Contents |
|--------|---------|----------|
| Code | 0x000000+ | RPG-II processor assembly |
| RPG source deck | 0x080000 | Input 80-byte records (program specs) |
| Data deck | 0x090000 | Input 80-byte records (data to process) |
| Output deck | 0x0A0000 | Output 80-byte records (card punch) |
| Printer buffer | 0x0B0000 | 132-byte lines (line printer) |
| Working storage | 0x0C0000 | Indicators, fields, accumulators |
| Stack | 0xFEEC00 | Hardware stack (EBR, grows down) |

Addresses are approximate; exact layout decided during implementation.

## Components

### Spec Parser
Reads RPG-II source records and classifies them by type (H, F, I, C, O, E).
Extracts fields from fixed columns. Builds internal tables for file
descriptions, input fields, calculations, and output specs.

### Indicator Table
256 bytes (one per indicator 00-99 + MR, LR, L1-L9, OA-OG, OV, etc.).
Set/test via byte operations on the table.

### Field Storage
Working fields extracted from input records. Fields are byte slices
referencing positions within the current record buffer.

### RPG Cycle Driver
Main loop: detail time (read record, move fields, calc, output detail)
then total time (control breaks, totals, final output). Terminates on EOF.

### Calculation Evaluator
Evaluates C-specs sequentially. Supports arithmetic, moves, comparisons,
indicator manipulation, and branching.

### Output Formatter
Applies O-spec edit codes (zero suppress, commas, decimal, blanks) and
writes formatted lines to the printer buffer or UART.

## I/O Model

- **Card reader**: sequential read from in-memory data deck array
- **Card punch**: append to in-memory output deck array
- **Printer**: write to in-memory 132-byte line buffer, flush to UART
- **UART**: character I/O at 0xFF0100

## Register Allocation

Follows Forth convention (frozen):

| Register | Use |
|----------|-----|
| r0 | Work register / scratch |
| r1 | Scratch / temp pointer |
| r2 | Pointer to current record / working area |
| fp | Frame pointer for subroutines |
| sp | Data stack (hardware push/pop) |

## Build / Test

```bash
make              # assemble check
make test         # run reg-rs regression suite
make demo         # run example program
./demo.sh         # interactive demo
./demo.sh test    # test suite
./demo.sh repl    # interactive (future)
```

All shell scripts, no Python/Rust/C. Follows sw-cor24-forth patterns.
