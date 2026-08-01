# CLAIM MATRIX

All technical claims asserted within this repository must be classified as exactly one of the following permissible categories:
1. `FORMALLY_PROVED`: Justified solely by completed Lean 4 proofs.
2. `EMPIRICALLY_VERIFIED`: Justified by reproducible, automated tests or benchmarks.
3. `CONJECTURE`: All other claims (including theoretical assumptions or pending work).

No other categories are permitted.

| Claim ID | Category | Claim Description | Justification / Evidence Source |
|---|---|---|---|
| **CLM-001** | `FORMALLY_PROVED` | The formal standard arithmetic theorem $1+1=2$ is mathematically sound and correct. | Proved in `theorems_proven/THM_000001__smoke_test.lean` |
| **CLM-002** | `FORMALLY_PROVED` | The constitutional metamodel is structurally valid and formalized in Lean. | Proved in `Verify.lean` (where `ConstitutionalObject`, `Operator`, `Witness`, `Fiber`, `Registry`, `Replay`, `Compiler`, `Serialization`, `Hash`, `Builder`, and `Invariants` are defined and compiled successfully) |
| **CLM-003** | `EMPIRICALLY_VERIFIED` | The SNAP optimization strategy effectively minimizes the standard Sphere and Rastrigin mathematical benchmark functions. | Replayed and verified via `benchmark.py` running in sandboxed environment, producing `real_results.json` |
| **CLM-004** | `CONJECTURE` | Serializing Lean metamodel objects to standard JSON structures is fully isomorphic and does not lose type information. | Future research/work item |

---

## Remaining Conjectures
- Isomorphism and preservation of serialized Lean metamodel object structures (**CLM-004**).

## Remaining External Dependencies
- Python libraries: `numpy`, `cma`, `coco-experiment`.
- Lean 4 toolchain package management dependencies.
