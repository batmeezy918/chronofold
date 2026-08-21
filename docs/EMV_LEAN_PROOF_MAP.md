# EMV Canonical ↔ Lean Proof Map

## Purpose

This document is the promotion map between the executable EMB/EMV stack and the formal Lean layer. It deliberately separates a Lean theorem from an EMV certification claim.

## Canonical chain

`observation -> canonical state -> quotient -> operator -> invariant check -> certificate -> replay`

## Proof obligations

| Runtime obligation | Lean foundation | Promotion meaning |
|---|---|---|
| State has stable semantic identity | `AgdCore.lean`, `AgdInvariants.lean` | Canonical state may be compared under declared invariants |
| Equivalent states form a quotient | `AgdUniversal.lean` | Quotient representation is mathematically well-defined |
| Lawful operators descend | `AgdUniversal.lean`, `AgdOperators.lean` | Runtime operator can be reasoned about at quotient level |
| Lawful operators compose | `AgdInvariants.lean`, `AgdIterate.lean` | Multi-step traces remain inside the admissible operator regime |
| Reconstruction preserves declared semantics | `AgdBidirectional.lean` | Quotient execution can be related back to a concrete state |
| Replay preserves invariants | constitutional/closure theorem family | Re-execution can be checked against the same semantic contract |
| Canonical serialization is stable | executable canonicalization tests | Hash equality is meaningful for identical canonical inputs |

## Evidence levels

- `FORMALLY_PROVEN`: current Lean source is compiled by the canonical Lean workflow.
- `EXECUTABLY_VERIFIED`: runtime implementation and tests pass, without implying formal proof.
- `EMPIRICALLY_DEMONSTRATED`: observed against a controlled measurement or fixture.
- `SIMULATED`: software model only.
- `PROJECTED`: expected behavior not yet demonstrated.
- `HYPOTHESIZED`: research claim.
- `UNSUPPORTED`: insufficient evidence.

## EMV boundary

A generic Lean theorem becomes an EMV theorem only after an explicit instantiation identifies the EMV state type, invariant function, operator semantics, and authority provenance. A passing software test does not establish EMVCo, scheme, issuer, regulatory, or laboratory certification.

## Required promotion record

Every promoted EMV theorem must record:

1. Lean source path.
2. Exact theorem/declaration names.
3. Lean toolchain/version.
4. CI run identifier.
5. Source content hash.
6. Runtime implementation path.
7. Evidence level.
8. Authority provenance.
9. Replay fixture/hash.
10. Known limitations.
