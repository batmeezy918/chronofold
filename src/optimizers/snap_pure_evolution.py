import numpy as np

# ===============================
# FITNESS
# ===============================
def sphere(x):
    return np.sum(x**2)

# ===============================
# INVARIANTS
# ===============================
def Omega(x):
    return x[0]

def Xi(x):
    return x[2] - 2*x[1] + x[0]

# ===============================
# PROJECTION (LEAN GUARANTEE)
# ===============================
def project(x, omega_ref, xi_ref):
    x_new = x.copy()
    x_new[0] = omega_ref
    x_new[2] = 2*x_new[1] - x_new[0] + xi_ref
    return x_new

# ===============================
# DISTRIBUTION OPERATOR (𝓓)
# ===============================
def compute_distribution(elites):
    mu = np.mean(elites, axis=0)
    centered = [e - mu for e in elites]
    Sigma = np.cov(np.array(centered).T) + 1e-6*np.eye(len(mu))
    return mu, Sigma

# ===============================
# EVOLUTION LOOP
# ===============================
def evolve(dim=10, pop_size=30, generations=60):

    population = [np.random.randn(dim) for _ in range(pop_size)]

    omega_ref = Omega(population[0])
    xi_ref = Xi(population[0])

    for gen in range(generations):

        fitness = [sphere(p) for p in population]

        # SELECTION (S)
        idx = np.argsort(fitness)
        elites = [population[i] for i in idx[:pop_size//3]]

        # DISTRIBUTION (𝓓)
        mu, Sigma = compute_distribution(elites)

        try:
            A = np.linalg.cholesky(Sigma)
        except:
            A = np.eye(dim)

        new_population = []

        for _ in range(pop_size):

            z = np.random.randn(dim)

            # CURVATURE SIGNAL (Ξ)
            xi_signal = np.linalg.norm(z)

            # MUTATION (ΔΞ𝓓)
            x = mu + A @ z + 0.1 * xi_signal * z

            # PROJECTION (Ω, Ξ invariants)
            x = project(x, omega_ref, xi_ref)

            new_population.append(x)

        population = new_population

        best = min([sphere(p) for p in population])
        print(f"Gen {gen}: Best = {best:.6f}")

    return population

# ===============================
# RUN
# ===============================
if __name__ == "__main__":
    print("Running PURE SNAP Evolution System...")
    evolve()
