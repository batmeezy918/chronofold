# PROVEN PILE — Lean 4 proofs (GREEN)

Status key: **GREEN** = `verified_by_lean`, no `sorry` in the source module.
Commit: `08111272` + this inventory refresh.
Build target: `lake build Chronofold`.

Every named theorem below is in the proven pile.

## A. AGD core — GREEN
| Theorem | File |
|---|---|
| AGDEquiv.refl / .symm / .trans | src/Chronofold/AgdOperators.lean |
| TBar_sound | src/Chronofold/AgdOperators.lean |
| interchangeable_iff | src/Chronofold/AgdInvariants.lean |
| admission_iff_TBar | src/Chronofold/AgdInvariants.lean |
| admissible_implies_descends | src/Chronofold/AgdInvariants.lean |
| admissible_compose | src/Chronofold/AgdClosure.lean |
| admissible_id | src/Chronofold/AgdIterate.lean |
| opIterate_zero / opIterate_succ | src/Chronofold/AgdIterate.lean |
| admissible_iterate | src/Chronofold/AgdIterate.lean |
| TBar_iterate_sound | src/Chronofold/AgdIterate.lean |

## B. Universal / rank / multi-Ω / graph — GREEN
| Theorem | File |
|---|---|
| respects_of_interchangeable | src/Chronofold/AgdUniversal.lean |
| lift_pi | src/Chronofold/AgdUniversal.lean |
| projective_collapse | src/Chronofold/AgdRank.lean |
| apply_is_fixed | src/Chronofold/AgdRank.lean |
| MultiEquiv.refl / .symm | src/Chronofold/AgdMultiOmega.lean |
| certifiedEdge_class_step | src/Chronofold/AgdClassGraph.lean |
| classAdjacent_of_mem | src/Chronofold/AgdClassGraph.lean |

## C. Bidirectional / fibre / finite / safety — GREEN
| Theorem | File |
|---|---|
| exists_reconstruct | src/Chronofold/AgdBidirectional.lean |
| residual_zero_observables | src/Chronofold/AgdBidirectional.lean |
| fibre_witness_collapses | src/Chronofold/AgdFibreClosure.lean |
| nontrivial_fibre_pi_not_injective | src/Chronofold/AgdFibreClosure.lean |
| pi_surjective | src/Chronofold/AgdFiniteReduction.lean |
| strict_card_of_surjective_not_injective | src/Chronofold/AgdFiniteReduction.lean |
| invariantSafe'_of_safe / invariantSafe_of_safe' | src/Chronofold/AgdInvariantSafety.lean |
| invariantSafe_iff, invariantSafe_nil, invariantSafe_omega, invariantSafe_C | src/Chronofold/AgdInvariantSafety.lean |
| drop_critical_makes_unsafe | src/Chronofold/AgdInvariantSafety.lean |

## D. SIC constitutional — GREEN
| Theorem | File |
|---|---|
| operationalEq_symm | src/Chronofold/AgdSicConstitutional.lean |
| governor_identity | src/Chronofold/AgdSicConstitutional.lean |
| remaining SIC suite in that module | src/Chronofold/AgdSicConstitutional.lean |

## E. Witnesses — GREEN
| Theorem | File |
|---|---|
| w1_ne_w2 / w1_omega_eq_w2_omega | src/Chronofold/AgdWitness.lean |
| witness_ne / witness_omega | src/Chronofold/AgdProductionWitness.lean |
| agd_ci_marker (`True`, smoke) | src/Chronofold/AgdCiMarker.lean |

## F. Auto Ω — GREEN (PRs #63 / #65)
| Theorem | File |
|---|---|
| omega_divides_n | src/Chronofold/AutoOmega.lean |
| omega_nonneg | src/Chronofold/AutoOmega.lean |
| omega_le_n | src/Chronofold/AutoOmega.lean |

## G. CVR Phase 0 — GREEN (PR #22 / #65)
| Theorem | File |
|---|---|
| namespace_preservation | src/Chronofold/CvrPhase0.lean |
| version_preservation | src/Chronofold/CvrPhase0.lean |
| provenance_preservation | src/Chronofold/CvrPhase0.lean |
| relationship_resolution_preservation | src/Chronofold/CvrPhase0.lean |
| acyclicity_preservation | src/Chronofold/CvrPhase0.lean |
| omega_preservation | src/Chronofold/CvrPhase0.lean |
| admissibility_closure | src/Chronofold/CvrPhase0.lean |
| operator_composition_closed | src/Chronofold/CvrPhase0.lean |
| identity_operator_admissible | src/Chronofold/CvrPhase0.lean |
| operator_composition_associative | src/Chronofold/CvrPhase0.lean |
| inverse_is_admissible | src/Chronofold/CvrPhase0.lean |
| defect_monotonicity | src/Chronofold/CvrPhase0.lean |
| constitutional_closure | src/Chronofold/CvrPhase0.lean |

