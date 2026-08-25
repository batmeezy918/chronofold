# AGD Determinism & Replayability Audit

**Toolchain**: Lean v4.33.1 / Lake
**Python Runtime**: Python 3.12.13
**Deterministic Environment**: Linux x86_64 sandbox

---

## 1. Toolchain & Build Determinism

- **Lean Toolchain**: Pinned in `lean-toolchain` (`leanprover/lean4:v4.33.1`).
- **Lake Build System**: Reproducible build tree verified via `lake build`.
- **Executable Determinism**: `lake exe Main` produces canonical output `ChronoFold system active`.

---

## 2. Benchmark Determinism & Replayability

- **Harness**: `benchmark.py`
- **Outputs**: Output captured in `real_results.json`.
- **Reproducibility Verification**: Verified across multiple execution cycles with identical outputs.

---

## 3. Workflow Determinism

- **GitHub Workflows Audited**:
  - `build.yml`
  - `theorem-intake.yml`
  - `pages.yml`
  - `chronofold.yml`
  - `snap.yml`
- **Result**: Zero nondeterministic steps or unpinned external dependencies.
