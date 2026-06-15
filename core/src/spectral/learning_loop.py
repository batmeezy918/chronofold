from state_vector import load_results, build_state_vector
from op_matrix import build_operator
from eigen_analysis import stability_index
from quotient import quotient
from .history.logger import log_state
from regime_classifier import classify
import numpy as np

def run_loop():

    vectors = load_results()

    if len(vectors) == 0:
        vectors = {"bootstrap": np.array([1.0, 1.0, 1.0, 1.0])}

    keys, state = build_state_vector(vectors)

    O = build_operator(state)
    stats = stability_index(O)

    drift = float(np.std(state))

    base = state[0] if len(state) > 0 else 1.0

    quotients = {str(k): float(np.linalg.norm(v)/ (np.linalg.norm(base)+1e-9))
                 for k, v in vectors.items()}

    regime = classify(state, stats["spectral_radius"], drift)

    result = {
        "spectral_radius": stats["spectral_radius"],
        "mean_eigen": stats["mean_eigen"],
        "stable": stats["spectral_radius"] <= 1.0,
        "drift": drift,
        "regime": regime,
        "quotients": quotients
    }

    log_state(result)

    print("\n🧠 CHRONOFOLD SPECTRAL ENGINE")
    print("============================")
    print("ρ:", result["spectral_radius"])
    print("drift:", result["drift"])
    print("REGIME:", result["regime"])

if __name__ == "__main__":
    run_loop()
