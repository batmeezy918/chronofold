"""Transition-level canonical protocol contract.

This layer binds an executable EMB transition to explicit pre/post conditions,
quotient observations, invariant checks, and replay evidence.  It does not
claim external EMV certification or substitute for the Lean proofs.
"""
from __future__ import annotations

from typing import Any, Dict, Iterable, List

from agd.canonical import sha256_hash


SUPPORTED_OPERATORS = {
    "OP_SELECT_AID": {"before": {"INIT"}, "after": "SELECTED"},
    "OP_GET_PROCESSING_OPTIONS": {"before": {"INIT", "SELECTED"}, "after": "GPO_COMPLETED"},
    "OP_READ_RECORD": {"before": {"GPO_COMPLETED", "SELECTED"}, "after": "RECORDS_READ"},
    "OP_GENERATE_AC": {"before": {"RECORDS_READ", "GPO_COMPLETED", "SELECTED"}, "after": "COMPLETED"},
}


def verify_transition_contract(record: Dict[str, Any]) -> Dict[str, Any]:
    """Verify the structural contract of one admitted transition."""
    failures: List[str] = []
    operator = record.get("operator")
    before = record.get("state_before") or {}
    after = record.get("state_after") or {}
    pre = record.get("preconditions") or {}
    post = record.get("postconditions") or {}
    delta = record.get("invariant_delta") or {}

    spec = SUPPORTED_OPERATORS.get(operator)
    if record.get("status") != "ADMITTED":
        failures.append("status_not_admitted")
    if spec is None:
        failures.append("unsupported_operator")
    else:
        if before.get("stage") not in spec["before"]:
            failures.append("pre_stage_violation")
        if after.get("stage") != spec["after"]:
            failures.append("post_stage_violation")
        if pre.get("stage") != before.get("stage"):
            failures.append("precondition_mismatch")
        if post.get("stage") != after.get("stage"):
            failures.append("postcondition_mismatch")

    if after.get("sequence_number") != before.get("sequence_number", -1) + 1:
        failures.append("sequence_violation")
    if after.get("invariants", {}).get("valid") is not True:
        failures.append("invariant_invalid")
    if delta.get("seq_increment") != 1:
        failures.append("invariant_delta_violation")
    if not record.get("constitution_hash"):
        failures.append("missing_constitution_hash")

    return {
        "valid": not failures,
        "operator": operator,
        "transition_id": record.get("transition_id"),
        "failures": failures,
        "state_before_hash": sha256_hash(before),
        "state_after_hash": sha256_hash(after),
        "invariant_contract": "PASS" if not failures else "FAIL",
    }


def verify_trace_contract(events: Iterable[Dict[str, Any]]) -> Dict[str, Any]:
    """Verify every transition in a trace and return an auditable summary."""
    results = [verify_transition_contract(event) for event in events]
    return {
        "valid": all(result["valid"] for result in results),
        "event_count": len(results),
        "transition_results": results,
        "failed_transitions": [r["transition_id"] for r in results if not r["valid"]],
    }
