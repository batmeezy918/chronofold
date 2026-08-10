# Deterministic COCO Benchmark

Canonical execution path for Chronofold S6 on the official COCO/BBOB `cocoex` interface
(PyPI package: `coco-experiment`).

## Determinism contract

- Fixed Python version: 3.10.14
- Fixed dependencies: `coco-experiment==2.8.2`, `numpy==2.2.6`
- Fixed `PYTHONHASHSEED=0`
- Fixed NumPy/random seed: `20260810`
- Fixed BBOB suite: `bbob`
- Fixed dimension: 10
- Fixed per-problem optimizer budget: 1000 iterations
- Double-run byte comparison of stdout, JSON results, and trace
- Results and trace are SHA-256 hashed into `determinism_manifest.json`
- Git commit SHA and package versions recorded by CI

The harness uses the official `cocoex.Suite` and `cocoex.Observer` interfaces.
No COCO objective implementation is duplicated here.

## Local verify

```bash
export PYTHONHASHSEED=0
pip install -r requirements.lock
bash verify.sh
```
