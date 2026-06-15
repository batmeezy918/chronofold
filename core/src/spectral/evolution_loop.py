import numpy as np

from .state_vector import load_results, build_state_vector
from .evolution import step
from .memory import save_state, load_state

def run_evolution(iterations=10):

    vectors = load_results()
    _, state = build_state_vector(vectors)

    # initialize memory
    state = load_state(state)

    print("\n🧠 SPECTRAL EVOLUTION ENGINE")
    print("============================")

    for t in range(iterations):

        state = step(state)

        rho = float(np.linalg.norm(state))

        drift = float(np.std(state))

        print(f"t={t} | ρ={rho:.6f} | drift={drift:.6f}")

        save_state(state)

    print("\n✔ evolution complete")
