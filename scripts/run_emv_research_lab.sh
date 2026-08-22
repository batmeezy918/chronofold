#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PORT="${PORT:-8766}"

printf '\n=== CHRONOFOLD EMV RESEARCH-GRADE LAB ===\n'
printf 'Repository: %s\n' "$ROOT"
printf 'Verified core is untouched; this is an adjacent research layer.\n\n'

python -m unittest tests/test_emv_research_lab.py -v
printf '\n=== LEVEL 5 PLAN ===\n'
python - <<'PY'
from ui.emv_research_lab import level5_plan
import json
print(json.dumps(level5_plan(), indent=2, sort_keys=True))
PY

printf '\n=== START UI ===\n'
printf 'Open: http://127.0.0.1:%s\n' "$PORT"
exec env PORT="$PORT" python -m ui.research_lab_server
