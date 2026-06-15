#!/bin/bash

cd ~/chronofold || exit 1

echo "🧠 Clean autosync watcher started"

LAST_COMMIT=0

while true; do

  git add -A

  if ! git diff --cached --quiet; then

    NOW=$(date +%s)

    if [ $((NOW - LAST_COMMIT)) -gt 30 ]; then

      CHANGED=$(git diff --cached --name-only | head -n 10)

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
