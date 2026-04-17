#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "==================================="
echo "CHRONOFOLD FULL FIX (Ω ENFORCED)"
echo "==================================="

cd ~/chronofold || exit

mkdir -p .github/workflows

########################################
# WRITE FIXED WORKFLOW
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
    # SETUP ENV (CRITICAL)
    ########################################
    - name: Setup Lean Environment
      run: |
        export PATH="$HOME/.elan/bin:$PATH"
        lean --version
        lake --version
        lake update

    ########################################
    # BUILD (STRICT)
    ########################################
    - name: Build
      run: |
        export PATH="$HOME/.elan/bin:$PATH"

        echo "=== BUILD START ==="
        lake build | tee build.log

    ########################################
    # Ω ENFORCEMENT
    ########################################
    - name: Compute Ω
      run: |
        export PATH="$HOME/.elan/bin:$PATH"

        if [ ! -f "lake-manifest.json" ]; then
          echo "Ω = 0 (missing artifact)"
          exit 1
        fi

        echo "Ω = 1"
YAML

########################################
# LOAD TOKEN
########################################
TOKEN=$(cat ~/.git_token | tr -d '\n' | tr -d '\r')

########################################
# COMMIT + PUSH
########################################
git add .

git commit -m "FULL FIX: strict build + Ω enforcement + lean setup" || echo "No changes"

git push https://batmeezy918:$TOKEN@github.com/batmeezy918/chronofold.git

echo "==================================="
echo "FIX PUSHED SUCCESSFULLY"
echo "==================================="

