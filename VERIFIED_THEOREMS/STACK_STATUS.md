# Verified Lean 4 Stack — Status

## Current merged backbone

- PR #79 merged: Constitutional Kernel T0.1–T0.6 maximal operational scope.
- PR #77 merged: O1–O∞ constitutional closure/report synchronization.
- PR #76 merged: AGD derived computational domain semantic closure.
- PR #75 merged: Nrebbi-El simulation theorem kernel.
- PR #73 merged: standalone EMV theorem kernel validation.
- PR #72 merged: extracted EMV constitution theorems.
- PR #71 merged: cost-independent operational equivalence.

## T0 kernel

`src/Chronofold/ConstitutionalKernelT0.lean` is a non-vacuous Lean 4 core-only kernel. It explicitly defines five independent constitutional components in `Omega` and proves their preservation, admissibility closure, composition, iteration, finite-chain closure, concrete admissible operators, and a `wipeNs` counterexample.

No `sorry`, no `admit`, no extra axioms, and no Mathlib dependency are claimed by the source module.

## Key AGD closure

The established semantic stack is:

constitution/invariants → admissibility → class preservation → quotient projection → descended operator → recursive quotient execution → reconstruction/factorization/safety.

The Nrebbi-El kernel separately proves the descent/simulation/recursive/exact-trajectory bridge.

## Claim boundary

A merged Lean theorem proves only the propositions actually encoded and compiled. It does not automatically prove physical speedup, real-world protocol certification, or universal novelty. The current mathematical frontier remains formalizing a general finite coarsest dynamical quotient construction and its universal minimality/factorization property if that stronger claim is pursued.