## H. Measurement harvest — GREEN (PRs #10 / #12 / #66)
| Theorem | File |
|---|---|
| measurement_equiv_refl / .symm / .trans | src/Chronofold/AgdMeasurement.lean |
| agd_measurement_invariant | src/Chronofold/AgdMeasurement.lean |
| jitter_close_reflexive / .symmetric / .triangle | src/Chronofold/AgdMeasurement.lean |
| speedup_positive | src/Chronofold/AgdMeasurement.lean |
| benchmark_claim_valid | src/Chronofold/AgdMeasurement.lean |
| agd_transport_closure | src/Chronofold/AgdMeasurement.lean |
| agd_bisimulation | src/Chronofold/AgdMeasurement.lean |
| agd_flow_semigroup | src/Chronofold/AgdMeasurement.lean |
| agd_master_dynamic_closure | src/Chronofold/AgdMeasurement.lean |
| agd_failure_recovery | src/Chronofold/AgdMeasurement.lean |
| memory_lineage_reconstruction | src/Chronofold/AgdMeasurement.lean |

## I. Operational quotient — GREEN (chronoflow-proof #1 / #66)
| Theorem | File |
|---|---|
| admissibility_sufficient | src/Chronofold/AgdOperationalQuotient.lean |
| operationalEq_refl / .symm / .trans | src/Chronofold/AgdOperationalQuotient.lean |
| operationalEq_preserved_by_operator | src/Chronofold/AgdOperationalQuotient.lean |
| control_preserved | src/Chronofold/AgdOperationalQuotient.lean |
| theta_projected_fixed | src/Chronofold/AgdOperationalQuotient.lean |
| quotient_of_full_chain | src/Chronofold/AgdOperationalQuotient.lean |
| quotient_iterate_operator | src/Chronofold/AgdOperationalQuotient.lean |
| speedup_implies_faster | src/Chronofold/AgdOperationalQuotient.lean |

## J. Intake pile `core/theorems_proven/` — GREEN
| Theorem | File |
|---|---|
| t1 | core/theorems_proven/T1.lean |
| nat_add_zero_right | core/theorems_proven/THM_000001__nat_add_zero_right.lean |
| correct_by_construction_search (+ pivotal, identity_preservation, tilde_iff_stateEq, omega_sigma_id, step_implies_D_lt, execution_terminates, correct_reconstruction) | core/theorems_proven/THM_000002__correct_by_construction_search.lean |
| omega_divides_n (intake copy) | core/theorems_proven/THM_000003__omega_divides_n.lean |

## K. OIC-Core-Calculus (sister repo) — GREEN
| Theorem | File |
|---|---|
| Compose_assoc | OICCore/Basic.lean |
| IdOp_left / IdOp_right | OICCore/Basic.lean |
| derive_sound | OICCore/Basic.lean |
| residual_zero_is_decided | OICCore/Basic.lean |
| bidirectional_closure | OICCore/Basic.lean |
| empty_corpus_always_boundary | OICCore/Basic.lean |
| phaseTransition_preserves_cert | OICCore/Basic.lean |
| elevation_requires_provenance | OICCore/Basic.lean |
| authorized_implies_provenance | OICCore/Basic.lean |
| rcc_coherent_implies_realized | OICCore/Basic.lean |
| residual_zero_sound | OICCore/Basic.lean |
| instantiation_requires_AGD | OICCore/Basic.lean |
| elevated_agd_scope | OICCore/Basic.lean |
| authorized_extension_replay | OICCore/Basic.lean |
| can_detect_boundary | OICCore/Basic.lean |

## Not in the proven pile
- `disabled/*` — rejected
- `core/theorems_rejected/*` — rejected (Mathlib / intake fail)
- EMV-0001 (PR #61 draft) — HYPOTHESIZED, not Lean-closed
- Jules O∞ markdown PRs targeting `auto` — reports, not kernels
