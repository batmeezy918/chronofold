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
