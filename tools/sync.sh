#!/data/data/com.termux/files/usr/bin/bash

echo "🔍 Checking changes..."

git add -A

# prevent empty commits
if git diff --cached --quiet; then
  echo "⚠️ No meaningful changes"
  exit 0
fi

echo "🧠 Committing with context..."
git commit -m "auto-sync: $(date +%Y-%m-%d_%H-%M-%S)"

echo "🚀 Pushing..."
git push

echo "✅ Sync complete"
