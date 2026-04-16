# Plan

## Approach

Single COR24 assembly file (`rpg2.s`), built up incrementally.
Shell scripts for build/test/demo. `reg-rs` for regression tests.
Follows sw-cor24-forth pattern directly.

## Step 1 -- Skeleton and UART output

Set up `rpg2.s` with reset vector, UART emit subroutine, and a halt loop.
Verify it assembles and runs with `cor24-run`.

**Deliverable**: `rpg2.s` prints "RPG-II" to UART and halts.

**Test**: `reg-rs` golden output contains "RPG-II".

## Step 2 -- Card deck reader

Implement subroutine to read 80-byte records from a memory-backed deck.
Load a small test deck via `--load-binary` and verify records are read
correctly.

**Deliverable**: `_read_record` subroutine, deck descriptor layout.

**Test**: read 3 records, print first 10 bytes of each to UART.

## Step 3 -- Spec parser (H and F specs)

Parse header and file description specs from the source deck.
Classify records by column 6 type code.

**Deliverable**: `_parse_h_spec`, `_parse_f_spec`, spec type dispatch.

**Test**: parse a simple F-spec, print file name to UART.

## Step 4 -- Spec parser (I specs)

Parse input field definitions. Build field descriptor table.
Implement field extraction from a record buffer.

**Deliverable**: `_parse_i_spec`, `_extract_field`, field descriptor table.

**Test**: extract fields from a data record, print field values.

## Step 5 -- Indicator table

Implement indicator set/test/clear. Map indicator numbers to table bytes.
Handle MR, LR, and general indicators.

**Deliverable**: `_set_ind`, `_test_ind`, `_clear_ind`, 256-byte table.

**Test**: set indicator 01, test it, print result.

## Step 6 -- RPG cycle driver

Implement the basic detail loop: read record, extract fields, check EOF.
No calculations or output yet -- just the cycle skeleton.

**Deliverable**: `_rpg_cycle` main loop.

**Test**: read through a 3-record deck, print "detail" for each, "EOF" at end.

## Step 7 -- C-spec arithmetic (ADD, SUB, MULT)

Implement basic arithmetic calculations. Parse C-spec operation lines.
Evaluate ADD, SUB, MULT with factor/result field references.

**Deliverable**: `_eval_c_spec` (arithmetic subset), C-spec parser.

**Test**: add two input fields, print result.

## Step 8 -- MOVE, Z-ADD, SETON, SETOF

Implement move operations and indicator manipulation.
Z-ADD zeros the result before adding.

**Deliverable**: move, z-add, seton, setof operations.

**Test**: move a field, set indicator, print results.

## Step 9 -- O-spec output (detail lines)

Implement output specification processing for detail time.
Write formatted fields to the print line buffer.
Flush completed lines to UART.

**Deliverable**: `_eval_o_spec`, `_format_field`, `_flush_line`.

**Test**: print a formatted detail line from input data.

## Step 10 -- Totals and LR indicator

Implement total-time processing. Accumulate totals in working storage.
Set LR on EOF, evaluate total-time C-specs and O-specs.

**Deliverable**: total-time cycle, accumulator support.

**Test**: sum a field across all records, print total.

## Step 11 -- Card listing demo

Wire up a complete card listing program (RPG-II's "hello world").
Input: data deck of 80-byte records. Output: each record printed as a line.

**Deliverable**: example RPG-II source, demo script, `reg-rs` test.

## Step 12 -- Control break report demo

Add single-level control break detection.
Compare control field to previous value, trigger L1 on change.
Print subtotals on break, grand total at EOF.

**Deliverable**: control break logic, department salary report example.

## Step 13 -- Edit codes and formatting

Implement zero suppression, right-justify, comma/decimal insertion
in O-spec output formatting.

**Deliverable**: edit code processing in `_format_field`.

**Test**: format 1000 as "1,000", 42 as "    42", 0 as blank.

## Deferred

- Multiple input files
- Record identification by type code
- COMP with branching (CAB, CAS)
- GOTO/TAG in calculations
- Page overflow and skip-before/skip-after
- Heading and footing lines
- Card punch output
- Interactive console input
