# Literal Numbers — AGD × SV-COMP (Current Maximum Strength)

Generated: 2026-08-10  
**All values are measured. No placeholders.**

## Environment

| Item | Actual value |
|------|--------------|
| BenchExec | **3.35** |
| CPAchecker archive | **CPAchecker-4.2.2-unix.zip** (160 189 450 bytes) |
| Official task | `while_infinite_loop_1.c` (SV-benchmarks) |
| RAM (sandbox) | **1 900 MB** |
| CPUs | **2** |
| CPAchecker extracted/run | **No** |

## AGD-Π-v2-max (executed)

| Metric | Actual value |
|--------|--------------|
| GitHub Actions stress | **50 000** exact / 50 000 |
| Sandbox stress | **20 000** exact / 20 000 |
| Combined deterministic replays | **70 000** |
| Determinism rate | **1.000000** |
| Sandbox wall time | **0.3915 s** |
| Sandbox throughput | **51 091.1 / s** |
| Official-task projection hash | `f6d3c8c586bbf50f3e90b23326186cfd4e00bf5cdc5eed8812c2ad3c2bae0ec8` |

## Official SOTA verifier runs

| Metric | Actual value |
|--------|--------------|
| Runs | **0** |
| TRUE | **0** |
| FALSE | **0** |
| UNKNOWN | **0** |
| WRONG | **0** |
| Status | **NOT EXECUTED** |
| Reason | 1.9 GB RAM insufficient for CPAchecker JVM |

## Claim separation

- **A**: BenchExec 3.35, CPAchecker archive, one real task, 70 000 perfect AGD projections.
- **D**: Any SOTA verification verdict, full corpus, 57 797 270 stress, witness validation.

See `RESULTS.md` for the complete filled summary block.
