# PROOF GRAPH REPORT

```
                    [State α]
                        │
             ┌──────────┴──────────┐
             ▼                     ▼
         [Omega Ω]           [Covariant C]
             │                     │
             └──────────┬──────────┘
                        ▼
                  [AGDEquiv α]
                        │
                        ▼
                [Setoid (State α)]
                        │
                        ▼
                 [QStar α (Q*)]
                        │
         ┌──────────────┴──────────────┐
         ▼                             ▼
    [pi Project]                [TBar Descent]
         │                             │
         ▼                             ▼
  [uniqueMorph]           [admission_iff_descends]
         │                             │
         └──────────────┬──────────────┘
                        ▼
           [Constitutional Metamodel]
                        │
            (State, Hash, Replay, etc.)
                        │
                        ▼
          [replay_preserves_invariants]
```

## Node Inventory
1. **`State`**: Primary operational state structure.
2. **`AGDEquiv`**: Equivalence relation standardizing state indistinguishability under $\Omega$ and $C$.
3. **`QStar` / `pi`**: Minimal quotient construction using Lean 4 quotient primitives.
4. **`TBar` / `admission_iff_descends`**: Canonical operator descent map on $Q^*$.
5. **`Constitutional Metamodel`**: Metamodel structures (`ConstitutionalObject`, `Witness`, `Replay`, `Invariants`, etc.).
6. **`replay_preserves_invariants`**: List induction theorem proving invariant preservation over arbitrary admissible operator sequences.
