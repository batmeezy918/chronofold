"""Deterministic EMV AGD acceptance quotient engine.

This layer is intentionally separate from the canonical ChronoFold EMV/EMB
state machine. It projects a scenario onto acceptance-relevant observables,
treating timing as residual/noise for the default quotient.

Evidence labels remain executable rather than formal certification.
"""
from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from typing import Any

ACCEPTANCE_FIELDS = (
    "cla", "ins", "p1", "p2", "data", "le",
    "response_data", "sw1", "sw2", "tlv",
    "aip", "afl", "cvr", "cdol", "cryptogram",
    "terminal_context",
)
NOISE_FIELDS = ("timing",)
SUCCESS = {"9000"}
FAILURE = {
    "6985", "6986", "6A80", "6A81", "6A82",
    "6A83", "6A84", "6A86", "6A87", "6A88",
}


def clean(value: Any) -> str:
    if value is None:
        return ""
    if isinstance(value, bytes):
        return value.hex().upper()
    return str(value).strip().replace(" ", "").upper()


def canonical_json(value: Any) -> bytes:
    return json.dumps(
        value, sort_keys=True, separators=(",", ":"), ensure_ascii=False
    ).encode("utf-8")


def sha256(value: Any) -> str:
    return hashlib.sha256(canonical_json(value)).hexdigest()


@dataclass(frozen=True)
class AcceptanceVector:
    cla: str = ""
    ins: str = ""
    p1: str = ""
    p2: str = ""
    data: str = ""
    le: str = ""
    response_data: str = ""
    sw1: str = ""
    sw2: str = ""
    tlv: str = ""
    aip: str = ""
    afl: str = ""
    cvr: str = ""
    cdol: str = ""
    cryptogram: str = ""
    terminal_context: str = ""

    def canonical(self) -> dict[str, str]:
        return {name: getattr(self, name) for name in ACCEPTANCE_FIELDS}

    @property
    def quotient_id(self) -> str:
        return "Q_EMV-" + sha256(self.canonical())[:16]


def project(raw: dict[str, Any]) -> AcceptanceVector:
    return AcceptanceVector(**{
        name: clean(raw.get(name, "")) for name in ACCEPTANCE_FIELDS
    })


def outcome(raw: dict[str, Any]) -> str:
    return clean(raw.get("sw1")) + clean(raw.get("sw2"))


def acceptance_observation(raw: dict[str, Any]) -> dict[str, Any]:
    sw = outcome(raw)
    return {
        "status_word": sw,
        "accepted": sw in SUCCESS,
        "known_failure": sw in FAILURE,
    }


def idempotent(raw: dict[str, Any]) -> bool:
    first = project(raw)
    second = project(first.canonical())
    return first == second


def analyze(records: list[dict[str, Any]]) -> dict[str, Any]:
    rows = []
    classes: dict[str, list[int]] = {}
    for index, raw in enumerate(records):
        vector = project(raw)
        qid = vector.quotient_id
        row = {
            "index": index,
            "canonical": vector.canonical(),
            "quotient_class": qid,
            "outcome": outcome(raw),
            "acceptance_observation": acceptance_observation(raw),
            "projection_idempotent": idempotent(raw),
            "timing": clean(raw.get("timing")),
        }
        rows.append(row)
        classes.setdefault(qid, []).append(index)

    counterexamples = []
    for qid, members in classes.items():
        outcomes = sorted({rows[i]["outcome"] for i in members})
        if len(outcomes) > 1:
            counterexamples.append({
                "quotient_class": qid,
                "members": members,
                "outcomes": outcomes,
            })

    return {
        "raw_scenarios": len(rows),
        "quotient_classes": len(classes),
        "compression_ratio": len(rows) / len(classes) if classes else None,
        "projection_idempotence": all(r["projection_idempotent"] for r in rows),
        "acceptance_congruence": not counterexamples,
        "counterexamples": counterexamples,
        "acceptance_fields": list(ACCEPTANCE_FIELDS),
        "noise_fields": list(NOISE_FIELDS),
        "records": rows,
        "classes": classes,
    }


def mutate(base: dict[str, Any], field: str, value: str) -> dict[str, Any]:
    result = dict(base)
    result[field] = value
    return result


def falsification_matrix(base: dict[str, Any]) -> list[dict[str, Any]]:
    variants = [dict(base)]
    for timing in ("0", "1", "10", "100", "1000", "10000", "100000"):
        variants.append(mutate(base, "timing", timing))
    for field, value in (
        ("ins", "B0"), ("tlv", "77"), ("aip", "0000"),
        ("afl", "10010100"), ("cvr", "FF000000"),
        ("cdol", "9F02069F0306"), ("cryptogram", "DEADBEEF"),
        ("terminal_context", "ATM"), ("sw2", "82"),
    ):
        variants.append(mutate(base, field, value))
    return variants


def perturbation_matrix(base: dict[str, Any]) -> list[dict[str, Any]]:
    variants = []
    definitions = (
        ("Timing", "timing", "10000"), ("APDU", "ins", "B0"),
        ("TLV", "tlv", "77"), ("AIP", "aip", "0000"),
        ("AFL", "afl", "10010100"), ("CVR", "cvr", "FF000000"),
        ("CDOL", "cdol", "9F02069F0306"),
        ("Cryptogram", "cryptogram", "DEADBEEF"),
        ("Terminal Context", "terminal_context", "ATM"),
    )
    for label, field, value in definitions:
        row = mutate(base, field, value)
        row["_mutation"] = label
        variants.append(row)
    return variants


def evidence(result: dict[str, Any]) -> dict[str, Any]:
    return {"evidence_level": "EXECUTABLY_VERIFIED", "result_hash": sha256(result)}


BASE_SCENARIO = {
    "card_id": "CARD-0001", "pan": "4111111111111111", "expiry": "1230",
    "aid": "A0000000031010", "profile": "CONTROL",
    "cla": "00", "ins": "A4", "p1": "04", "p2": "00",
    "data": "A0000000031010", "le": "00",
    "response_data": "6F0A8407A0000000031010", "sw1": "90", "sw2": "00",
    "tlv": "6F", "aip": "5800", "afl": "08010100", "cvr": "00000000",
    "cdol": "", "cryptogram": "A1B2C3D4E5F67890",
    "terminal_context": "TEST", "timing": "1000",
}
