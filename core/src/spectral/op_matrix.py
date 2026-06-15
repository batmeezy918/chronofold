import numpy as np

def build_operator(state_vec):
    v = np.array(state_vec, dtype=float)
    v = v / (np.linalg.norm(v) + 1e-9)
    return np.outer(v, v)
