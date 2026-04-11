#!/usr/bin/env bash
set -euo pipefail

########################################
# CONFIG
########################################

REPO_URL="https://github.com/batmeezy918/chronofold"
BASE="$HOME/chronofold_system"
REPO="$BASE/repo"

########################################
# CLONE REPO
########################################

rm -rf "$REPO"
mkdir -p "$BASE"
cd "$BASE"

git clone "$REPO_URL" repo
cd "$REPO"

########################################
# NORMALIZE STRUCTURE
########################################

if [ -d "Chronofold" ]; then
  mkdir -p ChronoFold
  cp -r Chronofold/* ChronoFold/ || true
  rm -rf Chronofold
fi

mkdir -p ChronoFold/Auto
mkdir -p theorems_unproven
mkdir -p theorems_proven

########################################
# INSTALL LEAN
########################################

if ! command -v lake >/dev/null; then
  curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y
  source "$HOME/.elan/env"
fi

lake update

########################################
# BUILD ENGINE SCRIPT
########################################

cat <<'EOT' > chronofold_engine.sh
#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(pwd)"
AUTO="$REPO_DIR/ChronoFold/Auto"
UNPROVEN="$REPO_DIR/theorems_unproven"
PROVEN="$REPO_DIR/theorems_proven"
LOG="$REPO_DIR/build.log"

mkdir -p "$AUTO" "$UNPROVEN" "$PROVEN"

########################################
# CONTINUOUS LOOP
########################################

while true; do

  echo "[SYNC]"
  git pull || true

  ####################################
  # WATCH FOR NEW FILES
  ####################################
  inotifywait -e create -e modify -r "$UNPROVEN" >/dev/null 2>&1 &

  ####################################
  # INJECT
  ####################################
  for f in "$UNPROVEN"/*.lean; do
    [ -e "$f" ] || continue

    name=$(basename "$f")

    cat > "$AUTO/$name" <<EOF2
import Mathlib
set_option maxHeartbeats 1000000

$(cat "$f")
EOF2

  done

  ####################################
  # BUILD
  ####################################
  if lake build > "$LOG" 2>&1; then

    for f in "$UNPROVEN"/*.lean; do
      [ -e "$f" ] || continue
      mv "$f" "$PROVEN/"
    done

    git add .
    git commit -m "AUTO: full proof convergence" || true
    git push || true

    continue
  fi

  ####################################
  # ANALYZE FAILURES
  ####################################
  FAILS=$(grep -o 'Auto/[^:]*\.lean' "$LOG" | sort -u || true)

  ####################################
  # PROMOTE SUCCESS
  ####################################
  for f in "$UNPROVEN"/*.lean; do
    [ -e "$f" ] || continue

    name=$(basename "$f")

    if ! grep -q "$name" <<< "$FAILS"; then
      mv "$f" "$PROVEN/"
      git add .
      git commit -m "PROVEN: $name" || true
      git push || true
    fi
  done

  ####################################
  # SIGNAL CODEX
  ####################################
  echo "------ NEED CODEX FIX ------"
  echo "$FAILS"
  tail -n 20 "$LOG"

  sleep 2

done
EOT

chmod +x chronofold_engine.sh

########################################
# TERMUX WIDGET SETUP
########################################

mkdir -p ~/.shortcuts

cat <<EOW > ~/.shortcuts/chronofold_run
#!/usr/bin/env bash
cd "$REPO"
./chronofold_engine.sh
EOW

chmod +x ~/.shortcuts/chronofold_run

########################################
# DONE
########################################

echo "====================================="
echo "INSTALL COMPLETE"
echo "====================================="
echo "Use Termux Widget → tap 'chronofold_run'"
echo "====================================="
