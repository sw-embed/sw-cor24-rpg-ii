# Plan

## Step 1 -- HLASM rewrite analysis and plan

Analyze the current project docs, the existing assembler source, and the current state of ../sw-cor24-hlasm. Produce docs/hlasm-rewrite-plan.md describing rewrite goals, architecture, structured-programming approach, feature gaps, migration phases, validation strategy, and recommended source file extensions.

**Deliverable**: docs/hlasm-rewrite-plan.md

**Test**: document is internally consistent and grounded in repo evidence.

## Step 2 -- HLASM capability spike

Prototype the minimal HLASM source skeleton, build entry point, and any compatibility shims required to assemble and run a first UART/hello-world variant.

## Step 3 -- Rewrite skeleton

Create the initial RPG-II rewrite skeleton in the chosen HLASM source format with build wiring and placeholder structured sections.
