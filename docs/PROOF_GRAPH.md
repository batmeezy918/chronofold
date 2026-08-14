# PROOF_GRAPH.md

## Formal Proof Graph Architecture

The Lean specification in `Verify.lean` and `theorems_proven/` forms a directed acyclic graph (DAG) of verified formal structures and theorems.

---

## Proof Graph Nodes

### 1. Core Metamodel (`Verify.lean`)

- **Node: `State`** (`structure`)
  - Operational state parameterized over payload type $\alpha$.
- **Node: `Omega`** (`abbrev`)
  - Invariant signature function `State α → Nat`.
- **Node: `Covariant`** (`abbrev`)
  - Constitutional law signature function `State α → Nat`.
- **Node: `Operator`** (`abbrev`)
  - State transformation `State α → State α`.
- **Node: `Admissible`** (`def`)
  - Operator admissibility condition preserving both $\Omega$ and $C$.
- **Node: `AGDEquiv`** (`def`)
  - Equivalence relation induced by equal $\Omega$ and $C$ values.
  - *Dependencies*: `Omega`, `Covariant`, `State`.

### 2. Quotient Construction & Universal Property (`Verify.lean`)

- **Node: `AGDEquiv.refl`, `symm`, `trans`** (`theorem`)
  - Proofs that `AGDEquiv` is an equivalence relation.
- **Node: `agdSetoid`** (`def`)
  - Setoid instance for `State α` under `AGDEquiv`.
- **Node: `QStar`** (`def`)
  - Minimal quotient space $Q^* = \text{Quotient}(\text{agdSetoid})$.
- **Node: `pi`** (`def`)
  - Canonical projection $\pi : \text{State } \alpha \to Q^*$.
- **Node: `TBar`** (`noncomputable def`)
  - Descended operator on $Q^*$.
- **Node: `TBar_sound`** (`theorem`)
  - $\text{TBar}(\pi(s)) = \pi(T(s))$.
- **Node: `descends`** (`theorem`)
  - Existence of descended quotient operator for admissible $T$.
- **Node: `PreservingQuotient`** (`structure`)
  - Structure defining arbitrary preserving quotient spaces.
- **Node: `uniqueMorph`** (`noncomputable def`)
  - Universal morphism $Q^* \to Q$.
- **Node: `uniqueMorph_unique`** (`theorem`)
  - Uniqueness proof of universal initiality morphism $Q^* \to Q$.
- **Node: `interchangeable` & `interchangeable_iff`** (`def` / `theorem`)
  - Characterization of quotient state interchangeability.
- **Node: `admission_iff_descends`** (`theorem`)
  - Characterization of admissibility via identity behavior on $Q^*$.

### 3. Theorem Intake Suite (`theorems_proven/`)

- **Node: `THM_000001__smoke_test`** (`theorem`)
  - Formally intake-validated theorem verifying core system execution.

---

## Directed Acyclic Proof Dependency Graph

```
State, Omega, Covariant
       │
       ▼
   AGDEquiv ──► agdSetoid ──► QStar ──► pi
       │                           │
       ▼                           ▼
   Admissible ───────────────► TBar, TBar_sound ──► descends
                                   │
                                   ▼
 PreservingQuotient ──► uniqueMorph ──► uniqueMorph_unique
                                   │
                                   ▼
                           admission_iff_descends
```

---

## Verification Status

- **Acyclic**: Checked.
- **Incomplete proofs (`sorry`, `admit`)**: 0.
- **Axiomatic assumptions (`axiom`, `unsafe`)**: 0.
- **Status**: 100% Closed & Sound.
