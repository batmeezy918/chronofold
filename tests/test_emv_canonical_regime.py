import hashlib
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(__file__))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)

from agd.canonical import canonical_json_dumps, sha256_hash
from constitution.canonical_constitution import build_canonical_constitution
from emb.state_machine import EMBStateMachine


def test_canonical_json_is_stable():
    a = {"b": 2, "a": [3, 1]}
    b = {"a": [3, 1], "b": 2}
    assert canonical_json_dumps(a) == canonical_json_dumps(b)
    assert sha256_hash(a) == sha256_hash(b)


def test_constitution_is_hash_stable():
    c1 = build_canonical_constitution()
    c2 = build_canonical_constitution()
    assert c1.compute_hash() == c2.compute_hash()


def test_basic_emv_trace_replays_deterministically():
    def run():
        sm = EMBStateMachine()
        trace = []
        trace.append(sm.execute_transition("OP_SELECT_AID", {"aid": "A0000000031010"}))
        trace.append(sm.execute_transition("OP_GET_PROCESSING_OPTIONS", {"amount": "000000001000"}))
        trace.append(sm.execute_transition("OP_READ_RECORD", {"afl": "08010100"}))
        trace.append(sm.execute_transition("OP_GENERATE_AC", {"ac": "A1B2C3D4E5F67890", "cryptogram_type": "TC"}))
        return sha256_hash(trace)

    assert run() == run()


def test_illegal_transition_is_rejected():
    sm = EMBStateMachine()
    result = sm.execute_transition("OP_GET_PROCESSING_OPTIONS", {"amount": "000000001000"})
    assert result["status"] == "STRUCTURED_REJECTION"
