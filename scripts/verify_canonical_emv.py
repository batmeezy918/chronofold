"""Run the canonical EMV/EMB deterministic gates without external dependencies."""
from __future__ import annotations
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agd.canonical import sha256_hash
from constitution.canonical_constitution import build_canonical_constitution
from emb.state_machine import EMBStateMachine
from emb.replay_certificate import build_replay_certificate, verify_replay_certificate
from emb.protocol_contract import verify_trace_contract


def main() -> int:
    constitution = build_canonical_constitution()
    c_hash = constitution.compute_hash()

    def execute():
        sm = EMBStateMachine(constitution)
        events = []
        for operator, data in [
            ("OP_SELECT_AID", {"aid": "A0000000031010"}),
            ("OP_GET_PROCESSING_OPTIONS", {"amount": "000000001000"}),
            ("OP_READ_RECORD", {"afl": "08010100"}),
            ("OP_GENERATE_AC", {"ac": "A1B2C3D4E5F67890", "cryptogram_type": "TC"}),
        ]:
            result = sm.execute_transition(operator, data)
            if result.get("status") != "ADMITTED":
                raise AssertionError(result)
            events.append(result)
        return events

    first = execute()
    second = execute()
    replay_hash = sha256_hash(first)
    assert replay_hash == sha256_hash(second), "replay mismatch"

    contract = verify_trace_contract(first)
    assert contract["valid"], contract

    certificate = build_replay_certificate(
        constitution_hash=c_hash,
        authority_hash=sha256_hash(constitution.authority_set),
        environment_hash=sha256_hash({"runtime": "python", "schema": "canonical-emv-v1"}),
        events=first,
        evidence_level="SIMULATED",
    )
    assert verify_replay_certificate(certificate)

    audit = {
        "schema_version": "1.1.0",
        "constitution_hash": c_hash,
        "trace_hash": certificate["trace_hash"],
        "replay_deterministic": True,
        "transition_contract_valid": contract["valid"],
        "transition_count": contract["event_count"],
        "certificate_valid": True,
        "evidence_level": "SIMULATED",
        "note": "This verifies the software model and replay contract; it is not external EMV certification.",
    }
    out = ROOT / "reports" / "canonical_emv_smoke_audit.json"
    out.parent.mkdir(exist_ok=True)
    out.write_text(json.dumps(audit, indent=2, sort_keys=True))
    print(json.dumps(audit, indent=2, sort_keys=True))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
