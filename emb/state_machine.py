"""
EMB Protocol State Machine Kernel
=================================
Executes explicit, deterministic protocol state transitions s_{k+1} = O_k(s_k).
Enforces preconditions, postconditions, constitutional invariants, and structured
rejections on illegal transitions.
"""

from typing import Dict, Any, List, Optional
from agd.canonical import sha256_hash, canonical_json_dumps
from agd.quotient import QuotientEngine
from constitution.model import Constitution
from constitution.compiler import ConstitutionCompiler
from constitution.canonical_constitution import build_canonical_constitution

class EMBStateMachine:
    def __init__(self, constitution: Optional[Constitution] = None):
        if constitution is None:
            constitution = build_canonical_constitution()
        self.constitution = constitution
        self.compiler = ConstitutionCompiler(self.constitution)
        self.compiler.compile()
        self.quotient_engine = QuotientEngine(self.constitution.equivalence_relation)

        # Initial State s0
        self.current_state = {
            "state_id": "STATE_000",
            "sequence_number": 0,
            "stage": "INIT",
            "card_state": {},
            "transaction_context": {},
            "invariants": {"valid": True},
            "quotient_state": {}
        }
        self.current_state["quotient_state"] = self.quotient_engine.omega(self.current_state)
        self.history: List[Dict[str, Any]] = []

    def execute_transition(self, operator: str, input_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Executes transition s_{k+1} = O_k(s_k) with strict validation.
        """
        state_before = dict(self.current_state)

        transition_candidate = {
            "operator": operator,
            "input": input_data,
            "state_before": state_before
        }

        # 1. Validate operator & admission rules via compiler
        adm_result = self.compiler.validate_transition(transition_candidate)

        if not adm_result["admitted"]:
            rejection = {
                "status": "STRUCTURED_REJECTION",
                "operator": operator,
                "input": input_data,
                "state_before": state_before,
                "reason": "Transition rejected by constitution compiler.",
                "rule_results": adm_result["rule_results"],
                "constitution_hash": adm_result["constitution_hash"]
            }
            return rejection

        # 2. Compute state transition according to operator semantics
        new_stage = state_before["stage"]
        new_card_state = dict(state_before["card_state"])
        new_tx_context = dict(state_before["transaction_context"])

        if operator == "OP_SELECT_AID":
            aid = input_data.get("aid", "")
            if not aid:
                return {
                    "status": "STRUCTURED_REJECTION",
                    "reason": "OP_SELECT_AID requires non-empty 'aid'."
                }
            new_stage = "SELECTED"
            new_card_state["aid"] = aid

        elif operator == "OP_GET_PROCESSING_OPTIONS":
            amount = input_data.get("amount", "000000000100")
            new_stage = "GPO_COMPLETED"
            new_tx_context["amount"] = amount
            new_tx_context["9F66"] = input_data.get("9F66", "28000000")

        elif operator == "OP_READ_RECORD":
            new_stage = "RECORDS_READ"
            new_card_state["afl"] = input_data.get("afl", "08010100")

        elif operator == "OP_GENERATE_AC":
            new_stage = "COMPLETED"
            new_card_state["ac"] = input_data.get("ac", "A1B2C3D4E5F67890")
            new_card_state["cryptogram_type"] = input_data.get("cryptogram_type", "TC")

        else:
            return {
                "status": "STRUCTURED_REJECTION",
                "reason": f"Unknown operator '{operator}'."
            }

        next_seq = state_before["sequence_number"] + 1
        state_after = {
            "state_id": f"STATE_{next_seq:03d}",
            "sequence_number": next_seq,
            "stage": new_stage,
            "card_state": new_card_state,
            "transaction_context": new_tx_context,
            "invariants": {"valid": True},
            "quotient_state": {}
        }
        state_after["quotient_state"] = self.quotient_engine.omega(state_after)

        # 3. Validate state invariants for s_{k+1}
        st_result = self.compiler.validate_state(state_after)
        if not st_result["valid"]:
            return {
                "status": "STRUCTURED_REJECTION",
                "reason": "State_after violated invariant rules.",
                "rule_results": st_result["rule_results"]
            }

        # 4. Compute invariant delta & quotient transformation
        phi_before = self.quotient_engine.phi(state_before)
        phi_after = self.quotient_engine.phi(state_after)

        invariant_delta = {
            "seq_increment": next_seq - state_before["sequence_number"],
            "stage_changed": state_before["stage"] != new_stage,
            "phi_before_hash": sha256_hash(phi_before[0]),
            "phi_after_hash": sha256_hash(phi_after[0])
        }

        authority_id = self.constitution.authority_set[0] if self.constitution.authority_set else "EMVCO"

        record = {
            "status": "ADMITTED",
            "transition_id": f"TRANS_{next_seq:03d}",
            "state_before": state_before,
            "input": input_data,
            "preconditions": {"stage": state_before["stage"]},
            "operator": operator,
            "state_after": state_after,
            "postconditions": {"stage": new_stage},
            "invariant_delta": invariant_delta,
            "authority": authority_id,
            "constitution_hash": self.constitution.compute_hash()
        }

        self.current_state = state_after
        self.history.append(record)
        return record
