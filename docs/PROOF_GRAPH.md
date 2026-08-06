# Proof Dependency Graph

This document details the hierarchy, import relations, and dependencies of the Chronofold formal proof system.

---

## 1. Graph Visualization

```
              [ Lean 4 Core Primitives ]
                     /          \
                    /            \
                   v              v
         [ Verify.lean ]    [ Constitutional.lean ]
                \                 /
                 \               /
                  v             v
                [ Main.lean Executable ]
```

---

## 2. Node & Dependency Catalog

### Node A: Lean 4 Core
- **Type**: Compiler / Language Core
- **Dependencies**: None
- **Responsibility**: Provides basic types (`Nat`, `List`, `Prop`, `String`), quotient mechanisms, and tactics (`decide`, `rfl`, `simp`, `induction`).

### Node B: `Verify.lean`
- **Type**: Core Theorem Specification
- **Dependencies**: Lean 4 Core
- **Exported Theorems**:
  - `uniqueMorph_unique`
  - `admission_iff_descends`
  - `TBar_sound`

### Node C: `Constitutional.lean`
- **Type**: Metamodel Formalization
- **Dependencies**: Lean 4 Core
- **Exported Theorems**:
  - `path_preservation` (Proves that the state invariant is preserved under any sequence/chain of registered operators in the system)

### Node D: `theorems_proven/THM_000001__smoke_test.lean`
- **Type**: Dynamic Theorem Ingest
- **Dependencies**: `Verify.lean`
- **Exported Theorems**:
  - `smoke_test`

### Node E: `Main.lean`
- **Type**: System Integration Target
- **Dependencies**: `Verify.lean`, `Constitutional.lean`
- **Responsibility**: Invokes execution of verified system layers and reports runtime status.
