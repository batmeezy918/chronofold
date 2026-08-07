# Recommended Next Operator

To maintain and expand the constitutional state $\psi$ with zero defects, we propose the following next operator:

## Operator: $O_{intake}$ (Deterministic Theorem Expansion)

### Objective
Ingest, validate, and promote new theorem candidates placed in `theorems_inbox/` using the automated intake pipeline (`scripts/process_inbox.sh`).

### Pre-conditions
- Lean 4 toolchain is fully active and compiled.
- Working directory is clean and fully synchronized.

### Post-conditions
- Verified theorems are promoted to `theorems_proven/`.
- Non-conforming or failing theorems are segregated under `theorems_rejected/`.
- Receipt files (`.json`) are updated in `theorem_receipts/`.
