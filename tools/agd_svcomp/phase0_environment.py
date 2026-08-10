#!/usr/bin/env python3
"""Phase 0 — Environment audit for AGD × SV-COMP compatible experiment."""
import json
import os
import platform
import subprocess
import sys
from datetime import datetime, timezone

def sh(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, text=True, stderr=subprocess.DEVNULL).strip()
    except Exception:
        return "UNKNOWN"

def main():
    env = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "runner": "github-actions" if os.environ.get("GITHUB_ACTIONS") else "local",
        "os": platform.platform(),
        "kernel": sh("uname -r"),
        "architecture": platform.machine(),
        "cpu_model": sh("lscpu | grep 'Model name' | cut -d: -f2 | xargs"),
        "cpu_count": os.cpu_count(),
        "ram_total_mb": int(sh("free -m | awk '/Mem:/{print $2}'") or 0),
        "python_version": platform.python_version(),
        "benchexec_version": "NOT_INSTALLED",
        "git_version": sh("git --version"),
        "note": (
            "GitHub Actions ubuntu-latest does NOT meet official SV-COMP resource "
            "requirements (15 GB RAM, 4 CPUs, 15 min CPU per task). "
            "This is a limited compatible reproduction environment only."
        ),
        "official_svcomp_requirements": {
            "ram_gb": 15,
            "cpus_per_run": 4,
            "cpu_time_limit_min": 15,
            "architecture": "x86_64 Linux"
        }
    }
    try:
        import benchexec
        env["benchexec_version"] = getattr(benchexec, "__version__", "installed")
    except ImportError:
        pass

    print(json.dumps(env, indent=2))

if __name__ == "__main__":
    main()
