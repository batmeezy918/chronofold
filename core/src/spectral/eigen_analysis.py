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
