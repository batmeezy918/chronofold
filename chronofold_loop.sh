#!/data/data/com.termux/files/usr/bin/bash

while true; do
  echo "=== LOOP START ==="

  # (Here is where Codex edits would happen)
  # You manually or programmatically modify files

  ./chronofold_push.sh

  echo "Waiting for GitHub Actions..."
  sleep 120

done
