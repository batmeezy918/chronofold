#!/data/data/com.termux/files/usr/bin/bash

cd ~/chronofold || exit

echo "[ChronoFold] INIT PUSH..."

git add .

git commit -m "Init commit $(date +%s)" || echo "No changes"

git push https://batmeezy918:$(cat ~/.git_token)@github.com/batmeezy918/chronofold.git
