import json
import numpy as np

LOG_PATH = "core/src/spectral/history/spectral_log.jsonl"

def load_history():
    data = []
    try:
        with open(LOG_PATH, "r") as f:
            for line in f:
                data.append(json.loads(line))
    except:
        pass
    return data


def compute_entropy(quotients):
    if not quotients:
        return 0.0
    vals = np.array(list(quotients.values()))
    return float(np.var(vals))


def detect_transitions(alpha=1.0, beta=1.0, gamma=1.0, threshold=1.5):
    data = load_history()

    if len(data) < 2:
        print("Not enough history")
        return

    print("\n🧠 PHASE TRANSITION ANALYSIS")
    print("============================")

    for i in range(1, len(data)):
        prev = data[i-1]
        curr = data[i]

        rho_diff = abs(curr["spectral_radius"] - prev["spectral_radius"])
        drift = abs(curr.get("drift", 0.0) - prev.get("drift", 0.0))

        H_prev = compute_entropy(prev.get("quotients", {}))
        H_curr = compute_entropy(curr.get("quotients", {}))
        entropy_shift = abs(H_curr - H_prev)

        theta = alpha * rho_diff + beta * drift + gamma * entropy_shift

        label = "STABLE"
        if theta > threshold:
            label = "⚡ PHASE TRANSITION"

        print(f"\nStep {i}")
        print(f"Theta = {theta:.6f} -> {label}")

if __name__ == "__main__":
    detect_transitions()
