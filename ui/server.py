"""
Lightweight UI Web Server
==========================
Serves interactive audit dashboard and API endpoints for authority graph,
constitution rules, replay engine, and audit report.
"""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import http.server
import socketserver
import json
from authority.model import AuthorityGraph
from authority.emvco import register_emvco_rules
from networks.adapters import register_network_authorities
from constitution.canonical_constitution import build_canonical_constitution

PORT = 8080

class ProtocolLabHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/" or self.path == "/index.html":
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            with open("ui/index.html", "rb") as f:
                self.wfile.write(f.read())
            return

        elif self.path == "/api/audit_report":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            report_file = "reports/audit_report.json"
            if os.path.exists(report_file):
                with open(report_file, "rb") as f:
                    self.wfile.write(f.read())
            else:
                self.wfile.write(json.dumps({"status": "REPORT_PENDING"}).encode('utf-8'))
            return

        elif self.path == "/api/authorities":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            g = AuthorityGraph()
            register_emvco_rules(g)
            register_network_authorities(g)
            auth_data = [a.to_dict() for a in g.nodes.values()]
            self.wfile.write(json.dumps(auth_data, indent=2).encode('utf-8'))
            return

        elif self.path == "/api/constitution":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            const = build_canonical_constitution()
            self.wfile.write(json.dumps(const.to_dict(), indent=2).encode('utf-8'))
            return

        else:
            self.send_error(404, "File Not Found")

def start_server_background():
    """
    Starts UI server in background on port 8080 if invoked.
    """
    os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    handler = ProtocolLabHandler
    with socketserver.TCPServer(("", PORT), handler) as httpd:
        print(f"UI Server running on http://localhost:{PORT}")
        httpd.serve_forever()

if __name__ == "__main__":
    start_server_background()
