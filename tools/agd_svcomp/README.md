# AGD × SV-COMP 2026 Compatible Experiment

This directory implements a **strict, reproducible** workflow that follows the experiment specification given to Grok, with the following hard constraints:

## What this workflow does

1. Installs official **BenchExec** (the resource-measurement tool used by SV-COMP).
2. Records a full **environment fingerprint** (Phase 0).
3. Attempts to pull the official `svcomp26` benchmark-definition tag.
4. Runs a **deterministic AGD projection + replay stress harness**.
5. Emits a machine-readable certificate + SHA-256.

## What this workflow deliberately does **NOT** do

| Item | Status |
|------|--------|
| Full official SV-COMP 2026 corpus (36 402 C + 1 731 Java tasks) | **NOT EXECUTED** |
| Actual software verification (TRUE / FALSE / UNKNOWN) | **NOT EXECUTED** |
| 57 797 270 official-scale stress | **NOT EXECUTED** |
| Witness validation | **NOT EXECUTED** |
| Independent cross-checker | **NOT EXECUTED** |

Reasons:

- GitHub Actions runners do **not** meet official SV-COMP hardware requirements (15 GB RAM, 4 CPUs, 15 min CPU per task).
- The ChronoFold repository currently contains AGD **Lean formalizations** and optimizer benchmarks, **not** a C-program model checker that can consume `.yml` + `.c` SV-COMP tasks.
- Cloning the full `sv-benchmarks` repository is multi-gigabyte and exceeds practical Actions limits.

## How to run

```bash
# Locally
python tools/agd_svcomp/phase0_environment.py
python tools/agd_svcomp/run_agd_svcomp_harness.py --max-tasks 8 --stress-count 1000
python tools/agd_svcomp/make_certificate.py --artifact-dir artifacts/agd_svcomp --out artifacts/agd_svcomp/agd_svcomp2026_certificate.json
```

Or trigger the GitHub Action:

**Actions → AGD × SV-COMP 2026 Compatible Experiment → Run workflow**

## Claim discipline

All reports separate:

- **A.** Directly established by this run
- **B.** Empirically observed
- **C.** Hypotheses
- **D.** Not tested

Never upgrade a category.
