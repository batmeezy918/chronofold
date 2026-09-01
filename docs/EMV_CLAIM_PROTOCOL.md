# EMV Claim Protocol

## Purpose

This protocol defines the machine-readable claim object and promotion semantics for the EMV/EMB constitutional proof loop. It is deliberately expressive enough to represent a claim's mathematical scope, executable realization, empirical evidence, formal proposition, correspondence relation, and limitations without collapsing distinct kinds of evidence into one status.

## Claim lifecycle

`HYPOTHESIZED -> DERIVED -> IMPLEMENTED -> EXECUTABLY_VERIFIED -> EMPIRICALLY_DEMONSTRATED -> LEAN_SCAFFOLDED -> FORMALLY_PROVEN -> CONSTITUTIONALLY_ESTABLISHED`

A claim MAY transition to `REJECTED` or `REFINEMENT_REQUIRED` from any nonterminal state when a gate fails or a counterexample changes its valid scope. Promotion SHALL be monotone with respect to evidence: stronger status MUST NOT erase weaker/prior evidence or unresolved limitations.

## Full claim expressiveness

A claim SHALL be represented as a tuple

`K = (I, D, Q, S, A, R, O, T, Inv, G, Impl, B, W, L, Corr, E, Lim)`

where:

- `I` = stable claim identity and lineage.
- `D` = domain/type universe over which the claim ranges.
- `Q` = quantifier/scope specification.
- `S` = informal and formal statements.
- `A` = explicit axioms and assumptions.
- `R` = derivation/provenance references.
- `O` = operators/functions/relations appearing in the proposition.
- `T` = transition, temporal, or execution semantics when applicable.
- `Inv` = declared invariants and preservation obligations.
- `G` = admissibility/precondition and exclusion conditions.
- `Impl` = executable implementation mapping.
- `B` = benchmark/empirical protocol.
- `W` = witnesses and certificates.
- `L` = Lean source, declaration, environment, and result.
- `Corr` = formal-to-executable correspondence mapping.
- `E` = evidence ledger and gate results.
- `Lim` = limitations, boundary conditions, and known counterexamples.

The protocol SHALL NOT reduce a proposition to an informal sentence plus a single Boolean proof flag.

## Scope and quantifier semantics

Every formal claim SHALL make its scope explicit. At minimum, the claim record SHALL identify:

- quantified variables;
- their types/domains;
- universal, existential, or conditional quantifiers;
- admissibility predicates;
- transition/operator parameters;
- initial-state constraints;
- environmental assumptions;
- observation/quotient boundary;
- whether the claim is pointwise, finite-trace, inductive, or invariant over arbitrary iterations.

For example, the candidate

`x ~ y -> T(x) ~ T(y)`

is incomplete until the record defines the domain of `x` and `y`, the exact relation `~`, the domain and admissibility conditions of `T`, and whether the proposition is intended for one transition or arbitrary compositions/iterates.

## Mathematical claim form

Where the project uses operator-state notation, the canonical representation SHALL permit:

`psi_(k+1) = O psi_k`

and, for an n-step execution,

`psi_n = O_n ∘ ... ∘ O_2 ∘ O_1 psi_0`.

An invariant-preservation claim SHALL identify the invariant explicitly, e.g.

`Inv(O psi) = Inv(psi)`

or the weaker declared relation actually intended by the claim.

A quotient claim SHALL identify:

`X, ~, X/~, pi, R`

and SHALL distinguish equivalence, representative selection, projection, and reconstruction obligations.

## Required fields

Every claim SHALL identify:

- `claim_id`
- `version`
- `domain`
- `scope`
- `informal_statement`
- `formal_statement`
- `variables`
- `quantifiers`
- `assumptions`
- `preconditions`
- `operators`
- `relations`
- `invariants`
- `derivation_refs`
- `implementation_refs`
- `benchmark_ref`
- `witness_refs`
- `lean.source`
- `lean.declaration`
- `lean.toolchain`
- `lean.result`
- `correspondence_ref`
- `evidence_level`
- `gate_results`
- `canonical_content_hash`
- `limitations`
- `counterexamples`
- `lineage`

Fields MAY contain structured subobjects, but SHALL remain canonicalizable and hashable.

