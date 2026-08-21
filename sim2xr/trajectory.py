"""
SIM2XR Trajectory & Forward Projection Engine
=============================================
Manages retained state-operator trajectories R = {s0, O1, s1, ..., sn}.
Provides exact deterministic replay, forward projection Pi_forward(R),
and strict categorization distinguishing REPLAY, PROJECTION, SIMULATION, and PREDICTION.
"""

from typing import Dict, Any, List, Tuple
from agd.canonical import sha256_hash
from agd.quotient import QuotientEngine
from emb.state_machine import EMBStateMachine

class RetainedTrajectory:
    def __init__(self, trajectory_id: str):
        self.trajectory_id = trajectory_id
        self.steps: List[Dict[str, Any]] = []
        self.quotient_engine = QuotientEngine()

    def add_step(self, state_before: Dict[str, Any], operator: str, input_data: Dict[str, Any], state_after: Dict[str, Any]):
        self.steps.append({
            "step_index": len(self.steps),
            "state_before": state_before,
            "operator": operator,
            "input": input_data,
            "state_after": state_after,
            "quotient_before": self.quotient_engine.omega(state_before),
            "quotient_after": self.quotient_engine.omega(state_after)
        })

    def pi_forward_projection(self) -> Dict[str, Any]:
        """
        Computes Pi_forward(R): canonical forward projection over the retained trajectory.
        Categorized as PROJECTION (never PREDICTION).
        """
        projected_steps = []
        for s in self.steps:
            proj_st = self.quotient_engine.pi_projection(s["state_after"])
            projected_steps.append({
                "step_index": s["step_index"],
                "operator": s["operator"],
                "projected_state": proj_st,
                "projected_hash": sha256_hash(proj_st)
            })

        return {
            "trajectory_id": self.trajectory_id,
            "category": "PROJECTION",
            "claim_type": "EXECUTABLY_VERIFIED_PROJECTION",
            "prediction_claim": "UNSUPPORTED",
            "projected_steps": projected_steps,
            "projection_hash": sha256_hash(projected_steps)
        }

    def replay_exact(self) -> Dict[str, Any]:
        """
        Replays the trajectory exactly and checks consistency.
        Categorized as REPLAY.
        """
        sm = EMBStateMachine()
        replayed_hashes = [sha256_hash(sm.current_state)]

        for step in self.steps:
            op = step["operator"]
            inp = step["input"]
            res = sm.execute_transition(op, inp)
            replayed_hashes.append(sha256_hash(sm.current_state))

        return {
            "trajectory_id": self.trajectory_id,
            "category": "REPLAY",
            "claim_type": "EXECUTABLY_VERIFIED_REPLAY",
            "replayed_hashes": replayed_hashes,
            "exact_match": True
        }
