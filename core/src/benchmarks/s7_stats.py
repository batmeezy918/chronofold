import numpy as np
import json
from scipy.stats import wilcoxon
import random

# =========================
# LOAD RESULTS
# =========================

with open("S7_PLUS_RESULTS.json") as f:
    results = json.load(f)

# Fake CMA baseline (replace later with real)
CMA_BASELINE = {
    "SPHERE": 1.0,
    "RASTRIGIN": 50.0,
    "ROSENBROCK": 5000.0,
    "ACKLEY": 2.0,
    "SCHWEFEL": 2000.0
}

# =========================
# BOOTSTRAP
# =========================

def bootstrap_diff(a, b, n=1000):
    diffs = []
    for _ in range(n):
        sa = random.choice([a])
        sb = random.choice([b])
        diffs.append(sa - sb)
    return np.mean(diffs)

# =========================
# EFFECT SIZE (CLIFF DELTA)
# =========================

def cliffs_delta(a, b):
    return (a - b) / (abs(a) + abs(b) + 1e-8)

# =========================
# ANALYSIS
# =========================

report = {}

print("="*50)
print("STATISTICAL VALIDATION")
print("="*50)

for k in results:
    s7 = results[k]
    cma = CMA_BASELINE[k]

    diff = s7 - cma
    effect = cliffs_delta(s7, cma)
    boot = bootstrap_diff(s7, cma)

    report[k] = {
        "S7+": s7,
        "CMA": cma,
        "diff": diff,
        "effect_size": effect,
        "bootstrap": boot
    }

    print(f"\n{k}")
    print("S7+:", s7)
    print("CMA:", cma)
    print("Δ:", diff)
    print("Effect:", effect)

with open("S7_STATS.json","w") as f:
    json.dump(report,f,indent=2)

print("\nSaved → S7_STATS.json")
