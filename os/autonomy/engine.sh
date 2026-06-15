#!/usr/bin/env bash

echo "🧠 AR-OS AUTONOMOUS ENGINE STARTED"

INTERVAL=300   # 5 min cycle
MAX_CYCLES=999

CYCLE=0

while [ $CYCLE -lt $MAX_CYCLES ]; do

    echo "-----------------------------"
    echo "🔁 Cycle: $CYCLE"

    # STEP 1: run kernel (safe default target)
    bash run_kernel.sh cfpc

    # STEP 2: capture state
    DATE=$(date +%Y%m%d_%H%M%S)
    echo "{\"cycle\":$CYCLE,\"time\":\"$DATE\"}" > os/state/last_cycle.json

    # STEP 3: check git changes
    git add -A

    if ! git diff --cached --quiet; then

        echo "📦 Changes detected → committing"

        git commit -m "auto-cycle: $DATE cycle=$CYCLE" || true

        # push (safe gated)
        git push origin main || echo "⚠️ push failed (network or lock)"

    else
        echo "✔ No changes this cycle"
    fi

    # STEP 4: sleep
    sleep $INTERVAL

    CYCLE=$((CYCLE+1))

done

echo "🧠 AR-OS ENGINE STOPPED"
