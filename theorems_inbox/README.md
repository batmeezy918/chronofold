# Theorems Inbox

Place new theorem suggestions here as single-file Lean candidates.

## Required filename format

THM_000001__theorem_name.lean

- `THM_` prefix is required
- theorem id must be 6 digits
- theorem name must be lowercase snake_case
- one theorem per file

## Required file template

Copy `templates/theorem_candidate.lean` and replace the fields.

## Processing states

- `theorems_inbox/` -> raw submitted candidates
- `theorems_checked/` -> normalized candidates that passed structure validation
- `theorems_proven/` -> candidates that compiled successfully
- `theorems_rejected/` -> candidates rejected for structure or proof failure
- `theorem_receipts/` -> machine-readable JSON receipts for every processed theorem
