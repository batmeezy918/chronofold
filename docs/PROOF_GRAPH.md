# O∞ Proof Dependency Graph (PROOF_GRAPH.md)

This document charts the formal dependency graph of theorems and proofs verified within the AGD/CTG Constitutional Oracle (`Verify.lean` and `ChronoFold/Auto.lean`).

## 1. Minimal Admissible Quotient Layer

The core of the state quotient system is built bottom-up through algebraic equivalence relations:

```
  [State α] ---> [AGDEquiv α Ω C]
                       |
                       v (refl, symm, trans)
                 [agdSetoid α Ω C]
                       |
                       v (Quotient)
                  [QStar α Ω C]
                       |
                       +---> [pi (projection)]
                       +---> [OmegaBar]
                       +---> [CBar]
```

### Nodes and Dependencies
- **`AGDEquiv.refl`, `AGDEquiv.symm`, `AGDEquiv.trans`**:
  - *Dependencies*: Pure reflexivity, symmetry, and transitivity of equality over `Nat`.
- **`agdSetoid`**:
  - *Dependencies*: Proved using `AGDEquiv.refl`, `AGDEquiv.symm`, `AGDEquiv.trans`.
- **`QStar`**:
  - *Dependencies*: Defined as the Quotient type over `agdSetoid`.

---

## 2. Operator Descent Layer

Operators are projected onto the quotient space $Q^*$ and verified for semantic congruence:

```
                  [Admissible]
                       |
                       v
         [TBar] <------+------> [TBar_sound]
           |
           v
      [descends]
```

### Nodes and Dependencies
- **`TBar`**:
  - *Dependencies*: `Quotient.lift` of the operator projection. Requires `Admissible` to prove congruence on equivalent states.
- **`TBar_sound`**:
  - *Dependencies*: Follows directly from definition of `TBar` and `Quotient.lift`.
- **`descends`**:
  - *Dependencies*: Derived using `TBar`.

---

## 3. Metamodel Verification Layer

Ensures soundness and replayability of operators in sequence, and proves the core descent characterization theorem:

```
  [Admissible] <=======> [admission_iff_descends] (Equivalence Theorem)
        ^
        |
  [Replay sequence] ---> [replay_preserves_invariants] (Inductive Replay Soundness)
```

### Nodes and Dependencies
- **`admission_iff_descends`**:
  - *Dependencies*: `Quotient.exact`, `Quotient.sound`, `TBar_sound`. Establishes the necessary and sufficient condition for admissibility as identity projection.
- **`replay_preserves_invariants`**:
  - *Dependencies*: List induction over operator sequences (`Replay`). Uses list membership proofs (`List.Mem.head`, `List.Mem.tail`) and `Admissible` step properties.

---

## 4. Algebraic Probe Layer (`ChronoFold/Auto.lean`)

```
  [omega (x, n)] ---> [omega_divides_n] (Nat.gcd_dvd_right)
                 ---> [omega_nonneg]    (Nat.zero_le)
                 ---> [omega_le_n]      (Nat.gcd_le_right)
```
