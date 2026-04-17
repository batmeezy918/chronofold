#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "==================================="
echo "FIXING SNAP WORKFLOW"
echo "==================================="

cd ~/chronofold || exit

mkdir -p .github/workflows

########################################
# WRITE SNAP WORKFLOW (CORRECT VERSION)
########################################
cat <<'YAML' > .github/workflows/snap.yml
name: Lean + SNAP Pipeline

on:
  # REQUIRED FOR APP TRIGGER
  workflow_dispatch:

  # KEEP AUTOMATIC TRIGGERS
  push:
    branches: [ "main" ]

jobs:
  snap:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    ########################################
    # INSTALL LEAN
    ########################################
    - name: Install Lean
      run: |
        curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y
        echo "$HOME/.elan/bin" >> $GITHUB_PATH
        export PATH="$HOME/.elan/bin:$PATH"

    ########################################
    # RUN SNAP / BUILD
    ########################################
    - name: Run SNAP Pipeline
      run: |
        export PATH="$HOME/.elan/bin:$PATH"

        echo "=== RUNNING SNAP ==="
        lake build > build.log 2>&1 || true

        tail -n 50 build.log || true

        ########################################
        # Ω ENFORCEMENT
        ########################################
        if grep -i "error" build.log; then
          echo "Ω = 0 (error detected)"
          exit 1
        fi

        echo "Ω = 1 (success)"

    ########################################
    # ARTIFACT EXPORT
    ########################################
    - name: Export Results
      if: always()
      run: |
        mkdir -p results
        echo "SNAP completed" > results/status.txt

    - name: Upload Results
      uses: actions/upload-artifact@v4
      with:
        name: snap-results
        path: results/
YAML

########################################
# LOAD TOKEN
########################################
TOKEN=$(cat ~/.git_token | tr -d '\n' | tr -d '\r')

########################################
# COMMIT + PUSH
########################################
git add .

git commit -m "Fix SNAP workflow: add workflow_dispatch + Ω gate" || echo "No changes"

git push https://batmeezy918:$TOKEN@github.com/batmeezy918/chronofold.git

echo "==================================="
echo "SNAP WORKFLOW FIXED + PUSHED"
echo "==================================="

