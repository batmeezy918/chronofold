#!/data/data/com.termux/files/usr/bin/bash

set -e

cd ~/chronofold || exit

mkdir -p .github/workflows

########################################
# FULL WORKFLOW FIX (WITH BOOTSTRAP)
########################################
cat <<'YAML' > .github/workflows/chronofold.yml
name: ChronoFold Verification

on:
  workflow_dispatch:
  push:
    branches: [ "main" ]

jobs:
  verify:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    ########################################
    # INSTALL LEAN
    ########################################
    - name: Install Lean
      run: |
        curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y

    ########################################
    # SETUP ENV + FETCH DEPS (CRITICAL)
    ########################################
    - name: Setup Lean Project
      run: |
        export PATH="$HOME/.elan/bin:$PATH"

        lean --version
        lake --version

        # THIS IS THE MISSING PIECE
        lake update

    ########################################
    # BUILD (STRICT)
    ########################################
    - name: Build
      run: |
        export PATH="$HOME/.elan/bin:$PATH"

        echo "=== BUILD START ==="
        lake build

    ########################################
    # Ω ENFORCEMENT
    ########################################
    - name: Compute Ω
      run: |
        if [ ! -f "lake-manifest.json" ]; then
          echo "Ω = 0 (missing manifest)"
          exit 1
        fi

        echo "Ω = 1"
YAML

########################################
# PUSH
########################################
TOKEN=$(cat ~/.git_token | tr -d '\n' | tr -d '\r')

git add .
git commit -m "Fix: add lake bootstrap (real build fix)" || echo "No changes"

git push https://batmeezy918:$TOKEN@github.com/batmeezy918/chronofold.git

echo "FIX APPLIED"
