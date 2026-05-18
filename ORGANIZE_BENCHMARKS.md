# Chronofold Benchmark Organization

This directory structure is designed to provide a clear evolution of the Omega Optimizer and a reproducible baseline for COCO benchmarks.

## Structure

- `benchmarks/optimizer_evolution/`: Contains results and runner scripts for each major version of the optimizer (S6, S7, S8).
  - `s6/`: Baseline implementation.
  - `s7/`: Enhanced gradient-based approach.
  - `s8/`: Covariance-adapted evolution strategy.
- `benchmarks/coco_baseline/`: Standard COCO test suite scripts and setup.
- `benchmarks/logs/`: Build and benchmark execution logs.
- `benchmarks/results_archive/`: Historical results from earlier runs and different variants.

## How to Run Benchmarks

Each version folder in `optimizer_evolution/` contains its own `run_*.py` script which is a standalone equivalent for that version's COCO benchmark run.

To run a full pipeline, refer to scripts in `scripts/benchmark/`.
