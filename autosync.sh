#!/bin/bash

cd ~/chronofold || exit 1

echo "🧠 Semantic autosync watcher started"

LAST_COMMIT=0

# noise filtering (critical for your repo)
IGNORE="(\\.git|\\.lake|omega_env|runs|cfpc_runs|control|__pycache__)"

while true; do

  # stage changes
  git add -A

  # remove noise from staging (safety pass)
  git reset .gitignore 2>/dev/null

  # check real diff
  if ! git diff --cached --quiet; then

    NOW=$(date +%s)

    # throttle (30s)
    if [ $((NOW - LAST_COMMIT)) -gt 30 ]; then

      # detect changed files (light semantic signal)
      CHANGED=$(git diff --cached --name-only | head -n 5)

      echo "📦 Changes detected:"
      echo "$CHANGED"

      git commit -m "auto-sync: $(date +%Y-%m-%d_%H-%M-%S)"

      git push

      LAST_COMMIT=$NOW

      echo "✅ synced"

    else
      echo "⏳ throttled"
    fi

  fi

  sleep 10

done