## Evidence separation

The following are distinct states of evidence and SHALL NOT be conflated:

- `HYPOTHESIZED`: proposed claim.
- `DERIVED`: derivation exists under declared assumptions.
- `IMPLEMENTED`: executable realization exists.
- `EXECUTABLY_VERIFIED`: deterministic implementation gates pass.
- `EMPIRICALLY_DEMONSTRATED`: controlled measurements/fixtures support the declared behavior.
- `LEAN_SCAFFOLDED`: exact candidate proposition has been generated in Lean syntax but formal acceptance is pending.
- `FORMALLY_PROVEN`: the exact declaration is accepted by the canonical Lean workflow.
- `CONSTITUTIONALLY_ESTABLISHED`: the required formal, executable, provenance, and correspondence gates all pass for the declared scope.
- `REJECTED`: a required condition is false or a counterexample invalidates the current claim.
- `REFINEMENT_REQUIRED`: evidence supports only a narrower proposition than the current statement.

## Gate semantics

### Deterministic gate

For fixed declared inputs, configuration, seed, implementation revision, dependency/toolchain profile, and execution environment, the canonicalized result SHALL be identical.

### Replay gate

A recorded execution SHALL reproduce the declared state/trace/result hash under the declared replay profile.

### Witness gate

A witness SHALL bind the claim identity/version, relevant input/configuration hashes, implementation revision, result hashes, gate results, evidence level, and provenance.

### Lean scaffold gate

The generated Lean artifact SHALL parse as the intended proposition and SHALL identify its exact declaration name. A scaffold is not a proof.

### Lean proof gate

The exact theorem declaration SHALL compile under the repository's canonical Lean workflow with no unsound placeholder admitted as proof. The proof result SHALL be bound to the exact source revision/toolchain.

### Correspondence gate

The formal state, predicates, operators, observations, and implementation state SHALL have an explicit mapping sufficient to justify that the formally proven proposition is the proposition exercised by the executable artifact.

### Scope gate

Evidence SHALL cover the same quantified domain and assumptions as the promoted claim. Finite fixtures SHALL NOT establish an unrestricted universal theorem.

## Promotion invariant

No claim SHALL be labeled `CONSTITUTIONALLY_ESTABLISHED` unless every required gate for its declared scope is recorded as passing.

Formally:

`Established(K) -> ScopeMatch(K) ∧ Deterministic(K) ∧ Replay(K) ∧ Witness(K) ∧ LeanProof(K) ∧ Correspondence(K)`

A passing benchmark alone SHALL NEVER imply `FORMALLY_PROVEN` or `CONSTITUTIONALLY_ESTABLISHED`.

## Counterexample and refinement rule

Any reproducible counterexample SHALL be attached to the exact claim version and SHALL prevent promotion of that version until resolved.

If evidence establishes only a restricted proposition, the system SHALL create a refined claim rather than silently weakening the original claim. The refinement SHALL preserve lineage:

`K_original -> K_refined`.

## Deterministic claim identity

Canonical claim serialization SHALL use a stable field order, UTF-8 encoding, normalized numeric/string representations, and SHA-256 over the canonical byte representation. Hashes SHALL exclude volatile timestamps unless timestamps are explicitly part of the claim semantics.

## Claim-state transformation

For claim state `psi_K`, promotion is an evidence-gated operator:

`psi_(K,k+1) = Gate_k psi_(K,k)`.

A failed gate SHALL map to `REJECTED` or `REFINEMENT_REQUIRED`, never directly to a stronger evidence state.

## Implementation notes

The protocol is designed to make the theorem prover part of construction rather than an after-the-fact label. A research iteration MAY therefore execute:

`conception -> formal candidate -> implementation -> deterministic benchmark -> witness -> Lean scaffold -> Lean check -> correspondence -> promotion/refinement`.

This creates a bidirectional engineering path while preserving the critical distinction between empirical validity and formal validity.

The existing EMV/Lean proof map already requires an explicit EMV instantiation before a generic Lean theorem becomes an EMV theorem, and separately records runtime, Lean, provenance, and replay information. This protocol makes that boundary machine-expressible rather than merely documentary.
