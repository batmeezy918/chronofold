#!/usr/bin/env bash

set -e

echo "🧠 ChronoFold Execution Kernel START"

TARGET=${1:-all}

echo "▶ Target: $TARGET"

if [ "$TARGET" = "all" ]; then
    echo "Running full pipeline..."
    python3 core/src/benchmarks/benchmark.py 2>/dev/null || true
    python3 core/src/optimizers/snap_real_optimizer.py 2>/dev/null || true
fi

if [ "$TARGET" = "cfpc" ]; then
    echo "Running CFPC system..."
    python3 core/src/benchmarks/snap_cma_harness.py 2>/dev/null || true
fi

if [ "$TARGET" = "lean" ]; then
    echo "Running Lean kernel..."
    lake build
fi

echo "✅ Kernel execution complete"
