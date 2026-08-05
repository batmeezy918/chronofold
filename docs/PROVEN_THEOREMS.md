# PROVEN THEOREMS — Lean 4.29 (no sorries)

**Build:** `lake build Chronofold` → success (13 jobs)

## Invariant Safety (`AgdInvariantSafety.lean`) — NEW
- `invariantSafe` / `invariantSafe'` / `invariantSafe_iff`
- `invariantSafe_nil`, `invariantSafe_omega`, `invariantSafe_C`, `invariantSafe_omega_and_C`
- `invariantSafe_of_criticals_in_constitution`
- **`drop_critical_makes_unsafe`** — counterexample theorem
- `multiInvariantSafe_of_components`
- `coarser_may_be_unsafe`
- `checkSafeSample` + `checkSafeSample_implies_pairwise`

## Prior
Q*, universal property, rank, multi-Ω, class graph, admissible iterate.
