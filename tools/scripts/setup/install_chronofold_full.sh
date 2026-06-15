#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/batmeezy918/chronofold"
BASE="$HOME/chronofold_system"
REPO="$BASE/repo"

mkdir -p "$BASE"
cd "$BASE"

if [ ! -d "$REPO" ]; then
  git clone "$REPO_URL" repo
else
  cd "$REPO"
  git pull || true
fi

cd "$REPO"

mkdir -p ChronoFold/Auto theorems_unproven theorems_proven

# Install system deps
if command -v apt >/dev/null; then
  sudo apt-get update
  sudo apt-get install -y inotify-tools jq
fi

# Install Lean
if ! command -v lake >/dev/null; then
  curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y
  source "$HOME/.elan/env"
fi

lake update

cat <<'EOT' > chronofold_engine.sh
#!/usr/bin/env bash
set -euo pipefail

AUTO="ChronoFold/Auto"
UNPROVEN="theorems_unproven"
PROVEN="theorems_proven"
LOG="build.log"

mkdir -p "$AUTO" "$UNPROVEN" "$PROVEN"

while true; do
  git pull || true

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
    mv "$UNPROVEN"/*.lean "$PROVEN"/ 2>/dev/null || true
    git add .
    git commit -m "AUTO: full proof convergence" || true
    git push || true
    sleep 2
    continue
  fi

  FAILS=$(grep -o 'Auto/[^:]*\\.lean' "$LOG" | sort -u || true)

  for f in "$UNPROVEN"/*.lean; do
    [ -e "$f" ] || continue
    name=$(basename "$f")

    if ! grep -q "$name" <<< "$FAILS"; then
      mv "$f" "$PROVEN"/
      git add .
      git commit -m "PROVEN: $name" || true
      git push || true
    fi
  done

  echo "------ NEED CODEX FIX ------"
  echo "$FAILS"
  tail -n 20 "$LOG"

  sleep 5
done
EOT

chmod +x chronofold_engine.sh

mkdir -p ~/.shortcuts

cat <<EOW > ~/.shortcuts/chronofold_run
#!/usr/bin/env bash
cd "$REPO"
./chronofold_engine.sh
EOW

chmod +x ~/.shortcuts/chronofold_run

echo "Install complete. Run via Termux widget: chronofold_run"
