#!/data/data/com.termux/files/usr/bin/bash

set -e

cd ~/chronofold || exit

########################################
# OVERWRITE snap.yml WITH DISPATCH ENABLED
########################################
cat <<'YAML' > .github/workflows/snap.yml
name: Lean + SNAP Pipeline

on:
  workflow_dispatch:
  push:
    branches: [ "main" ]

jobs:
  snap:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Install Lean
      run: |
        curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y
        echo "$HOME/.elan/bin" >> $GITHUB_PATH
        export PATH="$HOME/.elan/bin:$PATH"

    - name: Run SNAP
      run: |
        export PATH="$HOME/.elan/bin:$PATH"

        lake build > build.log 2>&1 || true

        tail -n 50 build.log || true

        ########################################
        # Ω ENFORCEMENT
        ########################################
        if grep -i "error" build.log; then
          echo "Ω = 0"
          exit 1
        fi

        echo "Ω = 1"
YAML

########################################
# PUSH
########################################
TOKEN=$(cat ~/.git_token | tr -d '\n' | tr -d '\r')

git add .
git commit -m "Fix snap.yml: add workflow_dispatch" || echo "No changes"

git push https://batmeezy918:$TOKEN@github.com/batmeezy918/chronofold.git

echo "SNAP WORKFLOW FIXED"
