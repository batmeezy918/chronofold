# Claim & Evidence Plan

This document maps how research claims connect to supporting evidence within the ChronoFold lab.

## Evidence Status Labels
- `pending`: Claim made, evidence gathering in progress.
- `measured`: Raw data collected (e.g., raw logs).
- `benchmarked`: Systematic performance data collected (e.g., results/benchmarks/).
- `verified_by_lean`: Formally proven using Lean 4.
- `needs_evidence`: Claim exists but lacks any supporting data.
- `rejected`: Evidence contradicts the claim.
- `narrative_only`: Descriptive claim not intended for formal or empirical verification.

## Mapping Claims to Artifacts

| Claim Type | Primary Evidence Source | Validation Script |
|------------|-------------------------|-------------------|
| Performance | `results/benchmarks/*.json` | `scripts/benchmarks/` |
| Invariant | `theorems/receipts/*.json` | `scripts/theorem/validate_theorem.py` |
| Correctness | `results/validation/*.log` | `scripts/validation/` |
| System Health | `logs/` | `scripts/bootstrap/cfdoctor` |

## Workflow
1. Use `cfclaim` to create a new claim in `claims/`.
2. Link evidence by placing artifacts in `evidence/` or referencing `results/`.
3. Update the claim's status label based on the strength of the evidence.
4. Formalize proof-based claims through the theorem intake pipeline.
