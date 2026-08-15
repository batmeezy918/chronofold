# DETERMINISM_REPORT

## Toolchain Determinism

- **Lean Toolchain**: `v4.33.0` (Lake version 5.0.0-src+d8b1897) managed via `elan`.
- **Build Hash / Verification**: Binary target `Main` builds deterministically without environmental drift.
- **Compiler Invocations**: Executed directly via `lake build` and `lake env lean`.

## Pipeline & Process Determinism

- **Theorem Validation**: Enforced via `scripts/validate_theorem.py` with strict regex and syntax rules.
- **Intake Engine**: Enforced via `scripts/process_inbox.sh` sorting files deterministically (`sort`) before processing.
- **Receipt Generation**: Generated JSON receipts in `theorem_receipts/` with fixed schema fields.

## Verification Log

| Target | Command | Result | Hash / Status |
|---|---|---|---|
| Lean Kernel | `lake build` | SUCCESS | Clean build (0 errors) |
| System Main | `lake exe Main` | SUCCESS | Executed successfully |
| Theorem Intake | `scripts/process_inbox.sh` | SUCCESS | Receipts updated |
