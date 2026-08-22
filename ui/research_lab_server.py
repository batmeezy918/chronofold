"""Standalone research-grade EMV Knowledge / Exchange Lab UI server.

Runs beside the existing verified UI and never modifies its canonical lock.
"""
import json, os, http.server, socketserver
from urllib.parse import urlparse
from ui.emv_research_lab import PROFILES, SCENARIOS, AUTHORITATIVE_KNOWLEDGE, campaign, level5_plan, run_one

ROOT=os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PORT=int(os.getenv("PORT","8766"))


def send(h,payload,status=200):
    b=json.dumps(payload,indent=2,sort_keys=True).encode()
    h.send_response(status); h.send_header("Content-Type","application/json; charset=utf-8"); h.send_header("Cache-Control","no-store"); h.end_headers(); h.wfile.write(b)


def body(h):
    n=int(h.headers.get("Content-Length","0")); return json.loads(h.rfile.read(n) or b"{}")

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        p=urlparse(self.path).path
        if p in ("/","/index.html"):
            with open(os.path.join(ROOT,"ui","emv_research_lab.html"),"rb") as f: b=f.read()
            self.send_response(200); self.send_header("Content-Type","text/html; charset=utf-8"); self.end_headers(); self.wfile.write(b); return
        if p=="/api/research/profiles": send(self,PROFILES); return
        if p=="/api/research/scenarios": send(self,SCENARIOS); return
        if p=="/api/research/knowledge": send(self,AUTHORITATIVE_KNOWLEDGE); return
        if p=="/api/research/level5": send(self,level5_plan()); return
        if p=="/api/health": send(self,{"status":"ok","service":"chronofold-emv-research-lab","evidence":"SIMULATED/EXECUTABLY_VERIFIED"}); return
        self.send_error(404)

    def do_POST(self):
        p=urlparse(self.path).path
        try: x=body(self)
        except Exception as e: send(self,{"error":repr(e)},400); return
        if p=="/api/research/run":
            pi=x.get("profile_id"); si=x.get("scenario_id")
            prof=next((z for z in PROFILES if z["profile_id"]==pi),None); sc=next((z for z in SCENARIOS if z["id"]==si),None)
            if not prof or not sc: send(self,{"error":"unknown profile/scenario"},400); return
            send(self,run_one(prof,sc)); return
        if p=="/api/research/campaign":
            profs=[z for z in PROFILES if z["profile_id"] in x.get("profile_ids",[p["profile_id"] for p in PROFILES])]
            scs=[z for z in SCENARIOS if z["id"] in x.get("scenario_ids",[s["id"] for s in SCENARIOS])]
            reps=max(1,min(int(x.get("repetitions",1)),100))
            send(self,campaign(profs,scs,reps,5)); return
        if p=="/api/research/level5/run":
            send(self,campaign(PROFILES,SCENARIOS,max(1,min(int(x.get("repetitions",3)),100)),5)); return
        self.send_error(404)

    def log_message(self,*args): pass

if __name__=="__main__":
    os.chdir(ROOT)
    class Reuse(socketserver.ThreadingTCPServer): allow_reuse_address=True
    with Reuse(("127.0.0.1",PORT),Handler) as s:
        print(f"ChronoFold Research Lab: http://127.0.0.1:{PORT}")
        s.serve_forever()
