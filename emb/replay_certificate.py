"""Deterministic EMB replay certificate helpers."""
from __future__ import annotations
from typing import Any, Dict, List
from agd.canonical import sha256_hash, canonical_json_dumps


def event_hash(previous_hash: str, event: Dict[str, Any]) -> str:
    return sha256_hash({"previous_event_hash": previous_hash, "event": event})


def build_trace_hash(events: List[Dict[str, Any]]) -> str:
    previous = "0" * 64
    for event in events:
        previous = event_hash(previous, event)
    return previous


def build_replay_certificate(
    *,
    constitution_hash: str,
    authority_hash: str,
    environment_hash: str,
    events: List[Dict[str, Any]],
    evidence_level: str = "SIMULATED",
) -> Dict[str, Any]:
    trace_hash = build_trace_hash(events)
    return {
        "certificate_version": "1.0.0",
        "constitution_hash": constitution_hash,
        "authority_hash": authority_hash,
        "environment_hash": environment_hash,
        "event_count": len(events),
        "trace_hash": trace_hash,
        "events": events,
        "evidence_level": evidence_level,
        "certificate_hash": sha256_hash({
            "certificate_version": "1.0.0",
            "constitution_hash": constitution_hash,
            "authority_hash": authority_hash,
            "environment_hash": environment_hash,
            "event_count": len(events),
            "trace_hash": trace_hash,
            "evidence_level": evidence_level,
        }),
    }


def verify_replay_certificate(certificate: Dict[str, Any]) -> bool:
    events = certificate.get("events", [])
    if build_trace_hash(events) != certificate.get("trace_hash"):
        return False
    expected = sha256_hash({
        "certificate_version": certificate.get("certificate_version"),
        "constitution_hash": certificate.get("constitution_hash"),
        "authority_hash": certificate.get("authority_hash"),
        "environment_hash": certificate.get("environment_hash"),
        "event_count": certificate.get("event_count"),
        "trace_hash": certificate.get("trace_hash"),
        "evidence_level": certificate.get("evidence_level"),
    })
    return expected == certificate.get("certificate_hash")
