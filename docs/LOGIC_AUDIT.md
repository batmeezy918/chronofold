# Chronofold Logic Audit (2026-08-05)

## Severity legend
- **P0** — claim is false or proof is vacuous
- **P1** — breaks at runtime / wrong for general inputs
- **P2** — weak but not crashing

---

## 1. Lean AGD stack (`src/Chronofold/Agd*.lean`) — P0

| File | Issue |
|------|--------|
| `AgdOperators.lean` | `S`, `Delta`, `Omega`, `Xi` are all **identity**. Composition is identity. No dynamics. |
| `AgdInvariants.lean` | `Invariant _ := 0`. Preservation theorems are **tautologies**. |
| `AgdClosure.lean` | `AGD_Universal_Closure` only repackages hypotheses; proves nothing new. |
| `verification_report.md` | Claims "all operators verified" while admitting placeholders. |

**Fix applied:** Replaced with a real Minimal Admissible Quotient kernel aligned to the AGD commercial core:
- `AGDEquiv` from `(Ω, C)`
- `QStar`, `pi`, `TBar`
- `admission_iff_TBar` (non-vacuous)
- `interchangeable_iff`

---

## 2. `CategoryQuotient.lean` — P1

- `Category DynSys` only defines `Hom` / `id` / `comp`. Newer Mathlib needs `id_comp`, `comp_id`, `assoc` (or use `CategoryTheory.Category.Basic` patterns carefully).
- `CostFunctor` / `CompressionRefinement` are empty shells.

**Fix applied:** Added identity/assoc proofs; marked cost objects as stubs explicitly.

---

## 3. `chronofold_x/core/omega.py` — P1

- `json.dumps` of graphs that contain **float vectors** is not bit-stable across platforms (float repr).
- Hash used for fixed-point of normalize can oscillate or disagree across runs.

**Fix applied:** Round vectors before hashing; exclude volatile fields consistently.

---

## 4. `core/src/optimizers/snap_core.py` — P1

- `project(g)` **hard-codes indices 0,1,2**. Fails or is meaningless for `n ≠ 3` (script uses `n=10`).
- "Tangent projection" is an ad-hoc 3-D rule, not a general SNAP operator.

**Fix applied:** Dimension-generic projection (remove mean / optional manifold constraint) + safe descent.

---

## 5. `omega_run.py` — P2

- Covariance update is not CMA; mixing `R * (C @ z)` with outer-product `H` is heuristic.
- Still a valid experiment harness; left as experimental, documented.

---

## 6. Repo structure — P2

- Massive `archive/`, duplicate `cocoex_*` trees, many empty/trivial Lean files in `experiments/cfpc_runs`.
- Does not break logic but obscures the real kernel.

**Recommendation:** Keep `src/Chronofold/` + `chronofold_x/` + `docs/LOGIC_AUDIT.md` as source of truth; treat the rest as historical.

---

## What "fixed" means in this commit

1. Lean AGD files express **real quotient/admission logic**, not identity placeholders.
2. SNAP core works for **any dimension**.
3. Omega normalization **hashes stably**.
4. This audit is in-tree so claims cannot silently drift again.
