# Claim Matrix Report

Every technical claim inside the AGD/ChronoFold system must be explicitly classified. No additional categories beyond `FORMALLY_PROVED`, `EMPIRICALLY_VERIFIED`, and `CONJECTURE` are permitted.

## Classification Table

| ID | Claim Name / Description | Classification | Mapping in Code / Workspace |
| --- | --- | --- | --- |
| **CLM-001** | AGD equivalence relation is a valid Setoid over State. | **FORMALLY_PROVED** | `AGD.agdSetoid` in `Verify.lean` |
| **CLM-002** | Admissible operators lift to a descended operator $TBar$ on $Q^*$. | **FORMALLY_PROVED** | `AGD.TBar_sound` and `AGD.descends` in `Verify.lean` |
| **CLM-003** | $Q^*$ satisfies universal initiality among all quotient spaces preserving invariants. | **FORMALLY_PROVED** | `AGD.uniqueMorph` and `AGD.uniqueMorph_unique` in `Verify.lean` |
| **CLM-004** | Operational interchangeable equality corresponds exactly to AGD equivalence. | **FORMALLY_PROVED** | `AGD.interchangeable_iff` in `Verify.lean` |
| **CLM-005** | Operator admissibility is structurally equivalent to descending as the identity on $Q^*$. | **FORMALLY_PROVED** | `AGD.admission_iff_descends` in `Verify.lean` |
| **CLM-006** | System smoke test validates successfully via Lean kernel. | **FORMALLY_PROVED** | `smoke_test` in `theorems_proven/THM_000001__smoke_test.lean` |
| **CLM-007** | Lean toolchain installs and builds workspace without compilation warnings. | **EMPIRICALLY_VERIFIED** | Verified by running `lake build` |
| **CLM-008** | Executor runtime initiates and outputs status correctly. | **EMPIRICALLY_VERIFIED** | Verified by executing `lake exe Main` |
| **CLM-009** | Automated intake pipeline rejects invalid or forbidden theorem files. | **EMPIRICALLY_VERIFIED** | Verified by running `scripts/process_inbox.sh` and tracking `theorem_receipts/` |
| **CLM-010** | Fintype cardinality bounds and minimality constraints. | **CONJECTURE** | `AGD.minimality_sketch` in `Verify.lean` (Scaffolded) |

## Admissibility Decision
All verified claims correspond 1:1 to their formalizations in Lean. No undocumented semantic behavior exists in the runtime environment.
