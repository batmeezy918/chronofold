# Technical Claim Matrix

Every technical claim in the ChronoFold repository is classified into exactly one of three permissible categories:
1. `FORMALLY_PROVED`
2. `EMPIRICALLY_VERIFIED`
3. `CONJECTURE`

No other categories are permitted.

---

## Technical Claims Classification

| Claim ID | Claim Description | Lean Specification File | Implementation / Verification Artifact | Classification |
| :--- | :--- | :--- | :--- | :--- |
| **CLM_001** | **Invariant Composition Closure:** Composition of two operators preserving `Invariants` preserves `Invariants`. | `Verify.lean` (`invariant_composition`) | Proved via Lean kernel compilation (`lake build`). | `FORMALLY_PROVED` |
| **CLM_002** | **Identity Invariant Preservation:** The identity operator preserves `Invariants`. | `Verify.lean` (`identity_preserves_invariants`) | Proved via Lean kernel compilation (`lake build`). | `FORMALLY_PROVED` |
| **CLM_003** | **Smoke Test Validity:** Proves that $1 + 1 = 2$. | `theorems_proven/THM_000001__smoke_test.lean` | Verified by standard Lean kernel via `scripts/process_inbox.sh`. | `FORMALLY_PROVED` |
| **CLM_004** | **Theorem Intake Pipeline Determinism:** The theorem processing and validation sequence is repeatable and outputs identical results for identical candidates. | None (Tooling claim) | Validated by `scripts/process_inbox.sh` and output logs in `logs/`. | `EMPIRICALLY_VERIFIED` |
| **CLM_005** | **Zero-Failure Build:** The repository builds successfully without compilation warnings, type-checking errors, or unresolved imports. | `lakefile.lean` | Validated by `lake build` and execution of `lake exe Main`. | `EMPIRICALLY_VERIFIED` |
| **CLM_006** | **Metamodel Adherence:** All system elements (Objects, Operators, Witnesses, etc.) conform to the formal definitions in `Verify.lean`. | `Verify.lean` | Validated by structural code compliance. | `EMPIRICALLY_VERIFIED` |

---

## Detailed Classification Justifications

### 1. FORMALLY_PROVED
- **CLM_001, CLM_002, CLM_003**: Fully formalized in Lean 4 source files (`Verify.lean` and `theorems_proven/THM_000001__smoke_test.lean`). The Lean 4 compiler type-checks these proofs without using `sorry`, `admit`, or non-trivial axioms, verifying them completely in the Lean kernel.

### 2. EMPIRICALLY_VERIFIED
- **CLM_004**: Checked by verifying that running `scripts/process_inbox.sh` multiple times on identical candidate states yields the exact same validation results and JSON receipts.
- **CLM_005**: Verified via direct terminal execution of `lake build` and `lake exe Main`, returning exit status `0`.
- **CLM_006**: Audited through manual and script-driven checks of the files to confirm the structural and semantic correspondence with the formal models.

### 3. CONJECTURE
- There are currently no unresolved conjectures in the active system. All functional behaviors are either fully proved or empirically verified.
