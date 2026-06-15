#!/bin/bash

cd ~/chronofold

echo "🟢 Stable autosync started"

while inotifywait -r -e modify,create,delete .; do

  git add -A

  if ! git diff --cached --quiet; then
    git commit -m "auto-sync: $(date +%Y-%m-%d_%H-%M-%S)"
    git push
  fi

done
