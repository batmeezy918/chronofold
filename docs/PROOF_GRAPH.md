# PROOF GRAPH

This document specifies the proof dependencies and hierarchical structure of the formalized Lean modules in the ChronoFold repository.

```
       [ Lean 4 Core Primitives ]
                   │
         ┌─────────┴─────────┐
         ▼                   ▼
  [ Verify.lean ]    [ ChronoFold/Auto.lean ]
         │                   │
         ├─ State            ├─ rho_step
         ├─ Omega            ├─ omega
         ├─ Covariant        ├─ omega_step
         ├─ Operator         │
         ├─ Admissible       ├─ omega_divides_n
         ├─ AGDEquiv         ├─ omega_nonneg
         ├─ QStar            └─ omega_le_n
         ├─ TBar
         ├─ TBar_sound
         ├─ descends
         ├─ PreservingQuotient
         ├─ uniqueMorph
         ├─ uniqueMorph_unique
         ├─ interchangeable
         ├─ interchangeable_iff
         ├─ admission_iff_descends
         ├─ Invariants
         ├─ ConstitutionalObject
         ├─ Witness
         ├─ Fiber
         ├─ Registry
         ├─ replay
         ├─ replay_preserves_invariants
         ├─ Replay
         ├─ Compiler
         ├─ Serialization
         ├─ Hash
         └─ Builder
```

## Module Dependency Details

### 1. `Verify.lean`
- **Depends On:** Standard Lean 4 Core library (No external package dependencies such as Mathlib).
- **Core Results:**
  - `uniqueMorph_unique`: Proves that the minimal quotient space $Q^*$ exhibits universal initiality amongst all preserving quotients.
  - `admission_iff_descends`: Proves equivalence of operator admissibility and identity equivalence under projection.
  - `replay_preserves_invariants`: Establishes the constitutional safety of sequential replay sequences of admissible operators.

### 2. `ChronoFold/Auto.lean`
- **Depends On:** Mathlib (Nat divisibility/GCD library definitions).
- **Core Results:**
  - `omega_divides_n`: Mathematical proof that the algebraic omega probe is a factor of state parameter $n$.
  - `omega_le_n`: Upper-bounding of the omega probe.
