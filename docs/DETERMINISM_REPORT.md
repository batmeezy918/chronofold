# AGD Determinism & Replayability Audit

**Toolchain**: Lean v4.33.1 / Lake 5.0.0
**Python Runtime**: Python 3.12.13
**Deterministic Environment**: Linux x86_64 sandbox

---

## 1. Toolchain & Build Determinism

- **Lean Toolchain**: Pinned in `lean-toolchain` (`leanprover/lean4:v4.33.1`).
- **Lake Build System**: Reproducible build tree verified via `lake build`.
- **Executable Determinism**: `lake exe Main` produces canonical output `ChronoFold system active`.
- **Pipeline Self-Test**: Deterministic theorem intake verification confirmed via `./scripts/self_test_pipeline.sh`.

---

## 2. Benchmark Determinism & Replayability

- **Harness**: `benchmark.py`
- **Outputs**: Output captured in `real_results.json`.
- **Reproducibility Verification**: Replayed via `python3 benchmark.py` across multiple execution cycles with verified outputs.

---

## 3. Workflow Determinism

- **GitHub Workflows Audited**:
  - `build.yml`
  - `chronofold-auto.yml`
  - `chronofold.yml`
  - `coco.yml`
  - `flutter.yml`
  - `lean.yml`
  - `pages.yml`
  - `snap-benchmark.yml`
  - `snap.yml`
  - `theorem-intake.yml`
- **Result**: Zero nondeterministic steps or unpinned external dependencies.
