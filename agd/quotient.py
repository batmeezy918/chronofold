"""
AGD Quotient & Projection Machinery
====================================
Implements quotient map Phi(s) = (Omega(s), C(s)), equivalence s1 ~ s2,
canonical projection Pi(s), residual extraction, reconstruction, and formal verification
of idempotence and operator invariants.
"""

from typing import Dict, Any, Tuple
from agd.canonical import sha256_hash, canonical_json_dumps

class QuotientEngine:
    def __init__(self, equivalence_spec: Dict[str, Any] = None):
        if equivalence_spec is None:
            equivalence_spec = {
                "canonical_fields": ["sequence_number", "stage", "card_state.aid", "transaction_context.amount"],
                "ignored_fields": ["timestamp_raw", "debug_metadata", "ephemeral_channel_id"]
            }
        self.equivalence_spec = equivalence_spec

    def omega(self, state: Dict[str, Any]) -> Dict[str, Any]:
        """
        Quotient map Omega(s): Extracts invariant canonical state variables,
        filtering out ephemeral residuals.
        """
        canonical_fields = self.equivalence_spec.get("canonical_fields", [])
        extracted = {}

        for f in canonical_fields:
            parts = f.split('.')
            curr = state
            found = True
            for p in parts:
                if isinstance(curr, dict) and p in curr:
                    curr = curr[p]
                else:
                    found = False
                    break
            if found:
                extracted[f] = curr

        # Include top-level essential keys if not nested
        for k in ["sequence_number", "stage"]:
            if k in state and k not in extracted:
                extracted[k] = state[k]

        return extracted

    def c_residual(self, state: Dict[str, Any]) -> Dict[str, Any]:
        """
        Residual extraction C(s): Captures ephemeral or channel-specific context.
        """
        ignored_fields = self.equivalence_spec.get("ignored_fields", [])
        residuals = {}
        for k, v in state.items():
            if k in ignored_fields:
                residuals[k] = v
        return residuals

    def phi(self, state: Dict[str, Any]) -> Tuple[Dict[str, Any], Dict[str, Any]]:
        """
        Quotient map Phi(s) = (Omega(s), C(s))
        """
        return (self.omega(state), self.c_residual(state))

    def are_equivalent(self, s1: Dict[str, Any], s2: Dict[str, Any]) -> bool:
        """
        s1 ~ s2 iff Phi(s1)[0] == Phi(s2)[0]
        """
        return self.omega(s1) == self.omega(s2)

    def pi_projection(self, state: Dict[str, Any]) -> Dict[str, Any]:
        """
        Canonical projection Pi(s): Returns the canonical representative state
        where residual fields are reset to neutral canonical defaults.
        """
        omega_s = self.omega(state)
        # Construct representative state
        proj = {
            "sequence_number": omega_s.get("sequence_number", 0),
            "stage": omega_s.get("stage", "INIT"),
            "card_state": {
                "aid": omega_s.get("card_state.aid", state.get("card_state", {}).get("aid", "UNKNOWN"))
            },
            "transaction_context": {
                "amount": omega_s.get("transaction_context.amount", state.get("transaction_context", {}).get("amount", "0"))
            },
            "quotient_hash": sha256_hash(omega_s)
        }
        return proj

    def reconstruct(self, omega_s: Dict[str, Any], residual: Dict[str, Any]) -> Dict[str, Any]:
        """
        Reconstructs full state from quotient representation and residual.
        """
        proj = self.pi_projection(omega_s)
        proj.update(residual)
        return proj

    def verify_idempotence(self, state: Dict[str, Any]) -> bool:
        """
        Verifies Pi(Pi(s)) == Pi(s)
        """
        pi1 = self.pi_projection(state)
        pi2 = self.pi_projection(pi1)
        return sha256_hash(pi1) == sha256_hash(pi2)

    def verify_phi_invariance(self, state: Dict[str, Any]) -> bool:
        """
        Verifies Phi(Pi(s))[0] == Phi(s)[0]
        """
        phi_s = self.omega(state)
        pi_s = self.pi_projection(state)
        phi_pi_s = self.omega(pi_s)
        return phi_s == phi_pi_s
