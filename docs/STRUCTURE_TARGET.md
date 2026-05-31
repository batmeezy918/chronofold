# ChronoFold Target Structure

This document outlines the intended deterministic research lab organization for the ChronoFold repository.

## Directory Overview

### Documentation & Planning
- `docs/`: Repository documentation, plans, and manifests.
- `claims/`: High-level research claims.
- `evidence/`: Supporting evidence for claims (measured, benchmarked, etc.).

### Scripts & Tooling
- `scripts/bootstrap/`: Core command helpers and bootstrap scripts (`cf`, `cflab`, etc.).
- `scripts/dag/`: DAG execution, graph traversal, and orchestration scripts.
- `scripts/theorem/`: Lean theorem intake and processing scripts.
- `scripts/benchmarks/`: Executable benchmark runner scripts.
- `scripts/validation/`: Scripts for validating system state and invariants.
- `scripts/apk/`: Android package synthesis and build scripts.
- `scripts/nfc/`: NFC-related utility scripts.
- `scripts/utilities/`: General purpose maintenance scripts.

### Source Code
- `src/chronofold/`: Core ChronoFold logic (formerly chronofold_x/core).
- `src/operators/`: Operator definitions and implementations.
- `src/runtime/`: Execution engines and runtimes.
- `src/validation/`: Runtime validation logic.

### Formal Verification (Lean 4)
- `lean/ChronoFold/Core/`: Base types, algebraic closures, and abstract structures.
- `lean/ChronoFold/Metric/`: Metric closures, energy bounds, and operator validity.
- `lean/ChronoFold/Spectral/`: Spectral skeletons, heat traces, and frequency analysis.
- `lean/ChronoFold/ProofCarrying/`: Infrastructure for proof-carrying code and receipts.

### Theorem Management
- `theorems/inbox/`: New theorems awaiting processing.
- `theorems/proven/`: Formally verified theorems.
- `theorems/rejected/`: Theorems that failed verification or were rejected.
- `theorems/receipts/`: Machine-readable proof receipts and metadata.

### Benchmarks & Results
- `benchmarks/coco/`: COCO/BBOB benchmark harnesses and data.
- `benchmarks/graph/`: Graph-based benchmarks (e.g., Graph500).
- `benchmarks/optimizer/`: Optimizer-specific benchmark suites.
- `benchmarks/spectral/`: Spectral analysis benchmarks.
- `benchmarks/microbench/`: Low-level performance microbenchmarks.
- `results/benchmarks/`: Raw and processed benchmark outputs.
- `results/theorem/`: Lean verification results and summaries.
- `results/validation/`: System validation reports.
- `results/reports/`: Compiled research papers and dossiers.

### Ephemeral & Archival
- `sessions/`: Active research session data.
- `runs/`: Specific execution run logs and artifacts.
- `logs/`: General system and process logs.
- `snapshots/`: Periodic system state snapshots.
- `archive/`: Deprecated or historical artifacts.
