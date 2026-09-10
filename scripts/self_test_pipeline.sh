#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.elan/bin:$PATH"

echo "=== Running Theorem Intake Pipeline Self-Test ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

mkdir -p theorems_inbox theorems_proven theorems_rejected theorem_receipts logs

PASS_FILE="theorems_inbox/THM_999999__selftest_pass.lean"
FAIL_FILE="theorems_inbox/THM_999998__selftest_fail.lean"

# 1. Create a valid theorem candidate
cat > "$PASS_FILE" <<'LEAN'
import Verify

/--
THEOREM_ID: THM_999999
TITLE: selftest_pass
AUTHOR: self_test
STATUS: candidate
-/

theorem selftest_pass : 2 + 2 = 4 := by
  decide
LEAN

# 2. Create an invalid theorem candidate (contains forbidden token 'sorry')
cat > "$FAIL_FILE" <<'LEAN'
import Verify

/--
THEOREM_ID: THM_999998
TITLE: selftest_fail
AUTHOR: self_test
STATUS: candidate
-/

theorem selftest_fail : 2 + 2 = 5 := by
  sorry
LEAN

# 3. Run inbox processing pipeline
bash scripts/process_inbox.sh

# 4. Verify pass candidate moved to theorems_proven and receipt generated
if [ ! -f "theorems_proven/THM_999999__selftest_pass.lean" ]; then
  echo "ERROR: Valid theorem candidate was not moved to theorems_proven" >&2
  exit 1
fi

if [ ! -f "theorem_receipts/THM_999999__selftest_pass.json" ]; then
  echo "ERROR: Receipt for valid theorem candidate was not generated" >&2
  exit 1
fi

grep -q '"status": "proven"' "theorem_receipts/THM_999999__selftest_pass.json" || {
  echo "ERROR: Receipt status for valid candidate is not 'proven'" >&2
  exit 1
}

# 5. Verify fail candidate moved to theorems_rejected and receipt generated
if [ ! -f "theorems_rejected/THM_999998__selftest_fail.lean" ]; then
  echo "ERROR: Invalid theorem candidate was not moved to theorems_rejected" >&2
  exit 1
fi

if [ ! -f "theorem_receipts/THM_999998__selftest_fail.json" ]; then
  echo "ERROR: Receipt for invalid theorem candidate was not generated" >&2
  exit 1
fi

grep -q '"status": "rejected"' "theorem_receipts/THM_999998__selftest_fail.json" || {
  echo "ERROR: Receipt status for invalid candidate is not 'rejected'" >&2
  exit 1
}

# 6. Cleanup self-test artifacts
rm -f theorems_proven/THM_999999__selftest_pass.lean
rm -f theorems_rejected/THM_999998__selftest_fail.lean
rm -f theorem_receipts/THM_999999__selftest_pass.json
rm -f theorem_receipts/THM_999998__selftest_fail.json
rm -f logs/THM_999999__selftest_pass.log
rm -f logs/THM_999998__selftest_fail.log

echo "SELF-TEST PASSED"
