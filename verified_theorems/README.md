# VERIFIED THEOREM DOSSIER

This directory is the review set for Lean-verified theorem artifacts in Chronofold.

## Evidence rule

A theorem is listed here only with the exact Lean source/declaration that is represented as verified by the repository history. Empirical results, hypotheses, scaffolds, and unresolved frontiers are separated from FORMALLY_PROVEN material.

## Current verified set

### 01 — Master Bidirectional Operational Closure
- Source: `src/Chronofold/MasterBidirectionalOperationalClosure.lean`
- Core declarations: `admissible_iff_preservesClass`, `admissible_iff_class_eq`, `TBar_unique`, `master_bidirectional_operational_closure`
- Consequences: admissibility ↔ class preservation; exact quotient execution; exact iteration; reconstruction; unique quotient-respecting observable factorization; invariant safety.
- Origin: PR #67, merged.

### 02 — Maximal Constitutional Operational Closure
- Source: `src/Chronofold/AgdMaximalConstitutionalOperationalClosure.lean`
- Core declaration: `maximal_constitutional_operational_closure`
- Consequences: operational equivalence, bidirectional admissibility, quotient execution, iterative closure, reconstruction, observable factorization, composition closure, safety preservation.
- Origin: PR #68, merged.

### 03 — SIM2XR Universal Cost-Independent Operational Closure
- Source: `src/Chronofold/SIM2XR_Universal_Costless_Logic.lean`
- Core declarations: `descends_iff_recursive`, `universal_cost_independent_operational_closure`
- Consequences: one-step descent ↔ exact finite recursive trajectory correspondence, semantic closure independent of realization cost, induced quotient operator, uniqueness, observable factorization, reconstruction.
- Origin: PR #71, merged.

### 04 — Nrebbi-El Theorem
- Source: `src/Chronofold/NrebbiElTheorem.lean`
- Core declaration: `nrebbi_el_theorem`
- Consequences: admissibility ↔ identity descent; descent ↔ recursive exactness; well-definedness; admissible iteration; composition; reconstruction interfaces; observable factorization.
- Origin: PR #74, merged.

### 05 — Nrebbi-El Simulation Theorem
- Source: `src/Chronofold/NrebbiElSimulation.lean`
- Core declaration: `nrebbi_el_simulation_theorem`
- Consequences: graph simulation ↔ descent; one-step simulation ↔ recursive simulation; simulation ↔ exact trajectory correspondence; admissibility as identity simulation.
- Origin: PR #75, merged.

### 06 — EMV Constitutional Theorem Family
- Source: `src/Chronofold/EmvConstitution.lean`
- Core declarations: `annotate_admissible`, `stampSequence_admissible`, `sealOverlay_admissible`, `advance_wellDefined_phase`, `transition_not_wellDefined`, `transition_not_admissible`, `criticalFailed_factors_pi`, `emv_master_closure`, `emv_maximal_abstract`, `emv_agd_maximal`, `emv_overlays_closed`.
- Consequences: concrete laboratory instantiation of the AGD constitutional kernel; admissible fibre overlays; rejection of fibre-sensitive transition as quotient descent; critical observable factorization; maximal closure package.
- Origin: PR #72, merged; independently verified in PR #73.

### 07 — Operational Quotient / Full-Chain Closure
- Source: `src/Chronofold/AgdOperationalQuotient.lean`
- Core declarations include `admissibility_sufficient`, `operationalEq_preserved_by_operator`, `control_preserved`, `quotient_of_full_chain`, `quotient_iterate_operator`.
- Consequences: preservation/intertwining across quotient and full-chain execution.
- Origin: PR #66, merged.

### 08 — CVR Phase-0 Constitutional Kernel
- Source: `src/Chronofold/CvrPhase0.lean`
- Core declarations include `omega_preservation`, `admissibility_closure`, `operator_composition_closed`, `inverse_is_admissible`, `defect_monotonicity`, `constitutional_closure`.
- Consequences: preservation of constitutional predicates and closure under admissible operator chains.
- Origin: PR #65, merged.

### 09 — Auto Ω Theorems
- Source: `src/Chronofold/AutoOmega.lean`
- Core declarations: `omega_divides_n`, `omega_nonneg`, `omega_le_n`.
- Consequences: arithmetic bounds for the Ω operator (with `omega_le_n` requiring `0 < n`).
- Origin: PR #65, merged.

### 10 — Correct-by-Construction Search
- Source: `core/theorems_proven/THM_000002__correct_by_construction_search.lean`
- Core declaration: `correct_by_construction_search`
- Consequences: quotient-compatible search condition, well-founded execution under an explicit decreasing measure, reconstruction of terminal quotient representatives.
- Origin: PR #65, merged.

## Related verified theorem artifacts

- `core/theorems_proven/THM_000001__nat_add_zero_right.lean`
- `core/theorems_proven/THM_000003__omega_divides_n.lean`

## Not yet promoted

`PR #76` (`AgdDerivedComputationalDomain`) is intentionally retained as a frontier artifact. Its current formalization proves semantic consequences of a supplied `DerivedDomain`; the finite coarsest-quotient derivation algorithm and universal minimality theorem are NOT represented here as proven.

## Review rule

This directory is a curated view. The authoritative proof remains the exact Lean declaration at the cited source path and its successful repository verification history. A dossier entry does not upgrade the evidence status of any theorem.
