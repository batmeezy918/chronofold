import numpy as np

def validate_state(state):
    state = np.array(state, dtype=float)

    if len(state) == 0:
        return np.array([0.0, 0.0, 0.0])

    if np.all(state == state[0]):
        # prevent collapse to constant vector
        state = state + np.random.normal(0, 1e-6, size=state.shape)

    if np.any(np.isnan(state)) or np.any(np.isinf(state)):
        state = np.nan_to_num(state)

    return state
