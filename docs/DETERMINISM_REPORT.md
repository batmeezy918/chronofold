# DETERMINISM REPORT

## Execution Environment & Toolchains
- **Lean Toolchain:** Lean 4 v4.33.0 (x86_64-unknown-linux-gnu, commit `d8b18978322de05a8f3dba51ef03cf5461676c17`)
- **Lake Version:** 5.0.0
- **Python Runtime:** Python 3.12 with `numpy` and `cma`
- **CI Workflows:** Fully pinned GitHub Actions using standard Ubuntu runner and cached toolchains.

## Verification & Reproducibility Metrics
1. **Lean Specification Build:** `lake build` executes deterministically producing zero warnings or errors.
2. **Executable Smoke Test:** `lake exe Main` outputs `ChronoFold system active`.
3. **Theorem Verification Pipeline:** `scripts/process_inbox.sh` and `scripts/validate_theorem.py` enforce strict syntactic and semantic verification without non-deterministic side effects.
4. **Benchmark Replay:** `python3 benchmark.py` reproduces optimization runs across Sphere, Rastrigin, and Rosenbrock test suites.

## Determinism Status
All build steps, proof checking routines, and benchmark executions have zero non-deterministic variances.
