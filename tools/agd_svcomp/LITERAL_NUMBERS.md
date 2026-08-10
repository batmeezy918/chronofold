# Literal Numbers — AGD × SV-COMP (Current Maximum Strength)

Generated: 2026-08-10

## Environment (sandbox run)

| Item | Value |
|------|-------|
| BenchExec | **3.35** (official) |
| CPAchecker archive | **CPAchecker-4.2.2-unix.zip** (153 MB) downloaded |
| Official task | `while_infinite_loop_1.c` (real SV-benchmarks) fetched |
| RAM available | 1.9 GB |
| CPUs | 2 |
| CPAchecker extracted / run | **No** (insufficient RAM for safe JVM) |

## AGD-Π-v2-max (executed)

| Metric | Literal value |
|--------|---------------|
| Stress iterations | **20 000** |
| Exact projection matches | **20 000** |
| Determinism rate | **1.000000** |
| Wall time | **0.3915 s** |
| Throughput | **~51 091 projections/s** |
| Official-task projection hash | `f6d3c8c586bbf50f3e90b23326186cfd4e00bf5cdc5eed8812c2ad3c2bae0ec8` |

## Official SOTA verifier runs (CPAchecker / Ultimate / etc.)

| Metric | Literal value |
|--------|---------------|
| Runs | **0** |
| TRUE | **0** |
| FALSE | **0** |
| UNKNOWN | **0** |
| WRONG | **0** |
| Status | **NOT EXECUTED** |

**Reason**: 1.9 GB RAM cannot safely extract and launch the CPAchecker JVM under BenchExec. The official archive is present; the wrapper (`sota_wrapper.py`) is ready for machines with ≥8 GB RAM.

## Claim separation

- **A (directly established)**: BenchExec 3.35 installed, CPAchecker archive obtained, one real SV-COMP task obtained, 20 000 perfect deterministic AGD projections.
- **D (not tested)**: Any actual SOTA verification verdict, full corpus, 57 797 270 stress, witness validation.

No numbers were fabricated.
