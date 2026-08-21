"""Lightweight deterministic EMV/EMB protocol laboratory server."""

import json
import os
import sys
import http.server
import socketserver
from urllib.parse import urlparse

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from agd.canonical import sha256_hash
from authority.model import AuthorityGraph
from authority.emvco import register_emvco_rules
from networks.adapters import register_network_authorities
from constitution.canonical_constitution import build_canonical_constitution
from emb.state_machine import EMBStateMachine
from emb.replay_certificate import build_replay_certificate, verify_replay_certificate

PORT = 8080


def _json(handler, payload, status=200):
    body = json.dumps(payload, indent=2, sort_keys=True).encode("utf-8")
    handler.send_response(status)
    handler.send_header("Content-Type", "application/json; charset=utf-8")
    handler.send_header("Cache-Control", "no-store")
    handler.end_headers()
    handler.wfile.write(body)


def _run_demo():
    constitution = build_canonical_constitution()
    sm = EMBStateMachine(constitution)
    events = []
    for operator, data in [
        ("OP_SELECT_AID", {"aid": "A0000000031010"}),
        ("OP_GET_PROCESSING_OPTIONS", {"amount": "000000001000"}),
        ("OP_READ_RECORD", {"afl": "08010100"}),
        ("OP_GENERATE_AC", {"ac": "A1B2C3D4E5F67890", "cryptogram_type": "TC"}),
    ]:
        events.append(sm.execute_transition(operator, data))
    return constitution, events


class ProtocolLabHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        path = urlparse(self.path).path

        if path in ("/", "/index.html"):
            self._serve_file("ui/index.html", "text/html; charset=utf-8")
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
            _json(self, {
                "evidence_level": "SIMULATED",
                "constitution_hash": constitution.compute_hash(),
                "trace_hash": trace_hash,
                "certificate_valid": verify_replay_certificate(certificate),
                "events": events,
                "certificate": certificate,
            })
            return

        if path == "/api/authorities":
            g = AuthorityGraph()
            register_emvco_rules(g)
            register_network_authorities(g)
            _json(self, [a.to_dict() for a in g.nodes.values()])
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

        self.send_error(404, "File Not Found")

    def _serve_file(self, filename, content_type):
        with open(filename, "rb") as f:
            body = f.read()
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)


def start_server_background():
    os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    with socketserver.TCPServer(("", PORT), ProtocolLabHandler) as httpd:
        print(f"UI Server running on http://localhost:{PORT}")
        httpd.serve_forever()


if __name__ == "__main__":
    start_server_background()
