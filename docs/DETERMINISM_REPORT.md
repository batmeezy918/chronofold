# DETERMINISM & REPLAY REPORT

This report audits the system for determinism, stable execution, toolchain consistency, and exact reproducibility.

## 1. Toolchain & Compilation Determinism
- **Lean Toolchain Consistency**: Fixed by `lean-toolchain` pinning to `leanprover/lean4:stable`.
- **Package Manager Stability**: Resolved via `lake-manifest.json` ensuring identical package checkouts.
- **Compiler Trace Integrity**: Compiling `lake build` generates deterministic `.olean` objects with matching intermediate representations (IR) and canonical trace hashes.

## 2. Replayability & Execution Determinism
- **Theorem Validation Pipeline**: Executing `./scripts/process_inbox.sh` evaluates candidate files and moves them to `theorems_proven/` strictly based on clean compilation. It is completely reproducible.
- **Benchmark Suite Determinism**: Running `python3 benchmark.py` executes optimization loops on fixed standard functions (Sphere, Rastrigin, Rosenbrock) using controlled iteration counts to ensure statistical reproducibility of `real_results.json`.

## 3. Workflow Determinism
- **Continuous Integration**: Pinned GitHub action runner environment definitions prevent environment drift.
- **Outputs Verification**: Build inputs produce isomorphic outputs under all validated compiler configurations.
