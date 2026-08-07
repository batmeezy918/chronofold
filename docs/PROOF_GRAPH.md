# Constitutional Proof Graph

This document illustrates the dependency structure of formal proofs inside the ChronoFold repository.

```
                  [State Representation]
                            │
               ┌────────────┴────────────┐
               ▼                         ▼
      [AGDEquiv Relation]      [ConstitutionalObject]
               │                         │
               ▼                         ▼
        [agdSetoid]                 [Invariant]
               │                         │
               ▼                         ▼
         [QStar (Q*)]               [Admissible]
               │                         │
      ┌────────┴────────┐                │
      ▼                 ▼                │
   [pi Proj]     [uniqueMorph]           │
      │                 │                │
      ▼                 ▼                │
   [TBar]       [uniqueMorph_unique]     │
      │                                  │
      ▼                                  ▼
[admission_iff_descends]        [path_preservation]
```

## Proof Nodes

### 1. Minimal Admissible Quotient ($Q^*$) Subgraph (`Verify.lean`)
* **State** $\to$ **AGDEquiv** $\to$ **agdSetoid**: Sets up the setoid structure on operator states.
* **QStar** $\to$ **pi**: Builds the quotient map.
* **TBar** $\to$ **TBar_sound**: Lifts admissible operator transformations to $Q^*$.
* **uniqueMorph** $\to$ **uniqueMorph_unique**: Proves the universal mapping and minimality properties of $Q^*$.
* **admission_iff_descends**: Establishes equivalence between admissibility and identity-preserving descendibility on $Q^*$.

### 2. Constitutional Metamodel Subgraph (`Constitutional.lean`)
* **ConstitutionalObject** $\to$ **Invariant**: Models the base system state and state constraints.
* **Admissible**: Restricts state operators to invariant-preserving transitions.
* **path_preservation**: Proves by list induction that executing a sequence of admissible operators maintains system-wide invariants.
