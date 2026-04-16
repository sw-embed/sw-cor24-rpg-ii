# Design

## RPG-II Source Format

Each RPG-II source line is an 80-byte record with fixed columns:

| Columns | Spec | Purpose |
|---------|------|---------|
| 6 | H | Header / control |
| 7-15, 19-26 | F | File description |
| 7-32 | I | Input field definition |
| 7-20, 22-70 | C | Calculation |
| 7-32, 34-70 | O | Output specification |
| 15-16 | E | End / conditional |

Column 6 identifies the spec type. Columns 7-71 carry spec data.
Column 72+ ignored. Columns 1-5 are sequence numbers.

## Internal Data Structures

All structures live in COR24 SRAM as flat byte arrays.

### Source Deck Descriptor
```
+0: base address (24-bit)
+3: record length = 80 (24-bit)
+6: record count (24-bit)
+9: current index (24-bit)
```

### Data Deck Descriptor
Same layout as source deck. Contains the input data records to process.

### Indicator Table
256 bytes. One byte per indicator. Addresses mapped by indicator number:
- 00-99: general purpose
- 100+: MR, LR, L1-L9, OA-OG, OV, etc.

### Field Descriptor
Per input field (I-spec):
```
+0: record type (1 byte, 0=any)
+1: field start column (1 byte)
+2: field end column (1 byte)
+3: decimal places (1 byte)
+4: field type (1 byte: 'A'=alpha, 'N'=numeric, blank=undefined)
+5: result field name (2 bytes, packed name)
```

### Working Storage
Flat byte area for extracted fields, accumulators, and temp values.
Fields addressed by descriptor offset.

## RPG Cycle

```
startup:
    load RPG source specs from source deck
    parse H, F, I, C, O specs into internal tables
    open data deck
    set indicators: 1P on, LR off

detail_loop:
    read next record from data deck
    if EOF: goto total_time

    ; detail time
    match record to I-specs by type code
    move input fields to working storage
    evaluate all C-specs (skip if indicators off)
    evaluate all detail O-specs (skip if indicators off)
    write output lines to printer buffer
    goto detail_loop

total_time:
    set LR indicator on
    evaluate all total-time C-specs
    evaluate all total-time O-specs
    flush printer buffer to UART
    halt
```

Control breaks are a future extension on top of this basic cycle.

## C-Spec Evaluation

Each C-spec is a 3-row block in RPG-II source (operation, factor1, factor2, result).
Internal representation is a compact opcode + operand indices.

Operations map to COR24 arithmetic directly:
- `ADD F1,F2 RESULT` -> `lw r0,F1; lw r1,F2; add r0,r1; sw r0,RESULT`
- `Z-ADD F1 RESULT` -> `lw r0,F1; ceq r0,z; brt skip; sw r0,RESULT`
- `MOVE F1 RESULT` -> byte copy from field to field
- `COMP F1 F2` -> compare, set condition indicator
- `SETON IN` -> set indicator byte to 1
- `SETOF IN` -> set indicator byte to 0

## O-Spec Output Formatting

O-specs define output line layout with edit codes:
- Blank: raw field data
- `1-4`: zero suppress leading digits
- `J`: right-justify with blank fill
- `B`: blank after (spacing)
- Comma/decimal insertion for numeric fields

Formatting is done byte-by-byte into the print line buffer, then
the completed line is flushed to UART.

## Software Divide

COR24 has no hardware divide. For RPG-II DIV operation, use a
subroutine-based software divide (shift-and-subtract). Borrow from
existing implementations in the COR24 ecosystem if available.

## Assembly Conventions

Follow the Forth repo's frozen rules:
- Labels on own line: `label:` (no inline)
- Comments: `;` only
- Decimal immediates: `la r0, -65280` not hex
- `.byte 72,101,108` for string data (no string literals)
- No `.align`; pad with `.byte 0` manually
- Branch offset range: +/-127 bytes; use `la+jmp` for far jumps
- `push`/`pop` only for r0, r1, r2, fp

## Subroutine Structure

The RPG-II processor uses a small set of subroutines with standard
COR24 calling convention:

```asm
; Call: push args right-to-left, jal, add sp to clean up
push    arg2
push    arg1
la      r0, _subroutine
jal     r1, (r0)
add     sp, 6

; Prologue
push    fp
push    r2
push    r1
mov     fp, sp
add     sp, -N

; Epilogue
mov     sp, fp
pop     r1
pop     r2
pop     fp
jmp     (r1)
```
