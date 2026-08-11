# Determinism and Reproducibility Report

Our workspace is continuously verified to ensure absolute determinism and reproducible outputs across all workflows, builds, and runtime execution.

## 1. Toolchain Stability
- **Toolchain Manager**: `elan` manages the Lean toolchain, locked strictly to Lean version `4.33.0` as specified in `./lean-toolchain`.
- **Package Manager**: `lake` handles package building and compilation, with a locked manifest configuration in `lake-manifest.json`.
- **System Compiler**: Consistent compilation across environments is guaranteed by building with standard, deterministic Lean 4 backend code generation without third-party or native C compiler environment drift.

## 2. CI/CD Pipeline Determinism
Our GitHub Action workflows located in `.github/workflows/` are locked to stable commits/actions with deterministic behaviors:
- **Intake Pipeline**: `scripts/process_inbox.sh` processes theorems from `theorems_inbox/` strictly sorted alphabetically using `sort` to prevent intake nondeterminism.
- **Validation Engine**: `scripts/validate_theorem.py` validates the files using deterministic regex checking, filename validation, and checking for forbidden terms (`sorry`, `admit`, `axiom`, `unsafe`).
- **Audit Logs**: Compilation logs and validation receipts are committed as immutable files in `theorem_receipts/` and `logs/` to guarantee historical traceability.

## 3. Runtime and Execution Reproducibility
- **No Side-Effects**: `Main.lean` compiles down to a native executable with no dependencies on random number generators, system clocks, or thread-scheduling nondeterminism.
- **Pure Functional Core**: Lean 4 core specifications are pure mathematical definitions ensuring that evaluation of proofs is fully deterministic and independent of execution environment.
