#!/usr/bin/env bash
set -euo pipefail

mkdir -p theorems_checked theorems_proven theorems_rejected theorem_receipts logs

FILES=$(find theorems_inbox -type f -name '*.lean' | sort || true)

for FILE in $FILES; do
  BASENAME=$(basename "$FILE")
  STEM="${BASENAME%.lean}"

  if ! python3 scripts/validate_theorem.py "$FILE"; then
    mv "$FILE" "theorems_rejected/$BASENAME"
    echo "REJECTED $BASENAME"
    continue
  fi

  cp "$FILE" "theorems_checked/$BASENAME"

  if lake env lean "theorems_checked/$BASENAME" > "logs/$STEM.log" 2>&1; then
    mv "theorems_checked/$BASENAME" "theorems_proven/$BASENAME"
    rm -f "$FILE"
    STATUS="proven"
  else
    mv "theorems_checked/$BASENAME" "theorems_rejected/$BASENAME"
    rm -f "$FILE"
    STATUS="rejected"
  fi

  cat <<EOF > theorem_receipts/$STEM.json
{
  "theorem_id": "$STEM",
  "status": "$STATUS"
}
EOF

done
