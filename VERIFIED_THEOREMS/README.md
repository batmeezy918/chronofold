# Chronofold — Verified Theorem Dossier

This folder is a curated index of theorem artifacts whose Lean source exists in the repository and whose verification status is recorded separately from explanatory claims.

## Evidence discipline

- **GREEN / VERIFIED:** theorem source is present and a repository Lean/CI workflow has passed for the corresponding revision.
- **SANDBOX:** executable finite evidence only; not a replacement for Lean.
- **YELLOW / FORMAL FRONTIER:** statement or scaffold exists, but the stronger universal construction/minimality theorem is not yet machine-checked.
- No theorem is upgraded merely because an experiment succeeded.
- Physical speedup/cost claims are kept separate from semantic theorems.

## Primary theorem families currently catalogued

| ID | Family | Canonical Lean artifact | Status | Core consequence |
|---|---|---|---|---|
| T01 | AGD Iteration | `src/Chronofold/AgdIterate.lean` | GREEN* | Iterated AGD operator laws and closure |
| T02 | AGD Universal | `src/Chronofold/AgdUniversal.lean` | GREEN* | Universal factorization through AGD quotient |
| T03 | AGD Invariant Safety | `src/Chronofold/AgdInvariantSafety.lean` | GREEN* | Invariant/safety preservation layer |
| T04 | AGD Bidirectional Closure | `src/Chronofold/AgdBidirectional.lean` | GREEN* | Bidirectional class/quotient interfaces |
| T05 | Master Bidirectional Operational Closure | `src/Chronofold/MasterBidirectionalOperationalClosure.lean` | GREEN* | Admissibility ↔ class preservation, unique quotient dynamics, recursive operational closure |
| T06 | Nrebbi-El Simulation | `src/Chronofold/NrebbiElSimulation.lean` | GREEN* | Descent ↔ simulation ↔ recursive simulation ↔ exact projected trajectories |
| T07 | AGD Derived Computational Domain | `src/Chronofold/AgdDerivedComputationalDomain.lean` | GREEN* for current scaffold | Descent → well-defined/unique quotient operator → recursive executable semantics; coarsest-domain derivation remains a boundary |

\* GREEN means repository history previously recorded successful Lean/CI verification for the corresponding theorem layer; inspect the commit/CI record before making a stronger claim.

## Formal dependency hierarchy

```text
First principles / declarations
        |
        v
Constitution + invariant observables
        |
        v
Operational equivalence / quotient projection pi
        |
        +-----------------------------+
        |                             |
        v                             v
Class preservation              Observable factorization
        |                             |
        v                             v
Admissibility <--------------> Universal quotient behavior
        |
        v
Operator descent: pi ∘ T = Tbar ∘ pi
        |
        v
Well-definedness + uniqueness of Tbar
        |
        v
Recursive closure: pi ∘ T^n = Tbar^n ∘ pi
        |
        v
Exact finite projected trajectories
        |
        v
Executable quotient domain
        |
        +--------------------+
        |                    |
        v                    v
Reconstruction          Safety/invariant layer
        |
        v
Physical realization / cost  <-- separate empirical layer
```

## Critical scope boundary

The current formal core proves what follows **from a valid descended quotient**. The stronger theorem that a general AGD procedure itself constructs the **coarsest** constitutionally admissible dynamical quotient, together with a universal minimality property, remains the principal formal frontier.

## Examination rule

For each theorem, examine:

1. the exact Lean source;
2. the imported dependencies;
3. the theorem statement;
4. the proof term / tactic proof;
5. the CI/build commit that verified it;
6. the evidence boundary for any empirical or physical consequence.
