#!/usr/bin/env bash
set -euo pipefail

RUN_ID="cf_lean_$(date +%Y%m%dT%H%M%SZ)"
LOG_DIR="./logs/$RUN_ID"
mkdir -p "$LOG_DIR"

echo "======================================="
echo "ChronoFold Lean Execution"
echo "RUN_ID: $RUN_ID"
echo "======================================="

echo "[1] Project root: $(pwd)" | tee "$LOG_DIR/meta.log"

echo "[2] Cleaning build cache..." | tee -a "$LOG_DIR/meta.log"
rm -rf .lake/build || true

echo "[3] Updating dependencies..." | tee "$LOG_DIR/lake_update.log"
lake update

echo "[4] Building project..." | tee "$LOG_DIR/lake_build.log"
lake build

echo "[5] Checking Mathlib..." | tee -a "$LOG_DIR/meta.log"
if [ ! -d ".lake/packages/mathlib/Mathlib" ]; then
  echo "ERROR: Mathlib missing" | tee -a "$LOG_DIR/error.log"
  exit 1
fi

echo "✔ Mathlib OK" | tee -a "$LOG_DIR/meta.log"

TARGET_FILE="${1:-CategoryQuotient.lean}"

echo "[6] Running Lean: $TARGET_FILE" | tee -a "$LOG_DIR/meta.log"

lake env lean "$TARGET_FILE" | tee "$LOG_DIR/lean_run.log"

EXIT_CODE=$?

echo "=======================================" | tee -a "$LOG_DIR/meta.log"

if [ "$EXIT_CODE" -eq 0 ]; then
  STATUS="PASS"
  echo "✔ LEAN SUCCESS"
else
  STATUS="FAIL"
  echo "✘ LEAN FAILURE"
fi

cat > "$LOG_DIR/summary.json" <<EOT
{
  "run_id": "$RUN_ID",
  "status": "$STATUS",
  "file": "$TARGET_FILE"
}
EOT

echo "RUN COMPLETE"
echo "STATUS: $STATUS"
echo "LOG DIR: $LOG_DIR"

exit $EXIT_CODE
