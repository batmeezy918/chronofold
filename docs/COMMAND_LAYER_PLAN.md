# Command Layer Plan

This document outlines the planned helper scripts in `scripts/bootstrap/`. These are not active replacements but plans for future implementation.

## Helpers

- `cf`: The primary entry point for the ChronoFold lab. Orchestrates common tasks.
- `cfopen`: Opens the lab environment, ensuring all dependencies (Lean, Python, etc.) are in the PATH.
- `cflab`: Manages the lab state, listing active sessions and runs.
- `cfdoctor`: Runs health checks on the repository, validating structure and invariant proofs.
- `cfsnap`: Creates a snapshot of the current repository state in `snapshots/`.
- `cfsearch`: Searches through claims, evidence, and theorems.
- `cfclaim`: Formalizes a new research claim in `claims/`.
- `cftheorem`: Manages the theorem intake pipeline (`theorems/inbox` -> verification -> `theorems/proven` or `rejected`).
- `cfbench`: Runs benchmark suites and records results in `results/benchmarks/`.

## Implementation Strategy
These helpers will be implemented as bash scripts or python wrappers that provide a unified CLI for the research lab. They will reside in `scripts/bootstrap/` and should be added to the user's PATH via `cfopen`.
