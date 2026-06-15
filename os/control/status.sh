#!/usr/bin/env bash

echo "🧠 ChronoFold OS STATUS"
echo "----------------------"

git status --short
echo ""
echo "Kernel:"
ls kernel/runner/run.sh 2>/dev/null && echo "✔ active" || echo "✖ missing"
