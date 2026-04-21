# Theorems Inbox

Place new theorem suggestions here as single-file Lean candidates.

## Required filename format

```text
THM_000001__theorem_name.lean
```

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

## Deterministic rule

A file enters `theorems_proven/` only if:

1. filename is valid
2. metadata header is valid
3. theorem name matches filename
4. forbidden tokens are absent
5. the file compiles with `lake env lean`
