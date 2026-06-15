import os
import json
import numpy as np

STATE_PATH = "core/src/spectral/history/state_vector.npy"

def save_state(state):
    os.makedirs(os.path.dirname(STATE_PATH), exist_ok=True)
    np.save(STATE_PATH, state)

def load_state(default):
    if os.path.exists(STATE_PATH):
        return np.load(STATE_PATH)
    return default
