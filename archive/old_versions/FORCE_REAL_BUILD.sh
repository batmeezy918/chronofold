#!/data/data/com.termux/files/usr/bin/bash

set -e
cd ~/chronofold || exit

########################################
# CLEAN EVERYTHING (CRITICAL RESET)
########################################
rm -rf ChronoFold
rm -f ChronoFold.lean

mkdir -p ChronoFold

########################################
# CREATE ROOT LIBRARY FILE
########################################
cat <<'LEAN' > ChronoFold.lean
def hello : String := "ChronoFold Alive"

#eval hello
LEAN

########################################
# FIX LAKEFILE (FORCE DEFAULT TARGET)
########################################
cat <<'LEAN' > lakefile.lean
import Lake
open Lake DSL

package chronofold

@[default_target]
lean_lib ChronoFold
LEAN

########################################
# VERIFY STRUCTURE
########################################
echo "=== STRUCTURE ==="
ls -R

########################################
# PUSH
########################################
TOKEN=$(cat ~/.git_token | tr -d '\n' | tr -d '\r')

git add .
git commit -m "FORCE BUILD: inject default target + root module" || echo "No changes"

git push https://batmeezy918:$TOKEN@github.com/batmeezy918/chronofold.git

echo "==================================="
echo "FORCED BUILD DEPLOYED"
echo "==================================="

