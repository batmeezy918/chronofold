#!/data/data/com.termux/files/usr/bin/bash

REPO="batmeezy918/chronofold"
TOKEN="YOUR_TOKEN"

echo "[+] Fetching artifact metadata..."

API_RESPONSE=$(curl -s \
  -H "Authorization: token $TOKEN" \
  https://api.github.com/repos/$REPO/actions/artifacts)

ARTIFACT_URL=$(echo "$API_RESPONSE" \
  | grep archive_download_url \
  | head -n 1 \
  | cut -d '"' -f 4)

echo "[+] Downloading artifact..."

curl -L \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/octet-stream" \
  "$ARTIFACT_URL" \
  -o chronofold.zip

echo "[+] Verifying file size..."

ls -lh chronofold.zip

echo "[+] Extracting..."

unzip -o chronofold.zip -d ~/storage/downloads/

echo "[+] Done → Downloads folder"
