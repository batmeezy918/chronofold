import os
import json
import numpy as np
from .safety import validate_state

def load_results(path="experiments"):
    vectors = {}

    for root, _, files in os.walk(path):
        for f in files:
            if not f.endswith(".json"):
                continue

            try:
                with open(os.path.join(root, f)) as fp:
                    d = json.load(fp)

                score = float(d.get("score", d.get("best_f", 1.0)))
                runtime = float(d.get("time", d.get("runtime", 1.0)))
                evals = float(d.get("evaluations", 1.0))
                stability = float(d.get("stable", 1.0))

                # 🧠 MULTI-DIM STATE
                vectors[f] = np.array([
                    score,
                    runtime,
                    evals,
                    stability
                ], dtype=float)

            except:
                continue

    return vectors


def build_state_vector(vectors):
    keys = list(vectors.keys())

    if len(keys) == 0:
        return [], np.array([0.0, 0.0, 0.0, 0.0])

    state = np.array([vectors[k] for k in keys], dtype=float)

    # flatten to global manifold vector
    state = state.mean(axis=0)

    return keys, validate_state(state)
