"""
Protocol Digital Twin
=====================
Stateful replay model preserving raw observations, derived state,
quotient state, protocol state, residual state, and event chronology.
Supports branching, counterfactual simulation, and projection comparison.
"""

from typing import Dict, Any, List
from agd.canonical import sha256_hash
from agd.quotient import QuotientEngine
from emb.state_machine import EMBStateMachine
from adapters.observation_adapter import ObservationAdapter

class DigitalTwin:
    def __init__(self):
        self.state_machine = EMBStateMachine()
        self.quotient_engine = QuotientEngine()
        self.adapter = ObservationAdapter()

        self.raw_observations: List[Dict[str, Any]] = []
        self.canonical_observations: List[Dict[str, Any]] = []
        self.derived_states: List[Dict[str, Any]] = []
        self.quotient_states: List[Dict[str, Any]] = []
        self.residual_states: List[Dict[str, Any]] = []
        self.event_chronology: List[Dict[str, Any]] = []

    def ingest_observation(self, raw_obs: Dict[str, Any], operator: str) -> Dict[str, Any]:
        """
        Ingests real-world observation and steps the digital twin state machine.
        """
        adapted = self.adapter.ingest_raw_rf_observation(raw_obs)

        raw_o = adapted["raw_observation"]
        canon_o = adapted["canonical_observation"]
        p_input = adapted["protocol_input"]

        self.raw_observations.append(raw_o)
        self.canonical_observations.append(canon_o)

        # Step state machine
        trans_res = self.state_machine.execute_transition(operator, p_input)

        curr_st = self.state_machine.current_state
        phi = self.quotient_engine.phi(curr_st)

        self.derived_states.append(curr_st)
        self.quotient_states.append(phi[0])
        self.residual_states.append(phi[1])

        event_entry = {
            "sequence_number": curr_st["sequence_number"],
            "operator": operator,
            "raw_hash": sha256_hash(raw_o),
            "canonical_hash": sha256_hash(canon_o),
            "state_hash": sha256_hash(curr_st),
            "quotient_hash": sha256_hash(phi[0]),
            "status": trans_res["status"]
        }
        self.event_chronology.append(event_entry)

        return {
            "status": trans_res["status"],
            "sequence_number": curr_st["sequence_number"],
            "stage": curr_st["stage"],
            "event_entry": event_entry
        }

    def counterfactual_simulation(self, modified_input: Dict[str, Any], operator: str) -> Dict[str, Any]:
        """
        Runs counterfactual simulation from current digital twin state on a branched fork.
        """
        forked_sm = EMBStateMachine(self.state_machine.constitution)
        forked_sm.current_state = dict(self.state_machine.current_state)

        sim_result = forked_sm.execute_transition(operator, modified_input)

        return {
            "simulation_type": "COUNTERFACTUAL",
            "modified_input": modified_input,
            "operator": operator,
            "forked_outcome": sim_result["status"],
            "forked_state_after": forked_sm.current_state if sim_result["status"] == "ADMITTED" else None
        }
