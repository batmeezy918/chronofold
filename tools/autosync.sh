#!/bin/bash

cd ~/chronofold || exit 1

echo "🧠 AUTOSYNC ENGINE v6 (RESEARCH OS) STARTED"

LAST_COMMIT=0
LOCK_FILE="/tmp/chronofold_autosync.lock"

# ─────────────────────────────
# 🔒 SINGLE INSTANCE GUARD
# ─────────────────────────────
if [ -f "$LOCK_FILE" ]; then
  echo "⚠️ autosync already running"
  exit 1
fi

touch "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT

# ─────────────────────────────
# 🧠 MODULE DETECTION (PATH ONLY)
# ─────────────────────────────
detect_module() {
  FILES="$1"

  echo "$FILES" | grep -q "ChronoFold" && { echo "ChronoFold"; return; }
  echo "$FILES" | grep -q "SIM2XR" && { echo "SIM2XR"; return; }
  echo "$FILES" | grep -q "ThreadLock" && { echo "ThreadLock"; return; }

  echo "core"
}

# ─────────────────────────────
# 🧠 TYPE CLASSIFIER (SAFE HEURISTIC)
# ─────────────────────────────
classify_type() {
  FILES="$1"

  ALGO=$(echo "$FILES" | grep -Ei "engine|solver|spectral|opt|core|chrono" | wc -l)
  CONFIG=$(echo "$FILES" | grep -Ei "config|json|yaml|settings" | wc -l)
  EXP=$(echo "$FILES" | grep -Ei "run|bench|log|result|trace|data" | wc -l)

  TYPE="misc"

  if [ "$ALGO" -ge "$CONFIG" ] && [ "$ALGO" -ge "$EXP" ]; then
    TYPE="algorithm"
  elif [ "$CONFIG" -ge "$EXP" ]; then
    TYPE="config"
  elif [ "$EXP" -gt 0 ]; then
    TYPE="experiment"
  fi

  echo "$TYPE"
}

# ─────────────────────────────
# 🧠 SESSION BUFFER (KEY UPGRADE)
# ─────────────────────────────
BUFFER_FILES=""
SESSION_START=$(date +%s)

flush_commit() {

  FILES="$BUFFER_FILES"

  if [ -z "$FILES" ]; then
    return
  fi

  MODULE=$(detect_module "$FILES")
  TYPE=$(classify_type "$FILES")
  FILE_COUNT=$(echo "$FILES" | wc -l)

  echo "📦 Flushing commit:"
  echo "   module=$MODULE"
  echo "   type=$TYPE"
  echo "   files=$FILE_COUNT"

  SUMMARY="module=$MODULE | type=$TYPE | files=$FILE_COUNT"

  case "$TYPE" in
    algorithm)
      MSG="🧠 [RESEARCH EVENT] $MODULE core evolution | $SUMMARY"
      ;;
    experiment)
      MSG="📊 [EXPERIMENT BATCH] $MODULE run summary | $SUMMARY"
      ;;
    config)
      MSG="⚙️ [CONFIG UPDATE] $MODULE system tuning | $SUMMARY"
      ;;
    *)
      MSG="📦 [SYNC EVENT] $MODULE update | $SUMMARY"
      ;;
  esac

  git commit -m "$MSG"
  git push

  BUFFER_FILES=""
  SESSION_START=$(date +%s)

  echo "✅ commit flushed"
}

# ─────────────────────────────
# 🧠 MAIN LOOP (SESSION-BASED BATCHING)
# ─────────────────────────────
while true; do

  git add -A

  FILES=$(git diff --cached --name-only)

  if [ -n "$FILES" ]; then
    BUFFER_FILES="$FILES"

    NOW=$(date +%s)
    AGE=$((NOW - SESSION_START))

    # flush conditions:
    # 1. 60s passed
    # 2. buffer too large (>15 files)
    # 3. algorithm change detected
    FILE_COUNT=$(echo "$BUFFER_FILES" | wc -l)

    IS_ALGO=$(echo "$FILES" | grep -Ei "engine|solver|spectral|chrono|core" | wc -l)

    if [ $AGE -gt 60 ] || [ $FILE_COUNT -gt 15 ] || [ "$IS_ALGO" -gt 0 ]; then
      flush_commit
    else
      echo "⏳ buffering session (files=$FILE_COUNT, age=${AGE}s)"
    fi
  fi

  sleep 10

done
