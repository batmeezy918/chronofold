#!/usr/bin/env bash

echo "🧠 Safe Repo Map Generator (NO PIPE STREAMING)"

OUT="repo_map.json"
TMP="repo_map.tmp.json"

echo "{" > "$TMP"

find . -type f \
  ! -path "*/omega_env/*" \
  ! -path "*/.git/*" \
  ! -path "*/experiments/*" \
  ! -path "*/external/*" \
  2>/dev/null | while IFS= read -r f; do

    [ -f "$f" ] || continue

    preview=$(head -n 3 "$f" 2>/dev/null | tr '\n' ' ' | sed 's/"/\\"/g')

    echo "  \"$f\": { \"preview\": \"$preview\" }," >> "$TMP"

done

echo "}" >> "$TMP"

mv "$TMP" "$OUT"

echo "✅ Repo map generated safely"
