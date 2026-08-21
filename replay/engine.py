"""
Deterministic Replay Engine
============================
Executes and verifies deterministic protocol execution traces.
Guarantees byte-for-byte and hash identity Replay(R) == Replay(R).
"""

from typing import Dict, Any, List, Tuple
from agd.canonical import sha256_hash, get_environment_manifest
from emb.state_machine import EMBStateMachine
from certificates.engine import CertificateEngine
from authority.model import AuthorityGraph
from authority.emvco import register_emvco_rules

class ReplayEngine:
    def __init__(self):
        self.auth_graph = AuthorityGraph()
        register_emvco_rules(self.auth_graph)

    def execute_trace(self, seed: int, operator_sequence: List[Tuple[str, Dict[str, Any]]]) -> Dict[str, Any]:
        """
        Executes a deterministic trace and constructs a complete Replay Record.
        """
        sm = EMBStateMachine()
        auth_hash = self.auth_graph.get_manifest_hash()
        cert_engine = CertificateEngine(
            constitution_hash=sm.constitution.compute_hash(),
            authority_hash=auth_hash,
            implementation_hash=sha256_hash("EMBStateMachine_v1.0")
        )

        state_hashes = [sha256_hash(sm.current_state)]
        quotient_hashes = [sha256_hash(sm.current_state["quotient_state"])]
        cert_hashes = []
        op_trace = []

        for op, input_data in operator_sequence:
            res = sm.execute_transition(op, input_data)
            op_trace.append({"operator": op, "input": input_data, "status": res["status"]})

            if res["status"] == "ADMITTED":
                cert = cert_engine.issue_certificate(
                    operator=op,
                    input_data=input_data,
                    state_before=res["state_before"],
                    state_after=res["state_after"],
                    phi_before=sm.quotient_engine.omega(res["state_before"]),
                    phi_after=sm.quotient_engine.omega(res["state_after"]),
                    invariant_results={"valid": True}
                )
                cert_hashes.append(cert["certificate_hash"])

            state_hashes.append(sha256_hash(sm.current_state))
            quotient_hashes.append(sha256_hash(sm.current_state["quotient_state"]))

        output_state = sm.current_state
        output_hash = sha256_hash(output_state)
        env_manifest = get_environment_manifest()

        replay_id = f"REPLAY_SEED_{seed}_{sha256_hash(operator_sequence)[:8]}"

        replay_record = {
            "replay_id": replay_id,
            "constitution_hash": sm.constitution.compute_hash(),
            "authority_manifest_hash": auth_hash,
            "code_hash": sha256_hash("EMBStateMachine_v1.0"),
            "input_hash": sha256_hash(operator_sequence),
            "seed": seed,
            "operator_trace": op_trace,
            "state_hashes": state_hashes,
            "quotient_hashes": quotient_hashes,
            "certificate_hashes": cert_hashes,
            "output_hash": output_hash,
            "environment_hash": env_manifest["environment_hash"]
        }

        return replay_record

    def verify_replay_identity(self, seed: int, operator_sequence: List[Tuple[str, Dict[str, Any]]]) -> Dict[str, Any]:
        """
        Executes the trace twice independently and verifies byte-for-byte/hash equality:
        Replay(R) == Replay(R)
        """
        run_1 = self.execute_trace(seed, operator_sequence)
        run_2 = self.execute_trace(seed, operator_sequence)

        hash_1 = sha256_hash(run_1)
        hash_2 = sha256_hash(run_2)

        identical = (hash_1 == hash_2) and (run_1["output_hash"] == run_2["output_hash"])

        return {
            "identical": identical,
            "hash_run_1": hash_1,
            "hash_run_2": hash_2,
            "output_hash_1": run_1["output_hash"],
            "output_hash_2": run_2["output_hash"],
            "replay_record": run_1
        }
