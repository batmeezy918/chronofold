# AGD Proof Graph Architecture

```
                       +-------------------------------+
                       |      AGD State Space          |
                       |      State α / Invariants     |
                       +---------------+---------------+
                                       |
                                       v
                       +---------------+---------------+
                       | Minimal Admissible Quotient   |
                       |       QStar (Q*)              |
                       +---------------+---------------+
                                       |
                   +-------------------+-------------------+
                   |                                       |
                   v                                       v
     +-------------+-------------+           +-------------+-------------+
     |   Admissibility Descent   |           |  Replay Preservation       |
     |   admission_iff_descends  |           | replay_preserves_invariants|
     +-------------+-------------+           +-------------+-------------+
                   |                                       |
                   +-------------------+-------------------+
                                       |
                                       v
                       +---------------+---------------+
                       | Constitutional Metamodel      |
                       |  (Oracle - Single Source)     |
                       +---------------+---------------+
                                       |
                +----------------------+----------------------+
                |                                             |
                v                                             v
  +-------------+-------------+                 +-------------+-------------+
  | ChronoFold Auto Theorems  |                 |  Intake Processing Pipeline |
  |   (omega_divides_n, etc)  |                 |  process_inbox.sh Receipts  |
  +---------------------------+                 +---------------------------+
```

## Proof Node Registry

1. **`AGD.agdSetoid`**: Generates equivalence relation from invariant functions $(\Omega, C)$.
2. **`AGD.QStar`**: Minimal admissible quotient space constructed via pure Lean quotient primitives.
3. **`AGD.TBar`**: Descended state operator on $Q^*$.
4. **`AGD.admission_iff_descends`**: Proves an operator is admissible if and only if its descended map acts as the identity on $Q^*$.
5. **`AGD.replay_preserves_invariants`**: Proves list induction preservation of invariants across arbitrary operator replay chains.
