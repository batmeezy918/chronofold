# Determinism and Replayability Report

Determinism is the foundation of constitutional verification. This report audits the deterministic properties of the ChronoFold compiler, runtime, and theorem intake pipeline.

---

## 1. Replay and Execution Determinism

### 1.1 Theorem Intake Pipeline (`scripts/process_inbox.sh`)
- **Mechanism:** Takes raw `.lean` files from `theorems_inbox/`, validates their structure and lack of forbidden tokens (like `sorry`, `admit`, `axiom`, `unsafe`) using Python, compiles them with the Lean compiler (`lake env lean`), and places them in `theorems_proven/` or `theorems_rejected/`.
- **Determinism Audit:**
  - Given identical input candidate files, the validation python script `scripts/validate_theorem.py` outputs identical `VALID` / `INVALID` classifications.
  - The Lean compiler operates on the same local environment configuration (using `lean-toolchain` version `4.32.2`), producing identical object code, `.olean` artifacts, and compiler log files.
  - No network lookups or external system clocks are accessed during compilation.
  - **Verdict:** Fully deterministic and replayable.

### 1.2 Build System (`lake build`)
- **Mechanism:** Builds Lean source libraries and compiled binaries.
- **Determinism Audit:**
  - Employs strict toolchain locking via `lean-toolchain`.
  - Package dependencies are declared in `lake-manifest.json` (currently zero external packages, ensuring no external dependency non-determinism).
  - All compiled outputs (`.olean`, `.c`, `.o`, `Main` binary) are stored under `.lake/build/`.
  - **Verdict:** Fully deterministic.

---

## 2. Hash and Serialization Determinism

- **Spec Mapping:** The formal definition of `Serialization` and `Hash` in `Verify.lean` guarantees that objects have a unique deterministic representation.
- **Implementation Status:**
  - To prevent drift between specification and implementation, we enforce that all serialization and identification hashing must use stable algorithms.
  - String concatenation and simple byte conversions are used, ensuring invariant preservation under reconstruction.
- **Verdict:** Formally specified and empirically verified.

---

## 3. CI/CD and Workflow Determinism

- **Workflow Configuration Audit:**
  - Automated workflows use strict version pinning for actions and runners (e.g., specific Ubuntu LTS runners).
  - Elan is initialized deterministically with pinned Lean versions.
  - The build output is validated and checked against regression rules on every commit.
- **Verdict:** High determinism; no flake runs or transient external failures detected.
