# DETERMINISM_REPORT.md

## Determinism & Reproducibility Audit Report

### 1. Toolchain & Oracle Determinism
- **Lean Toolchain**: `leanprover/lean4:v4.33.0`
- **Lake Version**: `5.0.0-src+d8b1897`
- **Python Runtime**: `3.12.x`
- **Execution Mandate**: Strict fixed seeds and pure functional specifications.

### 2. Proof & Build Reproducibility
- **`lake build`**: Clean, deterministic compilation producing identical bytecode and `.olean` artifacts.
- **`lake exe Main`**: Produces deterministic console execution output.
- **`scripts/process_inbox.sh`**: Deterministic theorem intake validation with strict JSON receipts generated in `theorem_receipts/`.

### 3. Serialization & Hash Determinism
- **Metamodel Hash**: `Hash(s) = s.id * 31 + 17` (Canonical deterministic integer hash)
- **State Serialization**: `Serialization(s) = "State(id, payload)"` (Pure deterministic string formatting)

### 4. Benchmark Determinism & Replayability
- **Benchmark Suite**: `benchmark.py`
- **Optimizers Benchmarked**: SNAP (Gradient-augmented operator) vs CMA-ES.
- **Test Problems**: Sphere, Rastrigin, Rosenbrock.
- **Artifact**: `real_results.json` generated reproducibly upon execution.

### 5. Workflow & CI Integrity
- Deterministic environment initialization via `elan`.
- Isolated build directories and strict clean worktree maintenance.
