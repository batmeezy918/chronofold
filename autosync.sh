#!/bin/bash

cd ~/chronofold

while true; do
  git add -A

  if ! git diff --cached --quiet; then
    git commit -m "auto-sync: $(date +%Y-%m-%d_%H-%M-%S)"
    git push
  fi

  sleep 60
done
