#!/usr/bin/env bash
set -euo pipefail

########################################
# 1. FIX GITHUB ACTIONS WORKFLOW
########################################

mkdir -p .github/workflows

cat <<'YAML' > .github/workflows/chronofold.yml
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
    - name: Checkout repo
      uses: actions/checkout@v4

    ########################################
    # FIXED LEAN INSTALL
    ########################################
    - name: Install Lean (fixed)
      run: |
        curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y

        echo "$HOME/.elan/bin" >> $GITHUB_PATH
        export PATH="$HOME/.elan/bin:$PATH"

        lean --version
        lake --version

    ########################################
    # INSTALL DEPENDENCIES
    ########################################
    - name: Install deps
      run: |
        sudo apt update
        sudo apt install -y jq

    ########################################
    # PREP PROJECT
    ########################################
    - name: Prepare ChronoFold
      run: |
        if [ -d "Chronofold" ]; then
          mkdir -p ChronoFold
          cp -r Chronofold/* ChronoFold/ || true
          rm -rf Chronofold
        fi

        mkdir -p ChronoFold/Auto
        mkdir -p theorems_unproven
        mkdir -p theorems_proven

    ########################################
    # FETCH MATHLIB (CRITICAL)
    ########################################
    - name: Lake update
      run: |
        lake update

    ########################################
    # RUN ENGINE
    ########################################
    - name: Run ChronoFold
      run: |
        chmod +x chronofold_ci_engine.sh
        ./chronofold_ci_engine.sh

    ########################################
    # COMMIT RESULTS
    ########################################
    - name: Commit results
      run: |
        git config --global user.name "chronofold-bot"
        git config --global user.email "bot@chronofold.ai"

        git add .
        git commit -m "AUTO: theorem updates" || echo "No changes"

        git push
YAML

########################################
# 2. FIX ENGINE SCRIPT
########################################

cat <<'SCRIPT' > chronofold_ci_engine.sh
#!/usr/bin/env bash
set -euo pipefail

AUTO="ChronoFold/Auto"
UNPROVEN="theorems_unproven"
PROVEN="theorems_proven"
LOG="build.log"

mkdir -p "$AUTO" "$UNPROVEN" "$PROVEN"

########################################
# INJECT THEOREMS
########################################

for f in "$UNPROVEN"/*.lean; do
  [ -e "$f" ] || continue

  name=$(basename "$f")

  cat > "$AUTO/$name" <<EOF
import Mathlib
set_option maxHeartbeats 1000000

$(cat "$f")
