#!/usr/bin/env bash
set -euo pipefail

########################################
# FIX WORKFLOW
########################################

mkdir -p .github/workflows

cat > .github/workflows/chronofold.yml <<'YAML'
name: ChronoFold Autonomous Engine

on:
  push:
  workflow_dispatch:
  schedule:
    - cron: "*/5 * * * *"

jobs:
  chronofold:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Install Lean
      run: |
        curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y
        echo "$HOME/.elan/bin" >> $GITHUB_PATH
        export PATH="$HOME/.elan/bin:$PATH"
        lean --version
        lake --version

    - name: Install deps
      run: |
        sudo apt update
        sudo apt install -y jq

    - name: Prepare
      run: |
        mkdir -p ChronoFold/Auto
        mkdir -p theorems_unproven
        mkdir -p theorems_proven

    - name: Lake update
      run: lake update

    - name: Run engine
      run: |
        chmod +x chronofold_ci_engine.sh
        ./chronofold_ci_engine.sh

    - name: Commit
      run: |
        git config --global user.name "bot"
        git config --global user.email "bot@local"
        git add .
        git commit -m "auto update" || true
        git push
YAML

########################################
# FIX ENGINE
########################################

cat > chronofold_ci_engine.sh <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

AUTO="ChronoFold/Auto"
UNPROVEN="theorems_unproven"
PROVEN="theorems_proven"
LOG="build.log"

mkdir -p "$AUTO" "$UNPROVEN" "$PROVEN"

for f in "$UNPROVEN"/*.lean; do
  [ -e "$f" ] || continue
  name=$(basename "$f")

  cat > "$AUTO/$name" <<EOF2
import Mathlib
set_option maxHeartbeats 1000000

$(cat "$f")
EOF2
done

if lake build > "$LOG" 2>&1; then
  for f in "$UNPROVEN"/*.lean; do
    [ -e "$f" ] || continue
    mv "$f" "$PROVEN/"
  done
  exit 0
fi

FAILS=$(grep -o 'Auto/[^:]*\.lean' "$LOG" | sort -u || true)

for f in "$UNPROVEN"/*.lean; do
  [ -e "$f" ] || continue
  name=$(basename "$f")
  if ! grep -q "$name" <<< "$FAILS"; then
    mv "$f" "$PROVEN/"
  fi
done

echo "FAILURES:"
echo "$FAILS"
tail -n 50 "$LOG"
SCRIPT

chmod +x chronofold_ci_engine.sh

########################################
# COMMIT FIX
########################################

git add .
git commit -m "FIX: CI heredoc + stable pipeline" || true
git push || true

echo "DONE"
