# PROVEN THEOREMS — Lean 4 verified (v4.29.0)

**Status:** `lake build Chronofold` completed successfully (8 jobs).
**Toolchain:** leanprover/lean4:v4.29.0
**Date:** 2026-08-05
**Scope:** AGD Q* constitutional kernel (no Mathlib required for this slice).

Only items that typechecked are listed.

## Theorems (Lean-accepted)

### Equivalence and quotient
- `AGDEquiv.refl` / `symm` / `trans`
- `TBar_sound`
- `interchangeable_iff`
- `admission_iff_TBar`
- `admissible_implies_descends`
- `admissible_compose`

### Universal property of Q*
- `respects_of_interchangeable`
- `lift_pi`
- `lift_unique`
- **`qstar_universal_exists`**
- **`qstar_universal_unique`**
- **`qstar_universal`**
- `morphTo_commutes` / `morphTo_unique`
- **`qstar_initial`**
- **`TBar_is_lift`**

## Reproduce

```bash
elan toolchain install leanprover/lean4:v4.29.0
lake build Chronofold
```

Expected: `Build completed successfully`.
