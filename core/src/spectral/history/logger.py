import os, json
from datetime import datetime

LOG_PATH = "core/src/spectral/history/spectral_log.jsonl"

def log_state(data):
    os.makedirs(os.path.dirname(LOG_PATH), exist_ok=True)

    entry = {
        "time": datetime.utcnow().isoformat(),
        "spectral_radius": float(data.get("spectral_radius", 0.0)),
        "mean_eigen": float(data.get("mean_eigen", 0.0)),
        "stable": bool(data.get("stable", False)),
        "drift": float(data.get("drift", 0.0)),
        "quotients": data.get("quotients", {})
    }

    with open(LOG_PATH, "a") as f:
        f.write(json.dumps(entry) + "\n")
