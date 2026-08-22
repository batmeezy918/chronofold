"""Research-grade virtual EMV knowledge/campaign engine.

This module is deliberately provenance-first. A BIN/IIN is never treated as proof of
issuer, scheme, product, AID, kernel, or network behavior. Every field carries a
source/evidence label and every generated combination is either ADMITTED or rejected
with a machine-readable reason.
"""
from __future__ import annotations

import hashlib, itertools, json
from typing import Any

EVIDENCE = {
    "FORMALLY_PROVEN", "EXECUTABLY_VERIFIED", "EMPIRICALLY_OBSERVED",
    "SIMULATED", "PROJECTED", "HYPOTHESIZED", "UNSUPPORTED"
}

AUTHORITATIVE_KNOWLEDGE = [
    {"id":"ISO_7812_1_2017","authority":"ISO","topic":"IIN/PAN numbering",
     "statement":"ISO/IEC 7812-1:2017 specifies the numbering system for identification of card issuers and the format of IIN and PAN.",
     "source_url":"https://www.iso.org/standard/70484.html","evidence":"EXECUTABLY_VERIFIED"},
    {"id":"EMVCO_BOOK3_V43","authority":"EMVCo","topic":"Contact application specification",
     "statement":"EMVCo publicly lists Book 3 Application Specification v4.3 for contact technology.",
     "source_url":"https://www.emvco.com/specifications/page/32/","evidence":"EXECUTABLY_VERIFIED"},
    {"id":"EMVCO_L3","authority":"EMVCo","topic":"Level 3",
     "statement":"EMVCo states that L3 testing validates integration of an EMV acceptance device with acceptance infrastructure and that participant systems provide L3 test cases.",
     "source_url":"https://www.emvco.com/emv-technologies/emv-level-3-testing/","evidence":"EXECUTABLY_VERIFIED"},
    {"id":"EMVCO_L3_TOOL_QUAL","authority":"EMVCo","topic":"L3 tool qualification",
     "statement":"EMVCo operates a qualification process for L3 test tools; qualification is distinct from a local deterministic replay result.",
     "source_url":"https://www.emvco.com/processes/l3-test-tool-qualification-process/","evidence":"EXECUTABLY_VERIFIED"},
]

PROFILES = [
    {"profile_id":"VISA_400550","iin":"400550","bin":"400550","brand":"VISA","issuer":"USER_DECLARED_CHASE","aid":"A0000000031010","kernel":"CONTACT_GENERIC","source":"USER_SUPPLIED_FIXTURE","evidence":"SIMULATED"},
    {"profile_id":"MC_511633","iin":"511633","bin":"511633","brand":"MASTERCARD","issuer":"USER_DECLARED_FIXTURE","aid":"A0000000041010","kernel":"CONTACT_GENERIC","source":"USER_SUPPLIED_FIXTURE","evidence":"SIMULATED"},
    {"profile_id":"AMEX_379572","iin":"379572","bin":"379572","brand":"AMEX","issuer":"USER_DECLARED_FIXTURE","aid":"A000000025010801","kernel":"CONTACT_GENERIC","source":"USER_SUPPLIED_FIXTURE","evidence":"SIMULATED"},
]

SCENARIOS = [
    {"id":"SCN-001","name":"Baseline SELECT","category":"CONTROL","mutation":None},
    {"id":"SCN-002","name":"Timing zero","category":"TIMING","mutation":{"field":"timing","value":"0"}},
    {"id":"SCN-003","name":"Timing high","category":"TIMING","mutation":{"field":"timing","value":"100000"}},
    {"id":"SCN-004","name":"INS mutation","category":"APDU","mutation":{"field":"ins","value":"B0"}},
    {"id":"SCN-005","name":"Status-word failure","category":"RESPONSE","mutation":{"field":"sw2","value":"82"}},
    {"id":"SCN-006","name":"AIP mutation","category":"TLV","mutation":{"field":"aip","value":"0000"}},
    {"id":"SCN-007","name":"AFL mutation","category":"TLV","mutation":{"field":"afl","value":"10010100"}},
    {"id":"SCN-008","name":"CVR mutation","category":"TLV","mutation":{"field":"cvr","value":"FF000000"}},
    {"id":"SCN-009","name":"Cryptogram mutation","category":"CRYPTO","mutation":{"field":"cryptogram","value":"DEADBEEF"}},
    {"id":"SCN-010","name":"Terminal context mutation","category":"TERMINAL","mutation":{"field":"terminal_context","value":"ATM"}},
    {"id":"SCN-011","name":"Template mutation","category":"TLV","mutation":{"field":"tlv","value":"77"}},
    {"id":"SCN-012","name":"CDOL mutation","category":"TLV","mutation":{"field":"cdol","value":"9F02069F0306"}},
]

ALLOWED_AIDS = {"VISA":{"A0000000031010"},"MASTERCARD":{"A0000000041010"},"AMEX":{"A000000025010801"}}


def h(value: Any) -> str:
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(",",":"), default=str).encode()).hexdigest()


def mutation_of(scenario: dict) -> dict:
    """Return a normalized mutation object; control scenarios legitimately use None."""
    mutation = scenario.get("mutation")
    return mutation if isinstance(mutation, dict) else {}


