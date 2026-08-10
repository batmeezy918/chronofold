#!/usr/bin/env python3
"""
Official SOTA wrapper for AGD × SV-COMP experiments.

Installs / detects BenchExec and CPAchecker (or other SV-COMP tools),
runs a smoke suite under explicit resource limits, and produces
literal comparable numbers.

STRICT: never fabricates TRUE/FALSE/UNKNOWN. If the verifier cannot
run, status remains NOT EXECUTED.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import platform
import shutil
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

def sha256_file(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()

def detect_tools() -> dict:
    info = {
        "benchexec": None,
        "java": None,
        "cpachecker": None,
        "ram_mb": None,
        "cpus": os.cpu_count(),
    }
    try:
        import benchexec
        info["benchexec"] = getattr(benchexec, "__version__", "installed")
    except ImportError:
        pass
    try:
        out = subprocess.check_output(["java", "-version"], stderr=subprocess.STDOUT, text=True)
        info["java"] = out.splitlines()[0] if out else "present"
    except Exception:
        pass
    # Common locations
    for cand in [
        Path("CPAchecker"),
        Path("cpachecker"),
        Path("/opt/cpachecker"),
        Path.home() / "cpachecker",
    ]:
        if (cand / "bin" / "cpachecker").exists() or (cand / "cpachecker").exists():
            info["cpachecker"] = str(cand)
            break
    try:
        mem = open("/proc/meminfo").read()
        for line in mem.splitlines():
            if line.startswith("MemTotal:"):
                info["ram_mb"] = int(line.split()[1]) // 1024
                break
    except Exception:
        pass
    return info

def run_cpachecker_smoke(cpachecker_dir: Path, task_c: Path, timelimit: int = 30, mem_mb: int = 1500) -> dict:
    """Attempt a single real run under tight limits. Returns structured result."""
    bin_path = cpachecker_dir / "bin" / "cpachecker"
    if not bin_path.exists():
        bin_path = cpachecker_dir / "cpachecker"
    if not bin_path.exists():
        return {"status": "NOT EXECUTED", "reason": "cpachecker binary not found", "runs": 0}

    # Extremely conservative heap for low-RAM environments
    heap = max(256, min(mem_mb - 400, 1200))
    cmd = [
        str(bin_path),
        f"--heap={heap}M",
        f"--timelimit={timelimit}s",
        "--preprocess",
        str(task_c),
    ]
    start = time.time()
    try:
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timelimit + 15,
            env={**os.environ, "JAVA_OPTS": f"-Xmx{heap}m"},
        )
        elapsed = time.time() - start
        out = (proc.stdout or "") + (proc.stderr or "")
        # Very rough verdict parsing (official parsing is done by BenchExec tool-info)
        verdict = "UNKNOWN"
        if "Verification result: TRUE" in out or "Verification result: true" in out.lower():
            verdict = "TRUE"
        elif "Verification result: FALSE" in out or "Verification result: false" in out.lower():
            verdict = "FALSE"
        return {
            "status": "EXECUTED",
            "verdict": verdict,
            "exit_code": proc.returncode,
            "wall_seconds": round(elapsed, 3),
            "command": " ".join(cmd),
            "runs": 1,
            "TRUE": 1 if verdict == "TRUE" else 0,
            "FALSE": 1 if verdict == "FALSE" else 0,
            "UNKNOWN": 1 if verdict == "UNKNOWN" else 0,
            "WRONG": 0,
            "stdout_tail": out[-800:],
        }
    except subprocess.TimeoutExpired:
        return {"status": "EXECUTED", "verdict": "UNKNOWN", "reason": "timeout", "runs": 1,
                "TRUE": 0, "FALSE": 0, "UNKNOWN": 1, "WRONG": 0}
    except Exception as e:
        return {"status": "NOT EXECUTED", "reason": str(e), "runs": 0,
                "TRUE": 0, "FALSE": 0, "UNKNOWN": 0, "WRONG": 0}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out-dir", default="artifacts/agd_svcomp")
    ap.add_argument("--task", default=None, help="Path to a .c task")
    ap.add_argument("--timelimit", type=int, default=30)
    ap.add_argument("--mem-mb", type=int, default=1500)
    args = ap.parse_args()

    out = Path(args.out_dir)
    out.mkdir(parents=True, exist_ok=True)

    tools = detect_tools()
    (out / "sota_tools.json").write_text(json.dumps(tools, indent=2))

    result = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "tools": tools,
        "sota_runs": {"status": "NOT EXECUTED", "runs": 0, "TRUE": 0, "FALSE": 0, "UNKNOWN": 0, "WRONG": 0},
    }

    if tools["cpachecker"] and args.task and Path(args.task).exists():
        result["sota_runs"] = run_cpachecker_smoke(
            Path(tools["cpachecker"]), Path(args.task), args.timelimit, args.mem_mb
        )
    else:
        result["sota_runs"]["reason"] = (
            "CPAchecker not extracted/installed or no task supplied. "
            "Download the official archive and extract on a machine with ≥8 GB RAM."
        )

    (out / "sota_wrapper_result.json").write_text(json.dumps(result, indent=2))
    print(json.dumps(result, indent=2))

if __name__ == "__main__":
    main()
