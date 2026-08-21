"""ChronoFold deterministic EMV/EMB protocol laboratory server."""

import json
import os
import sys
import http.server
import socketserver
from urllib.parse import urlparse

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from agd.canonical import sha256_hash
from authority.model import AuthorityGraph
from authority.emvco import register_emvco_rules
from networks.adapters import register_network_authorities
from constitution.canonical_constitution import build_canonical_constitution
from emb.state_machine import EMBStateMachine
from emb.replay_certificate import build_replay_certificate, verify_replay_certificate
from ui.emv_quotient_engine import (
    BASE_SCENARIO,
    analyze as analyze_quotient,
    evidence as quotient_evidence,
    falsification_matrix,
    perturbation_matrix,
)

PORT = int(os.getenv("PORT", "8080"))
FIXTURE = [
    ("OP_SELECT_AID", {"aid": "A0000000031010"}),
    ("OP_GET_PROCESSING_OPTIONS", {"amount": "000000001000"}),
    ("OP_READ_RECORD", {"afl": "08010100"}),
    ("OP_GENERATE_AC", {"ac": "A1B2C3D4E5F67890", "cryptogram_type": "TC"}),
]


def _json(handler, payload, status=200):
    body = json.dumps(payload, indent=2, sort_keys=True).encode("utf-8")
    handler.send_response(status)
    handler.send_header("Content-Type", "application/json; charset=utf-8")
    handler.send_header("Cache-Control", "no-store")
    handler.end_headers()
    handler.wfile.write(body)


def _body(handler):
    length = int(handler.headers.get("Content-Length", "0"))
    return json.loads(handler.rfile.read(length) or b"{}")


def _run_demo():
    constitution = build_canonical_constitution()
    sm = EMBStateMachine(constitution)
    events = [sm.execute_transition(operator, data) for operator, data in FIXTURE]
    return constitution, events


def _run_deterministic_self_check():
    constitution_a, events_a = _run_demo()
    constitution_b, events_b = _run_demo()
    trace_a = sha256_hash(events_a)
    trace_b = sha256_hash(events_b)
    rejection_machine = EMBStateMachine(build_canonical_constitution())
    state_before = json.loads(json.dumps(rejection_machine.current_state, sort_keys=True))
    rejection = rejection_machine.execute_transition("OP_UNKNOWN", {})
    state_after = json.loads(json.dumps(rejection_machine.current_state, sort_keys=True))
    deterministic = (
        constitution_a.compute_hash() == constitution_b.compute_hash()
        and events_a == events_b
        and trace_a == trace_b
    )
    non_mutating = rejection.get("status") == "STRUCTURED_REJECTION" and state_before == state_after
    return {
        "status": "PASS" if deterministic and non_mutating else "FAIL",
        "evidence_level": "EXECUTABLY_VERIFIED",
        "deterministic_replay": deterministic,
        "illegal_transition_non_mutating": non_mutating,
        "constitution_hash": constitution_a.compute_hash(),
        "trace_hash": trace_a,
        "final_stage": events_a[-1]["state_after"]["stage"],
        "final_sequence": events_a[-1]["state_after"]["sequence_number"],
    }


def _quotient_payload(body):
    scenario = dict(BASE_SCENARIO)
    scenario.update(body.get("scenario") or {})
    result = analyze_quotient([scenario])
    result["scenario"] = scenario
    result["evidence"] = quotient_evidence(result)
    return result


class ProtocolLabHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        path = urlparse(self.path).path
        if path in ("/", "/index.html"):
            self._serve_file("ui/index.html", "text/html; charset=utf-8")
            return
        if path in ("/emv", "/emv-quotient", "/emv_quotient.html"):
            self._serve_file("ui/emv_quotient.html", "text/html; charset=utf-8")
            return
        if path == "/api/health":
            _json(self, {"status": "ok", "service": "chronofold-emv-ui", "mode": "deterministic-local-core"})
            return
        if path == "/api/audit_report":
            report_file = "reports/audit_report.json"
            if os.path.exists(report_file):
                with open(report_file, "r", encoding="utf-8") as f:
                    _json(self, json.load(f))
            else:
                _json(self, {"status": "REPORT_PENDING"})
            return
        if path == "/api/canonical_emv":
            constitution, events = _run_demo()
            trace_hash = sha256_hash(events)
            certificate = build_replay_certificate(
                constitution_hash=constitution.compute_hash(),
                authority_hash=sha256_hash(constitution.authority_set),
                environment_hash=sha256_hash({"runtime": "python", "schema": "canonical-emv-v1"}),
                events=events,
                evidence_level="SIMULATED",
            )
            _json(self, {"evidence_level": "SIMULATED", "constitution_hash": constitution.compute_hash(), "trace_hash": trace_hash, "certificate_valid": verify_replay_certificate(certificate), "events": events, "certificate": certificate})
            return
        if path == "/api/deterministic-self-check":
            _json(self, _run_deterministic_self_check())
            return
        if path == "/api/authorities":
            graph = AuthorityGraph(); register_emvco_rules(graph); register_network_authorities(graph)
            _json(self, [a.to_dict() for a in graph.nodes.values()])
            return
        if path == "/api/constitution":
            _json(self, build_canonical_constitution().to_dict())
            return
        if path == "/api/verification-map":
            filename = "docs/EMV_LEAN_PROOF_MAP.md"
            if os.path.exists(filename):
                with open(filename, "r", encoding="utf-8") as f:
                    _json(self, {"status": "AVAILABLE", "path": filename, "content": f.read()})
            else:
                _json(self, {"status": "MISSING"}, 404)
            return
        if path == "/api/emv-quotient/base":
            _json(self, {"scenario": BASE_SCENARIO, "acceptance_fields": list(analyze_quotient([BASE_SCENARIO])["acceptance_fields"]), "noise_fields": ["timing"]})
            return
        if path == "/api/emv-quotient/verified-core":
            self._verified_core()
            return
        self.send_error(404, "File Not Found")

    def do_POST(self):
        path = urlparse(self.path).path
        try:
            body = _body(self)
        except (ValueError, TypeError, json.JSONDecodeError):
            _json(self, {"error": "invalid JSON"}, 400)
            return
        if path == "/api/emv-quotient/analyze":
            _json(self, _quotient_payload(body)); return
        if path == "/api/emv-quotient/replay":
            scenario = dict(BASE_SCENARIO); scenario.update(body.get("scenario") or {})
            first = analyze_quotient([scenario]); second = analyze_quotient([scenario])
            first_hash = quotient_evidence(first)["result_hash"]; second_hash = quotient_evidence(second)["result_hash"]
            _json(self, {"status": "PASS" if first == second else "FAIL", "replay_equal": first == second, "first_hash": first_hash, "second_hash": second_hash, "evidence_level": "EXECUTABLY_VERIFIED"}); return
        if path == "/api/emv-quotient/falsify":
            scenario = dict(BASE_SCENARIO); scenario.update(body.get("scenario") or {})
            result = analyze_quotient(falsification_matrix(scenario)); result["evidence"] = quotient_evidence(result)
            _json(self, result); return
        if path == "/api/emv-quotient/perturbations":
            scenario = dict(BASE_SCENARIO); scenario.update(body.get("scenario") or {})
            rows = perturbation_matrix(scenario); result = analyze_quotient(rows)
            result["perturbations"] = [{"mutation": row["_mutation"], "quotient_class": result["records"][i]["quotient_class"], "outcome": result["records"][i]["outcome"], "changed": result["records"][i]["quotient_class"] != result["records"][0]["quotient_class"]} for i, row in enumerate(rows)]
            result["evidence"] = quotient_evidence(result)
            _json(self, result); return
        self.send_error(404, "File Not Found")

    def _verified_core(self):
        deterministic = _run_deterministic_self_check()
        constitution, events = _run_demo()
        trace_hash = sha256_hash(events)
        certificate = build_replay_certificate(
            constitution_hash=constitution.compute_hash(),
            authority_hash=sha256_hash(constitution.authority_set),
            environment_hash=sha256_hash({"runtime": "python", "schema": "canonical-emv-v1"}),
            events=events,
            evidence_level="SIMULATED",
        )
        _json(self, {"deterministic_self_check": deterministic, "canonical_replay": {"constitution_hash": constitution.compute_hash(), "trace_hash": trace_hash, "certificate_valid": verify_replay_certificate(certificate), "events": events}})

    def _serve_file(self, filename, content_type):
        with open(filename, "rb") as f:
            body = f.read()
        self.send_response(200); self.send_header("Content-Type", content_type); self.send_header("Cache-Control", "no-store"); self.end_headers(); self.wfile.write(body)


def start_server_background():
    os.chdir(ROOT)
    with socketserver.ThreadingTCPServer(("127.0.0.1", PORT), ProtocolLabHandler) as httpd:
        print(f"UI Server running on http://127.0.0.1:{PORT}")
        httpd.serve_forever()


if __name__ == "__main__":
    start_server_background()
