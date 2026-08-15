# PROOF_GRAPH

```mermaid
graph TD
    State[AGD.State] --> Omega[AGD.Omega & AGD.Covariant]
    Omega --> AGDEquiv[AGD.AGDEquiv]
    AGDEquiv --> agdSetoid[AGD.agdSetoid]
    agdSetoid --> QStar[AGD.QStar]
    QStar --> pi[AGD.pi]

    pi --> TBar[AGD.TBar]
    TBar --> TBar_sound[TBar_sound]
    TBar_sound --> descends[AGD.descends]

    QStar --> uniqueMorph[AGD.uniqueMorph]
    uniqueMorph --> uniqueMorph_unique[AGD.uniqueMorph_unique]

    AGDEquiv --> interchangeable_iff[AGD.interchangeable_iff]
    TBar_sound --> admission_iff_descends[AGD.admission_iff_descends]

    State --> Replay[AGD.Replay]
    Replay --> replay_preserves_invariants[AGD.replay_preserves_invariants]
```

## Formal Dependency Hierarchy

1. **Core State & Invariants**: `AGD.State`, `AGD.Omega`, `AGD.Covariant`, `AGD.Operator`
2. **Equivalence & Quotient Layer**: `AGD.AGDEquiv` $\to$ `AGD.agdSetoid` $\to$ `AGD.QStar` $\to$ `AGD.pi`
3. **Morphism & Initiality**: `AGD.PreservingQuotient` $\to$ `AGD.uniqueMorph` $\to$ `AGD.uniqueMorph_unique`
4. **Metamodel & Replay**: `AGD.Replay`, `AGD.Witness`, `AGD.Invariants` $\to$ `AGD.replay_preserves_invariants`
