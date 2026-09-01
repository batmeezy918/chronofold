# EMV Claim Protocol

## Claim lifecycle

`HYPOTHESIZED -> DERIVED -> IMPLEMENTED -> EXECUTABLY_VERIFIED -> EMPIRICALLY_DEMONSTRATED -> LEAN_SCAFFOLDED -> FORMALLY_PROVEN -> CONSTITUTIONALLY_ESTABLISHED`

A claim may move backward or to `REJECTED` when a gate fails. Status promotion is evidence-driven and SHALL preserve prior statuses in provenance.

## Required fields

Every claim SHALL identify:

- `claim_id`
- informal and formal statement
- axioms/assumptions
- derivation references
- implementation references
- benchmark reference
- witness reference
- Lean source/declaration reference
- toolchain/version
- canonical content hash
- evidence level
- limitations

## Gate semantics

### Deterministic gate

Same declared inputs, configuration, seed, and runtime profile SHALL produce the same canonical result hash.

### Replay gate

Recorded execution SHALL reproduce the declared state/trace hash under the replay profile.

### Witness gate

The witness SHALL bind the claim, input/configuration hashes, result hashes, and evidence level.

### Lean gate

The exact theorem declaration SHALL compile under the repository's canonical Lean workflow. A scaffold that does not compile is not formally proven.

### Correspondence gate

The formal state and implementation state SHALL have an explicit mapping sufficient for the promoted claim. This gate is separate from theorem compilation.

## Promotion invariant

No claim SHALL be labeled `CONSTITUTIONALLY_ESTABLISHED` unless all required gates for that claim are recorded as passing.

## Counterexample rule

Any deterministic counterexample SHALL create or update a rejection/refinement record and SHALL prevent promotion of the affected claim until resolved.
