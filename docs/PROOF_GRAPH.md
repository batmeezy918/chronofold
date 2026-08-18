# PROOF_GRAPH.md

## AGD Proof Dependency Graph

```mermaid
graph TD
    State[AGD.State] --> AGDEquiv[AGD.AGDEquiv]
    AGDEquiv --> agdSetoid[AGD.agdSetoid]
    agdSetoid --> QStar[AGD.QStar]
    QStar --> pi[AGD.pi]

    Admissible[AGD.Admissible] --> TBar[AGD.TBar]
    TBar --> TBar_sound[AGD.TBar_sound]
    TBar_sound --> admission_iff_descends[AGD.admission_iff_descends]

    PreservingQuotient[AGD.PreservingQuotient] --> uniqueMorph[AGD.uniqueMorph]
    uniqueMorph --> uniqueMorph_unique[AGD.uniqueMorph_unique]

    Invariants[AGD.Invariants] --> Replay[AGD.Replay]
    Admissible --> replay_preserves_invariants[AGD.replay_preserves_invariants]
    Replay --> replay_preserves_invariants
```

---

## Verified Core Theorems Summary

1. **`AGDEquiv.refl`, `symm`, `trans`**: Establishes equivalence relation properties for $\Omega$ and $C$.
2. **`agdSetoid`**: Constructs Lean setoid over operational states.
3. **`QStar` & `pi`**: Defines canonical minimal quotient space and projection map.
4. **`TBar` & `TBar_sound`**: Proves sound descendability of admissible operators onto $Q^*$.
5. **`uniqueMorph` & `uniqueMorph_unique`**: Formalizes initiality and universal property of $Q^*$.
6. **`interchangeable_iff`**: Establishes quotient equivalence characterization.
7. **`admission_iff_descends`**: Proves operator admissibility iff descended map acts as identity on $Q^*$.
8. **`replay_preserves_invariants`**: Inductive proof that sequential admissible operator replay preserves state invariants across arbitrarily long traces.
