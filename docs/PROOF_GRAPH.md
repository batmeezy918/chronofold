# Proof Graph Report

This document maps the dependency and proof structure of the ChronoFold repository.

## Proof Graph Nodes

We define three types of nodes in our constitutional proof graph:
1. **Definition / Structure Node (D)**: Core specifications of the metamodel.
2. **Theorem / Lemma Node (T)**: Mathematical proofs verified by the Lean 4 kernel.
3. **Verification Node (V)**: Empirical test and tool execution checkpoints.

### Node Registry

| Node ID | Node Name | Type | Source File | Description |
| :--- | :--- | :--- | :--- | :--- |
| **D_001** | `Hash` | Definition | `Verify.lean` | Abstract representation of content-addressable hashes. |
| **D_002** | `ConstitutionalObject` | Definition | `Verify.lean` | Core system artifact representation. |
| **D_003** | `Witness` | Definition | `Verify.lean` | Proof/evidence certificates. |
| **D_004** | `Operator` | Definition | `Verify.lean` | Action representing state transitions. |
| **D_005** | `Fiber` | Definition | `Verify.lean` | Equivalence partitioning of system states. |
| **D_006** | `Registry` | Definition | `Verify.lean` | Object/witness database tracker. |
| **D_007** | `Replay` | Definition | `Verify.lean` | Verification of transition history. |
| **D_008** | `Compiler` | Definition | `Verify.lean` | High-to-low compilation/witness emission. |
| **D_009** | `Serialization` | Definition | `Verify.lean` | Deterministic encoding/decoding. |
| **D_010** | `Builder` | Definition | `Verify.lean` | System assembly constraints. |
| **D_011** | `Invariants` | Definition | `Verify.lean` | Baseline object health predicate. |
| **T_001** | `invariant_composition` | Theorem | `Verify.lean` | Theorem proving composite operator preservation. |
| **T_002** | `identity_preserves_invariants` | Theorem | `Verify.lean` | Theorem proving identity operator preservation. |
| **T_003** | `smoke_test` | Theorem | `theorems_proven/THM_000001__smoke_test.lean` | Initial sanity check theorem ($1 + 1 = 2$). |
| **V_001** | `lake build` | Verification | Command-line | Build validation of all Lean targets. |
| **V_002** | `lake exe Main` | Verification | Command-line | Runtime verification test. |
| **V_003** | `process_inbox.sh` | Verification | `scripts/process_inbox.sh` | Automated theorem intake and verification pipeline. |

---

## Proof Graph Edges (Dependencies)

The edges represents "depends on" or "verifies" relations:

```
 D_001 (Hash) ──────┐
                    ▼
 D_002 (ConstitutionalObject) ───► D_011 (Invariants)
                    │                  │
                    ▼                  ▼
 D_004 (Operator) ──┴───────────► T_001 (invariant_composition) ──► V_001 (lake build)
                                       ▲
                                       │
 D_011 (Invariants) ───────────────────┘

 T_003 (smoke_test) ────► V_003 (process_inbox.sh) ────► V_001 (lake build)
```

### Dependency Relations List

- **T_001 (`invariant_composition`)** depends on:
  - `D_004` (`Operator`)
  - `D_011` (`Invariants`)
- **T_002 (`identity_preserves_invariants`)** depends on:
  - `D_004` (`Operator`)
  - `D_011` (`Invariants`)
- **T_003 (`smoke_test`)** depends on:
  - `Verify.lean` (Imports all metamodel definitions and theorems)
- **V_001 (`lake build`)** verifies:
  - `Verify.lean` (Includes all D_* and T_001, T_002)
  - `Main.lean` (Runtime target)
- **V_002 (`lake exe Main`)** depends on:
  - `V_001` (`lake build`)
- **V_003 (`process_inbox.sh`)** depends on:
  - `Verify.lean` (Via imports in candidates)
  - `scripts/validate_theorem.py` (Structural validation)
  - Lean compiler toolchain
