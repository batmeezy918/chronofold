# PROVEN THEOREMS — Lean 4.29 verified (no sorries)

**Build:** `lake build Chronofold` → **Build completed successfully (12 jobs)**  
**Date:** 2026-08-05

## Core Q* (prior)
- AGDEquiv.refl/symm/trans, TBar_sound, interchangeable_iff
- admission_iff_TBar, admissible_implies_descends, admissible_compose
- qstar_universal, qstar_initial, lift_unique, TBar_is_lift

## Tier A1 — Rank collapse (`AgdRank.lean`)
- `Projective` (idempotent P)
- `projective_collapse`, `apply_is_fixed`
- `RankedSpan.rank_eq_length`, `rank_le_length`

## Tier A2 — Multi-Ω (`AgdMultiOmega.lean`)
- `MultiEquiv.refl/symm/trans`, `multiSetoid`, `QStarMulti`
- `dropLast`, `multiEquiv_of_finer`, `finer_implies_coarser`
- `MultiAdmissible`, `multiAdmissible_compose`

## Tier A3 — Class graph (`AgdClassGraph.lean`)
- `CertifiedEdge`, `certifiedEdge_class_step`
- `classAdjacent`, `classPath`, `classPath_zero`, `classPath_one_of_adjacent`
- `outDegreeBound_eq`

## Tier A4 — Iterate (`AgdIterate.lean`)
- `opIterate`, `admissible_id`
- **`admissible_iterate`** — T admissible ⇒ T^[n] admissible ∀ n
- `TBar_iterate_sound`

## Reproduce
```bash
elan toolchain install leanprover/lean4:v4.29.0
lake build Chronofold
```
