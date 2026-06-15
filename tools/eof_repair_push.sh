#!/usr/bin/env bash

echo "🧠 EOF SYSTEM REPAIR + PUSH START"

cd "$(git rev-parse --show-toplevel)" || exit 1

# -------------------------
# 1. FIX NAMESPACE COLLISION
# -------------------------
if [ -f core/src/spectral/operator.py ]; then
    mv core/src/spectral/operator.py core/src/spectral/op_matrix.py
    echo "✅ Renamed operator.py → op_matrix.py"
fi

# -------------------------
# 2. ENSURE INIT FILES
# -------------------------
mkdir -p core/src/spectral
touch core/src/spectral/__init__.py

# -------------------------
# 3. REBUILD STATE VECTOR (SAFE VERSION)
# -------------------------
cat > core/src/spectral/state_vector.py << 'PY'
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
PY

# -------------------------
# 4. OPERATOR (SAFE NAME)
# -------------------------
cat > core/src/spectral/op_matrix.py << 'PY'
import numpy as np

def build_operator(state_vec):
    v = np.array(state_vec, dtype=float)
    v = v / (np.linalg.norm(v) + 1e-9)
    return np.outer(v, v)
PY

# -------------------------
# 5. EIGEN ENGINE
# -------------------------
cat > core/src/spectral/eigen_analysis.py << 'PY'
import numpy as np

def spectral_radius(O):
    eig = np.linalg.eigvals(O)
    return float(np.max(np.abs(eig))), eig

def stability_index(O):
    rho, eig = spectral_radius(O)
    return {
        "spectral_radius": rho,
        "mean_eigen": float(np.mean(np.abs(eig))),
        "stable": rho <= 1.0
    }
PY

# -------------------------
# 6. QUOTIENT ENGINE
# -------------------------
cat > core/src/spectral/quotient.py << 'PY'
def quotient(a, b):
    return a / (b + 1e-9)
PY

# -------------------------
# 7. RUNNER
# -------------------------
cat > core/src/spectral/run_spectral.py << 'PY'
from state_vector import load_results, build_state_vector
from op_matrix import build_operator
from eigen_analysis import stability_index
from quotient import quotient

def run():
    vectors = load_results()

    if not vectors:
        print("No data")
        return

    keys, state = build_state_vector(vectors)
    O = build_operator(state)
    stats = stability_index(O)

    print("\n🧠 SPECTRAL ENGINE")
    print("ρ =", stats["spectral_radius"])
    print("mean =", stats["mean_eigen"])
    print("stable =", stats["stable"])

    base = list(vectors.values())[0]
    for k, v in vectors.items():
        print(k, "Q =", quotient(v, base))

if __name__ == "__main__":
    run()
PY

# -------------------------
# 8. SAFE GIT PUSH (NO AUTOSYNC LOOP)
# -------------------------

git add -A

if git diff --cached --quiet; then
    echo "⚠️ No changes to commit"
    exit 0
fi

git commit -m "EOF spectral repair: stabilize operator namespace + fix engine"

git push

echo "✅ EOF REPAIR COMPLETE + PUSHED"
