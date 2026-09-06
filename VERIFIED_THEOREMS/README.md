# Chronofold — Lean 4 Verified Theorem Stack

This folder is an examination set for theorem families that the repository currently records as `verified_by_lean` and for the latest merged constitutional kernel.

## Status rule

`GREEN / verified_by_lean` means the repository theorem inventory identifies the source module as Lean-verified. This dossier does not silently promote narrative, hypothesized, rejected, sandbox-only, or performance-only claims.

## Canonical theorem stack

### T0 — Constitutional Kernel
**Source:** `src/Chronofold/ConstitutionalKernelT0.lean`

Merged in PR #79 (`e428529ce4419b8baca3893d475e5167b779680b`). The kernel contains non-vacuous invariants and proves:

- T0.1 namespace preservation
- T0.2 version preservation
- T0.3 provenance preservation
- T0.4 relationship-resolution preservation
- T0.5 stratified-acyclicity preservation
- T0.6 Ω preservation and Ω characterization
- admissibility closure
- admissible-operator composition closure
- iterate admissibility
- finite-chain constitutional closure
- concrete admissible operators
- `wipeNs` counterexample showing an invalid operator can break the constitution

### AGD Core
**Sources:** `AgdCore.lean`, `AgdOperators.lean`, `AgdInvariants.lean`, `AgdClosure.lean`

Core interfaces and consequences include `AGDEquiv`, `TBar_sound`, `interchangeable_iff`, `admission_iff_TBar`, and admissible composition closure.

### AGD Dynamics / Universal Quotient
**Sources:** `AgdIterate.lean`, `AgdUniversal.lean`, `AgdRank.lean`, `AgdMultiOmega.lean`, `AgdClassGraph.lean`

Includes admissible iteration, quotient lifting, projective collapse, multi-Ω equivalence, and certified class-graph transition machinery.

### AGD Reconstruction / Safety / Quotient
**Sources:** `AgdBidirectional.lean`, `AgdFibreClosure.lean`, `AgdFiniteReduction.lean`, `AgdInvariantSafety.lean`, `AgdSicConstitutional.lean`, `AgdOperationalQuotient.lean`

Includes reconstruction witnesses, fibre collapse, quotient surjectivity, invariant-safety suite, SIC operational equality, and operational quotient closure.

### Omega / Support
**Sources:** `AutoOmega.lean`, `CvrPhase0.lean`, `AgdMeasurement.lean`

Includes Ω arithmetic, constitutional closure support, and measurement/certification interfaces.

### Nrebbi-El Simulation Kernel
**Source:** `src/Chronofold/NrebbiElSimulation.lean`

Standalone dependency-free simulation kernel. The core equivalences are:

`Descent ↔ graph simulation ↔ recursive simulation ↔ exact projected finite trajectories`.

### Derived Computational Domain
**Source:** `src/Chronofold/AgdDerivedComputationalDomain.lean`

Formalized semantic consequences include fibre well-definedness, quotient-operator uniqueness under surjective projection, local-to-recursive exactness, recursive-to-local descent, and executable quotient semantics.

**Formal frontier:** the universal theorem that a finite refinement algorithm itself constructs the coarsest constitutionally admissible dynamical quotient remains a separate target unless independently merged and CI-verified.

## Evidence hierarchy

1. Lean theorem source + successful repository verification = formal theorem evidence.
2. Sandbox execution = empirical evidence for a concrete instantiation; not a replacement for Lean.
3. Benchmark timing = physical/implementation evidence; not semantic proof.
4. Narrative or hypothesis = not promoted to theorem status.

## Source inventory

The repository's `docs/THEOREM_INVENTORY.md` is the authoritative inventory for the GREEN / rejected / narrative-only / hypothesized classification.
