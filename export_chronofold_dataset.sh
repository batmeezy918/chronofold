#!/data/data/com.termux/files/usr/bin/bash

set -e

ROOT="$HOME/chronofold"
OUT="$ROOT/_EXPORT_DATASET"
STAMP=$(date +%Y%m%d_%H%M%S)
FINAL="$HOME/storage/shared/chronofold_dataset_$STAMP"

echo "[1/6] Creating export workspace..."
rm -rf "$OUT"
mkdir -p "$OUT"/{results,logs,theorems,benchmarks,core,meta}

echo "[2/6] Copying result JSONs..."
cp -f $ROOT/*.json "$OUT/results/" 2>/dev/null || true

echo "[3/6] Copying logs..."
cp -rf $ROOT/logs "$OUT/" 2>/dev/null || true
cp -f $ROOT/build.log "$OUT/logs/" 2>/dev/null || true

echo "[4/6] Copying theorem artifacts..."
cp -rf $ROOT/theorems_* "$OUT/" 2>/dev/null || true
cp -rf $ROOT/theorem_receipts "$OUT/" 2>/dev/null || true

echo "[5/6] Copying benchmarks..."
cp -f $ROOT/benchmark*.py "$OUT/benchmarks/" 2>/dev/null || true
cp -f $ROOT/run_*.py "$OUT/benchmarks/" 2>/dev/null || true
cp -f $ROOT/s7_stats.py "$OUT/benchmarks/" 2>/dev/null || true

echo "[6/6] Creating dataset manifest..."

cat > "$OUT/meta/MANIFEST.json" << EOF
{
  "project": "ChronoFold",
  "timestamp": "$STAMP",
  "components": {
    "results": "JSON system outputs",
    "logs": "execution traces",
    "theorems": "Lean / formal proofs artifacts",
    "benchmarks": "simulation + evaluation scripts"
  },
  "notes": "Auto-generated research dataset export"
}
EOF

echo "Zipping dataset..."
cd "$OUT/.."
zip -r "chronofold_dataset_$STAMP.zip" "$(basename $OUT)" >/dev/null

echo "Moving to shared storage..."
mkdir -p "$FINAL"
mv "chronofold_dataset_$STAMP.zip" "$FINAL.zip"

echo "DONE:"
echo "$FINAL.zip"
