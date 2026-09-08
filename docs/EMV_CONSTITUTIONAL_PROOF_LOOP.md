# EMV Constitutional Proof–Evidence Loop

## Status

`DESIGN + EXECUTABLE PIPELINE SCAFFOLD`

This document defines the EMV research loop that binds deterministic execution, empirical evidence, witnesses, quotient/equivalence reasoning, and Lean theorem candidates. It does not promote simulated or benchmark evidence to EMVCo certification or to a formal theorem without the required instantiation and proof.

## Objective

For each EMV research claim, maintain one provenance-bound path:

`claim -> derivation -> implementation -> benchmark -> witness -> Lean scaffold -> Lean result -> promotion decision`

## Evidence separation

- `HYPOTHESIZED`: research claim not yet derived or tested.
- `DERIVED`: derivation exists in project mathematics.
- `EXECUTABLY_VERIFIED`: implementation and deterministic tests pass.
- `EMPIRICALLY_DEMONSTRATED`: controlled measurement or fixture supports the claim.
- `FORMALLY_PROVEN`: the exact formal proposition is accepted by the canonical Lean workflow.
- `CONSTITUTIONALLY_ESTABLISHED`: required formal result, executable evidence, provenance, and correspondence record are present.
- `REJECTED`: a required gate failed.

## Mathematical fibers

The EMV construction MAY instantiate the project's candidate mathematical machinery only when each instantiation is explicit:

1. **Equivalence/quotient:** define the EMV state set, observable boundary, equivalence predicate, and quotient projection.
2. **SIM2XR:** define the projected admissible state and the retention/reconstruction property being tested.
3. **Stateless memory:** define exactly what state is reconstructed and which observables/invariants must be preserved.
4. **DIOF/operator constructions:** define concrete EMV transition/operator semantics before asserting a theorem.
5. **Constitutional geometry:** define measurable quantities before interpreting geometry as a computational property.

## Primary research target

The first high-value vertical slice is behavioral preservation under an explicit EMV equivalence relation:

`x ~ y -> T(x) ~ T(y)`

This is a candidate congruence/preservation theorem. It is not established until the EMV state, observable boundary, transition semantics, assumptions, and formal proof are supplied.

## Correspondence requirement

Empirical and formal paths remain distinct:

`claim -> implementation -> evidence -> witness`

and

`claim -> axioms -> derivation -> Lean -> proof`

A correspondence artifact SHALL state what relationship connects the tested implementation representation to the formal representation. No benchmark result is treated as a Lean proof, and no Lean theorem is treated as implementation validation without a correspondence argument.

## Repository flow

The existing theorem-intake workflow is reused rather than replaced. EMV changes produce claim/theorem candidates; the deterministic EMV verifier produces executable evidence; the theorem-intake workflow transports theorem material into Lean; results are retained as provenance artifacts.

## Promotion rule

The default research gate is:

`schema -> deterministic execution -> replay -> witness -> theorem scaffold -> Lean check -> correspondence review`

A failed gate produces a diagnostic and prevents promotion.

## Non-claims

This framework does not assert that a software model is EMVCo-certified, scheme-certified, issuer-certified, laboratory-certified, or regulator-approved. Such claims require external authority and evidence outside this repository.
