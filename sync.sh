#!/data/data/com.termux/files/usr/bin/bash

echo "🔄 Staging files..."
git add -A

echo "🧠 Committing..."
git commit -m "auto-sync: $(date +%Y-%m-%d_%H-%M-%S)" || echo "No changes to commit"

echo "🚀 Pushing..."
git push

echo "✅ Done"
