import os, json
import numpy as np

def load_results(path="experiments"):
    vectors = {}

    for root, _, files in os.walk(path):
        for f in files:
            if f.endswith(".json"):
                full = os.path.join(root, f)
                try:
                    with open(full) as fp:
                        data = json.load(fp)

                    name = f.replace(".json","")
                    score = float(data.get("score", data.get("best_f", 0.0)))
                    time = float(data.get("time", data.get("runtime", 1.0)))

                    vectors[name] = score / max(time, 1e-9)
                except:
                    pass

    return vectors


def build_state_vector(vectors):
    keys = list(vectors.keys())
    vals = np.array([vectors[k] for k in keys], dtype=float)
    return keys, vals
