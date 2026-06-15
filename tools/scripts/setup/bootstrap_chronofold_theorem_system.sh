#!/usr/bin/env bash
set -euo pipefail

mkdir -p \
  .github/workflows \
  docs \
  scripts \
  templates \
  theorems_inbox \
  theorems_checked \
  theorems_proven \
  theorems_rejected \
  theorem_receipts \
  logs

cat > templates/theorem_candidate.lean <<'EOT'
import Mathlib
import Verify

/--
THEOREM_ID: THM_000001
TITLE: example_theorem
AUTHOR: user
STATUS: candidate
-/

theorem example_theorem : 1 + 1 = 2 := by
  decide
EOT

cat > theorems_inbox/README.md <<'EOT'
# Theorems Inbox

Place new theorem suggestions here as single-file Lean candidates.

## Required filename format

THM_000001__theorem_name.lean

- `THM_` prefix is required
- theorem id must be 6 digits
- theorem name must be lowercase snake_case
- one theorem per file

## Required file template

Copy `templates/theorem_candidate.lean` and replace the fields.

## Processing states

- `theorems_inbox/` -> raw submitted candidates
- `theorems_checked/` -> normalized candidates that passed structure validation
- `theorems_proven/` -> candidates that compiled successfully
- `theorems_rejected/` -> candidates rejected for structure or proof failure
- `theorem_receipts/` -> machine-readable JSON receipts for every processed theorem
EOT

cat > scripts/validate_theorem.py <<'EOT'
import re
import sys
from pathlib import Path

FILE = Path(sys.argv[1])
text = FILE.read_text()

name = FILE.name
if not re.match(r"THM_\d{6}__([a-z0-9_]+)\.lean$", name):
    print("INVALID FILENAME")
    sys.exit(1)

theorem_name = re.findall(r"theorem\s+([a-zA-Z0-9_]+)", text)
if len(theorem_name) != 1:
    print("MUST HAVE EXACTLY ONE THEOREM")
    sys.exit(1)

suffix = name.split("__", 1)[1].replace(".lean", "")
if theorem_name[0] != suffix:
    print("THEOREM NAME MISMATCH")
    sys.exit(1)

required = ["THEOREM_ID:", "TITLE:", "AUTHOR:", "STATUS:"]
for r in required:
    if r not in text:
        print(f"MISSING {r}")
        sys.exit(1)

for token in ["sorry", "admit", "axiom", "unsafe"]:
    if token in text:
        print(f"FORBIDDEN TOKEN: {token}")
        sys.exit(1)

print("VALID")
EOT

cat > scripts/process_inbox.sh <<'EOT'
#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.elan/bin:$PATH"

mkdir -p theorems_checked theorems_proven theorems_rejected theorem_receipts logs

FILES=$(find theorems_inbox -type f -name '*.lean' | sort || true)

for FILE in $FILES; do
  BASENAME=$(basename "$FILE")
  STEM="${BASENAME%.lean}"

  if ! python3 scripts/validate_theorem.py "$FILE"; then
    mv "$FILE" "theorems_rejected/$BASENAME"
    cat > "theorem_receipts/$STEM.json" <<JSON
{
  "theorem_id": "$STEM",
  "status": "rejected",
  "stage": "validation"
}
JSON
    echo "REJECTED $BASENAME"
    continue
  fi

  cp "$FILE" "theorems_checked/$BASENAME"

  if lake env lean "theorems_checked/$BASENAME" > "logs/$STEM.log" 2>&1; then
    mv "theorems_checked/$BASENAME" "theorems_proven/$BASENAME"
    rm -f "$FILE"
    STATUS="proven"
    STAGE="compile"
  else
    mv "theorems_checked/$BASENAME" "theorems_rejected/$BASENAME"
    rm -f "$FILE"
    STATUS="rejected"
    STAGE="compile"
  fi

  cat > "theorem_receipts/$STEM.json" <<JSON
{
  "theorem_id": "$STEM",
  "status": "$STATUS",
  "stage": "$STAGE",
  "log_path": "logs/$STEM.log"
}
JSON
done
EOT
chmod +x scripts/process_inbox.sh

