# Deterministic COCO Benchmark

Canonical execution path for Chronofold S6 on the official COCO/BBOB `cocoex` interface.

## Determinism contract

- Fixed Python version: 3.10
- Fixed dependency versions in `requirements.txt`
- Fixed `PYTHONHASHSEED=0`
- Fixed NumPy/random seed: 20260810
- Fixed BBOB suite: `bbob`
- Fixed dimension: 10
- Fixed per-problem optimizer budget: 1000 iterations
- Results and trace are SHA-256 hashed
- The Git commit SHA and COCO package version are recorded by CI

The harness uses the official `cocoex.Suite` and `cocoex.Observer` interfaces. No COCO objective implementation is duplicated here.
