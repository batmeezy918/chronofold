import numpy as np

def classify(state, spectral_radius, drift):

    score, runtime, evals, stability = state

    efficiency = score / (runtime + 1e-9)
    pressure = evals / (runtime + 1e-9)

    # RULE-BASED REGIMES (upgradeable to ML later)

    if spectral_radius > 1.2:
        return "DIVERGENT_REGIME"

    if drift < 1e-6 and spectral_radius < 1.01:
        return "STAGNATION_PLATEAU"

    if efficiency > 10 and stability > 0.8:
        return "OPTIMAL_CONVERGENCE"

    if pressure > 1000:
        return "EXPLORATION_HEAVY"

    return "MIXED_TRANSITION_REGIME"
