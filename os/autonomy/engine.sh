#!/usr/bin/env bash

echo "🧠 AR-OS AUTONOMOUS ENGINE (CLEAN V1)"

INTERVAL=300
MAX_CYCLES=999
CYCLE=0

LAST_COMMIT_TIME=0
COMMIT_COOLDOWN=60

while [ "$CYCLE" -lt "$MAX_CYCLES" ]; do

    echo "-----------------------------"
    echo "🔁 Cycle: $CYCLE"

    # RUN KERNEL (safe)
    bash run_kernel.sh cfpc || echo "kernel failed"

    DATE=$(date +%Y%m%d_%H%M%S)

    echo "{\"cycle\":$CYCLE,\"time\":\"$DATE\"}" > os/state/last_cycle.json

    # SAFE STAGING ONLY
    git add core experiments kernel os tools 2>/dev/null

    if ! git diff --cached --quiet; then

        NOW=$(date +%s)
        DIFF=$((NOW - LAST_COMMIT_TIME))

        if [ "$DIFF" -ge "$COMMIT_COOLDOWN" ]; then

            echo "📦 committing cycle $CYCLE"

            git commit -m "auto-cycle: $DATE cycle=$CYCLE" || true
            git push origin main || echo "push failed"

            LAST_COMMIT_TIME=$NOW

        else

            # SAFE PRINT (NO PARENTHESIS EXPANSION ISSUES)
            echo "⏳ commit throttled: wait $COMMIT_COOLDOWN sec window"

        fi

    else
        echo "✔ no changes"
    fi

    sleep "$INTERVAL"
    CYCLE=$((CYCLE+1))

done

echo "🧠 ENGINE STOPPED"
