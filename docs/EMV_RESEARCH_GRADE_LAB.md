# ChronoFold EMV Research-Grade Lab

## Boundary

This layer is an adjacent virtual research harness. It does not alter the canonical verified core or assert EMVCo, Visa, Mastercard, Amex, issuer, regulatory, laboratory, or payment-network certification.

## Evidence lattice

`FORMALLY_PROVEN -> EXECUTABLY_VERIFIED -> EMPIRICALLY_OBSERVED -> SIMULATED -> PROJECTED -> HYPOTHESIZED -> UNSUPPORTED`

A result is never promoted merely because a UI run succeeded.

## Provenance model

A profile stores IIN/BIN, brand, issuer declaration, AID, kernel, source, and evidence independently. The engine never infers:

`IIN/BIN => issuer => scheme => product => AID => kernel`

Instead, every combination must be explicitly declared/admitted. This prevents a convenient BIN label from becoming unsupported issuer or network knowledge.

## Level 5 campaign

The planner automatically expands:

1. profile dimension;
2. scenario dimension;
3. repetition dimension;
4. differential comparisons;
5. metamorphic comparisons;
6. adversarial mutations;
7. deterministic replay;
8. quotient-class mapping;
9. human-readable correlation;
10. machine-readable audit records.

For the initial 3-profile x 12-scenario fixture, primary executions are `3 x 12 x repetitions`. At the default three repetitions this is 108 primary virtual exchanges before differential/metamorphic expansion.

## Canonical record

Each exchange records:

- profile provenance;
- scenario and mutation;
- raw observation;
- canonical observation;
- observation hash;
- canonical hash;
- quotient class;
- state before/after;
- acceptance/status word;
- projection idempotence;
- evidence level;
- plain-language explanation.

## Authority backbone

The initial authority registry records externally verified facts from ISO and EMVCo sources. External source facts are not mixed with simulated profile behavior.

- ISO/IEC 7812-1:2017: IIN/PAN numbering system.
- EMVCo Book 3 v4.3: contact Application Specification listing.
- EMVCo Level 3 Testing: acceptance-device/infrastructure integration and participant-system test cases.
- EMVCo L3 Test Tool Qualification: separate qualification process for L3 test tools.

## Future empirical promotion

When a real exchange is later captured, it should enter through the same schema with `source=PHYSICAL_EXCHANGE` and `evidence_level=EMPIRICALLY_OBSERVED`. The raw APDU/response and reader/terminal metadata should remain immutable; canonical projection and quotient analysis are derived records.
