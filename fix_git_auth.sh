#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== FIXING GIT AUTH ==="

cd ~/chronofold || exit

########################################
# 1. CLEAR BAD CREDENTIALS
########################################

git config --global --unset credential.helper || true
rm -f ~/.git-credentials || true

########################################
# 2. VERIFY TOKEN EXISTS
########################################

if [ ! -f ~/.git_token ]; then
  echo "[ERROR] ~/.git_token not found"
  exit 1
fi

TOKEN=$(cat ~/.git_token | tr -d '\n' | tr -d '\r')

if [ -z "$TOKEN" ]; then
  echo "[ERROR] Token is empty"
  exit 1
fi

########################################
# 3. FORCE REMOTE RESET
########################################

git remote remove origin || true
git remote add origin https://github.com/batmeezy918/chronofold.git

########################################
# 4. TEST AUTH (IMPORTANT)
########################################

echo "[TEST] Authenticating..."

curl -s -H "Authorization: token $TOKEN" https://api.github.com/user | grep login || {
  echo "[ERROR] Token invalid"
  exit 1
}

########################################
# 5. PUSH USING CORRECT FORMAT
########################################

echo "[PUSH] Attempting push..."

git add .
git commit -m "Auth fix $(date +%s)" || true

git push https://batmeezy918:$TOKEN@github.com/batmeezy918/chronofold.git

echo "=== SUCCESS: AUTH FIXED ==="
