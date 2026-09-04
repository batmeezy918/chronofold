# Theorem Inventory — proven pile is GREEN

Status values: `verified_by_lean` (GREEN) | `rejected` | `narrative_only` | `hypothesized`

| File Path | Status | Notes |
|-----------|--------|-------|
| src/Chronofold/AgdCore.lean | verified_by_lean | types |
| src/Chronofold/AgdOperators.lean | verified_by_lean | AGDEquiv, TBar_sound |
| src/Chronofold/AgdInvariants.lean | verified_by_lean | interchangeable_iff, admission_iff_TBar |
| src/Chronofold/AgdClosure.lean | verified_by_lean | admissible_compose |
| src/Chronofold/AgdIterate.lean | verified_by_lean | admissible_iterate |
| src/Chronofold/AgdUniversal.lean | verified_by_lean | lift_pi |
| src/Chronofold/AgdRank.lean | verified_by_lean | projective_collapse |
| src/Chronofold/AgdMultiOmega.lean | verified_by_lean | MultiEquiv |
| src/Chronofold/AgdClassGraph.lean | verified_by_lean | certifiedEdge_class_step |
| src/Chronofold/AgdBidirectional.lean | verified_by_lean | exists_reconstruct |
| src/Chronofold/AgdFibreClosure.lean | verified_by_lean | fibre_witness_collapses |
| src/Chronofold/AgdFiniteReduction.lean | verified_by_lean | pi_surjective |
| src/Chronofold/AgdInvariantSafety.lean | verified_by_lean | invariantSafe suite |
| src/Chronofold/AgdSicConstitutional.lean | verified_by_lean | SIC operational equality |
| src/Chronofold/AgdWitness.lean | verified_by_lean | fibre witnesses |
| src/Chronofold/AgdProductionWitness.lean | verified_by_lean | production witnesses |
| src/Chronofold/AgdCiMarker.lean | verified_by_lean | smoke True |
| src/Chronofold/AutoOmega.lean | verified_by_lean | omega_divides_n, omega_le_n |
| src/Chronofold/CvrPhase0.lean | verified_by_lean | constitutional_closure |
| src/Chronofold/AgdMeasurement.lean | verified_by_lean | jitter / cert / transport |
| src/Chronofold/AgdOperationalQuotient.lean | verified_by_lean | quotient_of_full_chain |
| src/Chronofold/Benchmarks.lean | verified_by_lean | structures only |
| core/theorems_proven/T1.lean | verified_by_lean | t1 |
| core/theorems_proven/THM_000001__nat_add_zero_right.lean | verified_by_lean | n+0=n |
| core/theorems_proven/THM_000002__correct_by_construction_search.lean | verified_by_lean | CBC search |
| core/theorems_proven/THM_000003__omega_divides_n.lean | verified_by_lean | intake copy of AutoOmega |
| disabled/Auto.lean | rejected | |
| disabled/Theorems.lean | rejected | |
| disabled/Operators.lean | rejected | |
| disabled/Base.lean | rejected | |
| templates/theorem_candidate.lean | narrative_only | |
| core/theorems_rejected/THM_000001__smoke_test.lean | rejected | |
| core/theorems_rejected/THM_000001__nat_add_zero_right.lean | rejected | Mathlib import |
| theorems_inbox/EMV-0001 (PR #61) | hypothesized | not Lean-closed |
