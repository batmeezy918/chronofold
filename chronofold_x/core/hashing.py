import hashlib
import json

def compute_state_hash(psi):
    return hashlib.sha256(json.dumps(psi, sort_keys=True).encode()).hexdigest()

class ReplayLogger:
    def log_transition(self, prev_hash, next_hash, op):
        return {
            "prev_hash": prev_hash,
            "next_hash": next_hash,
            "operator": op,
            "timestamp": 0 # Deterministic timestamp
        }
