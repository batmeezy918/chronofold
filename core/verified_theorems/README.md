# Verified Theorems

This directory is a canonical index boundary for theorem artifacts that have current-tree Lean evidence.

## Promotion rule

A theorem may be listed here only when:

1. its source is present in the canonical repository;
2. its Lean declaration compiles in the repository's current Lean workflow;
3. the source contains no `sorry` placeholder for the promoted declaration;
4. the theorem is not merely narrative documentation or a historical PR claim;
5. the exact source path and content hash are recorded in `MANIFEST.json`.

This directory does not replace the source modules. It is an auditable promotion/index layer. Historical PR claims are not promoted automatically.

## Current canonical theorem families

- `AgdCore`: state, observables, operator, and admissibility definitions.
- `AgdOperators`: equivalence relation, quotient, quotient projection, descended operator, and soundness.
- `AgdInvariants`: interchangeability/equivalence correspondence, admission characterization, and descent existence.
- `AgdClosure`: compositional closure of admissible operators.
- `CFPC/KernelEquivalence`: function extensionality, logical equivalence, type swap equivalence, identity, composition associativity, and kernel wrapper.
- `core/theorems_proven/T1`: minimal smoke theorem.

Promotion is evidence-driven; this index intentionally does not include rejected or narrative-only material.