cat > .github/workflows/theorem-intake.yml <<'EOT'
name: Theorem Intake

on:
  workflow_dispatch:
  push:
    paths:
      - 'theorems_inbox/**'
      - 'scripts/**'
      - '.github/workflows/theorem-intake.yml'

permissions:
  contents: write

jobs:
  process-theorems:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Install Lean
        run: |
          curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y
          echo "$HOME/.elan/bin" >> $GITHUB_PATH

      - name: Install Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.10"

      - name: Run processor
        run: |
          chmod +x scripts/process_inbox.sh
          scripts/process_inbox.sh

      - name: Commit results
        run: |
          git config user.name "github-actions"
          git config user.email "actions@github.com"
          git add .
          git commit -m "Auto-process theorems" || echo "No changes"
          git push
EOT

cat > .github/workflows/build.yml <<'EOT'
name: Build ChronoFold

on:
  workflow_dispatch:
  push:
    branches: ["main"]
  pull_request:

permissions:
  contents: read

concurrency:
  group: build-${{ github.ref }}
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 20

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Restore Lake packages cache
        uses: actions/cache@v4
        with:
          path: |
            .lake/packages
            .lake/build
            ~/.elan
          key: ${{ runner.os }}-lean-${{ hashFiles('lean-toolchain', 'lakefile.lean', 'lake-manifest.json') }}
          restore-keys: |
            ${{ runner.os }}-lean-

      - name: Install Lean via elan
        shell: bash
        run: |
          set -euo pipefail
          curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y
          echo "$HOME/.elan/bin" >> "$GITHUB_PATH"
          export PATH="$HOME/.elan/bin:$PATH"
          elan --version
          lean --version
          lake --version

      - name: Validate repository structure
        shell: bash
        run: |
          set -euo pipefail
          test -f lean-toolchain
          test -f lakefile.lean
          test -f Main.lean

      - name: Resolve dependencies
        shell: bash
        run: |
          set -euo pipefail
          export PATH="$HOME/.elan/bin:$PATH"
          lake update

      - name: Build project
        shell: bash
        run: |
          set -euo pipefail
          export PATH="$HOME/.elan/bin:$PATH"
          lake build 2>&1 | tee build.log

      - name: Run executable smoke test
        shell: bash
        run: |
          set -euo pipefail
          export PATH="$HOME/.elan/bin:$PATH"
          lake exe Main 2>&1 | tee smoke.log
          grep -F "ChronoFold system active" smoke.log

      - name: Upload logs
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: chronofold-build-logs
          path: |
            build.log
            smoke.log
          if-no-files-found: warn
EOT

cat > docs/theorem_ui_contract.md <<'EOT'
# Deterministic Theorem UI Contract

This document defines the exact UI elements and their 1:1 mapping to the theorem intake workflow.

## Canonical state machine

DRAFT -> VALIDATED -> SUBMITTED -> PROCESSING -> PROVEN
                                 \-> REJECTED

No other states are permitted.
EOT

cat > docs/index.html <<'EOT'
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>ChronoFold Theorem Intake</title>
</head>
<body style="font-family: Arial, sans-serif; background:#0b1020; color:#e8ecf3; padding:24px;">
  <h1>ChronoFold Theorem Intake</h1>
  <p>UI installed successfully.</p>
  <p>Next step is to replace this minimal page with the full interface, or use the theorem inbox workflow directly.</p>
</body>
</html>
EOT

cat > .github/workflows/pages.yml <<'EOT'
name: Deploy Pages UI

on:
  workflow_dispatch:
  push:
    branches: ["main"]
    paths:
      - 'docs/**'
      - '.github/workflows/pages.yml'

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Pages
        uses: actions/configure-pages@v5

      - name: Upload Pages artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: docs

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
EOT

cat > theorems_inbox/THM_000001__nat_add_zero_right.lean <<'EOT'
import Mathlib
import Verify

/--
THEOREM_ID: THM_000001
TITLE: nat_add_zero_right
AUTHOR: user
STATUS: candidate
-/

theorem nat_add_zero_right (n : Nat) : n + 0 = n := by
  simp
EOT

echo "Bootstrap complete."
