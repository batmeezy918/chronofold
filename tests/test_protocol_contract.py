from emb.protocol_contract import verify_transition_contract, verify_trace_contract


def _event(operator="OP_SELECT_AID", before="INIT", after="SELECTED", seq=1):
    return {
        "status": "ADMITTED",
        "transition_id": f"TRANS_{seq:03d}",
        "operator": operator,
        "state_before": {"sequence_number": seq - 1, "stage": before},
        "preconditions": {"stage": before},
        "state_after": {"sequence_number": seq, "stage": after, "invariants": {"valid": True}},
        "postconditions": {"stage": after},
        "invariant_delta": {"seq_increment": 1},
        "constitution_hash": "a" * 64,
    }


def test_valid_transition_contract():
    result = verify_transition_contract(_event())
    assert result["valid"] is True


def test_invalid_stage_is_rejected():
    result = verify_transition_contract(_event(before="COMPLETED"))
    assert result["valid"] is False
    assert "pre_stage_violation" in result["failures"]


def test_trace_contract_reports_failed_transition():
    events = [_event(), _event(operator="OP_SELECT_AID", before="COMPLETED", after="SELECTED", seq=2)]
    result = verify_trace_contract(events)
    assert result["valid"] is False
    assert result["failed_transitions"] == ["TRANS_002"]
