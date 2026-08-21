#!/usr/bin/env python3
"""Deterministic self-check for the canonical EMV/EMB UI backend contract."""

import copy
import hashlib
import json

from emb.state_machine import EMBStateMachine
from constitution.canonical_constitution import build_canonical_constitution

FIXTURE = [
    ("OP_SELECT_AID", {"aid": "A0000000031010"}),
    ("OP_GET_PROCESSING_OPTIONS", {"amount": "000000001000"}),
    ("OP_READ_RECORD", {"afl": "08010100"}),
    ("OP_GENERATE_AC", {"ac": "A1B2C3D4E5F67890", "cryptogram_type": "TC"}),
]


def digest(value):
    raw = json.dumps(value, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(raw).hexdigest()


def run_once():
    constitution = build_canonical_constitution()
    machine = EMBStateMachine(constitution)
    events = [machine.execute_transition(op, data) for op, data in FIXTURE]
    return {
        "constitution_hash": constitution.compute_hash(),
        "trace_hash": digest(events),
        "events": events,
        "final_stage": machine.current_state["stage"],
        "final_sequence": machine.current_state["sequence_number"],
    }


def main():
    a = run_once()
    b = run_once()
    assert a["constitution_hash"] == b["constitution_hash"]
    assert a["trace_hash"] == b["trace_hash"]
    assert a["events"] == b["events"]
    assert a["final_stage"] == "COMPLETED"
    assert a["final_sequence"] == len(FIXTURE)

    # Verify a rejected operator does not mutate state.
    machine = EMBStateMachine(build_canonical_constitution())
    before = copy.deepcopy(machine.current_state)
    rejection = machine.execute_transition("OP_UNKNOWN", {})
    assert rejection["status"] == "STRUCTURED_REJECTION"
    assert machine.current_state == before

    print(json.dumps({
        "status": "PASS",
        "evidence_level": "EXECUTABLY_VERIFIED",
        "deterministic": True,
        "replay_equal": True,
        "illegal_transition_non_mutating": True,
        "constitution_hash": a["constitution_hash"],
        "trace_hash": a["trace_hash"],
        "final_stage": a["final_stage"],
        "final_sequence": a["final_sequence"],
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
