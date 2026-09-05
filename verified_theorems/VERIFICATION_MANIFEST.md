# LEAN 4 VERIFIED THEOREM MANIFEST

Branch: `verified-theorem-dossier`

## Status semantics

`VERIFIED` means the source theorem already exists in the repository's proof-bearing Lean module and has a successful verification/build history as recorded in the repository PR lineage. The dossier files below are thin review wrappers that reference those exact declarations; they do not create new mathematical content.

## Core verified families

| ID | Family | Exact source | Principal declarations | Repository evidence |
|---|---|---|---|---|
| 01 | Master Bidirectional Operational Closure | `src/Chronofold/MasterBidirectionalOperationalClosure.lean` | `admissible_iff_preservesClass`, `admissible_iff_class_eq`, `TBar_unique`, `master_bidirectional_operational_closure` | PR #67 merged |
| 02 | Maximal Constitutional Operational Closure | `src/Chronofold/AgdMaximalConstitutionalOperationalClosure.lean` | `maximal_constitutional_operational_closure`, `agd_maximal_constitutional_operational_closure` | PR #68 merged |
| 03 | SIM2XR Universal Costless Logic | `src/Chronofold/SIM2XR_Universal_Costless_Logic.lean` | `descends_iff_recursive`, `universal_cost_independent_operational_closure` | PR #71 merged |
| 04 | Nrebbi-El Theorem | `src/Chronofold/NrebbiElTheorem.lean` | `nrebbi_el_theorem`, `descent_iff_recursive` | PR #74 merged |
| 05 | Nrebbi-El Simulation | `src/Chronofold/NrebbiElSimulation.lean` | `simulation_iff_descent`, `simulation_iff_recursive_simulation`, `simulation_iff_exact_trajectory`, `nrebbi_el_simulation_theorem` | PR #75 merged |
| 06 | EMV Constitution | `src/Chronofold/EmvConstitution.lean` | admissibility, rejection, factorization, maximal closure family | PR #72 merged; PR #73 independent verification |
| 07 | AGD Operational Quotient | `src/Chronofold/AgdOperationalQuotient.lean` | `operationalEq_preserved_by_operator`, `quotient_of_full_chain`, `quotient_iterate_operator` | PR #66 merged |
| 08 | CVR Phase-0 | `src/Chronofold/CvrPhase0.lean` | `omega_preservation`, `admissibility_closure`, `operator_composition_closed`, `inverse_is_admissible`, `constitutional_closure` | PR #65 merged |
| 09 | Auto Omega | `src/Chronofold/AutoOmega.lean` | `omega_divides_n`, `omega_nonneg`, `omega_le_n` | PR #65 merged |
| 10 | Correct-by-Construction Search | `core/theorems_proven/THM_000002__correct_by_construction_search.lean` | `correct_by_construction_search` | PR #65 merged |

## Additional theorem artifact

`core/theorems_proven/THM_000001__nat_add_zero_right.lean` is included as a basic verified arithmetic artifact.

`core/theorems_proven/THM_000003__omega_divides_n.lean` is included as a verified omega arithmetic artifact.

## Evidence boundary

This dossier does NOT promote PR #76's coarsest-quotient derivation algorithm or universal minimality theorem to verified status. Those remain the next formal frontier.

It also does not promote empirical benchmark results to formal proofs, nor formal proofs to claims of external protocol certification.

## Dependency principle

The original proof-bearing modules are authoritative. Review wrappers are intentionally minimal and point back to the original declarations so the repository does not silently fork theorem logic.