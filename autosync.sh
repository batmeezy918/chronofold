#!/bin/bash

cd ~/chronofold || exit 1

echo "🟢 Production autosync started (stable mode)"

# track last commit time to avoid spam
LAST_COMMIT=0

while true; do

  # stage changes
  git add -A

  # check if there is anything meaningful
  if ! git diff --cached --quiet; then

    NOW=$(date +%s)

    # throttle commits (min 30 seconds apart)
    if [ $((NOW - LAST_COMMIT)) -gt 30 ]; then

      git commit -m "auto-sync: $(date +%Y-%m-%d_%H-%M-%S)"

      git push

      LAST_COMMIT=$NOW

      echo "✅ synced at $(date)"

    else
      echo "⏳ throttling commit (waiting window)"
    fi

  fi

  sleep 10

done
