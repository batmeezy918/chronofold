# Master Bidirectional Operational Closure — landing

Status: **FORMAL CANDIDATE** until `lake build Chronofold` is green.
After kernel accept + zero `sorry`/`admit`: **VERIFIED_BY_LEAN / GREEN**.

## The closed gap

Previously the kernel had:

- `Admissible T ⇒ AGDEquiv (T s) s`  (`admissible_preserves_class`)
- `pi s1 = pi s2 ↔ AGDEquiv s1 s2`  (`interchangeable_iff`)

It did **not** name the converse as a first-class theorem:

```
(∀ s, π(T s) = π s)  ↔  Admissible T
```

That biconditional is `admissible_iff_preservesClass` / `admissible_iff_class_eq`.
The counterexample `not_admissible_breaks_class` is the necessity direction:
a non-admissible operator leaves some class.

## Master conjunction

`master_bidirectional_operational_closure` packages:

1. class preservation ↔ admissibility
2. exact quotient execution `T̄(π s) = π(T s)`
3. exact admissible iteration `T̄ⁿ(π s) = π(Tⁿ s)`
4. reconstruction: every class has a representative
5. unique AGD-respecting factorization through Q*
6. `invariantSafe Ω C [Ω, C]`

Plus uniqueness of descended dynamics: `TBar_unique`.

## Evidence boundary (do not elevate past this)

Does **not** claim: universal speedup, universal termination, arbitrary
failure recovery, external-world restoration, optimizer dominance,
quantum advantage, or cryptographic capability.
