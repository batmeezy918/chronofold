# Canonical EMV Execution Regime

## Status

This document defines the canonical engineering regime for the EMV/EMB advancement layer. `main` is the sole canonical integration branch.

## Evidence boundaries

The system MUST distinguish: FORMALLY_PROVEN, EXECUTABLY_VERIFIED, EMPIRICALLY_DEMONSTRATED, SIMULATED, PROJECTED, HYPOTHESIZED, UNSUPPORTED.

Passing internal tests does not imply EMVCo, Visa, Mastercard, American Express, regulatory, or laboratory certification.

## Authority hierarchy

1. EMVCo generic technical authority where applicable.
2. Network-authorized material for network-specific rules.
3. Regulatory/issuer/regional authority where applicable.
4. LAB or secondary references only as lower-tier evidence.
5. PaymentCardTools is a secondary differential reference and never overrides a higher-authority source.

Conflicts MUST remain explicit as `AUTHORITY_CONFLICT`; no silent substitution is permitted.

## Deterministic pipeline

```text
observation
  -> canonical observation
  -> AGD quotient
  -> EMB protocol state
  -> deterministic operator trace
  -> certificate
  -> replay
```

For the same canonical input, constitution version, authority manifest, environment manifest, configuration, and operator sequence, the replay result MUST be identical at the canonical/hash level.

## Quotient boundary

A quotient is an abstraction of a representation. It does not grant permission to alter the underlying terminal, radio, operating system, payment network, or security boundary.

For each quotient, the repository MUST document which fields are invariant, residual, ignored, and why. Information loss must be explicit.

## Terminal twin

The digital twin represents the observation and protocol state that has been captured and canonicalized. It MUST NOT be described as physically identical to the underlying hardware merely because the software state is deterministic.

## Transition contract

Every protocol transition has:

- state before
- input
- preconditions
- operator
- state after
- postconditions
- invariant results
- authority/rule provenance
- certificate

Conceptually:

`psi_(k+1) = O_k psi_k`

and:

`psi_final = O_total psi_initial`.

## Required gates

Before a canonical commit, all applicable gates must pass:

- schema validation
- unit tests
- formal Lean build/proofs
- quotient/projection invariants
- deterministic replay
- adversarial mutation tests
- differential tests where references exist
- certificate verification
- audit report generation

If a required toolchain or source authority is unavailable, the system reports the blocker rather than fabricating success.
