#!/usr/bin/env bash

echo "🧠 ChronoFold OS BOOTING..."

# load state
if [ -f os/state/state.json ]; then
    echo "📦 Loading OS state..."
else
    echo '{"mode":"idle","kernel":"v1"}' > os/state/state.json
fi

echo "🔗 Linking kernel..."
bash run_kernel.sh lean

echo "✅ OS READY"
