# Chronofold AGD Lean4 Verification Report (updated 2026-08-05)

## Honest status

Previous report claimed full verification while operators were **identity** and
`Invariant := 0`. That made every preservation theorem vacuous.

## Current source of truth

```
src/Chronofold/
├── AgdCore.lean         # State, Omega, Covariant, Admissible
├── AgdOperators.lean    # AGDEquiv, QStar, pi, TBar (real descent)
├── AgdInvariants.lean   # interchangeable_iff, admission_iff_TBar
├── AgdClosure.lean      # admissible_compose
└── Benchmarks.lean      # import-graph placeholder
```

## What is actually proved (contentful)

| Theorem | Content |
|---------|---------|
| `AGDEquiv` is equivalence | refl / symm / trans |
| `TBar_sound` | descended map agrees with `pi ∘ T` |
| `interchangeable_iff` | same class ↔ same `(Ω,C)` |
| `admission_iff_TBar` | admissible ↔ exists concrete `TBar` |
| `admissible_compose` | admissible operators closed under composition |

## What is still open

- Full `Nat`-iterate induction in `admissible_iterate` (stubbed for compose-twice).
- Concrete domain instances of `Ω` / `C` (EMV, navigation) live in the Python AGX runtime.
- `CategoryQuotient.lean` remains a scaffold for dynamical systems, not the Q* kernel.

## Python logic fixes in same commit

- `snap_core.py`: dimension-generic projection (no hard-coded 0,1,2).
- `chronofold_x/core/omega.py`: float-stable hashing for normalize fixed-point.

See `docs/LOGIC_AUDIT.md` for the full defect list.