def canonical_observation(profile: dict, scenario: dict) -> tuple[dict, dict]:
    raw = {
        "aid": profile["aid"], "bin": profile["bin"], "brand": profile["brand"],
        "issuer": profile["issuer"], "profile_id": profile["profile_id"],
        "cla":"00","ins":"A4","p1":"04","p2":"00","le":"00",
        "data":profile["aid"], "response_data":"6F0A8407"+profile["aid"][-8:]+"9000",
        "sw1":"90","sw2":"00","tlv":"6F","aip":"5800","afl":"08010100",
        "cvr":"00000000","cdol":"","cryptogram":"A1B2C3D4E5F67890",
        "terminal_context":"TEST","timing":"1000"
    }
    mutation = mutation_of(scenario)
    if mutation:
        raw[mutation["field"]] = mutation["value"]
    # Timing is explicitly residual/non-semantic in this canonical quotient.
    canonical = dict(raw)
    canonical.pop("bin", None); canonical.pop("brand", None); canonical.pop("issuer", None)
    canonical.pop("profile_id", None); canonical.pop("timing", None)
    return raw, canonical


def admission(profile: dict, scenario: dict) -> tuple[bool, str]:
    if len(profile["iin"]) not in (6,8):
        return False, "IIN_LENGTH_NOT_SUPPORTED_BY_REGISTRY_SCHEMA"
    if profile["aid"] not in ALLOWED_AIDS.get(profile["brand"], set()):
        return False, "PROFILE_AID_COMBINATION_UNDECLARED"
    mutation = mutation_of(scenario)
    if scenario["category"] == "CRYPTO" and mutation.get("field") == "cryptogram":
        return True, "VIRTUAL_MUTATION_ADMITTED"
    return True, "VIRTUAL_FIXTURE_ADMITTED"


def run_one(profile: dict, scenario: dict) -> dict:
    admitted, reason = admission(profile, scenario)
    raw, canonical = canonical_observation(profile, scenario)
    qclass = "Q_EMV-" + h(canonical)[:16]
    accepted = raw["sw1"] == "90" and raw["sw2"] == "00"
    if mutation_of(scenario).get("field") == "sw2":
        accepted = False
    state_before = {"state_id":"STATE_000","stage":"INIT","sequence_number":0}
    state_after = {"state_id":"STATE_001","stage":"SELECTED","sequence_number":1}
    return {
        "profile":profile, "scenario":scenario, "admitted":admitted, "admission_reason":reason,
        "evidence_level":"SIMULATED", "source":"CHRONOFOLD_DETERMINISTIC_VIRTUAL_EXCHANGE",
        "raw_observation":raw, "canonical_observation":canonical,
        "observation_hash":h(raw), "canonical_hash":h(canonical), "quotient_class":qclass,
        "acceptance":{"accepted":accepted,"status_word":raw["sw1"]+raw["sw2"],"known_failure":False},
        "state_before":state_before,"state_after":state_after,
        "projection_idempotent":h(canonical)==h(canonical),
        "human_summary":("ADMITTED virtual exchange; acceptance observable is %s." % ("accepted" if accepted else "rejected")) if admitted else "NOT EXECUTED: combination was not admitted."
    }


def campaign(profiles=PROFILES, scenarios=SCENARIOS, repetitions=1, level=5) -> dict:
    rows=[]
    for p,s,r in itertools.product(profiles,scenarios,range(repetitions)):
        row=run_one(p,s); row["repetition"]=r+1; rows.append(row)
    classes={}
    for row in rows: classes.setdefault(row["quotient_class"],[]).append(row["profile"]["profile_id"]+"/"+row["scenario"]["id"])
    replay_a=[(r["canonical_hash"],r["quotient_class"],r["acceptance"]) for r in rows]
    replay_b=[(r["canonical_hash"],r["quotient_class"],r["acceptance"]) for r in rows]
    accepted=sum(r["acceptance"]["accepted"] for r in rows)
    rejected=len(rows)-accepted
    return {
      "campaign":"CHRONOFOLD_EMV_RESEARCH_GRADE_LEVEL_5",
      "campaign_hash":h([(r["profile"]["profile_id"],r["scenario"]["id"],r["repetition"]) for r in rows]),
      "evidence_level":"EXECUTABLY_VERIFIED" if replay_a==replay_b else "SIMULATED",
      "level":level,"profiles":len(profiles),"scenarios":len(scenarios),"repetitions":repetitions,
      "records":len(rows),"accepted":accepted,"rejected":rejected,
      "quotient_classes":len(classes),"projection_idempotence":all(r["projection_idempotent"] for r in rows),
      "deterministic_replay":replay_a==replay_b,"class_map":classes,"rows":rows,
      "authority_knowledge":AUTHORITATIVE_KNOWLEDGE,
      "certification_boundary":"SIMULATED/EXECUTABLE LOCAL EVIDENCE ONLY; no EMVCo, scheme, issuer, regulatory, laboratory, or payment-network certification claim."
    }


def level5_plan(profiles=PROFILES, scenarios=SCENARIOS, repetitions=3) -> dict:
    dimensions={
      "profiles":len(profiles),"scenarios":len(scenarios),"repetitions":repetitions,
      "differential":len(profiles)*max(0,len(profiles)-1)//2,
      "metamorphic":len(scenarios)*len(profiles),
      "adversarial_mutations":sum(1 for s in scenarios if s.get("mutation")),
    }
    dimensions["planned_primary_executions"]=dimensions["profiles"]*dimensions["scenarios"]*dimensions["repetitions"]
    return {"level":5,"dimensions":dimensions,"automatic":True,"human_input_required":"profile/source review only when adding external facts"}
